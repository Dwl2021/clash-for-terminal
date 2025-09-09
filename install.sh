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

# Prepare base configuration snapshot and restore for this install run
if [ ! -f "$SCRIPT_DIR/clash.yml.save" ]; then
  cp "$SCRIPT_DIR/clash.yml" "$SCRIPT_DIR/clash.yml.save"
  echo "✓ Created base template: $SCRIPT_DIR/clash.yml.save"
fi
cp "$SCRIPT_DIR/clash.yml.save" "$SCRIPT_DIR/clash.yml"
echo "✓ Restored clash.yml from template"

# Read port from configuration file
echo ""
echo "Reading configuration from clash.yml..."

# Check if mixed-port exists in configuration
if grep -q "^mixed-port:" "$SCRIPT_DIR/clash.yml"; then
  echo ""
  echo "✓ Mixed port configuration detected in clash.yml"
  # Extract mixed port value
  MIXED_PORT=$(grep "^mixed-port:" "$SCRIPT_DIR/clash.yml" | sed 's/mixed-port: *//' | tr -d ' ')
  echo "Current mixed port: $MIXED_PORT"
  # Direct input for mixed-port (Enter to keep current)
  read -p "Enter mixed-port (press Enter to keep $MIXED_PORT): " custom_mixed_port
  if [ -n "$custom_mixed_port" ]; then
    MIXED_PORT=$custom_mixed_port
    sed -i "s/^mixed-port:.*/mixed-port: $MIXED_PORT/" "$SCRIPT_DIR/clash.yml"
    echo "✓ Updated clash.yml with mixed-port: $MIXED_PORT"
  fi

  # Set variables for display purposes
  HTTP_PORT="mixed"
  SOCKS_PORT="mixed"

  # Extract external-controller port robustly and ask to modify
  if grep -q "^external-controller:" "$SCRIPT_DIR/clash.yml"; then
    EC_LINE=$(grep "^external-controller:" "$SCRIPT_DIR/clash.yml" | head -n1 | sed "s/^[[:space:]]*external-controller:[[:space:]]*//")
    # Remove surrounding quotes if any
    EC_LINE=${EC_LINE%"'"}
    EC_LINE=${EC_LINE#"'"}
    # Extract digits after last colon as port
    EXTERNAL_PORT=$(echo "$EC_LINE" | sed -E "s/.*:([0-9]+).*/\1/")
  else
    EXTERNAL_PORT=9090
  fi
  echo "Current external controller port: $EXTERNAL_PORT"
  # Direct input for external-controller port (Enter to keep current)
  read -p "Enter external-controller port (press Enter to keep $EXTERNAL_PORT): " custom_external_port
  if [ -n "$custom_external_port" ]; then
    EXTERNAL_PORT=$custom_external_port
    if grep -q "^external-controller:" "$SCRIPT_DIR/clash.yml"; then
      sed -i "s/^external-controller:.*/external-controller: 127.0.0.1:$EXTERNAL_PORT/" "$SCRIPT_DIR/clash.yml"
    else
      echo "external-controller: 127.0.0.1:$EXTERNAL_PORT" >> "$SCRIPT_DIR/clash.yml"
    fi
    echo "✓ Updated clash.yml with external-controller: :$EXTERNAL_PORT"
  fi
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
    # Update clash.yml with custom external controller port (write as :PORT)
    if grep -q "^external-controller:" "$SCRIPT_DIR/clash.yml"; then
      sed -i "s/^external-controller:.*/external-controller: 127.0.0.1:$EXTERNAL_PORT/" "$SCRIPT_DIR/clash.yml"
    else
      echo "external-controller: 127.0.0.1:$EXTERNAL_PORT" >> "$SCRIPT_DIR/clash.yml"
    fi
    echo "✓ Updated clash.yml with external controller port: $EXTERNAL_PORT"
  fi
fi

# Ensure external-ui and secret settings
echo ""
echo "Ensuring external-ui and secret settings..."

# Ensure secret is set to empty string '' (override or insert after external-controller)
if grep -q "^secret:" "$SCRIPT_DIR/clash.yml"; then
  sed -i "s/^secret:.*/secret: ''/" "$SCRIPT_DIR/clash.yml"
  echo "✓ Updated secret to empty string"
else
  echo "Inserting secret after external-controller"
  sed -i "/^external-controller:/a secret: ''" "$SCRIPT_DIR/clash.yml"
fi

# Force external-ui to absolute dashboard path (override or insert after external-controller)
if grep -q "^external-ui:" "$SCRIPT_DIR/clash.yml"; then
  sed -i "s|^external-ui:.*|external-ui: '$SCRIPT_DIR/dashboard'|" "$SCRIPT_DIR/clash.yml"
  echo "✓ Set external-ui to absolute path: $SCRIPT_DIR/dashboard"
else
  echo "Inserting external-ui after external-controller"
  sed -i "/^external-controller:/a external-ui: '$SCRIPT_DIR/dashboard'" "$SCRIPT_DIR/clash.yml"
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
