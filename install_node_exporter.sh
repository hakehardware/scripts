#!/bin/bash

# Fetch the latest release version from the GitHub API (e.g., "v1.8.2")
LATEST_RELEASE=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep "tag_name" | awk -F '"' '{print $4}')

# Strip the leading 'v' from the version tag (e.g., "1.8.2" instead of "v1.8.2")
VERSION=${LATEST_RELEASE#v}

# Define the download URL for the arm64 binary (using the stripped version)
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/${LATEST_RELEASE}/node_exporter-${VERSION}.linux-arm64.tar.gz"

# Download the latest arm64 version of Node Exporter with retry mechanism
echo "Downloading Node Exporter ${VERSION} for arm64..."
wget -q $DOWNLOAD_URL -O node_exporter.tar.gz

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to download Node Exporter. Exiting."
    exit 1
fi

# Extract the downloaded tarball
echo "Extracting Node Exporter..."
tar -xzf node_exporter.tar.gz

# Check if the extraction was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract Node Exporter. Exiting."
    exit 1
fi

# Move the binary to /usr/local/bin
echo "Installing Node Exporter..."
if [ -f node_exporter-${VERSION}.linux-arm64/node_exporter ]; then
    sudo mv node_exporter-${VERSION}.linux-arm64/node_exporter /usr/local/bin/node_exporter
else
    echo "Error: Node Exporter binary not found. Exiting."
    exit 1
fi

# Clean up the downloaded files
rm -rf node_exporter-${VERSION}.linux-arm64 node_exporter.tar.gz

# Make sure the binary is executable
sudo chmod +x /usr/local/bin/node_exporter

# Create a node_exporter user (without home directory and no-login shell)
echo "Creating node_exporter user..."
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create a systemd service file for Node Exporter
echo "Creating systemd service file for Node Exporter..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOL
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
EOL

# Reload systemd to recognize the new service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable and start the Node Exporter service
echo "Enabling and starting Node Exporter service..."
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Verify that the service is running
echo "Node Exporter service status:"
sudo systemctl status node_exporter --no-pager

# Confirm installation
echo "Node Exporter has been installed and is running as a service."
/usr/local/bin/node_exporter --version
