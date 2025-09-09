#!/bin/bash

# Get the absolute path of the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if clash.yml exists
if [ ! -f "$SCRIPT_DIR/clash.yml" ]; then
    echo "Error: clash.yml not found in $SCRIPT_DIR"
    echo "Please run install.sh first to download the configuration file"
    exit 1
fi

# Read port from clash.yml
echo "Reading port configuration from clash.yml..."

# Check if mixed-port exists, if not use port
if grep -q "^mixed-port:" "$SCRIPT_DIR/clash.yml"; then
    PORT=$(grep "^mixed-port:" "$SCRIPT_DIR/clash.yml" | sed 's/mixed-port: *//' | tr -d ' ')
    echo "Using mixed port: $PORT"
else
    PORT=$(grep "^port:" "$SCRIPT_DIR/clash.yml" | sed 's/port: *//' | tr -d ' ')
    if [ -z "$PORT" ]; then
        PORT=7890
        echo "No port found in configuration, using default: $PORT"
    else
        echo "Using HTTP port: $PORT"
    fi
fi

# Confirm modification
read -p "Do you want to modify ~/.bashrc and add proxy_on/proxy_off functions? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted. ~/.bashrc was not modified."
    exit 0
fi

# Backup .bashrc
if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.cft.save
    echo "Backup saved as ~/.bashrc.cft.save"
fi

# Append proxy functions to .bashrc
{
    echo ""
    echo "# Added by echo_bashrc.sh"
    echo "proxy_on() {"
    echo "    export http_proxy=http://127.0.0.1:$PORT"
    echo "    export https_proxy=http://127.0.0.1:$PORT"
    echo "    echo \"Proxy enabled on port $PORT\""
    echo "}"
    echo ""
    echo "proxy_off() {"
    echo "    unset http_proxy"
    echo "    unset https_proxy"
    echo "    echo \"Proxy disabled\""
    echo "}"
    echo ""
} >> ~/.bashrc

echo "proxy_on/proxy_off functions have been added to ~/.bashrc"
echo "Please run: source ~/.bashrc"
