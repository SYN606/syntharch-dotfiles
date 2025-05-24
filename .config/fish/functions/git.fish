# Git commit with message
function gcommit --description "Add all changes and commit with a message"
    if test (count $argv) -eq 0
        echo "❌ Error: Commit message required!"
        echo "Usage: gcommit 'Your commit message'"
        return 1
    end
    git add .
    git commit -m "$argv"
end

function gst --description "Show short Git status"
    git status -sb
end

function glg --description "Display Git log with graph"
    git log --oneline --graph --all --decorate
end

function guncommit --description "Undo last commit (keep staged)"
    git reset --soft HEAD~1
end

function gcleanup --description "Remove local branches gone from remote"
    git fetch --all --prune
    git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d
end

function gprev --description "Switch to previous branch"
    git switch -
end

function gfilelog --description "Show commit history for a file"
    if test (count $argv) -eq 0
        echo "❌ Error: File path required!"
        echo "Usage: gfilelog <file-path>"
        return 1
    end
    git log --follow --pretty=format:'%h %ad | %s%d [%an]' --date=short -- $argv
end

function gshowdiff --description "Show changed files in a commit"
    if test (count $argv) -eq 0
        echo "❌ Error: Commit hash required!"
        echo "Usage: gshowdiff <commit-hash>"
        return 1
    end
    git diff-tree --no-commit-id --name-status -r $argv
end

function gpush --description "Push current branch"
    git push origin (git branch --show-current)
end

function gpushf --description "Force push current branch (DANGEROUS)"
    read -l -p "⚠️  Are you sure you want to force push? (yes/no): " confirm
    if test "$confirm" = "yes"
        git push --force origin (git branch --show-current)
    else
        echo "❌ Force push aborted."
    end
end

function gpull --description "Pull latest changes with rebase"
    git pull --rebase origin (git branch --show-current)
end

function gmerge --description "Merge specified branch"
    if test (count $argv) -eq 0
        echo "❌ Error: Branch name required!"
        echo "Usage: gmerge <branch-name>"
        return 1
    end
    git merge $argv
end

function gmerge-abort --description "Abort ongoing merge"
    git merge --abort
end

function gconflicts --description "List unresolved merge conflicts"
    git diff --name-only --diff-filter=U
end

function gresolve --description "Add and commit resolved conflicts"
    git diff --name-only --diff-filter=U | xargs git add
    git commit -m "Resolved merge conflicts"
end

function gfetch --description "Fetch all remote branches"
    git fetch --all --prune
end

function gbranch --description "Show current Git branch"
    git branch --show-current
end

function gbranches --description "List all branches sorted by latest commit"
    git branch --sort=-committerdate
end

function gstash --description "Stash changes with a message"
    if test (count $argv) -eq 0
        echo "❌ Error: Stash message required!"
        echo "Usage: gstash 'Your message'"
        return 1
    end
    git stash push -m "$argv[*]"
end

function gstash-pop --description "Apply latest stash"
    if test -z (git stash list)
        echo "❌ No stashes found!"
        return 1
    end
    git stash pop
end

function gstash-list --description "List all stash entries"
    git stash list
end

function gclone --description "Clone a repo (with optional dir name)"
    if test (count $argv) -lt 1
        echo "❌ Error: Repository URL required!"
        echo "Usage: gclone <repo-url> [directory-name]"
        return 1
    end
    set repo_url $argv[1]
    set dir_name $argv[2]

    echo "📥 Cloning: $repo_url"
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

# Generate .gitignore file
function gignore --description "Generate .gitignore using gitignore.io"
    if test (count $argv) -eq 0
        echo "❌ Error: Language or platform required!"
        echo "Usage: gignore <language1,language2,...>"
        return 1
    end
    set url "https://www.toptal.com/developers/gitignore/api/"(string join ',' $argv)
    curl -s "$url" > .gitignore
    if test $status -eq 0
        echo "✅ .gitignore generated for: $argv[*]"
    else
        echo "❌ Failed to generate .gitignore"
    end
end

# Fuzzy switch to branch using fzf
function gcheckout --description "Switch to a Git branch using fzf"
    git fetch --all --prune
    git branch -a | sed 's/^[* ] //' | fzf --preview 'git log --oneline --color=always {}' | xargs git checkout
end

# Help command
function ghelp --description "List all Git functions and descriptions"
    echo "🚀 Available Git Commands:"
    for cmd in (functions --all | grep '^g')
        printf "  %-16s - %s\n" $cmd (functions --description $cmd)
    end
end
