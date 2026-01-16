# Dotfiles management helpers for syntharch-dotfiles

# Internal helper to locate dotfiles repo
function __dotfiles_repo
    set -l repo "$HOME/syntharch-dotfiles"
    test -d $repo; or begin
        echo "Dotfiles repo not found at $repo"
        return 1
    end
    echo $repo
end

# Internal helper to ensure git repo
function __dotfiles_require_git
    test -d .git; or begin
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

    set -l branch main
    git show-ref --verify --quiet refs/remotes/origin/main; or set branch master

    git switch $branch >/dev/null 2>&1; or begin
        cd $cwd
        return 1
    end
    git pull origin $branch; or begin
        cd $cwd
        return 1
    end

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

    git fetch --dry-run >/dev/null 2>&1

    set -l local (git rev-parse HEAD)
    set -l remote (git rev-parse '@{u}' 2>/dev/null)

    test "$local" = "$remote"; and echo "Status: up to date"; or echo "Status: updates available"

    if git diff --quiet; and git diff --cached --quiet
        echo "Working tree: clean"
    else
        echo "Working tree: dirty"
        git status --porcelain
    end

    echo "Stashes: "(git stash list | wc -l)

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

    git reset --hard HEAD; and git clean -fd

    read -l -P "Pull latest changes? (Y/n): " pull
    test (string lower $pull) = n; or git pull

    cd $cwd
end
