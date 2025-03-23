#!/bin/bash


# install required packages 
sudo pacman -S --needed --noconfirm fish eza bat fastfetch expac yay paru ugrep btop hwinfo reflector meld tar wget p7zip xsel starship ttf-firacode-nerd ttf-jetbrains-mono ttf-cascadia-code 

git clone https://github.com/NvChad/starter ~/.config/nvim

# Function to add Chaotic AUR support
enable_chaotic_aur() {
    read -p "Do you want to enable Chaotic AUR? (y/n): " choice

    case "$choice" in
        y|Y|yes|YES)
            echo "🔑 Importing Chaotic AUR keys..."
            sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
            sudo pacman-key --lsign-key 3056513887B78AEB

            echo "📦 Installing Chaotic AUR keyring and mirrorlist..."
            sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
            sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

            echo "🔧 Adding Chaotic AUR repository to pacman.conf..."
            echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

            echo "✅ Chaotic AUR has been enabled successfully!"
            ;;
        n|N|no|NO)
            echo "❌ Skipping Chaotic AUR setup."
            ;;
        *)
            echo "⚠️ Invalid input. Please enter 'y' or 'n'."
            enable_chaotic_aur  # Recursive call for valid input
            ;;
    esac
}

# Call the function
enable_chaotic_aur

handle_local_directory() {
    read -p "Are you using Konsole as your terminal? (y/n): " choice

    case "$choice" in
        y|Y|yes|YES)
            echo "📂 Syncing .local/ to $HOME/.local/ using rsync..."
            rsync -av .local/ "$HOME/.local/"
            echo "✅ Sync completed!"
            ;;
        n|N|no|NO)
            echo "⚠️ Deleting .local/ directory..."
            rm -rf .local
            echo "🗑️ .local/ directory deleted!"
            ;;
        *)
            echo "⚠️ Invalid input. Please enter 'y' or 'n'."
            handle_local_directory  # Recursive call for valid input
            ;;
    esac
}

# Call the function
handle_local_directory

rsync -av .config/ $HOME/.config/

echo "All done. Run neo vim to load config properly."
