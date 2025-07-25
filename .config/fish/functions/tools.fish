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

# --------- starship command ------------
function starship-use --description "Switch Starship prompt theme using custom .toml presets"
    if not type -q starship
        echo "❌ Error: Starship is not installed!"
        return 1
    end

    set preset_dir "$HOME/.config/starship"
    set output_file "$HOME/.config/starship.toml"
    set preset_files (ls $preset_dir/*.toml 2>/dev/null)

    if test (count $preset_files) -eq 0
        echo "❌ No Starship preset files found in $preset_dir"
        return 1
    end

    echo "🎨 Available Starship Presets:"
    for i in (seq (count $preset_files))
        set name (basename $preset_files[$i] .toml)
        printf "  [%d] %s\n" $i $name
    end

    echo -n "👉 Enter the number of the preset to use: "
    read choice

    if not string match -qr '^[0-9]+$' -- $choice
        echo "❌ Invalid input: Please enter a number."
        return 1
    end

    if test $choice -lt 1 -o $choice -gt (count $preset_files)
        echo "❌ Choice out of range."
        return 1
    end

    set selected_file $preset_files[$choice]
    set selected_name (basename $selected_file .toml)

    echo "📂 Switching to Starship preset: '$selected_name'"
    cp $selected_file $output_file

    if test $status -ne 0
        echo "❌ Failed to apply preset: $selected_name"
        return 1
    end

    echo "✅ Starship config set to '$selected_name'"
end
