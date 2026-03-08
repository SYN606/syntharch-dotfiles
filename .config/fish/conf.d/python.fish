# --------------------------------
# Python virtual environment helpers (Fish + Ubuntu)
# Uses uv if available, otherwise falls back to pip
# --------------------------------

set -g PY_VENV_NAME ".venv"

# Create virtual environment
function mkvenv --description "Create Python virtual environment"
    if test -d $PY_VENV_NAME
        echo "Virtual environment '$PY_VENV_NAME' already exists."
        return 1
    end

    if type -q uv
        echo "Creating venv using uv..."
        uv venv $PY_VENV_NAME; or return 1
    else
        if not type -q python
            echo "Python not found."
            return 1
        end

        echo "Creating venv using python..."
        python -m venv $PY_VENV_NAME; or return 1
    end

    echo "Virtual environment '$PY_VENV_NAME' created."
end


# Activate virtual environment
function acvt --description "Activate Python virtual environment"
    set -l activate_file "$PY_VENV_NAME/bin/activate.fish"

    if not test -f $activate_file
        echo "Activation script not found: $activate_file"
        echo "Did you run mkvenv?"
        return 1
    end

    source $activate_file
    echo "Activated virtual environment '$PY_VENV_NAME'."
end


# Initialize project using uv
function initproj --description "Initialize Python project with uv"
    if not type -q uv
        echo "uv is required for project initialization."
        return 1
    end

    if test -f pyproject.toml
        echo "Project already initialized."
        return 1
    end

    uv init .; or return 1

    # remove template file if created
    if test -f main.py
        rm main.py
    end

    echo "Python project initialized."
end


# Install package(s)
function installpkg --description "Install Python package(s)"
    if test (count $argv) -eq 0
        echo "Usage: installpkg <package> [package...]"
        return 1
    end

    if type -q uv
        uv add $argv; or return 1
    else
        pip install $argv; or return 1
    end

    echo "Package(s) installed: $argv"
end


# Remove package(s)
function removepkg --description "Remove Python package(s)"
    if test (count $argv) -eq 0
        echo "Usage: removepkg <package> [package...]"
        return 1
    end

    if type -q uv
        uv remove $argv; or return 1
    else
        pip uninstall -y $argv; or return 1
    end

    echo "Package(s) removed: $argv"
end


# Export requirements
function exportreq --description "Export requirements.txt"
    set -l outfile "requirements.txt"

    if test (count $argv) -ge 1
        set outfile $argv[1]
    end

    if not set -q VIRTUAL_ENV
        echo "No active virtual environment."
        echo "Run: acvt"
        return 1
    end

    if type -q uv
        uv pip freeze > $outfile; or return 1
    else
        pip freeze > $outfile; or return 1
    end

    echo "Requirements exported to '$outfile'."
end


# Remove virtual environment
function rmvenv --description "Remove Python virtual environment"
    set -l env_name $PY_VENV_NAME

    if test (count $argv) -ge 1
        set env_name $argv[1]
    end

    if not test -d $env_name
        echo "Virtual environment '$env_name' does not exist."
        return 1
    end

    rm -rf $env_name
    echo "Virtual environment '$env_name' removed."
end