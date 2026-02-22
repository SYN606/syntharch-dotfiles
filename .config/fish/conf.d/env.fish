# Disable virtualenv prompt pollution
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1

# Ensure SHELL reflects actual fish path (without hardcoding)
if type -q fish
    set -gx SHELL (command -v fish)
end

# Use bat/batcat for manpages when available
if type -q bat
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
else if type -q batcat
    set -gx MANPAGER "sh -c 'col -bx | batcat -l man -p'"
else
    set -gx MANPAGER less
end

# User-local binaries
fish_add_path ~/.local/bin