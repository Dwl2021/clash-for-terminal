#!/bin/bash
set -e

echo "Starting Clash uninstallation process..."

# Remove Clash binary
echo "Removing Clash binary..."
if [ -f /usr/local/bin/clash ]; then
    rm /usr/local/bin/clash
else
    echo "Clash binary not found, skipping..."
fi

# Remove Clash configuration directory
echo "Removing Clash configuration directory..."
if [ -d /usr/local/etc/clash ]; then
    rm -rf /usr/local/etc/clash
else
    echo "Clash configuration directory not found, skipping..."
fi

# Remove environment variables and alias from ~/.bashrc
echo "Cleaning up environment variables and aliases from ~/.bashrc..."

# Backup original .bashrc before making changes
cp ~/.bashrc ~/.bashrc.backup

# Remove lines related to Clash from ~/.bashrc
sed -i'' '/export http_proxy=http:\/\/127.0.0.1:7890/d' ~/.bashrc
sed -i'' '/export https_proxy=http:\/\/127.0.0.1:7890/d' ~/.bashrc
sed -i'' 'alias cft=/d' ~/.bashrc

echo "Clash has been uninstalled successfully."

