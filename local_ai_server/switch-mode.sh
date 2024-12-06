#!/bin/bash
# File: ./switch-mode.sh
# Purpose: Helper script to switch between CPU and GPU modes

function check_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        if nvidia-smi &> /dev/null; then
            return 0  # GPU available
        fi
    fi
    return 1  # No GPU available
}

function start_environment() {
    if check_gpu; then
        echo "GPU detected - starting with GPU support..."
        docker compose --profile gpu-nvidia up -d
    else
        echo "No GPU detected - starting in CPU mode..."
        docker compose --profile cpu up -d
    fi
}

function stop_environment() {
    docker compose down -v
}

case "$1" in
    "start")
        start_environment
        ;;
    "stop")
        stop_environment
        ;;
    "restart")
        stop_environment
        start_environment
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac