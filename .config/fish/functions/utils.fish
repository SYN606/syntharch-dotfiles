# System diagnostics helpers
function jctl --description "Show recent journalctl errors"
    set -l lines (or $argv[1] 50)
    journalctl -p 3 -xb -n $lines
end

# Update GRUB configuration
function grubup --description "Update GRUB config"
    sudo update-grub
end

# Remove pacman database lock safely
function fixpacman --description "Remove pacman db lock"
    if test -f /var/lib/pacman/db.lck
        sudo rm /var/lib/pacman/db.lck
        echo "Pacman lock removed."
    else
        echo "No pacman lock found."
    end
end

# List recently installed packages
function rip --description "Recently installed packages"
    set -l count (or $argv[1] 200)
    expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" \
        | sort -k1,1 | tail -n $count | nl
end

# Clear pacman cache interactively
function cls-cache --description "Clear pacman cache"
    read -l -P "Clear all cached packages? (y/N) " confirm
    test "$confirm" = y; or return
    yes | sudo pacman -Scc
end

# Remove orphaned packages
function orphans --description "Remove orphaned packages"
    set -l ops (pacman -Qdtq)
    if test -n "$ops"
        echo "Removing orphan packages:"
        echo $ops
        sudo pacman -Rns $ops
        sudo pacman -Sc
    else
        echo "No orphaned packages found."
    end
end

# Update pacman mirrorlist using reflector
function mirrors --description "Update pacman mirrorlist"
    sudo reflector --verbose --country India \
        --sort rate -l 20 \
        --save /etc/pacman.d/mirrorlist
end

# Create compressed tar archive
function tarnow --description "Create tar.gz archive"
    if test (count $argv) -lt 2
        echo "Usage: tarnow <archive.tar.gz> <files...>"
        return 1
    end
    tar -acf $argv
end

# Extract compressed tar archive
function untar --description "Extract tar.gz archive"
    if test (count $argv) -eq 0
        echo "Usage: untar <file.tar.gz>"
        return 1
    end
    tar -xvzf $argv
end
