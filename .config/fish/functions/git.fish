function gcommit --description "Add all changes and commit with a message"
    if test (count $argv) -eq 0
        echo "Error: Commit message required!"
        echo "Usage: gcommit <your message>"
        return 1
    end
    
    if not git add .
        echo "Error: Failed to add files"
        return 1
    end
    
    git commit -m "$argv"
end

function gst --description "Show short Git status"
    git status -sb
end

function glg --description "Display Git log with graph"
    git log --oneline --graph --all --decorate --color=always
end

function guncommit --description "Undo last commit (keep staged)"
    git reset --soft HEAD~1
end

function gcleanup --description "Remove local branches gone from remote"
    if not git fetch --all --prune
        echo "Error: Failed to fetch and prune remotes"
        return 1
    end
    
    set -l gone_branches (git branch -vv | grep ': gone]' | awk '{print $1}')
    if test (count $gone_branches) -eq 0
        echo "No gone branches to clean up"
        return 0
    end
    
    for branch in $gone_branches
        git branch -d $branch
        and echo "Deleted branch: $branch"
        or echo "Failed to delete branch: $branch"
    end
end

function gprev --description "Switch to previous branch"
    git switch -
end

function gfilelog --description "Show commit history for a file"
    if test (count $argv) -eq 0
        echo "Error: File path required!"
        echo "Usage: gfilelog <file-path>"
        return 1
    end
    
    if not test -f "$argv[1]"
        echo "Error: File '$argv[1]' does not exist"
        return 1
    end
    
    git log --follow --pretty=format:'%h %ad | %s%d [%an]' --date=short -- "$argv[1]"
end

function gshowdiff --description "Show changed files in a commit"
    if test (count $argv) -eq 0
        echo "Error: Commit hash required!"
        echo "Usage: gshowdiff <commit-hash>"
        return 1
    end
    
    git diff-tree --no-commit-id --name-status -r "$argv[1]" 2>/dev/null
    or begin
        echo "Error: Invalid commit hash '$argv[1]'"
        return 1
    end
end

# Push/Pull Operations
function gpush --description "Push current branch"
    set -l current_branch (git branch --show-current 2>/dev/null)
    
    if test -z "$current_branch"
        echo "Error: Not in a git repository or no current branch"
        return 1
    end
    
    git push origin "$current_branch"
end

function gpushf --description "Force push current branch (DANGEROUS)"
    set -l current_branch (git branch --show-current 2>/dev/null)
    
    if test -z "$current_branch"
        echo "Error: Not in a git repository or no current branch"
        return 1
    end
    
    echo "WARNING: Force pushing to branch '$current_branch'"
    read -l -P "Are you sure you want to force push? (yes/no): " confirm
    
    if test "$confirm" = "yes"
        git push --force origin "$current_branch"
    else
        echo "Force push aborted."
        return 1
    end
end

function gpull --description "Pull latest changes with rebase"
    set -l current_branch (git branch --show-current 2>/dev/null)
    
    if test -z "$current_branch"
        echo "Error: Not in a git repository or no current branch"
        return 1
    end
    
    git pull --rebase origin "$current_branch"
end

# Branch Operations
function gmerge --description "Merge specified branch"
    if test (count $argv) -eq 0
        echo "Error: Branch name required!"
        echo "Usage: gmerge <branch-name>"
        return 1
    end
    
    # Check if branch exists
    if not git show-ref --verify --quiet "refs/heads/$argv[1]"
        if not git show-ref --verify --quiet "refs/remotes/origin/$argv[1]"
            echo "Error: Branch '$argv[1]' does not exist locally or on remote"
            return 1
        end
    end
    
    git merge "$argv[1]"
end

function gmerge-abort --description "Abort ongoing merge"
    if not git merge --abort 2>/dev/null
        echo "Error: No merge in progress to abort"
        return 1
    end
    echo "Merge aborted successfully"
end

function gconflicts --description "List unresolved merge conflicts"
    set -l conflicts (git diff --name-only --diff-filter=U 2>/dev/null)
    
    if test (count $conflicts) -eq 0
        echo "No unresolved conflicts"
        return 0
    end
    
    echo "Unresolved conflicts:"
    for file in $conflicts
        echo "  $file"
    end
end

function gresolve --description "Add and commit resolved conflicts"
    set -l conflicts (git diff --name-only --diff-filter=U 2>/dev/null)
    
    if test (count $conflicts) -gt 0
        echo "Error: Unresolved conflicts still exist:"
        for file in $conflicts
            echo "  $file"
        end
        return 1
    end
    
    set -l msg (string join " " $argv)
    if test -z "$msg"
        set msg "Resolved merge conflicts"
    end
    
    git add -A
    git commit -m "$msg"
end

function gfetch --description "Fetch all remote branches"
    git fetch --all --prune
end

function gbranch --description "Show current Git branch"
    set -l current_branch (git branch --show-current 2>/dev/null)
    
    if test -z "$current_branch"
        echo "Error: Not in a git repository"
        return 1
    end
    
    echo "$current_branch"
end

function gbranches --description "List all branches sorted by latest commit"
    git branch --sort=-committerdate
end

# Stash Operations
function gstash --description "Stash changes with a message"
    if test (count $argv) -eq 0
        echo "Error: Stash message required!"
        echo "Usage: gstash <your message>"
        return 1
    end
    
    git stash push -m "$argv"
end

function gstash-pop --description "Apply latest stash"
    set -l stash_count (git stash list 2>/dev/null | wc -l)
    
    if test $stash_count -eq 0
        echo "Error: No stashes found!"
        return 1
    end
    
    git stash pop
end

function gstash-list --description "List all stash entries"
    git stash list
end

# Repository Operations
function gclone --description "Clone a repo (with optional dir name)"
    if test (count $argv) -lt 1
        echo "Error: Repository URL required!"
        echo "Usage: gclone <repo-url> [directory-name]"
        return 1
    end
    
    set -l repo_url "$argv[1]"
    set -l dir_name "$argv[2]"
    
    echo "Cloning: $repo_url"
    
    if test -n "$dir_name"
        git clone "$repo_url" "$dir_name"
    else
        git clone "$repo_url"
    end
    
    if test $status -eq 0
        echo "Clone successful!"
    else
        echo "Clone failed!"
        return 1
    end
end

function gignore --description "Generate .gitignore using gitignore.io"
    if test (count $argv) -eq 0
        echo "Error: Language or platform required!"
        echo "Usage: gignore <language1,language2,...>"
        return 1
    end
    
    set -l url "https://www.toptal.com/developers/gitignore/api/"(string join ',' $argv)
    
    if command -v curl >/dev/null
        if curl -s "$url" >.gitignore
            echo "Generated .gitignore for: $argv"
        else
            echo "Error: Failed to generate .gitignore"
            return 1
        end
    else if command -v wget >/dev/null
        if wget -qO .gitignore "$url"
            echo "Generated .gitignore for: $argv"
        else
            echo "Error: Failed to generate .gitignore"
            return 1
        end
    else
        echo "Error: curl or wget is required!"
        return 1
    end
end

function gcheckout --description "Switch to a Git branch using fzf"
    if not command -v fzf >/dev/null
        echo "Error: fzf is required for this function"
        return 1
    end
    
    git fetch --all --prune 2>/dev/null
    
    set -l branch (git branch -a | sed 's/^[* ] //' | fzf --preview 'git log --oneline --color=always {}' --height 40%)
    
    if test -n "$branch"
        # Remove remotes/origin/ prefix if present
        set branch (string replace -r '^remotes/origin/' '' "$branch")
        git checkout "$branch"
    else
        echo "No branch selected."
        return 1
    end
end

# Enhanced Help Function
function ghelp --description "Show help for all g* commands"
    echo ""
    echo "Git Command Suite for Fish Shell"
    echo "==============================================="
    
    set -l functions_with_desc
    
    # Get all functions starting with 'g' and their descriptions
    for func in (functions | grep '^g')
        set -l desc (functions --details $func | head -1)
        if test -n "$desc"
            set -a functions_with_desc "$func:$desc"
        else
            set -a functions_with_desc "$func:No description"
        end
    end
    
    # Sort and display
    for item in $functions_with_desc
        set -l parts (string split ':' -- $item)
        set -l func_name $parts[1]
        set -l func_desc $parts[2]
        
        printf "%-20s → %s\n" "$func_name" "$func_desc"
    end
    
    echo "==============================================="
    echo "Use 'functions <function-name>' to see source code"
    echo "Use '<function-name> --help' for detailed usage (where available)"
end

# Additional utility functions
function ginit --description "Initialize a new git repository"
    if test -d .git
        echo "Error: Already in a git repository"
        return 1
    end
    
    git init
    and echo "Initialized git repository"
end

function gremote --description "Show remote repositories"
    git remote -v
end

function gtag --description "Create a new tag"
    if test (count $argv) -eq 0
        echo "Error: Tag name required!"
        echo "Usage: gtag <tag-name> [message]"
        return 1
    end
    
    set -l tag_name "$argv[1]"
    set -l tag_message "$argv[2]"
    
    if test -n "$tag_message"
        git tag -a "$tag_name" -m "$tag_message"
    else
        git tag "$tag_name"
    end
end

function gundo --description "Undo last N commits (soft reset)"
    set -l num_commits 1
    
    if test (count $argv) -gt 0
        set num_commits $argv[1]
        
        if not string match -rq '^\d+$' -- "$num_commits"
            echo "Error: Number of commits must be a positive integer"
            return 1
        end
    end
    
    git reset --soft "HEAD~$num_commits"
    echo "Undid last $num_commits commit(s) (files still staged)"
end

function gclean --description "Clean untracked files and directories"
    echo "This will remove all untracked files and directories!"
    git clean -n
    echo ""
    read -l -P "Proceed with cleanup? (yes/no): " confirm
    
    if test "$confirm" = "yes"
        git clean -fd
        echo "Cleanup completed"
    else
        echo "Cleanup cancelled"
    end
end