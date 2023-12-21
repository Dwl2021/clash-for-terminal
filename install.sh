#/bin/bash
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
gunzip -c clash-linux-amd64-v1.18.0.gz > clash-linux-amd64-v1.18.0 &&
chmod +x clash-linux-amd64-v1.18.0 &&
cp clash-linux-amd64-v1.18.0 /usr/local/bin/clash &&
mkdir -p /usr/local/etc/clash &&
wget -P /usr/local/etc/clash "$1" &&
mv /usr/local/etc/clash/clash.yml /usr/local/etc/clash/config.yaml &&
cp Country.mmdb /usr/local/etc/clash/ &&
cp ~/.bashrc ~/.save.bashrc
echo "alias cft='clash -d /usr/local/etc/clash'" >> ~/.bashrc

echo "--------------------------------"
echo "    Successfully installed!!    "
echo "--------------------------------"
