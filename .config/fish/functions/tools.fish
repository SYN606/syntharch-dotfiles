function update_dotfiles --description "Update local dotfiles from SYN606/syntharch-dotfiles repo"
    set repo_dir "$HOME/syntharch-dotfiles"

    if not test -d $repo_dir
        echo "❌ Dotfiles repo not found at: $repo_dir"
        return 1
    end

    echo "📦 Updating dotfiles from GitHub..."
    cd $repo_dir

    # Ensure it's a valid Git repo
    if not test -d .git
        echo "❌ Not a Git repository: $repo_dir"
        return 1
    end

    # Optional: auto-stash if needed
    if not git diff --quiet
        echo "💾 Uncommitted changes detected — stashing..."
        git stash push -m "Auto-stash before update"
    end

    git pull origin main

    if test $status -eq 0
        echo "✅ Dotfiles updated successfully."
        # Re-run setup script if it exists
        if test -f script.sh
            echo "⚙️ Running setup script..."
            chmod +x script.sh
            ./script.sh
        end
    else
        echo "❌ Failed to update dotfiles."
    end

    cd -
end
