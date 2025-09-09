#!/bin/bash

# ===== User Settings =====
# Set your HTTP port here (default 7890)
PORT=7890
# =========================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/clash.yml"

# If clash.yml exists, try to read port from it
if [ -f "$CONFIG_FILE" ]; then
    # Check if mixed-port exists, if not use port
    if grep -q "^mixed-port:" "$CONFIG_FILE"; then
        CFG_PORT=$(grep "^mixed-port:" "$CONFIG_FILE" | head -1 | awk '{print $2}' | tr -d '\r')
        if [ -n "$CFG_PORT" ]; then
            PORT=$CFG_PORT
            echo "Using mixed port from clash.yml: $PORT"
        else
            echo "Warning: mixed-port value not found in clash.yml, using default $PORT"
        fi
    else
        CFG_PORT=$(grep "^port:" "$CONFIG_FILE" | head -1 | awk '{print $2}' | tr -d '\r')
        if [ -n "$CFG_PORT" ]; then
            PORT=$CFG_PORT
            echo "Using HTTP port from clash.yml: $PORT"
        else
            echo "Warning: port not found in clash.yml, using default $PORT"
        fi
    fi
else
    echo "Warning: clash.yml not found, using default $PORT"
fi

# Define proxy functions
proxy_on() {
    export http_proxy=http://127.0.0.1:$PORT
    export https_proxy=http://127.0.0.1:$PORT
    echo "Proxy enabled: http://127.0.0.1:$PORT"
}

proxy_off() {
    unset http_proxy
    unset https_proxy
    echo "Proxy disabled"
}

# Export functions to current shell
export -f proxy_on
export -f proxy_off

# Auto-run proxy_on
proxy_on

echo "proxy_on and proxy_off functions are now available in current shell"
echo "Use 'proxy_on' to enable proxy, 'proxy_off' to disable"
