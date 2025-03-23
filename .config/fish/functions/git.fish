# Add all changes and commit with a message
function gcommit --description "Add all changes and commit with a message"
    if test (count $argv) -eq 0
        echo "❌ Error: Commit message required!"
        echo "Usage: gcommit 'Your commit message'"
        return 1
    end
    git add .
    git commit -m "$argv"
end

# Short Git status
function gst --description "Show short Git status (staged, unstaged, and untracked files)"
    git status -sb
end

# Pretty Git log graph
function glg --description "Display a compact Git log with graph and decorations"
    git log --oneline --graph --all --decorate
end

# Undo last commit but keep changes staged
function guncommit --description "Undo the last commit but keep changes in staging"
    git reset --soft HEAD~1
end

# Remove local branches that no longer exist on remote
function gcleanup --description "Remove merged local branches that no longer exist on remote"
    git fetch --all --prune
    git branch -vv | grep ': gone' | awk '{print $1}' | xargs git branch -d
end

# Switch to the last used branch
function gprev --description "Switch to the previous branch"
    git switch -
end

# Show commit history for a specific file
function gfilelog --description "Show commit history for a specific file"
    if test (count $argv) -eq 0
        echo "❌ Error: File path required!"
        echo "Usage: gfilelog <file-path>"
        return 1
    end
    git log --follow --pretty=format:'%h %ad | %s%d [%an]' --date=short -- $argv
end

# View file changes in a specific commit
function gshowdiff --description "Show file changes in a specific commit"
    if test (count $argv) -eq 0
        echo "❌ Error: Commit hash required!"
        echo "Usage: gshowdiff <commit-hash>"
        return 1
    end
    git diff-tree --no-commit-id --name-status -r $argv
end

# 🚀 Additional Git Shortcuts

# Push current branch to origin
function gpush --description "Push the current branch to origin"
    git push origin (git branch --show-current)
end

# Force push (use with caution)
function gpushf --description "Force push the current branch (DANGEROUS: Overwrites remote history)"
    git push --force origin (git branch --show-current)
end

# Pull latest changes with rebase
function gpull --description "Pull the latest changes with rebase"
    git pull --rebase origin (git branch --show-current)
end

# Merge another branch into the current branch
function gmerge --description "Merge another branch into the current branch"
    if test (count $argv) -eq 0
        echo "❌ Error: Branch name required!"
        echo "Usage: gmerge <branch-name>"
        return 1
    end
    git merge $argv
end

# Abort a merge if conflicts arise
function gmerge-abort --description "Abort an ongoing merge process"
    git merge --abort
end

# List unresolved merge conflicts
function gconflicts --description "List files with unresolved merge conflicts"
    git diff --name-only --diff-filter=U
end

# Add & resolve all conflicted files
function gresolve --description "Automatically stage and commit all resolved conflicts"
    git diff --name-only --diff-filter=U | xargs git add
    git commit -m "Resolved merge conflicts"
end

# Fetch all branches & remove deleted ones
function gfetch --description "Fetch all remote branches and prune deleted ones"
    git fetch --all --prune
end

# Check the current branch name
function gbranch --description "Display the current Git branch name"
    git branch --show-current
end

# List all branches sorted by latest commit
function gbranches --description "List all Git branches sorted by latest commit"
    git branch --sort=-committerdate
end

# Stash changes with a message
function gstash --description "Stash current changes with a message"
    if test (count $argv) -eq 0
        echo "❌ Error: Stash message required!"
        echo "Usage: gstash 'Your stash message'"
        return 1
    end
    git stash push -m "$argv"
end

# Apply the latest stash
function gstash-pop --description "Apply the most recent stash"
    if test -z (git stash list)
        echo "❌ No stashes found!"
        return 1
    end
    git stash pop
end

# Show all stash entries
function gstash-list --description "List all stash entries"
    git stash list
end

function gclone --description "Clone a Git repository with optional directory name"
    if test (count $argv) -lt 1
        echo "❌ Error: Repository URL required!"
        echo "Usage: gclone <repo-url> [directory-name]"
        return 1
    end

    set repo_url $argv[1]
    set dir_name (count $argv) -gt 1; and echo $argv[2] || echo ""

    echo "📥 Cloning repository: $repo_url"

    if test -n "$dir_name"
        git clone "$repo_url" "$dir_name"
    else
        git clone "$repo_url"
    end

    if test $status -eq 0
        echo "✅ Clone successful!"
    else
        echo "❌ Clone failed!"
    end
end


# Show all available Git functions and their descriptions
function ghelp --description "List all Git shortcut commands and their descriptions"
    echo "🚀 Available Git Commands:"
    functions --all | grep '^g' | while read -l cmd
        echo "- $cmd: "(functions --description $cmd)
    end
end
