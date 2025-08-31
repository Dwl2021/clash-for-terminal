#!/bin/bash

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/clash.yml"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: clash.yml not found"
    exit 1
fi

# Read port from clash.yml
PORT=$(grep "^port:" "$CONFIG_FILE" | head -1 | awk '{print $2}' | tr -d '\r')

if [ -z "$PORT" ]; then
    echo "Error: port not found in clash.yml, using default 7890"
    PORT=7890
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
