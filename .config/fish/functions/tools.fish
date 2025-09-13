function update_dotfiles --description "Update local dotfiles from SYN606/syntharch-dotfiles repo"
    set repo_dir "$HOME/syntharch-dotfiles"
    set original_dir (pwd)
    
    # Validate repository exists
    if not test -d "$repo_dir"
        echo "Error: Dotfiles repo not found at: $repo_dir" >&2
        echo "Please clone the repository first:" >&2
        echo "  git clone https://github.com/SYN606/syntharch-dotfiles.git $repo_dir" >&2
        return 1
    end
    
    echo "Updating dotfiles from GitHub..."
    
    # Change to repository directory with error handling
    if not cd "$repo_dir"
        echo "Error: Failed to change to directory: $repo_dir" >&2
        return 1
    end
    
    # Validate it's a Git repository
    if not test -d .git
        echo "Error: Not a Git repository: $repo_dir" >&2
        cd "$original_dir" 2>/dev/null
        return 1
    end
    
    # Check if we're on the correct remote
    set remote_url (git remote get-url origin 2>/dev/null)
    if test $status -ne 0
        echo "Error: No remote 'origin' found" >&2
        cd "$original_dir" 2>/dev/null
        return 1
    end
    
    if not string match -q "*SYN606/syntharch-dotfiles*" "$remote_url"
        echo "Warning: Remote URL doesn't match expected repository:" >&2
        echo "  Expected: SYN606/syntharch-dotfiles" >&2
        echo "  Found: $remote_url" >&2
        read -l -P "Continue anyway? (y/N): " confirm
        if not test (string lower "$confirm") = "y"
            echo "Update cancelled"
            cd "$original_dir" 2>/dev/null
            return 1
        end
    end
    
    # Check for uncommitted changes and handle them properly
    if not git diff --quiet 2>/dev/null; or not git diff --cached --quiet 2>/dev/null
        echo "Uncommitted changes detected:"
        git status --porcelain 2>/dev/null
        echo ""
        read -l -P "Stash changes before updating? (Y/n): " stash_choice
        
        if not test (string lower "$stash_choice") = "n"
            echo "Stashing changes..."
            if not git stash push -m "Auto-stash before dotfiles update - $(date)"
                echo "Error: Failed to stash changes" >&2
                cd "$original_dir" 2>/dev/null
                return 1
            end
            echo "Changes stashed successfully"
        else
            echo "Warning: Proceeding with uncommitted changes" >&2
        end
    end
    
    # Fetch latest changes first
    echo "Fetching latest changes..."
    if not git fetch origin 2>/dev/null
        echo "Error: Failed to fetch from remote" >&2
        cd "$original_dir" 2>/dev/null
        return 1
    end
    
    # Check if main branch exists, fallback to master
    set target_branch "main"
    if not git show-ref --verify --quiet "refs/remotes/origin/main" 2>/dev/null
        if git show-ref --verify --quiet "refs/remotes/origin/master" 2>/dev/null
            set target_branch "master"
        else
            echo "Error: Neither 'main' nor 'master' branch found on remote" >&2
            cd "$original_dir" 2>/dev/null
            return 1
        end
    end
    
    # Get current branch
    set current_branch (git branch --show-current 2>/dev/null)
    if test $status -ne 0
        echo "Error: Failed to determine current branch" >&2
        cd "$original_dir" 2>/dev/null
        return 1
    end
    
    # Switch to target branch if not already on it
    if test "$current_branch" != "$target_branch"
        echo "Switching to $target_branch branch..."
        if not git checkout "$target_branch" 2>/dev/null
            echo "Error: Failed to checkout $target_branch branch" >&2
            cd "$original_dir" 2>/dev/null
            return 1
        end
    end
    
    # Pull latest changes
    echo "Pulling latest changes from origin/$target_branch..."
    if git pull origin "$target_branch" 2>/dev/null
        echo "Dotfiles updated successfully!"
        set update_success true
    else
        echo "Error: Failed to pull changes from remote" >&2
        set update_success false
    end
    
    # Run setup script if update was successful and script exists
    if test "$update_success" = true
        if test -f script.sh
            echo ""
            read -l -P "Setup script found. Run it now? (Y/n): " run_script
            if not test (string lower "$run_script") = "n"
                echo "Running setup script..."
                if test -x script.sh
                    if ./script.sh
                        echo "Setup script completed successfully"
                    else
                        echo "Warning: Setup script failed with exit code $status" >&2
                    end
                else
                    echo "Making script executable..."
                    if chmod +x script.sh
                        if ./script.sh
                            echo "Setup script completed successfully"
                        else
                            echo "Warning: Setup script failed with exit code $status" >&2
                        end
                    else
                        echo "Error: Failed to make script executable" >&2
                    end
                end
            end
        else if test -f setup.sh
            echo ""
            read -l -P "Setup script (setup.sh) found. Run it now? (Y/n): " run_script
            if not test (string lower "$run_script") = "n"
                echo "Running setup script..."
                if test -x setup.sh
                    if ./setup.sh
                        echo "Setup script completed successfully"
                    else
                        echo "Warning: Setup script failed with exit code $status" >&2
                    end
                else
                    echo "Making script executable..."
                    if chmod +x setup.sh
                        if ./setup.sh
                            echo "Setup script completed successfully"
                        else
                            echo "Warning: Setup script failed with exit code $status" >&2
                        end
                    else
                        echo "Error: Failed to make script executable" >&2
                    end
                end
            end
        else
            echo "No setup script found (looked for script.sh and setup.sh)"
        end
    end
    
    # Return to original directory
    if not cd "$original_dir"
        echo "Warning: Failed to return to original directory: $original_dir" >&2
        echo "Current directory: $(pwd)"
    end
    
    if test "$update_success" = true
        return 0
    else
        return 1
    end
end

# Helper function to check dotfiles status
function dotfiles_status --description "Check status of dotfiles repository"
    set repo_dir "$HOME/syntharch-dotfiles"
    
    if not test -d "$repo_dir"
        echo "Error: Dotfiles repo not found at: $repo_dir" >&2
        return 1
    end
    
    set original_dir (pwd)
    
    if not cd "$repo_dir"
        echo "Error: Failed to access repository directory" >&2
        return 1
    end
    
    echo "Dotfiles Repository Status"
    echo "=========================="
    echo "Location: $repo_dir"
    echo ""
    
    # Check if it's a git repo
    if not test -d .git
        echo "Error: Not a Git repository"
        cd "$original_dir" 2>/dev/null
        return 1
    end
    
    # Show current branch and remote info
    echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'Unknown')"
    echo "Remote URL: $(git remote get-url origin 2>/dev/null || echo 'No remote')"
    echo ""
    
    # Check for updates
    echo "Checking for updates..."
    if git fetch --dry-run 2>/dev/null
        set local_commit (git rev-parse HEAD 2>/dev/null)
        set remote_commit (git rev-parse '@{u}' 2>/dev/null)
        
        if test "$local_commit" = "$remote_commit"
            echo "Repository is up to date"
        else
            echo "Updates available!"
            echo "Local:  $local_commit"
            echo "Remote: $remote_commit"
        end
    else
        echo "Unable to check for updates (network issue?)"
    end
    
    echo ""
    
    # Show working directory status
    echo "Working directory status:"
    if git diff --quiet 2>/dev/null; and git diff --cached --quiet 2>/dev/null
        echo "Clean (no uncommitted changes)"
    else
        echo "Has uncommitted changes:"
        git status --porcelain 2>/dev/null
    end
    
    # Show stash status
    set stash_count (git stash list 2>/dev/null | wc -l)
    echo ""
    echo "Stashed changes: $stash_count"
    
    cd "$original_dir" 2>/dev/null
end

# Quick function to reset dotfiles to clean state
function dotfiles_reset --description "Reset dotfiles repository to clean state"
    set repo_dir "$HOME/syntharch-dotfiles"
    
    if not test -d "$repo_dir"
        echo "Error: Dotfiles repo not found at: $repo_dir" >&2
        return 1
    end
    
    echo "WARNING: This will discard all local changes in the dotfiles repository!"
    echo "Repository: $repo_dir"
    echo ""
    read -l -P "Are you sure you want to continue? (yes/no): " confirm
    
    if not test "$confirm" = "yes"
        echo "Reset cancelled"
        return 1
    end
    
    set original_dir (pwd)
    
    if not cd "$repo_dir"
        echo "Error: Failed to access repository directory" >&2
        return 1
    end
    
    # Reset to clean state
    echo "Resetting repository to clean state..."
    
    if git reset --hard HEAD 2>/dev/null; and git clean -fd 2>/dev/null
        echo "Repository reset successfully"
        
        # Optionally pull latest changes
        read -l -P "Pull latest changes from remote? (Y/n): " pull_choice
        if not test (string lower "$pull_choice") = "n"
            if git pull 2>/dev/null
                echo "Updated to latest version"
            else
                echo "Warning: Failed to pull latest changes" >&2
            end
        end
    else
        echo "Error: Failed to reset repository" >&2
        cd "$original_dir" 2>/dev/null
        return 1
    end
    
    cd "$original_dir" 2>/dev/null
end