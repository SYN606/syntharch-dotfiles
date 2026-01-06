# Git helper functions for Fish shell

# Internal helper to ensure we are inside a git repository
function __git_require_repo
    git rev-parse --git-dir >/dev/null 2>&1; or begin
        echo "Not inside a git repository."
        return 1
    end
end

# Add all changes and commit with message
function gcommit --description "Commit all changes with a message"
    test (count $argv) -gt 0; or begin
        echo "Usage: gcommit <message>"
        return 1
    end

    git add .; or return 1
    git commit -m (string join " " $argv)
end

# Show short git status
function gst --description "Show git status (short)"
    __git_require_repo; or return 1
    git status -sb
end

# Show git log graph
function glg --description "Show git log graph"
    __git_require_repo; or return 1
    git log --oneline --graph --all --decorate --color=always
end

# Undo last commit but keep changes staged
function guncommit --description "Undo last commit (soft reset)"
    __git_require_repo; or return 1
    git reset --soft HEAD~1
end

# Clean up local branches gone from remote
function gcleanup --description "Delete local branches removed from remote"
    __git_require_repo; or return 1
    git fetch --all --prune; or return 1

    set -l gone (git branch -vv | grep ': gone]' | awk '{print $1}')
    test (count $gone) -gt 0; or begin
        echo "No branches to clean."
        return 0
    end

    for branch in $gone
        git branch -d $branch
    end
end

# Switch to previous branch
function gprev --description "Switch to previous branch"
    __git_require_repo; or return 1
    git switch -
end

# Show commit history for a file
function gfilelog --description "Show commit history for a file"
    test (count $argv) -eq 1; or begin
        echo "Usage: gfilelog <file>"
        return 1
    end

    test -f $argv[1]; or begin
        echo "File not found: $argv[1]"
        return 1
    end

    git log --follow --date=short \
        --pretty=format:'%h %ad | %s%d [%an]' -- $argv[1]
end

# Show changed files in a commit
function gshowdiff --description "Show files changed in a commit"
    test (count $argv) -eq 1; or begin
        echo "Usage: gshowdiff <commit>"
        return 1
    end

    git diff-tree --no-commit-id --name-status -r $argv[1]
end

# Push current branch
function gpush --description "Push current branch"
    __git_require_repo; or return 1
    set -l branch (git branch --show-current)
    git push origin $branch
end

# Force push current branch
function gpushf --description "Force push current branch"
    __git_require_repo; or return 1
    set -l branch (git branch --show-current)

    read -l -P "Force push '$branch'? (yes/no): " confirm
    test "$confirm" = yes; or return 1

    git push --force origin $branch
end

# Pull with rebase
function gpull --description "Pull with rebase"
    __git_require_repo; or return 1
    set -l branch (git branch --show-current)
    git pull --rebase origin $branch
end

# Merge a branch
function gmerge --description "Merge a branch"
    test (count $argv) -eq 1; or begin
        echo "Usage: gmerge <branch>"
        return 1
    end

    git merge $argv[1]
end

# Abort merge
function gmerge_abort --description "Abort merge"
    git merge --abort
end

# Show unresolved merge conflicts
function gconflicts --description "List merge conflicts"
    set -l conflicts (git diff --name-only --diff-filter=U)
    test (count $conflicts) -gt 0; and printf "%s\n" $conflicts
end

# Add and commit resolved conflicts
function gresolve --description "Commit resolved merge conflicts"
    set -l conflicts (git diff --name-only --diff-filter=U)
    test (count $conflicts) -eq 0; or begin
        echo "Unresolved conflicts remain."
        return 1
    end

    set -l msg (string join " " $argv)
    test -n "$msg"; or set msg "Resolve merge conflicts"

    git add -A
    git commit -m "$msg"
end

# Fetch all remotes
function gfetch --description "Fetch all remotes"
    git fetch --all --prune
end

# Show current branch
function gbranch --description "Show current branch"
    git branch --show-current
end

# List branches sorted by last commit
function gbranches --description "List branches by recent activity"
    git branch --sort=-committerdate
end

# Stash changes with message
function gstash --description "Create a stash with message"
    test (count $argv) -gt 0; or begin
        echo "Usage: gstash <message>"
        return 1
    end

    git stash push -m (string join " " $argv)
end

# Apply latest stash
function gstash_pop --description "Apply latest stash"
    git stash pop
end

# List stashes
function gstash_list --description "List stashes"
    git stash list
end

# Clone repository
function gclone --description "Clone a repository"
    test (count $argv) -ge 1; or begin
        echo "Usage: gclone <url> [dir]"
        return 1
    end

    git clone $argv
end

# Generate .gitignore
function gignore --description "Generate .gitignore"
    test (count $argv) -gt 0; or begin
        echo "Usage: gignore <langs>"
        return 1
    end

    curl -s "https://www.toptal.com/developers/gitignore/api/"(string join ',' $argv) >.gitignore
end

# Interactive branch checkout using fzf
function gcheckout --description "Checkout branch with fzf"
    command -v fzf >/dev/null; or begin
        echo "fzf not installed."
        return 1
    end

    git fetch --all --prune
    set -l branch (git branch -a | sed 's/^[* ] //' | fzf)
    test -n "$branch"; or return 1
    git checkout (string replace -r '^remotes/origin/' '' $branch)
end

# Initialize new repository
function ginit --description "Initialize git repository"
    git init
end

# Show remotes
function gremote --description "Show git remotes"
    git remote -v
end

# Create a tag
function gtag --description "Create git tag"
    test (count $argv) -ge 1; or begin
        echo "Usage: gtag <name> [message]"
        return 1
    end

    test (count $argv) -eq 2; and git tag -a $argv[1] -m $argv[2]; or git tag $argv[1]
end

# Undo last N commits
function gundo --description "Undo last N commits"
    set -l n 1
    test (count $argv) -eq 1; and set n $argv[1]
    git reset --soft HEAD~$n
end

# Remove untracked files
function gclean --description "Remove untracked files"
    git clean -fd
end

# Show help for git helpers
function ghelp --description "Show git helper commands"
    for fn in (functions | grep '^g')
        printf "%-18s %s\n" $fn (functions --details $fn | head -1)
    end
end
