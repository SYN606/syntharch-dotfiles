# Enhanced GPU Management Commands for Fish Shell (Arch Linux + EnvyControl)

# Switch to NVIDIA GPU mode
function switch_nvidia --description "Switch to NVIDIA GPU mode using envycontrol"
    if not command -v envycontrol >/dev/null 2>&1
        echo "Error: envycontrol not found. Please install it first." >&2
        return 1
    end
    
    echo "Switching to NVIDIA GPU mode..."
    
    if not sudo envycontrol --switch nvidia 2>&1
        echo "Error: Failed to switch to NVIDIA mode" >&2
        return 1
    end
    
    echo "Switched to NVIDIA GPU. Reboot required to apply changes."
    _prompt_reboot
end

# Switch to Hybrid mode (Intel + NVIDIA)
function switch_hybrid --description "Switch to Hybrid mode (Intel + NVIDIA) using envycontrol"
    if not command -v envycontrol >/dev/null 2>&1
        echo "Error: envycontrol not found. Please install it first." >&2
        return 1
    end
    
    echo "Switching to Hybrid mode..."
    
    if not sudo envycontrol --switch hybrid 2>&1
        echo "Error: Failed to switch to Hybrid mode" >&2
        return 1
    end
    
    echo "Switched to Hybrid mode. Reboot required to apply changes."
    _prompt_reboot
end

# Switch to Integrated mode (Intel only)
function switch_integrated --description "Switch to Integrated (Intel only) GPU mode using envycontrol"
    if not command -v envycontrol >/dev/null 2>&1
        echo "Error: envycontrol not found. Please install it first." >&2
        return 1
    end
    
    echo "Switching to Integrated GPU mode..."
    
    if not sudo envycontrol --switch integrated 2>&1
        echo "Error: Failed to switch to Integrated mode" >&2
        return 1
    end
    
    echo "Switched to Integrated GPU. Reboot required to apply changes."
    _prompt_reboot
end

# Check the currently active GPU
function check_gpu --description "Check and display the currently active GPU"
    echo "GPU Information:"
    echo "==============="
    
    # Check if NVIDIA GPU is active via nvidia-smi
    if command -v nvidia-smi >/dev/null 2>&1
        if nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null
            echo "NVIDIA GPU is active and accessible"
        else
            echo "NVIDIA drivers installed but GPU not accessible"
        end
    else
        echo "NVIDIA drivers/tools not available"
    end
    
    # Show current EnvyControl mode
    if command -v envycontrol >/dev/null 2>&1
        echo ""
        echo "Current EnvyControl mode:"
        envycontrol --query 2>/dev/null
        or echo "Unable to query EnvyControl mode"
    end
    
    # Show additional GPU info from lspci
    echo ""
    echo "Detected GPUs (lspci):"
    lspci | grep -i "vga\|3d\|display" 2>/dev/null
    or echo "Unable to detect GPUs via lspci"
end

# Check current EnvyControl mode only
function gpu_mode --description "Display the current GPU mode from envycontrol"
    if not command -v envycontrol >/dev/null 2>&1
        echo "Error: envycontrol not found." >&2
        return 1
    end
    
    envycontrol --query 2>/dev/null
    or begin
        echo "Error: Unable to query EnvyControl mode" >&2
        return 1
    end
end

# Run a GPU benchmark using glmark2
function gpu_benchmark --description "Run a GPU benchmark using glmark2"
    if not command -v glmark2 >/dev/null 2>&1
        echo "glmark2 not found. Attempting to install..."
        
        if command -v pacman >/dev/null 2>&1
            if not sudo pacman -S --noconfirm glmark2
                echo "Error: Failed to install glmark2 via pacman" >&2
                return 1
            end
        else if command -v apt >/dev/null 2>&1
            if not sudo apt install -y glmark2
                echo "Error: Failed to install glmark2 via apt" >&2
                return 1
            end
        else if command -v yay >/dev/null 2>&1
            if not yay -S --noconfirm glmark2
                echo "Error: Failed to install glmark2 via yay" >&2
                return 1
            end
        else
            echo "Error: No supported package manager found. Please install glmark2 manually." >&2
            return 1
        end
    end
    
    echo "Running GPU benchmark with glmark2..."
    echo "This may take several minutes..."
    glmark2
end

# Run an FPS test using glxgears
function gpu_test --description "Run an FPS test using glxgears"
    if not command -v glxgears >/dev/null 2>&1
        echo "glxgears not found. Attempting to install mesa-utils..."
        
        if command -v pacman >/dev/null 2>&1
            if not sudo pacman -S --noconfirm mesa-utils
                echo "Error: Failed to install mesa-utils via pacman" >&2
                return 1
            end
        else if command -v apt >/dev/null 2>&1
            if not sudo apt install -y mesa-utils
                echo "Error: Failed to install mesa-utils via apt" >&2
                return 1
            end
        else if command -v yay >/dev/null 2>&1
            if not yay -S --noconfirm mesa-utils
                echo "Error: Failed to install mesa-utils via yay" >&2
                return 1
            end
        else
            echo "Error: No supported package manager found. Please install mesa-utils manually." >&2
            return 1
        end
    end
    
    echo "Running FPS test with glxgears..."
    echo "Press Ctrl+C to stop the test"
    glxgears
end

# Show GPU status information
function gpu_status --description "Show comprehensive GPU status information"
    echo "=== GPU Status Report ==="
    echo ""
    
    # Current mode
    echo "Current Mode:"
    if command -v envycontrol >/dev/null 2>&1
        envycontrol --query 2>/dev/null
        or echo "Unable to query mode"
    else
        echo "EnvyControl not available"
    end
    
    echo ""
    
    # GPU detection
    echo "Hardware Detection:"
    lspci | grep -i "vga\|3d\|display" 2>/dev/null
    or echo "Unable to detect GPUs"
    
    echo ""
    
    # NVIDIA status
    echo "NVIDIA Status:"
    if command -v nvidia-smi >/dev/null 2>&1
        if nvidia-smi --query-gpu=name,driver_version,temperature.gpu,utilization.gpu --format=csv 2>/dev/null
            echo "NVIDIA GPU is active"
        else
            echo "NVIDIA drivers installed but GPU not accessible"
        end
    else
        echo "NVIDIA drivers/tools not installed"
    end
    
    echo ""
    
    # Process using GPU
    echo "GPU Processes:"
    if command -v nvidia-smi >/dev/null 2>&1
        nvidia-smi pmon -c 1 2>/dev/null
        or echo "No NVIDIA processes or GPU not accessible"
    else
        echo "NVIDIA monitoring not available"
    end
end

# Helper function for reboot prompt
function _prompt_reboot --description "Internal helper to prompt for reboot"
    echo ""
    read -l -P "Reboot now to apply changes? (y/N): " choice
    
    switch (string lower "$choice")
        case y yes
            echo "Rebooting system..."
            sudo reboot
        case '*'
            echo "Reboot cancelled. Changes will take effect after next reboot."
    end
end

# Install GPU tools if missing
function gpu_install_tools --description "Install common GPU management and testing tools"
    echo "Installing GPU management tools..."
    
    set -l tools_to_install
    
    # Check what's missing
    if not command -v envycontrol >/dev/null 2>&1
        echo "EnvyControl not found - will install from AUR"
        set -a tools_to_install "envycontrol"
    end
    
    if not command -v nvidia-smi >/dev/null 2>&1
        echo "NVIDIA tools not found - will install nvidia-utils"
        set -a tools_to_install "nvidia-utils"
    end
    
    if not command -v glmark2 >/dev/null 2>&1
        echo "glmark2 not found - will install"
        set -a tools_to_install "glmark2"
    end
    
    if not command -v glxgears >/dev/null 2>&1
        echo "mesa-utils not found - will install"
        set -a tools_to_install "mesa-utils"
    end
    
    if test (count $tools_to_install) -eq 0
        echo "All GPU tools are already installed!"
        return 0
    end
    
    # Install tools
    if command -v yay >/dev/null 2>&1
        yay -S --noconfirm $tools_to_install
    else if command -v paru >/dev/null 2>&1
        paru -S --noconfirm $tools_to_install
    else if command -v pacman >/dev/null 2>&1
        # For AUR packages, suggest AUR helper
        set -l aur_packages
        set -l official_packages
        
        for tool in $tools_to_install
            switch $tool
                case envycontrol
                    set -a aur_packages $tool
                case '*'
                    set -a official_packages $tool
            end
        end
        
        if test (count $official_packages) -gt 0
            sudo pacman -S --noconfirm $official_packages
        end
        
        if test (count $aur_packages) -gt 0
            echo ""
            echo "The following packages need to be installed from AUR:"
            for pkg in $aur_packages
                echo "  $pkg"
            end
            echo ""
            echo "Please install an AUR helper (yay, paru) or install manually:"
            echo "git clone https://aur.archlinux.org/envycontrol.git && cd envycontrol && makepkg -si"
        end
    else
        echo "Error: No supported package manager found" >&2
        return 1
    end
end

# Cleanup GPU configurations
function gpu_cleanup --description "Clean up GPU configurations and reset to default"
    echo "WARNING: This will reset GPU configurations to default state!"
    read -l -P "Continue? (y/N): " confirm
    
    if not test (string lower "$confirm") = "y"
        echo "Cleanup cancelled."
        return 0
    end
    
    echo "Cleaning up GPU configurations..."
    
    # Reset EnvyControl to integrated mode
    if command -v envycontrol >/dev/null 2>&1
        echo "Resetting to integrated mode..."
        sudo envycontrol --switch integrated 2>/dev/null
        and echo "Reset to integrated mode"
        or echo "Warning: Could not reset EnvyControl mode"
    end
    
    echo "Cleanup completed. Reboot recommended."
end

# Display help for all GPU-related functions
function gpu_help --description "List all GPU management commands and their descriptions"
    echo "GPU Tools for Fish Shell (Arch Linux + EnvyControl)"
    echo "=================================================="
    echo ""
    echo "GPU Switching:"
    echo "  switch_nvidia      - Switch to NVIDIA GPU mode"
    echo "  switch_hybrid      - Switch to Hybrid mode (Intel + NVIDIA)"
    echo "  switch_integrated  - Switch to Integrated mode (Intel only)"
    echo ""
    echo "Information & Status:"
    echo "  check_gpu         - Check currently active GPU and show details"
    echo "  gpu_mode          - Show current EnvyControl mode"
    echo "  gpu_status        - Comprehensive GPU status report"
    echo ""
    echo "Testing & Benchmarks:"
    echo "  gpu_benchmark     - Run GPU benchmark with glmark2"
    echo "  gpu_test          - Run FPS test with glxgears"
    echo ""
    echo "Utilities:"
    echo "  gpu_install_tools - Install missing GPU management tools"
    echo "  gpu_cleanup       - Reset GPU configurations to default"
    echo "  gpu_help          - Show this help menu"
    echo ""
    echo "Requirements:"
    echo "  - envycontrol (AUR package)"
    echo "  - nvidia-utils (for NVIDIA monitoring)"
    echo "  - mesa-utils (for glxgears)"
    echo "  - glmark2 (for benchmarking)"
    echo ""
    echo "Note: Most functions will auto-install missing dependencies"
end