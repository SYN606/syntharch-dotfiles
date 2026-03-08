# System diagnostics helpers (Ubuntu/Debian)

# Show recent journalctl errors
function jctl --description "Show recent journalctl errors"
    set -l lines 50
    if test (count $argv) -ge 1
        set lines $argv[1]
    end

    journalctl -p err -xb -n $lines --no-pager
end


# Update GRUB configuration
function grubup --description "Update GRUB config"
    sudo update-grub
end


# Fix dpkg lock issues safely
function fixapt --description "Fix APT/dpkg lock safely"
    if pgrep -fa "apt|dpkg|unattended-upgrade" >/dev/null
        echo "APT or dpkg is currently running. Wait before fixing."
        return 1
    end

    if fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1
        echo "Lock file is still in use."
        return 1
    end

    sudo rm -f /var/lib/dpkg/lock-frontend
    sudo rm -f /var/lib/dpkg/lock

    sudo dpkg --configure -a

    echo "APT lock cleared and dpkg configured."
end


# List recently installed packages
function rip --description "Recently installed packages"
    set -l count 200
    if test (count $argv) -ge 1
        set count $argv[1]
    end

    zgrep " install " /var/log/dpkg.log* \
        | tail -n $count \
        | awk '{print $1, $2, $4}' \
        | nl
end


# Clean APT cache interactively
function cls-cache --description "Clear APT cache"
    read -l -P "Clear all cached packages? (y/N) " confirm

    if test (string lower $confirm) != y
        echo "Cancelled."
        return
    end

    sudo apt clean
    echo "APT cache cleared."
end


# Remove orphaned packages
function orphans --description "Remove orphaned packages"
    sudo apt autoremove
end


# Update package lists
function aptup --description "Update APT package lists"
    sudo apt update
end


# Create compressed tar archive
function tarnow --description "Create tar.gz archive"
    if test (count $argv) -lt 2
        echo "Usage: tarnow <archive.tar.gz> <files...>"
        return 1
    end

    set archive $argv[1]
    set files $argv[2..-1]

    tar -czvf $archive $files
end


# Extract tar archive (auto-detect compression)
function untar --description "Extract tar archive"
    if test (count $argv) -eq 0
        echo "Usage: untar <archive>"
        return 1
    end

    tar -xvf $argv
end