# 🔄 Switch to NVIDIA GPU mode
function switch_nvidia --description "Switch to NVIDIA GPU mode using envycontrol. Prompts for reboot."
    if not type -q envycontrol
        echo (set_color red)"❌ envycontrol not found. Please install it first."(set_color normal)
        return 1
    end
    sudo envycontrol --switch nvidia
    echo (set_color green)"✅ Switched to NVIDIA GPU. Reboot required to apply changes."(set_color normal)
    read --prompt "🔁 Reboot now? (y/N): " choice
    if test "$choice" = y
        sudo reboot
    end
end

# 🔄 Switch to Hybrid mode (Intel + NVIDIA)
function switch_hybrid --description "Switch to Hybrid mode (Intel + NVIDIA) using envycontrol. Prompts for reboot."
    if not type -q envycontrol
        echo (set_color red)"❌ envycontrol not found. Please install it first."(set_color normal)
        return 1
    end
    sudo envycontrol --switch hybrid
    echo (set_color green)"✅ Switched to Hybrid mode. Reboot required to apply changes."(set_color normal)
    read --prompt "🔁 Reboot now? (y/N): " choice
    if test "$choice" = y
        sudo reboot
    end
end

# 🔄 Switch to Integrated mode (Intel only)
function switch_integrated --description "Switch to Integrated (Intel only) GPU mode using envycontrol. Prompts for reboot."
    if not type -q envycontrol
        echo (set_color red)"❌ envycontrol not found. Please install it first."(set_color normal)
        return 1
    end
    sudo envycontrol --switch integrated
    echo (set_color green)"✅ Switched to Integrated GPU. Reboot required to apply changes."(set_color normal)
    read --prompt "🔁 Reboot now? (y/N): " choice
    if test "$choice" = y
        sudo reboot
    end
end

# 🔍 Check the currently active GPU (via NVIDIA-SMI or fallback)
function check_gpu --description "Check and display the currently active GPU."
    if type -q nvidia-smi
        echo (set_color cyan)"🔍 NVIDIA GPU Detected:"(set_color normal)
        nvidia-smi --query-gpu=name --format=csv,noheader
    else
        echo (set_color yellow)"⚠️  nvidia-smi not found. Displaying current EnvyControl mode instead:"(set_color normal)
        gpu_mode
    end
end

# 🧭 Check current EnvyControl mode
function gpu_mode --description "Display the current GPU mode from envycontrol."
    if not type -q envycontrol
        echo (set_color red)"❌ envycontrol not found."(set_color normal)
        return 1
    end
    envycontrol --query
end

# 🏎️ Run a GPU benchmark using glmark2
function gpu_benchmark --description "Run a GPU benchmark using glmark2. Installs glmark2 if missing."
    if not type -q glmark2
        echo (set_color yellow)"⚠️ glmark2 not found. Attempting to install..."(set_color normal)
        if type -q pacman
            sudo pacman -S glmark2
        else if type -q apt
            sudo apt install glmark2
        else
            echo (set_color red)"❌ Package manager not supported. Please install glmark2 manually."(set_color normal)
            return 1
        end
    end
    echo "🏎️ Running GPU benchmark with glmark2..."
    glmark2
end

# ⚙️ Run an FPS test using glxgears
function gpu_test --description "Run an FPS test using glxgears. Installs mesa-utils if missing."
    if not type -q glxgears
        echo (set_color yellow)"⚠️ glxgears not found. Attempting to install..."(set_color normal)
        if type -q pacman
            sudo pacman -S mesa-utils
        else if type -q apt
            sudo apt install mesa-utils
        else
            echo (set_color red)"❌ Package manager not supported. Please install glxgears manually."(set_color normal)
            return 1
        end
    end
    echo "⚙️ Running FPS test with glxgears..."
    glxgears
end

# 📖 Display help for all GPU-related functions
function gpu_help --description "List all GPU management commands and their descriptions."
    echo (set_color blue)"🖥️ GPU Tools for Fish Shell"(set_color normal)
    echo ""
    echo "  switch_nvidia      - Switch to NVIDIA GPU mode"
    echo "  switch_hybrid      - Switch to Hybrid mode (Intel + NVIDIA)"
    echo "  switch_integrated  - Switch to Integrated (Intel only)"
    echo "  check_gpu          - Check currently active GPU"
    echo "  gpu_mode           - Show current mode via envycontrol"
    echo "  gpu_benchmark      - Run benchmark with glmark2"
    echo "  gpu_test           - Run FPS test with glxgears"
    echo "  gpu_help           - Show this help menu"
    echo ""
    echo "📦 Requirements: envycontrol, glmark2, glxgears, nvidia-smi (optional)"
end
