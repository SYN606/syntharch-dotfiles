# ─────────────────────────────
# 📁 NAVIGATION
# ─────────────────────────────
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'

# ─────────────────────────────
# 📂 FILE LISTING (EZA)
# ─────────────────────────────
alias ls 'eza -al --color=always --group-directories-first --icons'
alias ld 'eza -D --color=always --group-directories-first --icons'
alias ll 'eza -l --color=always --group-directories-first --icons'
alias l. 'eza -ald --color=always --group-directories-first --icons .*'

# ─────────────────────────────
# 🐱 FILE VIEWING
# ─────────────────────────────
alias cat 'bat --style=header,snip,changes'

# ─────────────────────────────
# 🔍 SYSTEM UTILITIES
# ─────────────────────────────
alias grep 'ugrep --color=always'
alias hw 'hwinfo --short'

function jctl
    set lines (or $argv[1] 50)
    journalctl -p 3 -xb -n $lines
end

function grubup
    sudo update-grub
end

function fixpacman
    if test -f /var/lib/pacman/db.lck
        sudo rm /var/lib/pacman/db.lck
        echo "Pacman lock removed."
    else
        echo "No pacman lock found."
    end
end

function rip
    set count (or $argv[1] 200)
    expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" | sort -k1,1 | tail -$count | nl
end

# ─────────────────────────────
# 📦 PACKAGE MANAGEMENT
# ─────────────────────────────
alias pls sudo
alias please sudo
alias update 'pls pacman -Syu'
alias getpkg 'pls pacman -S --needed'
alias rmpkg 'pls pacman -Rns'
alias search 'yay -Ss'
alias aurget 'yay -S'

# ─────────────────────────────
# 🧹 SYSTEM CLEANING
# ─────────────────────────────
function cls-cache --description "Clear pacman cache"
    read -l -p "Clear all cached packages? (y/N) " confirm
    if test "$confirm" = y
        yes | pls pacman -Scc
    else
        echo "❌ Cancelled."
    end
end

function orphans --description "Remove orphaned packages"
    set ops (pacman -Qdtq)
    if test -n "$ops"
        echo "Removing orphan packages:"
        echo "$ops"
        sudo pacman -Rns $ops
        pls pacman -Sc
    else
        echo "✅ No orphans found."
    end
end

function mirrors --description "Update mirror list to fastest servers"
    pls reflector --verbose --country India --sort rate -l 20 --save /etc/pacman.d/mirrorlist
end

# ─────────────────────────────
# 💻 SYSTEM MONITORING
# ─────────────────────────────
alias psmem 'ps auxf | sort -nr -k 4'
alias psmem10 'ps auxf | sort -nr -k 4 | head -10'
alias big 'expac -H M "%m\t%n" | sort -h | nl'
alias btop 'btop --force-utf'

# MISC UTILITIES
alias wget 'wget -c'

function tarnow --description "Create tar.gz archive from files"
    if test (count $argv) -lt 2
        echo "Usage: tarnow <archive-name.tar.gz> <file(s)>"
        return 1
    end
    tar -acf $argv
end

function untar --description "Extract .tar.gz file"
    if test (count $argv) -eq 0
        echo "Usage: untar <file.tar.gz>"
        return 1
    end
    tar -xvzf $argv
end

# 🧼 HISTORY MANAGEMENT
alias cls-hist 'builtin history clear'
alias cls clear

# 🎨 SHELL GREETING (optional)
function fish_greeting
    fastfetch
end
