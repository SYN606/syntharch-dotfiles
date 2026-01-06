#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ========== SCRIPT METADATA ==========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/.local/state/syn606-setup.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'echo -e "\n\e[38;2;255;105;97m[ERROR] Script failed at line $LINENO\e[0m"' ERR

# ========== COLOR DEFINITIONS ==========
GREEN="\e[38;2;119;221;119m"
YELLOW="\e[38;2;253;253;150m"
BLUE="\e[38;2;174;198;207m"
RED="\e[38;2;255;105;97m"
CYAN="\e[38;2;176;224;230m"
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
OFFICIAL_PACKAGES=(
    fish eza bat fastfetch expac ugrep btop hwinfo reflector
    tar wget p7zip starship ttf-firacode-nerd neovim uv
)

NVIM_CONFIG_REPO="https://github.com/NvChad/starter"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
FISH_CONFIG="$HOME/.config/fish/config.fish"

# ========== FUNCTIONS ==========

check_root_notice() {
    [[ "$EUID" -ne 0 ]] && echo -e "${YELLOW}Root privileges will be requested when required.${RESET}"
}

check_internet() {
    echo -e "${BLUE}Checking internet connectivity...${RESET}"
    ping -q -c 1 archlinux.org &>/dev/null || {
        echo -e "${RED}No internet connection detected.${RESET}"
        exit 1
    }
}

system_update() {
    echo -e "${BLUE}Updating system (safe full upgrade)...${RESET}"
    sudo pacman -Syu --noconfirm
}

install_packages() {
    echo -e "${BLUE}Installing official packages...${RESET}"
    for pkg in "${OFFICIAL_PACKAGES[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            sudo pacman -S --noconfirm "$pkg"
        else
            echo -e "${GREEN}$pkg already installed.${RESET}"
        fi
    done
}

install_nvim_config() {
    if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
        echo -e "${BLUE}Cloning NvChad configuration...${RESET}"
        git clone "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR"
    else
        echo -e "${YELLOW}Neovim config exists — skipping.${RESET}"
    fi
}

enable_chaotic_aur() {
    read -rp "$(echo -e "${BLUE}Enable Chaotic AUR? (y/n): ${RESET}")" choice
    [[ ! "$choice" =~ ^[yY] ]] && {
        echo -e "${YELLOW}Chaotic AUR setup skipped.${RESET}"
        return
    }
    
    echo -e "${BLUE}Setting up Chaotic AUR...${RESET}"
    
    # ---- Import & sign key (idempotent) ----
    if ! sudo pacman-key --list-keys 3056513887B78AEB &>/dev/null; then
        echo -e "${BLUE}Importing Chaotic AUR signing key...${RESET}"
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
    else
        echo -e "${GREEN}Chaotic AUR signing key already present.${RESET}"
    fi
    
    # ---- Install keyring & mirrorlist if missing ----
    if ! pacman -Q chaotic-keyring &>/dev/null || ! pacman -Q chaotic-mirrorlist &>/dev/null; then
        echo -e "${BLUE}Installing Chaotic AUR keyring and mirrorlist...${RESET}"
        sudo pacman -U --noconfirm \
        https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst \
        https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst
    else
        echo -e "${GREEN}Chaotic AUR keyring and mirrorlist already installed.${RESET}"
    fi
    
    # ---- Add repo to pacman.conf safely ----
    if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
        echo -e "${BLUE}Adding Chaotic AUR repository to pacman.conf...${RESET}"
        echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | \
        sudo tee -a /etc/pacman.conf >/dev/null
    else
        echo -e "${GREEN}Chaotic AUR repository already configured.${RESET}"
    fi
    
    # ---- Sync package databases only (no upgrade) ----
    echo -e "${BLUE}Synchronizing package databases...${RESET}"
    sudo pacman -Sy
    
    echo -e "${GREEN}Chaotic AUR enabled successfully.${RESET}"
}

fish_remove_block() {
    local marker="$1"
    sed -i "/# BEGIN SYN606-$marker/,/# END SYN606-$marker/d" "$FISH_CONFIG" 2>/dev/null || true
}

handle_git_config() {
    read -p "$(echo -e "${BLUE}Enable Git Fish config? (y/n): ${RESET}")" choice
    [[ "$choice" =~ ^[yY] ]] || fish_remove_block "GIT"
}

handle_gpu_config() {
    read -p "$(echo -e "${BLUE}Enable GPU Fish config? (y/n): ${RESET}")" choice
    [[ "$choice" =~ ^[yY] ]] || fish_remove_block "GPU"
}

handle_local_directory() {
    [[ ! -d "$SCRIPT_DIR/.local" ]] && return
    read -p "$(echo -e "${BLUE}Using KDE (.local sync)? (y/n): ${RESET}")" choice
    if [[ "$choice" =~ ^[yY] ]]; then
        rsync -av "$SCRIPT_DIR/.local/" "$HOME/.local/"
    else
        rm -rf "$SCRIPT_DIR/.local" "$SCRIPT_DIR/.config/konsolerc"
    fi
}

sync_configs() {
    [[ -d "$SCRIPT_DIR/.config" ]] && rsync -av "$SCRIPT_DIR/.config/" "$HOME/.config/"
}

enable_starship_prompt() {
    grep -q "starship init fish" "$FISH_CONFIG" 2>/dev/null || \
    echo 'starship init fish | source' >> "$FISH_CONFIG"
}

install_pentest_tools() {
    local tool="$SCRIPT_DIR/dark-arch.sh"
    [[ ! -f "$tool" ]] && {
        echo -e "${YELLOW}Pentest installer not found — skipping.${RESET}"
        return
    }
    
    read -p "Install pentesting tools? (y/n): " choice
    [[ "$choice" =~ ^[yY] ]] || return
    chmod +x "$tool"
    "$tool"
}

# ========== MAIN ==========
main() {
    check_root_notice
    check_internet
    system_update
    install_packages
    install_nvim_config
    enable_chaotic_aur
    handle_git_config
    handle_gpu_config
    handle_local_directory
    sync_configs
    enable_starship_prompt
    install_pentest_tools
    
    echo -e "\n${GREEN}Setup complete. Run 'nvim' to finish Neovim setup.${RESET}"
    echo -e "${CYAN}Log saved to: $LOG_FILE${RESET}"
}

main
