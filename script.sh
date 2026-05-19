#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ========== SCRIPT METADATA ==========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/.local/state/syn606-setup.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

# ========== COLORS ==========
GREEN="\e[38;2;119;221;119m"
YELLOW="\e[38;2;253;253;150m"
BLUE="\e[38;2;174;198;207m"
RED="\e[38;2;255;105;97m"
CYAN="\e[38;2;176;224;230m"
RESET="\e[0m"

# ========== ERROR HANDLER ==========
trap 'echo -e "\n${RED}[ERROR] Script failed at line $LINENO${RESET}" >&2' ERR

# ========== APT ==========
export DEBIAN_FRONTEND=noninteractive
APT_FLAGS="-yqq"

# ========== BANNER ==========
clear

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
echo -e "${YELLOW}GitHub Repository${RESET}        | ${CYAN}https://github.com/syn606${RESET}"
echo -e "${BLUE}======================================================================${RESET}"

# ========== VARIABLES ==========
APT_PACKAGES=(
    fish
    eza
    bat
    fastfetch
    ugrep
    btop
    hwinfo
    tar
    wget
    p7zip-full
    unzip
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

# ========== HELPERS ==========
log_step() {
    echo -e "${BLUE}[•]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${RESET} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${RESET} $1"
}

# ========== FUNCTIONS ==========

check_root_notice() {
    [[ "$EUID" -ne 0 ]] && \
    log_warn "Sudo will be requested when required."
}

check_internet() {
    log_step "Checking internet connectivity..."
    ping -q -c 1 google.com &>/dev/null || {
        echo -e "${RED}[ERROR] No internet connection detected.${RESET}"
        exit 1
    }
    log_success "Internet connection OK"
}

enable_universe_repo() {
    log_step "Ensuring universe repository is enabled..."
    sudo add-apt-repository -y universe >/dev/null 2>&1 || true
    log_success "Universe repository ready"
}

system_update() {
    log_step "Updating system packages..."
    sudo apt-get update -qq >/dev/null
    sudo apt-get upgrade $APT_FLAGS >/dev/null
    log_success "System updated"
}

install_packages() {
    log_step "Installing required packages..."
    sudo apt-get install $APT_FLAGS "${APT_PACKAGES[@]}" >/dev/null
    log_success "Required packages installed"
}

install_starship() {
    if command -v starship &>/dev/null; then
        log_warn "starship already installed"
        return
    fi
    log_step "Installing starship..."
    curl -sS https://starship.rs/install.sh -o /tmp/starship-install.sh
    sh /tmp/starship-install.sh -y >/dev/null 2>&1
    rm -f /tmp/starship-install.sh
    log_success "starship installed"
}

install_uv() {
    if command -v uv &>/dev/null; then
        log_warn "uv already installed"
        return
    fi
    log_step "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh
    bash /tmp/uv-install.sh >/dev/null 2>&1
    rm -f /tmp/uv-install.sh
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
        log_warn "~/.local/bin added to PATH (restart shell required)"
    fi
    log_success "uv installed"
}

install_nvim_config() {
    if [[ -d "$NVIM_CONFIG_DIR" ]]; then
        log_warn "Neovim config already exists — skipping"
        return
    fi

    log_step "Cloning NvChad configuration..."
    git clone "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR" >/dev/null 2>&1
    log_success "NvChad installed"
}

sync_configs() {
    [[ ! -d "$SCRIPT_DIR/.config" ]] && return
    log_step "Syncing .config directory..."
    rsync -a "$SCRIPT_DIR/.config/" "$HOME/.config/" >/dev/null 2>&1
    log_success ".config synced"
}

handle_local_directory() {
    [[ ! -d "$SCRIPT_DIR/.local" ]] && return
    echo
    read -rp "Sync .local directory? (y/n): " choice
    [[ "$choice" =~ ^[yY] ]] || return
    log_step "Syncing .local directory..."
    rsync -a "$SCRIPT_DIR/.local/" "$HOME/.local/" >/dev/null 2>&1
    log_success ".local synced"
}

setup_starship_prompt() {
    log_step "Configuring fish shell prompt..."
    mkdir -p "$(dirname "$FISH_CONFIG")"
    grep -q "starship init fish" "$FISH_CONFIG" 2>/dev/null || \
    echo 'starship init fish | source' >> "$FISH_CONFIG"
    log_success "Fish prompt configured"
}


# ========== MAIN ==========
main() {
    check_root_notice
    check_internet
    enable_universe_repo
    system_update
    install_packages
    install_starship
    install_uv
    install_nvim_config
    sync_configs
    handle_local_directory
    setup_starship_prompt

    echo
    echo -e "${GREEN}======================================================${RESET}"
    echo -e "${GREEN}[✓] Ubuntu setup complete.${RESET}"
    echo -e "${CYAN}Log saved to:${RESET} $LOG_FILE"
    echo -e "${GREEN}======================================================${RESET}"
}

main