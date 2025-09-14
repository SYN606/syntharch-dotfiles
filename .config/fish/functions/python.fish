# ─────────────────────────────
# PYTHON DEV TOOLS (Fish + UV)
# ─────────────────────────────

# Check if uv is installed
function _check_uv
    if type -q uv
        return 0
    else
        return 1
    end
end

# Create a virtual environment (uv preferred, pip fallback)
function mkvenv --description "Create Python virtualenv"
    set env_name (or $argv[1] "env")

    if test -d $env_name
        echo "Virtual environment '$env_name' already exists."
        return 1
    end

    if _check_uv
        uv new $env_name
        echo "Virtual environment '$env_name' created using uv."
    else
        python -m venv $env_name
        echo "uv not found. Virtual environment '$env_name' created using venv."
    end
end

# Activate virtual environment
function acvt --description "Activate virtualenv"
    set env_name (or $argv[1] "env")

    if _check_uv
        if uv list | grep -q $env_name
            uv activate $env_name
            echo "Activated virtual environment '$env_name' via uv."
        else
            echo "Virtual environment '$env_name' not found in uv."
        end
    else
        if test -f $env_name/bin/activate.fish
            source $env_name/bin/activate.fish
            echo "Activated virtual environment '$env_name' via venv."
        else
            echo "Activation script not found for '$env_name'."
        end
    end
end

# Initialize project (pyproject.toml) using uv or poetry fallback
function initproj --description "Initialize Python project (pyproject.toml)"
    set project_name (or $argv[1] (basename (pwd)))

    if _check_uv
        uv init $project_name
        echo "Project '$project_name' initialized using uv."
    else
        poetry init --name $project_name --no-interaction
        echo "uv not found. Project '$project_name' initialized using poetry."
    end
end

# Install a package and update pyproject.toml
function installpkg --description "Install package and update pyproject.toml"
    set pkg $argv[1]
    if not set -q pkg
        echo "Please provide a package name."
        return 1
    end

    if _check_uv
        uv install $pkg
        echo "Package '$pkg' installed using uv and pyproject.toml updated."
    else
        pip install $pkg
        echo "uv not found. Package '$pkg' installed using pip."
    end
end

# Remove a package and update pyproject.toml
function removepkg --description "Remove package and update pyproject.toml"
    set pkg $argv[1]
    if not set -q pkg
        echo "Please provide a package name."
        return 1
    end

    if _check_uv
        uv remove $pkg
        echo "Package '$pkg' removed using uv and pyproject.toml updated."
    else
        pip uninstall -y $pkg
        echo "uv not found. Package '$pkg' removed using pip."
    end
end

# Export requirements.txt
function exportreq --description "Export requirements.txt"
    set file (or $argv[1] "requirements.txt")

    if _check_uv
        uv current | grep -q "env"
        if test $status -eq 0
            pip freeze > $file
            echo "Requirements exported to '$file'."
        else
            echo "Activate a uv environment first."
        end
    else
        if test -f env/bin/activate.fish
            source env/bin/activate.fish
            pip freeze > $file
            echo "Requirements exported to '$file' using pip."
        else
            echo "Activate a virtual environment first."
        end
    end
end

# Remove virtual environment
function rmvenv --description "Remove virtualenv"
    set env_name (or $argv[1] "env")

    if _check_uv
        if uv list | grep -q $env_name
            uv remove $env_name
            echo "Virtual environment '$env_name' removed using uv."
        else
            echo "Virtual environment '$env_name' not found in uv."
        end
    else
        if test -d $env_name
            rm -rf $env_name
            echo "Virtual environment '$env_name' removed using venv."
        else
            echo "Virtual environment '$env_name' does not exist."
        end
    end
end
