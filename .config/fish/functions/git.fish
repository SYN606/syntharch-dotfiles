# Git commit with message
function gcommit --description "Add all changes and commit with a message"
    if test (count $argv) -eq 0
        echo "❌ Error: Commit message required!"
        echo "Usage: gcommit <your message>"
        return 1
    end
    git add .
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
    git fetch --all --prune
    git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d
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
    git log --follow --pretty=format:'%h %ad | %s%d [%an]' --date=short -- "$argv"
end

function gshowdiff --description "Show changed files in a commit"
    if test (count $argv) -eq 0
        echo "❌ Error: Commit hash required!"
        echo "Usage: gshowdiff <commit-hash>"
        return 1
    end
    git diff-tree --no-commit-id --name-status -r "$argv[1]"
end

function gpush --description "Push current branch"
    git push origin (git branch --show-current)
end

function gpushf --description "Force push current branch (DANGEROUS)"
    read -l -p "⚠️  Are you sure you want to force push? (yes/no): " confirm
    if test (string lower "$confirm") = yes
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
    git merge "$argv[1]"
end

function gmerge-abort --description "Abort ongoing merge"
    git merge --abort
end

function gconflicts --description "List unresolved merge conflicts"
    git diff --name-only --diff-filter=U
end

function gresolve --description "Add and commit resolved conflicts"
    set msg (string join " " $argv)
    if test -z "$msg"
        set msg "Resolved merge conflicts"
    end
    git diff --name-only --diff-filter=U | xargs -r git add
    git commit -m "$msg"
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
        echo "Usage: gstash <your message>"
        return 1
    end
    git stash push -m "$argv"
end

function gstash-pop --description "Apply latest stash"
    if not git stash list | grep -q .
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
    set repo_url "$argv[1]"
    set dir_name "$argv[2]"

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

function gignore --description "Generate .gitignore using gitignore.io"
    if test (count $argv) -eq 0
        echo "❌ Error: Language or platform required!"
        echo "Usage: gignore <language1,language2,...>"
        return 1
    end
    set url "https://www.toptal.com/developers/gitignore/api/"(string join ',' $argv)
    if type -q curl
        curl -s "$url" >.gitignore
    else if type -q wget
        wget -qO .gitignore "$url"
    else
        echo "❌ curl or wget is required!"
        return 1
    end

    if test $status -eq 0
        echo "✅ .gitignore generated for: $argv"
    else
        echo "❌ Failed to generate .gitignore"
    end
end

function gcheckout --description "Switch to a Git branch using fzf"
    git fetch --all --prune
    set branch (git branch -a | sed 's/^[* ] //' | fzf --preview 'git log --oneline --color=always {}')
    if test -n "$branch"
        git checkout $branch
    else
        echo "❌ No branch selected."
    end
end

function ghelp --description "Show help for all g* commands"
    echo ""
    set_color yellow
    echo "🚀 Git Command Suite for Fish Shell"
    set_color normal
    echo "─────────────────────────────────────────────"

    set script_path (status current-filename)

    if test -z "$script_path"
        set_color red
        echo "⚠️  Cannot determine script path. Make sure you're sourcing this file."
        set_color normal
        return 1
    end

    for line in (grep '^function g' $script_path)
        # Extract function name
        set cmd (string match -r '^function ([^ ]+)' -- $line)[2]

        # Extract description
        if string match -q '*--description "*"' -- $line
            set parts (string split -- '--description ' $line)
            set rawdesc (string split -- '"' $parts[2])
            set desc $rawdesc[2]
        else
            set desc "(No description)"
        end

        # Print formatted and colorized output
        set_color cyan
        printf "🔸 "
        set_color green
        printf "%-15s" $cmd
        set_color normal
        printf " → "
        set_color brwhite
        echo "$desc"
        set_color normal
    end

    echo "─────────────────────────────────────────────"
    set_color normal
end
