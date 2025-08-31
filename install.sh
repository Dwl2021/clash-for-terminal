#!/bin/bash
set -e

# Get the absolute path of the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "    Clash for Terminal Setup Script"
echo "=========================================="

# Interactive subscription link input
echo ""
read -p "Please enter your subscription link: " subscription_link

# Check if subscription link is empty
if [ -z "$subscription_link" ]; then
  echo "Error: Subscription link cannot be empty"
  exit 1
fi

# Check if subscription link is example link
if [ "$subscription_link" = "https://example/clash.yml" ]; then
  echo "Error: Please enter your own subscription link, not the example link"
  exit 1
fi

echo ""
echo "Downloading configuration file..."

# Download configuration file to current directory
if wget -O "$SCRIPT_DIR/clash.yml" "$subscription_link"; then
  echo "✓ Configuration file downloaded successfully: $SCRIPT_DIR/clash.yml"
else
  echo "✗ Failed to download configuration file, please check if the subscription link is correct"
  exit 1
fi

# Read port from configuration file
echo ""
echo "Reading configuration from clash.yml..."

# Extract HTTP port from configuration file
HTTP_PORT=$(grep "^port:" "$SCRIPT_DIR/clash.yml" | head -1 | awk '{print $2}' | tr -d '\r')
if [ -z "$HTTP_PORT" ]; then
  echo "Warning: Could not find 'port' in configuration, using default port 7890"
  HTTP_PORT=7890
else
  echo "✓ Found HTTP port: $HTTP_PORT"
fi

# Extract SOCKS port from configuration file
SOCKS_PORT=$(grep "^socks-port:" "$SCRIPT_DIR/clash.yml" | head -1 | awk '{print $2}' | tr -d '\r')
if [ -z "$SOCKS_PORT" ]; then
  echo "Warning: Could not find 'socks-port' in configuration, using default port 7891"
  SOCKS_PORT=7891
else
  echo "✓ Found SOCKS port: $SOCKS_PORT"
fi

# Extract external controller port from configuration file
EXTERNAL_PORT=$(grep "^external-controller:" "$SCRIPT_DIR/clash.yml" | head -1 | awk -F: '{print $3}' | tr -d '\r')
if [ -z "$EXTERNAL_PORT" ]; then
  echo "Warning: Could not find 'external-controller' port in configuration, using default port 9090"
  EXTERNAL_PORT=9090
else
  echo "✓ Found external controller port: $EXTERNAL_PORT"
fi

# Create startup script
cat > "$SCRIPT_DIR/cft.sh" << EOF
#!/bin/bash
# Clash for Terminal startup script

# Get script directory
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"

# Check if configuration file exists
if [ ! -f "\$SCRIPT_DIR/clash.yml" ]; then
    echo "Error: Configuration file clash.yml not found"
    echo "Please run install.sh first"
    exit 1
fi

# Check if clash executable exists
if [ ! -f "\$SCRIPT_DIR/clash" ]; then
    echo "Error: clash executable not found"
    exit 1
fi

echo "Starting Clash..."
echo "Configuration file: \$SCRIPT_DIR/clash.yml"
echo "HTTP port: $HTTP_PORT"
echo "SOCKS port: $SOCKS_PORT"
echo "External controller port: $EXTERNAL_PORT"
echo ""

# Start clash
exec "\$SCRIPT_DIR/clash" -f "\$SCRIPT_DIR/clash.yml"
EOF

# Make startup script executable
chmod +x "$SCRIPT_DIR/cft.sh"

echo ""
echo "✓ Startup script created successfully: $SCRIPT_DIR/cft.sh"

echo ""
echo "=========================================="
echo "    Setup Complete!"
echo "=========================================="
echo ""
echo "Configuration detected:"
echo "  HTTP port: $HTTP_PORT"
echo "  External controller port: $EXTERNAL_PORT"
echo ""
echo "To start Clash, run:"
echo "  ./cft.sh"
echo ""
