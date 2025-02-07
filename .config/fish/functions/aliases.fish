alias ls 'eza -al --color=always --group-directories-first --icons'
alias ld 'eza -D --color=always --group-directories-first --icons'
alias ll 'eza -l --color=always --group-directories-first --icons'
alias l. 'eza -ald --color=always --group-directories-first --icons .*'
alias cat 'bat --style header --style snip --style changes --style header'

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
alias getpkg 'pls pacman -S --needed'
alias aurget 'yay -S'
alias rmpkg 'pls pacman -Rns'
alias update 'pls pacman -Syu'
alias btop 'btop --utf-force'

alias cls-hist 'builtin history clear'

function cls-cache --description "Clear pacman cache"
    yes | pls pacman -Scc
end

function mirrors --description "Update mirrors with the fastest ones"
    pls reflector --verbose --sort rate -l 20 --save /etc/pacman.d/mirrorlist
end

function orphans --description "Check and remove orphan packages"
    while pacman -Qdtq
        sudo pacman -R (pacman -Qdtq)
        pls pacman -Sc
    end
end

alias venv 'python -m venv env'
alias acvt 'source env/bin/activate.fish'

alias fastfetch 'fastfetch --colors-block-range-start 9 --colors-block-width 3'

