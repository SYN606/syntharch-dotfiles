#!/bin/bash


GREEN="\e[38;2;119;221;119m"   
RED="\e[38;2;255;105;97m"      
YELLOW="\e[38;2;253;253;150m"  
CYAN="\e[38;2;176;224;230m"    
NC="\e[0m"



function info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
function success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
function error()   { echo -e "${RED}[ERROR]${NC} $1"; }
function warn()    { echo -e "${YELLOW}[WARNING]${NC} $1"; }


# ─── Intro ────────────────────────────────────────
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════╗"
echo "║         DARK ARCH - Pentesting Toolkit       ║"
echo "║     Custom Fish Shell Dotfiles Installer      ║"
echo "║                                              ║"
echo "║           Developed by: syn 606               ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"


echo -e "${YELLOW}This script installs the BlackArch repository and essential penetration testing tools for Fish shell users.${NC}"


# ─── Step 1: Check BlackArch ─────────────────────
info "Verifying if BlackArch repository is enabled..."


if ! pacman -Sgq blackarch >/dev/null 2>&1; then
    warn "BlackArch repository not found. Downloading strap.sh script..."
    
    curl -O https://blackarch.org/strap.sh
    
    echo "bbf0a0b838aed0ec05fff2d375dd17591cbdf8aa  strap.sh" | sha1sum -c - || {
        error "SHA1 checksum verification failed. Aborting installation."
        exit 1
    }
    
    chmod +x strap.sh
    sudo ./strap.sh
    
    success "BlackArch repository successfully added."
else
    success "BlackArch repository is already present."
fi


# ─── Step 2: Define Package List ─────────────────────
PACKAGES=(
    # Core Tools
    bettercap bettercap-caplets nmap metasploit wireshark-cli
    
    # Wireless Attacks
    wifite reaver bully cowpatty pyrit macchanger hcxdumptool hcxtools
    
    # Cracking & Brute Forcing
    hashcat john hydra medusa
    
    # Recon / OSINT
    theharvester recon-ng subfinder amas masscan
    
    # Web Application Testing
    sqlmap ffuf gobuster wfuzz nikto xsstrike
    
    # Phishing / Social Engineering
    blackarch/gophish blackarch/gophish-debug
    
    # Exploits / Databases
    exploitdb
    
    # DNS / Subdomain Enumeration
    dnsrecon dnsenum sublist3r
    
    # Utility / Networking
    netcat socat
    
    # Optional Post-Exploitation Tools
    empire sliver veil
)


# ─── Step 3: Install Tools ───────────────────────
info "Starting installation of DARK ARCH pentesting tools..."
if sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"; then
    success "All specified tools have been installed successfully."
else
    error "Installation completed with some errors. Please check the output for details."
fi


# ─── Completion ─────────────────────────────────────
echo -e "${GREEN}[SUCCESS]${NC} ${CYAN}DARK ARCH setup is complete. Please verify tool functionality as needed.${NC}"
