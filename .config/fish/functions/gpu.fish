# 🔄 Switch to NVIDIA GPU mode
function switch_nvidia --description "Switch to NVIDIA GPU mode using envycontrol. Prompts for reboot."
    sudo envycontrol --switch nvidia
    echo "Switched to NVIDIA GPU. Reboot for changes to take effect."
    read -l -p "Would you like to reboot now? (y/N) " choice
    if test "$choice" = "y"
        sudo reboot
    end
end

# 🔄 Switch to Hybrid mode (Intel + NVIDIA)
function switch_hybrid --description "Switch to Hybrid mode (Intel + NVIDIA) using envycontrol. Prompts for reboot."
    sudo envycontrol --switch hybrid
    echo "Switched to Hybrid GPU mode. Reboot for changes to take effect."
    read -l -p "Would you like to reboot now? (y/N) " choice
    if test "$choice" = "y"
        sudo reboot
    end
end

# 🔄 Switch to Integrated mode (Intel only)
function switch_integrated --description "Switch to Integrated (Intel only) GPU mode using envycontrol. Prompts for reboot."
    sudo envycontrol --switch integrated
    echo "Switched to Integrated (Intel) mode. Reboot for changes to take effect."
    read -l -p "Would you like to reboot now? (y/N) " choice
    if test "$choice" = "y"
        sudo reboot
    end
end

# 🔍 Check the currently active GPU
function check_gpu --description "Check and display the currently active GPU. Uses nvidia-smi if available."
    if command -v nvidia-smi > /dev/null
        echo "🔍 Checking GPU..."
        nvidia-smi --query-gpu=name --format=csv,noheader
    else
        echo "⚠️ NVIDIA-SMI not found. Are NVIDIA drivers installed?"
    end
end

# 🏎️ Run a GPU benchmark using glmark2
function gpu_benchmark --description "Run a GPU benchmark using glmark2. Installs glmark2 if missing."
    if not command -v glmark2 > /dev/null
        echo "glmark2 is not installed. Installing..."
        sudo pacman -S glmark2
    end
    echo "🏎️ Running GPU benchmark..."
    glmark2
end

# ⚙️ Run an FPS test using glxgears
function gpu_test --description "Run an FPS test using glxgears. Installs mesa-utils if missing."
    if not command -v glxgears > /dev/null
        echo "glxgears is not installed. Installing..."
        sudo pacman -S mesa-utils
    end
    echo "⚙️ Running glxgears (FPS test)..."
    glxgears
end

# 📖 Display help for all GPU-related functions
function gpu_help --description "List all GPU management commands and their descriptions."
    echo "🖥️ GPU Tools for Fish Shell"
    echo ""
    echo "Commands:"
    echo "  switch_nvidia      - Switch to NVIDIA GPU mode (Prompts for reboot)"
    echo "  switch_hybrid      - Switch to Hybrid mode (Intel + NVIDIA, Prompts for reboot)"
    echo "  switch_integrated  - Switch to Integrated (Intel) GPU (Prompts for reboot)"
    echo "  check_gpu          - Check active GPU"
    echo "  gpu_benchmark      - Run GPU performance test (glmark2)"
    echo "  gpu_test           - Run GPU FPS test (glxgears)"
    echo "  gpu_help           - Show this help menu"
    echo ""
    echo "🔧 Make sure you have envycontrol installed for GPU switching."
end
