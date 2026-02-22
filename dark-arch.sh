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
echo "║         DARK UBUNTU - Pentesting Toolkit    ║"
echo "║        Curated Security Environment         ║"
echo "║                                              ║"
echo "║           Developed by: syn 606              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}This script installs a curated set of penetration testing tools for Ubuntu/Debian systems.${NC}"

# ─── Pre-flight Checks ─────────────────────────────
info "Checking internet connectivity..."
ping -q -c 1 google.com &>/dev/null || {
    error "No internet connection detected."
    exit 1
}

if [[ "$EUID" -eq 0 ]]; then
    warn "Running as root. Script is designed to use sudo."
fi

# ─── Update System ────────────────────────────────
info "Updating system..."
sudo apt update
sudo apt upgrade -y

# ─── Base Dependencies ─────────────────────────────
info "Installing base dependencies..."
sudo apt install -y \
    curl wget git build-essential \
    software-properties-common \
    ca-certificates gnupg lsb-release \
    python3 python3-pip python3-venv pipx

# Enable pipx globally
pipx ensurepath

# ─── Core Security Tools (APT) ─────────────────────
APT_PACKAGES=(
    nmap
    metasploit-framework
    wireshark
    aircrack-ng
    reaver
    bully
    hashcat
    john
    hydra
    medusa
    theharvester
    recon-ng
    amass
    masscan
    sqlmap
    gobuster
    wfuzz
    nikto
    dnsrecon
    dnsenum
    netcat-openbsd
    socat
    exploitdb
)

info "Installing core pentesting tools..."
sudo apt install -y "${APT_PACKAGES[@]}"

# ─── Tools via pipx (cleaner isolation) ───────────
info "Installing Python-based tools..."
pipx install subfinder || true
pipx install xsstrike || true
pipx install sublist3r || true
pipx install ffuf || true

# ─── Optional: Sliver C2 ───────────────────────────
info "Installing Sliver C2..."
curl -fsSL https://sliver.sh/install | sudo bash || warn "Sliver install failed."

# ─── Wireshark Permissions Fix ─────────────────────
info "Configuring Wireshark permissions..."
sudo usermod -aG wireshark "$USER"

# ─── Enable Services ───────────────────────────────
info "Enabling PostgreSQL for Metasploit..."
sudo systemctl enable postgresql
sudo systemctl start postgresql

# ─── Cleanup ───────────────────────────────────────
info "Cleaning unused packages..."
sudo apt autoremove -y

# ─── Completion ────────────────────────────────────
echo
success "DARK UBUNTU setup complete."
echo -e "${CYAN}Log out and back in to apply group changes (wireshark). Reboot recommended if kernel updated.${NC}"