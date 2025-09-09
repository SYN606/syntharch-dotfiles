#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


# ========== COLOR DEFINITIONS ==========
GREEN="\e[38;2;119;221;119m"   # Pastel green
YELLOW="\e[38;2;253;253;150m"  # Light pastel yellow
BLUE="\e[38;2;174;198;207m"    # Pale pastel blue
RED="\e[38;2;255;105;97m"      # Soft pastel red
CYAN="\e[38;2;176;224;230m"    # Pastel cyan
RESET="\e[0m"


# ========== WELCOME BANNER ==========
echo -e "${BLUE}"
cat <<'EOF'
  █████████                         █████    █████                                   █████     
 ███░░░░░███                       ░░███    ░░███                                   ░░███      
░███    ░░░  █████ ████ ████████   ███████   ░███████    ██████   ████████   ██████  ░███████  
░░█████████ ░░███ ░███ ░░███░░███ ░░░███░    ░███░░███  ░░░░░███ ░░███░░███ ███░░███ ░███░░███ 
 ░░░░░░░░███ ░███ ░███  ░███ ░███   ░███     ░███ ░███   ███████  ░███ ░░░ ░███ ░░░  ░███ ░███ 
 ███    ░███ ░███ ░███  ░███ ░███   ░███ ███ ░███ ░███  ███░░███  ░███     ░███  ███ ░███ ░███ 
░░█████████  ░░███████  ████ █████  ░░█████  ████ █████░░████████ █████    ░░██████  ████ █████
 ░░░░░░░░░    ░░░░░███ ░░░░ ░░░░░    ░░░░░  ░░░░ ░░░░░  ░░░░░░░░ ░░░░░      ░░░░░░  ░░░░ ░░░░░ 
              ███ ░███                                                                         
             ░░██████                                                                          
              ░░░░░░                                                                            

EOF
echo -e "${BLUE}======================================================================"
echo -e "${YELLOW}Arch Linux Dotfile Setup${RESET} | ${GREEN}by SYN606"
echo -e "${YELLOW}GitHub Repository${RESET}       | ${CYAN}https://github.com/syn606"
echo -e "${BLUE}======================================================================${RESET}"



# ========== VARIABLES ==========
PACKAGES=(
    fish eza bat fastfetch expac yay paru ugrep btop hwinfo reflector
    tar wget p7zip starship ttf-firacode-nerd neovim
)
NVIM_CONFIG_REPO="https://github.com/NvChad/starter"
NVIM_CONFIG_DIR="$HOME/.config/nvim"


# ========== FUNCTIONS ==========


check_root_notice() {
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "${YELLOW}Note: Some actions require root privileges. You will be prompted when necessary.${RESET}"
    fi
}


check_internet() {
    echo -e "${BLUE}Checking internet connectivity...${RESET}"
    if ! ping -q -c 1 archlinux.org &>/dev/null; then
        echo -e "${RED}Error: No internet connection detected. Please connect and try again.${RESET}"
        exit 1
    fi
}


install_packages() {
    echo -e "${BLUE}Installing required packages...${RESET}"
    for pkg in "${PACKAGES[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            echo -e "${YELLOW}Installing: ${GREEN}$pkg${RESET}"
            sudo pacman -S --noconfirm "$pkg"
        else
            echo -e "${GREEN}$pkg is already installed.${RESET}"
        fi
    done
}


install_nvim_config() {
    if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
        echo -e "${BLUE}Cloning Neovim configuration (NvChad)...${RESET}"
        git clone "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR"
    else
        echo -e "${YELLOW}Neovim configuration already exists. Skipping...${RESET}"
    fi
}


enable_chaotic_aur() {
    read -p "$(echo -e "${BLUE}Do you want to enable Chaotic AUR? (y/n): ${RESET}")" choice
    case "$choice" in
        y|Y|yes|YES)
            echo -e "${BLUE}Importing Chaotic AUR GPG key...${RESET}"
            sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
            sudo pacman-key --lsign-key 3056513887B78AEB

            echo -e "${BLUE}Installing Chaotic AUR packages (keyring, mirrorlist)...${RESET}"
            sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
            sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

            if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
                echo -e "${BLUE}Adding Chaotic AUR to pacman.conf...${RESET}"
                echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf > /dev/null
            else
                echo -e "${YELLOW}Chaotic AUR repository already configured.${RESET}"
            fi

            echo -e "${BLUE}Synchronizing and updating package lists...${RESET}"
            sudo pacman -Syu

            echo -e "${GREEN}Chaotic AUR has been successfully enabled.${RESET}"
        ;;
        n|N|no|NO)
            echo -e "${YELLOW}Chaotic AUR setup skipped.${RESET}"
        ;;
        *)
            echo -e "${RED}Invalid input. Please enter y or n.${RESET}"
            enable_chaotic_aur
        ;;
    esac
}


handle_gpu_config() {
    read -p "$(echo -e "${BLUE}Enable GPU configuration in Fish shell? (y/n): ${RESET}")" choice
    [[ "$choice" =~ ^[yY] ]] && return

    echo -e "${YELLOW}Removing GPU configuration from local dotfiles...${RESET}"
    rm -f .config/fish/functions/gpu.fish
    sed -i '/if test -f ~\/\.config\/fish\/functions\/gpu\.fish/,/end/d' .config/fish/config.fish
    echo -e "${GREEN}GPU configuration removed successfully.${RESET}"
}


handle_git_config() {
    read -p "$(echo -e "${BLUE}Enable Git configuration in Fish shell? (y/n): ${RESET}")" choice
    [[ "$choice" =~ ^[yY] ]] && return

    echo -e "${YELLOW}Removing Git configuration from local dotfiles...${RESET}"
    rm -f .config/fish/functions/git.fish
    sed -i '/if test -f ~\/\.config\/fish\/functions\/git\.fish/,/end/d' .config/fish/config.fish
    echo -e "${GREEN}Git configuration removed successfully.${RESET}"
}


install_pentest_tools() {
    echo "────────────────────────────────────────────"
    echo "  DARK ARCH :: Pentesting Tools Installer"
    echo "────────────────────────────────────────────"
    read -p "Install pentesting tools? (y/n): " answer

    case "${answer,,}" in
        y|yes)
            if [[ -f "./dark-arch.sh" ]]; then
                echo "Running dark-arch.sh..."
                chmod +x ./dark-arch.sh
                ./dark-arch.sh
            else
                echo "Error: dark-arch.sh not found."
                exit 1
            fi
        ;;
        *)
            echo "Pentesting tools installation skipped."
        ;;
    esac
}


handle_local_directory() {
    if [[ -d .local ]]; then
        read -p "$(echo -e "${BLUE}Are you using KDE (sync .local)? (y/n): ${RESET}")" choice
        case "$choice" in
            y|Y|yes|YES)
                echo -e "${BLUE}Synchronizing .local with $HOME/.local/...${RESET}"
                rsync -av .local/ "$HOME/.local/"
                echo -e "${GREEN}.local directory synced successfully.${RESET}"
            ;;
            n|N|no|NO)
                echo -e "${YELLOW}Removing local .local directory...${RESET}"
                rm -rf .local
                rm -rf .config/konsolerc
                echo -e "${GREEN}.local directory removed successfully.${RESET}"
            ;;
            *)
                echo -e "${RED}Invalid input.${RESET}"
                handle_local_directory
            ;;
        esac
    fi
}


sync_configs() {
    [[ -d .config ]] && rsync -av .config/ "$HOME/.config/"
    echo -e "${GREEN}Configuration files synced successfully.${RESET}"
}


enable_starship_prompt() {
    CONFIG_PATH="$HOME/.config/fish/config.fish"
    LINE='starship init fish | source'
    if [[ -f "$CONFIG_PATH" && ! $(grep -Fx "$LINE" "$CONFIG_PATH") ]]; then
        echo "$LINE" >> "$CONFIG_PATH"
        echo -e "${GREEN}Starship prompt enabled in Fish shell.${RESET}"
    fi
}


# ========== MAIN ==========
main() {
    check_root_notice
    check_internet
    install_packages
    install_nvim_config
    enable_chaotic_aur
    handle_git_config
    handle_gpu_config
    handle_local_directory
    sync_configs
    enable_starship_prompt
    install_pentest_tools
    echo -e "\n${GREEN}Setup complete. Launch Neovim with \`nvim\` to get started.${RESET}"
}


main
