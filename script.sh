#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ========== SCRIPT METADATA ==========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/.local/state/syn606-setup.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'echo -e "\n\e[38;2;255;105;97m[ERROR] Script failed at line $LINENO\e[0m"' ERR

# ========== COLORS ==========
GREEN="\e[38;2;119;221;119m"
YELLOW="\e[38;2;253;253;150m"
BLUE="\e[38;2;174;198;207m"
RED="\e[38;2;255;105;97m"
CYAN="\e[38;2;176;224;230m"
RESET="\e[0m"

# ========== BANNER ==========
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
echo -e "${YELLOW}Ubuntu/Debian Dotfile Setup${RESET} | ${GREEN}by SYN606"
echo -e "${YELLOW}GitHub Repository${RESET}        | ${CYAN}https://github.com/syn606"
echo -e "${BLUE}======================================================================${RESET}"
# ========== VARIABLES ==========
APT_PACKAGES=(
    fish
    eza
    batcat
    fastfetch
    ugrep
    btop
    hwinfo
    tar
    wget
    p7zip-full
    unzip
    starship
    neovim
    git
    curl
    rsync
    fonts-firacode
    build-essential
)

NVIM_CONFIG_REPO="https://github.com/NvChad/starter"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
FISH_CONFIG="$HOME/.config/fish/config.fish"

# ========== FUNCTIONS ==========

check_root_notice() {
    [[ "$EUID" -ne 0 ]] && echo -e "${YELLOW}Sudo will be requested when required.${RESET}"
}

check_internet() {
    echo -e "${BLUE}Checking internet connectivity...${RESET}"
    ping -q -c 1 google.com &>/dev/null || {
        echo -e "${RED}No internet connection detected.${RESET}"
        exit 1
    }
}

system_update() {
    echo -e "${BLUE}Updating system...${RESET}"
    sudo apt update
    sudo apt upgrade -y
}

install_packages() {
    echo -e "${BLUE}Installing required packages...${RESET}"
    sudo apt install -y "${APT_PACKAGES[@]}"
}

install_uv() {
    if command -v uv &>/dev/null; then
        echo -e "${GREEN}uv already installed.${RESET}"
        return
    fi

    echo -e "${BLUE}Installing uv (Astral official installer)...${RESET}"
    curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh
    bash /tmp/uv-install.sh
    rm /tmp/uv-install.sh

    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
        echo -e "${YELLOW}Added ~/.local/bin to PATH. Restart shell required.${RESET}"
    fi

    echo -e "${GREEN}uv installed successfully.${RESET}"
}

install_nvim_config() {
    if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
        echo -e "${BLUE}Cloning NvChad configuration...${RESET}"
        git clone "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR"
    else
        echo -e "${YELLOW}Neovim config exists — skipping.${RESET}"
    fi
}

sync_configs() {
    [[ -d "$SCRIPT_DIR/.config" ]] && \
    rsync -av "$SCRIPT_DIR/.config/" "$HOME/.config/"
}

handle_local_directory() {
    [[ ! -d "$SCRIPT_DIR/.local" ]] && return
    read -p "$(echo -e "${BLUE}Sync .local directory? (y/n): ${RESET}")" choice
    [[ "$choice" =~ ^[yY] ]] && \
    rsync -av "$SCRIPT_DIR/.local/" "$HOME/.local/"
}

setup_starship() {
    mkdir -p "$(dirname "$FISH_CONFIG")"
    grep -q "starship init fish" "$FISH_CONFIG" 2>/dev/null || \
    echo 'starship init fish | source' >> "$FISH_CONFIG"
}

install_pentest_tools() {
    local tool="$SCRIPT_DIR/dark-ubuntu.sh"
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
    install_uv
    install_nvim_config
    sync_configs
    handle_local_directory
    setup_starship
    install_pentest_tools

    echo -e "\n${GREEN}Ubuntu setup complete.${RESET}"
    echo -e "${CYAN}Log saved to: $LOG_FILE${RESET}"
}

main