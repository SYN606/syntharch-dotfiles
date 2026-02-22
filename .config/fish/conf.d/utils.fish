# System diagnostics helpers (Ubuntu/Debian)

# Show recent journalctl errors
function jctl --description "Show recent journalctl errors"
    set -l lines 50
    test (count $argv) -ge 1; and set lines $argv[1]
    journalctl -p 3 -xb -n $lines
end

# Update GRUB configuration
function grubup --description "Update GRUB config"
    sudo update-grub
end

# Fix dpkg lock issues safely
function fixapt --description "Fix APT/dpkg lock"
    if pgrep -x apt >/dev/null; or pgrep -x dpkg >/dev/null
        echo "APT or dpkg is currently running. Wait before fixing."
        return 1
    end

    if test -f /var/lib/dpkg/lock-frontend
        sudo rm /var/lib/dpkg/lock-frontend
        sudo rm -f /var/lib/dpkg/lock
        sudo dpkg --configure -a
        echo "APT lock cleared and dpkg configured."
    else
        echo "No APT lock found."
    end
end

# List recently installed packages
function rip --description "Recently installed packages"
    set -l count 200
    test (count $argv) -ge 1; and set count $argv[1]

    grep " install " /var/log/dpkg.log \
        | tail -n $count \
        | awk '{print $1, $2, $4}' \
        | nl
end

# Clean APT cache interactively
function cls-cache --description "Clear APT cache"
    read -l -P "Clear all cached packages? (y/N) " confirm
    test "$confirm" = y; or return
    sudo apt clean
    echo "APT cache cleared."
end

# Remove orphaned packages (unused dependencies)
function orphans --description "Remove orphaned packages"
    sudo apt autoremove
end

# Update package lists
function mirrors --description "Update APT package lists"
    sudo apt update
end

# Create compressed tar archive
function tarnow --description "Create tar.gz archive"
    if test (count $argv) -lt 2
        echo "Usage: tarnow <archive.tar.gz> <files...>"
        return 1
    end
    tar -czvf $argv
end

# Extract compressed tar archive
function untar --description "Extract tar.gz archive"
    if test (count $argv) -eq 0
        echo "Usage: untar <file.tar.gz>"
        return 1
    end
    tar -xvzf $argv
end