#!/bin/bash
set -e
# Check if the subscription link is provided
if [ -z "$1" ]; then
  echo "Error: Subscription link is missing."
  echo "Usage: $0 <subscription_link>"
  exit 1
fi

if [ "$1" = "https://example/clash.yml" ]; then
  echo "Please enter your own subscription link."
  exit 1
fi

# Download and install Clash
gunzip clash-linux-amd64-v1.18.0.gz &&
chmod +x clash-linux-amd64-v1.18.0 &&
cp clash-linux-amd64-v1.18.0 /usr/local/bin/clash &&
mkdir -p /usr/local/etc/clash &&
wget -P /usr/local/etc/clash "$1" &&
mv /usr/local/etc/clash/clash.yml /usr/local/etc/clash/config.yaml &&
cp Country.mmdb /usr/local/etc/clash/

echo "Clash installed and configured with subscription link: $1"
