#!/bin/bash
set -e

# Get the absolute path of the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "    Clash for Terminal Setup Script"
echo "=========================================="

# Check if clash.yml already exists
if [ -f "$SCRIPT_DIR/clash.yml" ]; then
  echo ""
  echo "✓ Configuration file clash.yml already exists"
  echo "Skipping download step..."
else
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
fi

# Read port from configuration file
echo ""
echo "Reading configuration from clash.yml..."

# Check if mixed-port exists in configuration
if grep -q "^mixed-port:" "$SCRIPT_DIR/clash.yml"; then
  echo ""
  echo "✓ Mixed port configuration detected in clash.yml"
  echo "Skipping individual port configuration..."
  
  # Extract mixed port value
  MIXED_PORT=$(grep "^mixed-port:" "$SCRIPT_DIR/clash.yml" | sed 's/mixed-port: *//' | tr -d ' ')
  echo "Mixed port: $MIXED_PORT"
  
  # Set variables for display purposes
  HTTP_PORT="mixed"
  SOCKS_PORT="mixed"
  EXTERNAL_PORT=$(grep "^external-controller:" "$SCRIPT_DIR/clash.yml" | sed "s/external-controller: *'127.0.0.1://" | sed "s/'//" | tr -d ' ')
else
  # Interactive port configuration
  echo ""
  echo "Port Configuration:"
  echo "=================="

  # HTTP port configuration
  read -p "Enter HTTP port (press Enter for default 7890): " custom_http_port
  if [ -z "$custom_http_port" ]; then
    HTTP_PORT=7890
    echo "Using default HTTP port: $HTTP_PORT"
  else
    HTTP_PORT=$custom_http_port
    echo "Using custom HTTP port: $HTTP_PORT"
    # Update clash.yml with custom HTTP port
    sed -i "s/^port:.*/port: $HTTP_PORT/" "$SCRIPT_DIR/clash.yml"
    echo "✓ Updated clash.yml with HTTP port: $HTTP_PORT"
  fi

  # SOCKS port configuration
  read -p "Enter SOCKS port (press Enter for default 7891): " custom_socks_port
  if [ -z "$custom_socks_port" ]; then
    SOCKS_PORT=7891
    echo "Using default SOCKS port: $SOCKS_PORT"
  else
    SOCKS_PORT=$custom_socks_port
    echo "Using custom SOCKS port: $SOCKS_PORT"
    # Update clash.yml with custom SOCKS port
    sed -i "s/^socks-port:.*/socks-port: $SOCKS_PORT/" "$SCRIPT_DIR/clash.yml"
    echo "✓ Updated clash.yml with SOCKS port: $SOCKS_PORT"
  fi

  # External controller port configuration
  read -p "Enter external controller port (press Enter for default 9090): " custom_external_port
  if [ -z "$custom_external_port" ]; then
    EXTERNAL_PORT=9090
    echo "Using default external controller port: $EXTERNAL_PORT"
  else
    EXTERNAL_PORT=$custom_external_port
    echo "Using custom external controller port: $EXTERNAL_PORT"
    # Update clash.yml with custom external controller port
    sed -i "s/^external-controller:.*/external-controller: '127.0.0.1:$EXTERNAL_PORT'/" "$SCRIPT_DIR/clash.yml"
    echo "✓ Updated clash.yml with external controller port: $EXTERNAL_PORT"
  fi
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
if [ "$HTTP_PORT" = "mixed" ]; then
  echo "Mixed port: $MIXED_PORT"
else
  echo "HTTP port: $HTTP_PORT"
  echo "SOCKS port: $SOCKS_PORT"
fi
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
if [ "$HTTP_PORT" = "mixed" ]; then
  echo "  Mixed port: $MIXED_PORT"
else
  echo "  HTTP port: $HTTP_PORT"
  echo "  SOCKS port: $SOCKS_PORT"
fi
echo "  External controller port: $EXTERNAL_PORT"
echo ""
echo "To start Clash, run:"
echo "  ./cft.sh"
echo ""
