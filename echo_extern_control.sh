#!/bin/bash

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/clash.yml"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: clash.yml not found"
    exit 1
fi

# Read external-controller port
EXTERNAL_PORT=$(grep "^external-controller:" "$CONFIG_FILE" | head -1 | awk -F: '{print $3}' | tr -d '\r' | tr -d "'" | tr -d '"')

if [ -z "$EXTERNAL_PORT" ]; then
    echo "Error: external-controller not found in clash.yml"
    exit 1
fi

echo "Open a new terminal locally and use the following command"
echo "ssh -L $EXTERNAL_PORT:localhost:$EXTERNAL_PORT username@server_ip"
echo "http://localhost:$EXTERNAL_PORT/ui"
