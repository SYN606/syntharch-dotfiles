# GPU management helpers using EnvyControl on Arch Linux

# Internal helper to check envycontrol availability
function __gpu_require_envycontrol
    command -v envycontrol >/dev/null 2>&1; or begin
        echo "envycontrol is not installed."
        return 1
    end
end

# Internal helper to prompt for reboot
function __gpu_prompt_reboot
    read -l -P "Reboot now to apply changes? (y/N): " choice
    switch (string lower $choice)
        case y yes
            sudo reboot
    end
end

# Switch to NVIDIA GPU mode
function switch_nvidia --description "Switch to NVIDIA GPU mode"
    __gpu_require_envycontrol; or return 1
    sudo envycontrol --switch nvidia; or return 1
    echo "Switched to NVIDIA mode. Reboot required."
    __gpu_prompt_reboot
end

# Switch to hybrid GPU mode
function switch_hybrid --description "Switch to hybrid GPU mode"
    __gpu_require_envycontrol; or return 1
    sudo envycontrol --switch hybrid; or return 1
    echo "Switched to hybrid mode. Reboot required."
    __gpu_prompt_reboot
end

# Switch to integrated GPU mode
function switch_integrated --description "Switch to integrated GPU mode"
    __gpu_require_envycontrol; or return 1
    sudo envycontrol --switch integrated; or return 1
    echo "Switched to integrated mode. Reboot required."
    __gpu_prompt_reboot
end

# Show current EnvyControl GPU mode
function gpu_mode --description "Show current GPU mode"
    __gpu_require_envycontrol; or return 1
    envycontrol --query
end

# Show detected GPUs
function gpu_detect --description "Detect GPUs via lspci"
    lspci | grep -i "vga\|3d\|display"
end

# Show NVIDIA GPU status
function gpu_nvidia --description "Show NVIDIA GPU status"
    command -v nvidia-smi >/dev/null 2>&1; or begin
        echo "nvidia-smi not available."
        return 1
    end
    nvidia-smi
end

# Show running NVIDIA GPU processes
function gpu_processes --description "Show NVIDIA GPU processes"
    command -v nvidia-smi >/dev/null 2>&1; or begin
        echo "nvidia-smi not available."
        return 1
    end
    nvidia-smi pmon -c 1
end

# Run glmark2 benchmark
function gpu_benchmark --description "Run glmark2 benchmark"
    command -v glmark2 >/dev/null 2>&1; or begin
        echo "glmark2 is not installed."
        return 1
    end
    glmark2
end

# Run glxgears FPS test
function gpu_test --description "Run glxgears FPS test"
    command -v glxgears >/dev/null 2>&1; or begin
        echo "glxgears is not installed."
        return 1
    end
    glxgears
end

# Show consolidated GPU status
function gpu_status --description "Show GPU status summary"
    echo "GPU mode:"
    gpu_mode 2>/dev/null

    echo ""
    echo "Detected GPUs:"
    gpu_detect

    echo ""
    echo "NVIDIA status:"
    gpu_nvidia 2>/dev/null; or echo "NVIDIA GPU not active."
end

# Show available GPU commands
function gpu_help --description "List GPU management commands"
    echo "GPU commands:"
    echo "  switch_nvidia      Switch to NVIDIA mode"
    echo "  switch_hybrid      Switch to hybrid mode"
    echo "  switch_integrated  Switch to integrated mode"
    echo "  gpu_mode           Show current GPU mode"
    echo "  gpu_detect         Detect GPUs"
    echo "  gpu_nvidia         Show NVIDIA status"
    echo "  gpu_processes      Show NVIDIA processes"
    echo "  gpu_benchmark      Run glmark2"
    echo "  gpu_test           Run glxgears"
    echo "  gpu_status         Show GPU summary"
end
