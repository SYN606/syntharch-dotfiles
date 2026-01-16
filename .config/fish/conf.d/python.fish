# Python virtual environment and project helpers using uv with pip fallback

# Create a virtual environment (.venv)
function mkvenv --description "Create Python virtualenv"
    set -l env_name .venv

    test -d $env_name; and begin
        echo "Virtual environment '$env_name' already exists."
        return 1
    end

    if type -q uv
        uv venv
    else
        python -m venv $env_name
    end

    echo "Virtual environment '$env_name' created."
end

# Activate virtual environment
function acvt --description "Activate virtualenv"
    set -l env_name .venv
    set -l activate_file $env_name/bin/activate.fish

    test -f $activate_file; or begin
        echo "Activation script not found for '$env_name'."
        return 1
    end

    source $activate_file
    echo "Activated virtual environment '$env_name'."
end

# Initialize Python project using uv
function initproj --description "Initialize Python project"
    set -l project_name (count $argv); and set project_name $argv[1]; or set project_name (basename (pwd))

    type -q uv; or begin
        echo "uv not found. Project initialization skipped."
        return 1
    end

    uv init .

    test -f main.py; and rm main.py

    echo "Project '$project_name' initialized."
end

# Install a package
function installpkg --description "Install Python package"
    test (count $argv) -ge 1; or begin
        echo "Usage: installpkg <package>"
        return 1
    end

    set -l pkg $argv[1]

    if type -q uv
        uv add $pkg
    else
        pip install $pkg
    end
end

# Remove a package
function removepkg --description "Remove Python package"
    test (count $argv) -ge 1; or begin
        echo "Usage: removepkg <package>"
        return 1
    end

    set -l pkg $argv[1]

    if type -q uv
        uv remove $pkg
    else
        pip uninstall -y $pkg
    end
end

# Export requirements.txt
function exportreq --description "Export requirements"
    set -l file (count $argv); and set file $argv[1]; or set file requirements.txt

    if not set -q VIRTUAL_ENV
        test -f .venv/bin/activate.fish; and source .venv/bin/activate.fish
    end

    set -q VIRTUAL_ENV; or begin
        echo "No active virtual environment."
        return 1
    end

    if type -q uv
        uv pip freeze >$file
    else
        pip freeze >$file
    end

    echo "Requirements exported to '$file'."
end

# Remove virtual environment
function rmvenv --description "Remove Python virtualenv"
    set -l env_name (count $argv); and set env_name $argv[1]; or set env_name .venv

    test -d $env_name; or begin
        echo "Virtual environment '$env_name' does not exist."
        return 1
    end

    rm -rf $env_name
    echo "Virtual environment '$env_name' removed."
end
