# Disable Fish greeting
set -g fish_greeting ""

# Disable virtual env prompt
set -x VIRTUAL_ENV_DISABLE_PROMPT 1

# Set default shell
set -x SHELL /usr/bin/fish

# Use bat for colored manpages (fallback to less if bat not available)
if type -q bat
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
else
    set -x MANPAGER less
end

# Add ~/.local/bin to PATH if it exists and not already present
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -gx PATH ~/.local/bin $PATH
    end
end

# Load tools if available
if test -f ~/.config/fish/functions/tools.fish
    source ~/.config/fish/functions/tools.fish
end

# Load Git aliases if available
if test -f ~/.config/fish/functions/git.fish
    source ~/.config/fish/functions/git.fish
end

# Load general aliases if available
if test -f ~/.config/fish/functions/aliases.fish
    source ~/.config/fish/functions/aliases.fish
end

# Load GPU config if available
if test -f ~/.config/fish/functions/gpu.fish
    source ~/.config/fish/functions/gpu.fish
end

# Starship prompt initialization
if type -q starship
    starship init fish | source
end
