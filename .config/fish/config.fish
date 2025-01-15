set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT "1"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -x SHELL /usr/bin/fish

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Starship prompt
starship init fish | source

# Useful aliases
alias ls 'eza -al --color=always --group-directories-first --icons'
alias la 'eza -a --color=always --group-directories-first --icons'
alias ll 'eza -l --color=always --group-directories-first --icons'
alias lt 'eza -aT --color=always --group-directories-first --icons'
alias l. 'eza -ald --color=always --group-directories-first --icons .*'
alias cat 'bat --style header --style snip --style changes --style header'

if not test -x /usr/bin/yay; and test -x /usr/bin/paru
    alias yay 'paru'
end

alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias big 'expac -H M "%m\t%n" | sort -h | nl'
alias fixpacman 'sudo rm /var/lib/pacman/db.lck'
alias gitpkg 'pacman -Q | grep -i "\-git" | wc -l'
alias grep 'ugrep --color=auto'
alias grubup 'sudo update-grub'
alias hw 'hwinfo --short'
alias ip 'ip -color'
alias psmem 'ps auxf | sort -nr -k 4'
alias psmem10 'ps auxf | sort -nr -k 4 | head -10'
alias tarnow 'tar -acf '
alias untar 'tar -zxvf '
alias wget 'wget -c '


alias pacdiff 'sudo -H DIFFPROG=meld pacdiff'
alias jctl 'journalctl -p 3 -xb'
alias rip 'expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" | sort | tail -200 | nl'


alias pls 'sudo'
alias search 'yay -Ss'
alias getpkg 'pls pacman -S'
alias aurget 'yay -S'
alias rmpkg 'pls pacman -Rns'
alias update 'eos-update'
alias btop 'btop --utf-force'


function mirrors --description 'Update the mirros as the fastest'
    pls reflector --verbose --sort rate -l 20 --save /etc/pacman.d/mirrorlist

end

function orphans --description 'Checks the orphan packages and removes it'
    while pacman -Qdtq
        sudo pacman -R (pacman -Qdtq)
        pls pacman -Sc
    end
end

alias venv 'python -m venv env'
alias acvt 'source env/bin/activate.fish'

# fastfetch
alias fastfetch 'fastfetch --colors-block-range-start 9 --colors-block-width 3'
fastfetch

function cpp
    set -e
    set total_size (stat -c '%s' $argv[1])
    set count 0

    strace -q -ewrite cp -- $argv[1] $argv[2] 2>&1 | while read line
        set count (math $count + (echo $line | awk '{print $NF}'))

        if math $count % 10 -eq 0
            set percent (math $count / $total_size * 100)
            printf "%3d%% [" $percent
            for i in (seq 1 $percent)
                printf "="
            end
            printf ">"
            for i in (seq $percent 100)
                printf " "
            end
            printf "]\r"
        end
    end
    echo ""
end

# Create and go to the directory
function mkdirg
    mkdir -p $argv[1]
    cd $argv[1]
end


# extract every archive using ark
function extract
    set archive $argv[1]
    set target_dir (count $argv) > 1 ? $argv[2] : "."

    if test -f $archive
        7z x $archive -o$target_dir
        if test $status -eq 0
            echo "Extraction completed successfully to '$target_dir'"
        else
            echo "Failed to extract '$archive'"
        end
    else
        echo "'$archive' is not a valid file!"
    end
end


# archive function using 7z
function archive --description 'add files and output name with extension.'
    if test (count $argv) -lt 1
        echo "Usage: archive <file_or_directory> [archive_name]"
        return 1
    end

    set target $argv[1]
    set archive_name (count $argv) > 1 ? $argv[2] : "archive.zip"

    # If * is used, select all files in the current directory
    if test $target = '*'
        set target (ls)
    end

    # Create the archive
    if test -e $target[1]
        7z a $archive_name $target
        if test $status -eq 0
            echo "Archive created successfully: '$archive_name'"
        else
            echo "Failed to create archive for '$target'"
        end
    else
        echo "'$target' does not exist!"
    end
end



# copy and go to the directory
function cpg
    if test -d $argv[2]
        cp $argv[1] $argv[2]
        cd $argv[2]
    else
        cp $argv[1] $argv[2]
    end
end

# Move and go to the directory
function mvg
    if test -d $argv[2]
        mv $argv[1] $argv[2]
        cd $argv[2]
    else
        mv $argv[1] $argv[2]
    end
end

