# ─────────────────────────────
# PYTHON DEV TOOLS (Fish + UV)
# ─────────────────────────────

# Create a virtual environment (uv preferred, pip fallback)
function mkvenv --description "Create Python virtualenv"
    set env_name .venv

    if test -d $env_name
        echo "Virtual environment '$env_name' already exists."
        return 1
    end

    if type -q uv
        uv venv
        echo "Virtual environment '$env_name' created using uv."
    else
        python -m venv $env_name
        echo "uv not found. Virtual environment '$env_name' created using python -m venv."
    end
end

# Activate virtual environment
function acvt --description "Activate virtualenv"
    set env_name .venv

    if test -f $env_name/bin/activate.fish
        source $env_name/bin/activate.fish
        echo "Activated virtual environment '$env_name'."
    else
        echo "Activation script not found for '$env_name'."
    end
end

# Initialize project (pyproject.toml) using uv
function initproj --description "Initialize Python project (pyproject.toml)"
    if test (count $argv) -ge 1
        set project_name $argv[1]
    else
        set project_name (basename (pwd))
    end

    if type -q uv
        uv init .
        echo "Project '$project_name' initialized using uv."

        # Remove unwanted main.py
        if test -f main.py
            rm main.py
            echo "Removed default main.py."
        end
    else
        echo "uv not found. No fallback available for init."
    end
end

# Install a package and update pyproject.toml
function installpkg --description "Install package"
    if test (count $argv) -eq 0
        echo "Please provide a package name."
        return 1
    end

    set pkg $argv[1]
    if type -q uv
        uv add $pkg
        echo "Package '$pkg' installed with uv."
    else
        pip install $pkg
        echo "uv not found. Package '$pkg' installed with pip."
    end
end

# Remove a package
function removepkg --description "Remove package"
    if test (count $argv) -eq 0
        echo "Please provide a package name."
        return 1
    end

    set pkg $argv[1]
    if type -q uv
        uv remove $pkg
        echo "Package '$pkg' removed with uv."
    else
        pip uninstall -y $pkg
        echo "uv not found. Package '$pkg' removed with pip."
    end
end

# Export requirements.txt
function exportreq --description "Export requirements.txt"
    if test (count $argv) -ge 1
        set file $argv[1]
    else
        set file requirements.txt
    end

    if set -q VIRTUAL_ENV
        if type -q uv
            uv pip freeze > $file
            echo "Requirements exported to '$file' using uv."
        else
            pip freeze > $file
            echo "Requirements exported to '$file' using pip."
        end
    else if test -f .venv/bin/activate.fish
        source .venv/bin/activate.fish
        pip freeze > $file
        echo "Requirements exported to '$file' using pip after activating .venv."
    else
        echo "No active virtual environment. Please activate one first."
    end
end

# Remove virtual environment
function rmvenv --description "Remove virtualenv"
    if test (count $argv) -ge 1
        set env_name $argv[1]
    else
        set env_name .venv
    end

    if type -q uv
        # uv doesn’t directly remove venvs by name, so fallback to rm -rf
        if test -d $env_name
            rm -rf $env_name
            echo "Virtual environment '$env_name' removed."
        else
            echo "Virtual environment '$env_name' does not exist."
        end
    else
        if test -d $env_name
            rm -rf $env_name
            echo "Virtual environment '$env_name' removed."
        else
            echo "Virtual environment '$env_name' does not exist."
        end
    end
end
