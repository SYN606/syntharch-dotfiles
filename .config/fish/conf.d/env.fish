# Disable virtualenv prompt pollution
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1

# Set default shell
set -gx SHELL /usr/bin/fish

# Use bat for manpages when available
if type -q bat
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
else
    set -gx MANPAGER less
end

# User-local binaries
fish_add_path ~/.local/bin
