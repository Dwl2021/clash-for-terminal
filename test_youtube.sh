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

# Set proxy environment variables
export http_proxy=http://127.0.0.1:$PORT
export https_proxy=http://127.0.0.1:$PORT

echo "Proxy set to: http://127.0.0.1:$PORT"
echo "Testing connection to YouTube..."

# Test connection
curl -I --proxy http://127.0.0.1:$PORT http://www.youtube.com
