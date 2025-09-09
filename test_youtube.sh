#!/bin/bash

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/clash.yml"

# Check if config file exists and read port
if [ -f "$CONFIG_FILE" ]; then
    echo "Reading port configuration from clash.yml..."
    
    # Check if mixed-port exists, if not use port
    if grep -q "^mixed-port:" "$CONFIG_FILE"; then
        PORT=$(grep "^mixed-port:" "$CONFIG_FILE" | head -1 | awk '{print $2}' | tr -d '\r')
        if [ -n "$PORT" ]; then
            echo "Using mixed port: $PORT"
        else
            echo "Warning: mixed-port value not found, using default 7890"
            PORT=7890
        fi
    else
        PORT=$(grep "^port:" "$CONFIG_FILE" | head -1 | awk '{print $2}' | tr -d '\r')
        if [ -n "$PORT" ]; then
            echo "Using HTTP port: $PORT"
        else
            echo "Warning: port not found, using default 7890"
            PORT=7890
        fi
    fi
else
    echo "Warning: clash.yml not found, using default port 7890"
    PORT=7890
fi

# Set proxy environment variables
export http_proxy=http://127.0.0.1:$PORT
export https_proxy=http://127.0.0.1:$PORT

echo "Proxy set to: http://127.0.0.1:$PORT"
echo "Testing connection to YouTube..."

# Test connection
curl -I --proxy http://127.0.0.1:$PORT http://www.youtube.com
