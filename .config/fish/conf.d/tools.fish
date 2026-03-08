# Dotfiles management helpers for syntharch-dotfiles

set -g DOTFILES_REPO "$HOME/syntharch-dotfiles"
set -g DOTFILES_BRANCH "ubuntu"

# Internal helper to locate dotfiles repo
function __dotfiles_repo
    test -d $DOTFILES_REPO; or begin
        echo "Dotfiles repo not found at $DOTFILES_REPO"
        return 1
    end
    echo $DOTFILES_REPO
end

# Internal helper to ensure git repo
function __dotfiles_require_git
    git rev-parse --is-inside-work-tree >/dev/null 2>&1; or begin
        echo "Not a git repository."
        return 1
    end
end


# Update dotfiles from remote
function update_dotfiles --description "Update local dotfiles"
    set -l repo (__dotfiles_repo); or return 1
    set -l cwd (pwd)

    cd $repo; or return 1
    __dotfiles_require_git; or begin
        cd $cwd
        return 1
    end

    set -l remote (git remote get-url origin 2>/dev/null)
    if not string match -q "*SYN606/syntharch-dotfiles*" $remote
        read -l -P "Remote does not match expected repo. Continue? (y/N): " confirm
        test (string lower $confirm) = y; or begin
            cd $cwd
            return 1
        end
    end

    # Handle local changes
    if not git diff --quiet; or not git diff --cached --quiet
        read -l -P "Uncommitted changes found. Stash them? (Y/n): " stash
        if not test (string lower $stash) = n
            git stash push -m "Auto-stash before dotfiles update"
        end
    end

    git fetch origin; or begin
        cd $cwd
        return 1
    end

    git switch $DOTFILES_BRANCH >/dev/null 2>&1; or begin
        echo "Failed to switch to branch '$DOTFILES_BRANCH'"
        cd $cwd
        return 1
    end

    git pull origin $DOTFILES_BRANCH; or begin
        cd $cwd
        return 1
    end

    # Run setup script if available
    if test -x setup.sh
        read -l -P "Run setup.sh now? (Y/n): " run
        test (string lower $run) = n; or ./setup.sh
    end

    cd $cwd
end


# Show dotfiles repository status
function dotfiles_status --description "Show dotfiles repo status"
    set -l repo (__dotfiles_repo); or return 1
    set -l cwd (pwd)

    cd $repo; or return 1
    __dotfiles_require_git; or begin
        cd $cwd
        return 1
    end

    echo "Repo: $repo"
    echo "Branch: "(git branch --show-current)
    echo "Remote: "(git remote get-url origin)

    git fetch --quiet

    set -l local (git rev-parse HEAD)
    set -l remote (git rev-parse origin/$DOTFILES_BRANCH 2>/dev/null)

    if test "$local" = "$remote"
        echo "Status: up to date"
    else
        echo "Status: updates available"
    end

    if git diff --quiet; and git diff --cached --quiet
        echo "Working tree: clean"
    else
        echo "Working tree: dirty"
        git status --porcelain
    end

    set -l stash_count (git stash list | wc -l)
    echo "Stashes: $stash_count"

    cd $cwd
end


# Reset dotfiles repository to clean state
function dotfiles_reset --description "Reset dotfiles repository"
    set -l repo (__dotfiles_repo); or return 1
    set -l cwd (pwd)

    read -l -P "This will discard ALL local changes. Continue? (yes/no): " confirm
    test $confirm = yes; or return 1

    cd $repo; or return 1
    __dotfiles_require_git; or begin
        cd $cwd
        return 1
    end

    git reset --hard HEAD
    git clean -fd

    read -l -P "Pull latest changes? (Y/n): " pull
    test (string lower $pull) = n; or git pull origin $DOTFILES_BRANCH

    cd $cwd
end