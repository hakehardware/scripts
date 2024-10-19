#!/bin/bash
# Author: Hake Hardware
# YouTube: https://www.youtube.com/@hakehardware

# Update and install necessary packages
sudo apt-get update
sudo apt-get install -y curl

# Detect the system architecture
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then
    ARCH_TYPE="amd64"
elif [[ "$ARCH" == "aarch64" ]]; then
    ARCH_TYPE="arm64"
else
    echo "Script is not set up to support this architecture: $ARCH"
    exit 1
fi

echo "Detected $ARCH_TYPE architecture type."

# Fetch the latest Node Exporter release version (with the 'v' prefix)
NODE_EXPORTER_VERSION=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep 'tag_name' | cut -d\" -f4)

echo "Downloading Node Exporter version: $NODE_EXPORTER_VERSION"

# Remove the 'v' from the version for the file name (as it doesn't have the 'v')
NODE_EXPORTER_VERSION_NO_V=$(echo $NODE_EXPORTER_VERSION | sed 's/^v//')

# Download the appropriate Node Exporter binary based on architecture
curl -sSLO https://github.com/prometheus/node_exporter/releases/download/${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION_NO_V}.linux-${ARCH_TYPE}.tar.gz

# Extract the downloaded file
tar xvf node_exporter-${NODE_EXPORTER_VERSION_NO_V}.linux-${ARCH_TYPE}.tar.gz

# Move Node Exporter binary to /usr/local/bin
sudo mv node_exporter-${NODE_EXPORTER_VERSION_NO_V}.linux-${ARCH_TYPE}/node_exporter /usr/local/bin/

# Remove the downloaded files
rm -rf node_exporter-${NODE_EXPORTER_VERSION_NO_V}.linux-${ARCH_TYPE}.tar.gz node_exporter-${NODE_EXPORTER_VERSION_NO_V}.linux-${ARCH_TYPE}

# Create a user for Node Exporter
sudo useradd --no-create-home --shell /bin/false node_exporter

# Set ownership and permissions
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create a systemd service file for Node Exporter
sudo bash -c 'cat <<EOF >/etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd to apply the new service file
sudo systemctl daemon-reload

# Start and enable Node Exporter
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Verify that the service is running
echo "Node Exporter service status:"
sudo systemctl status node_exporter --no-pager

# Confirm installation
echo "Node Exporter has been installed and is running as a service."
/usr/local/bin/node_exporter --version