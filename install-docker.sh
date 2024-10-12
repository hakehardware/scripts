#!/bin/bash

# Update repositories to ensure we have the latest packages
echo "Updating repositories..."
sudo apt update -y

# Install required dependencies
echo "Installing dependencies..."
sudo apt install -y ca-certificates curl

# Create the keyring directory if it doesn't exist
echo "Creating keyring directory..."
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's GPG key into the keyring directory
echo "Downloading Docker's GPG key..."
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc

# Set the appropriate permissions for docker.asc
echo "Setting permissions for Docker's GPG key..."
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's official repository to the system's package sources list
echo "Adding Docker's official repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update repositories to fetch Docker packages
echo "Updating repositories to get Docker packages..."
sudo apt update -y

# Install Docker packages
echo "Installing Docker packages..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Check Docker version to confirm installation
echo "Docker installation completed."
docker --version
