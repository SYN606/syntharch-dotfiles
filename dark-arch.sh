#!/bin/bash

# Color codes
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
NC="\033[0m"

# Output helpers
function info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
function success() { echo -e "${GREEN}[✔]${NC} $1"; }
function error()   { echo -e "${RED}[✘]${NC} $1"; }
function warn()    { echo -e "${YELLOW}[!]${NC} $1"; }

# ─── Intro ────────────────────────────────────────
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════╗"
echo "║       DARK ARCH - Pentesting Environment     ║"
echo "║     Custom Fish Shell Dotfiles Installer     ║"
echo "║                                              ║"
echo "║        Developed by: syn 606                 ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}This script installs BlackArch repository and essential penetration testing tools for Fish shell users.${NC}"

# ─── Step 1: Check BlackArch ─────────────────────
info "Checking if BlackArch repository is enabled..."

if ! pacman -Sgq blackarch >/dev/null 2>&1; then
    warn "BlackArch repo not found. Downloading strap.sh..."
    
    curl -O https://blackarch.org/strap.sh
    
    echo "bbf0a0b838aed0ec05fff2d375dd17591cbdf8aa  strap.sh" | sha1sum -c - || {
        error "SHA1 checksum failed! Aborting setup."
        exit 1
    }
    
    chmod +x strap.sh
    sudo ./strap.sh
    
    success "BlackArch repository added successfully!"
else
    success "BlackArch repository is already enabled."
fi

# ─── Step 2: Package List ────────────────────────
PACKAGES=(
    # Core Tools
    bettercap bettercap-caplets nmap metasploit wireshark-cli
    
    # Wireless Attacks
    wifite reaver bully cowpatty pyrit macchanger hcxdumptool hcxtools
    
    # Cracking & Brute Forcing
    hashcat john hydra medusa
    
    # Recon / OSINT
    theharvester recon-ng subfinder amas masscan
    
    # Web App Testing
    sqlmap ffuf gobuster wfuzz nikto xsstrike
    
    # Phishing / Social Engineering
    blackarch/gophish blackarch/gophish-debug
    
    # Exploits / Databases
    exploitdb
    
    # DNS / Subdomain Tools
    dnsrecon dnsenum sublist3r
    
    # Utility / Networking
    netcat socat
    
    # Optional Post-Exploitation
    empire sliver veil
)

# ─── Step 3: Install Tools ───────────────────────
info "Installing DARK ARCH pentesting tools..."
sudo pacman -S --noconfirm --needed "${PACKAGES[@]}" && \
success "All tools successfully installed." || \
error "Some packages may have failed to install."

# ─── Done ────────────────────────────────────────
echo -e "${GREEN}[✔]${NC} ${CYAN}DARK ARCH setup complete. Happy hacking, syn 606!${NC}"
