#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ─── Colors ────────────────────────────────────────
GREEN="\e[38;2;119;221;119m"
RED="\e[38;2;255;105;97m"
YELLOW="\e[38;2;253;253;150m"
CYAN="\e[38;2;176;224;230m"
NC="\e[0m"

info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARNING]${NC} $1"; }

trap 'error "Script failed at line $LINENO"' ERR

# ─── Intro ─────────────────────────────────────────
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════╗"
echo "║         DARK ARCH - Pentesting Toolkit       ║"
echo "║        BlackArch Bootstrap & Installer       ║"
echo "║                                              ║"
echo "║           Developed by: syn 606              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}This script installs the official BlackArch repository and a curated set of penetration testing tools.${NC}"

# ─── Pre-flight Checks ─────────────────────────────
info "Checking internet connectivity..."
ping -q -c 1 blackarch.org &>/dev/null || {
    error "No internet connection detected."
    exit 1
}

if [[ "$EUID" -eq 0 ]]; then
    warn "Running as root. Script is designed to use sudo."
fi

# ─── Enable multilib (official requirement) ───────
info "Checking multilib repository..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    warn "Multilib is disabled. Enabling it (required by BlackArch)..."
    sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    sudo pacman -Sy
else
    success "Multilib already enabled."
fi

# ─── Check BlackArch Repo ──────────────────────────
info "Verifying BlackArch repository..."
if ! pacman -Sgq blackarch &>/dev/null; then
    warn "BlackArch repository not found. Installing via strap.sh..."
    
    TMP_DIR="$(mktemp -d)"
    pushd "$TMP_DIR" >/dev/null
    
    curl -fsSLO https://blackarch.org/strap.sh
    
    info "Verifying strap.sh SHA1 checksum..."
    echo "00688950aaf5e5804d2abebb8d3d3ea1d28525ed  strap.sh" | sha1sum -c -
    
    chmod +x strap.sh
    sudo ./strap.sh
    
    popd >/dev/null
    rm -rf "$TMP_DIR"
    
    success "BlackArch repository successfully installed."
else
    success "BlackArch repository already present."
fi

# ─── Mandatory System Upgrade (Official) ───────────
info "Performing full system upgrade (required by BlackArch)..."
sudo pacman -Syu --noconfirm

# ─── Package List ──────────────────────────────────
PACKAGES=(
    # Core
    bettercap bettercap-caplets nmap metasploit wireshark-cli
    
    # Wireless
    wifite reaver bully cowpatty pyrit macchanger hcxdumptool hcxtools
    
    # Cracking
    hashcat john hydra medusa
    
    # Recon / OSINT
    theharvester recon-ng subfinder amass masscan
    
    # Web
    sqlmap ffuf gobuster wfuzz nikto xsstrike
    
    # Phishing / SE
    gophish gophish-debug
    
    # Exploits
    exploitdb
    
    # DNS
    dnsrecon dnsenum sublist3r
    
    # Utilities
    openbsd-netcat socat
    
    # Post-exploitation
    empire sliver veil
)

# ─── Install Tools ─────────────────────────────────
info "Installing DARK ARCH pentesting tools..."
if sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"; then
    success "All specified tools installed successfully."
else
    warn "Some tools failed to install. Review pacman output."
fi

# ─── Completion ────────────────────────────────────
echo
success "DARK ARCH setup complete."
echo -e "${CYAN}Verify tools individually and reboot if kernel or core libs were updated.${NC}"
