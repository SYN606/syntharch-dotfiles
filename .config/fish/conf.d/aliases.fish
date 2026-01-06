# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# File Listing (EZA)
alias ls='eza -al --group-directories-first --icons'
alias ld='eza -D --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons'
alias l.='eza -ald --group-directories-first --icons .*'

# File Viewing
alias cat='bat --style=header,snip,changes'

# Utilities
alias grep='ugrep --color=always'
alias hw='hwinfo --short'

# Package Management (safe)
alias update='sudo pacman -Syu'
alias getpkg='sudo pacman -S --needed'
alias rmpkg='sudo pacman -Rns'
alias search='yay -Ss'
alias aurget='yay -S'

# Monitoring
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias big='expac -H M "%m\t%n" | sort -h | nl'
alias btop='btop --force-utf'

# Misc
alias wget='wget -c'
alias cls='clear'
alias cls-hist='builtin history clear'
