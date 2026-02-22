# =========================
# Navigation
# =========================
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# =========================
# File Listing (eza)
# =========================
alias ls="eza -al --group-directories-first --icons"
alias ld="eza -D --group-directories-first --icons"
alias ll="eza -l --group-directories-first --icons"
alias l.="eza -ald --group-directories-first --icons .*"

# =========================
# File Viewing
# =========================
alias cat="batcat --style=header,snip,changes"
alias bat="batcat"

# =========================
# Utilities
# =========================
alias grep="ugrep --color=always"
alias hw="hwinfo --short"

# =========================
# Package Management (APT)
# =========================
alias update="sudo apt update; and sudo apt upgrade -y"
alias getpkg="sudo apt install"
alias rmpkg="sudo apt remove --purge"
alias autoremove="sudo apt autoremove -y"
alias search="apt search"

# =========================
# Monitoring
# =========================
alias psmem="ps auxf | sort -nr -k 4"
alias psmem10="ps auxf | sort -nr -k 4 | head -10"
alias btop="btop --force-utf"

# =========================
# Large Installed Packages (Fish-safe function)
# =========================
function big
    dpkg-query -Wf='${Installed-Size}\t${Package}\n' \
    | sort -n \
    | awk '{ printf "%.1fM\t%s\n", $1/1024, $2 }' \
    | nl
end

# =========================
# Misc
# =========================
alias wget="wget -c"
alias cls="clear"

function cls-hist
    history clear
end