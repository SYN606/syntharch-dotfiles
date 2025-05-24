# Disable Fish greeting
set fish_greeting

# Virtual Environment Prompt Disable
set VIRTUAL_ENV_DISABLE_PROMPT "1"

# Set Shell
set -x SHELL /usr/bin/fish

# Manpager: Use bat for colored manual pages
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Add ~/.local/bin to PATH if not already included
if test -d ~/.local/bin
    if not contains ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Load Git aliases from a separate file
if test -f ~/.config/fish/functions/git.fish
    source ~/.config/fish/functions/git.fish
end

# Load Aliases from a separate file
if test -f ~/.config/fish/functions/aliases.fish
    source ~/.config/fish/functions/aliases.fish
end

# Starship Prompt Initialization
starship init fish | source

