#!/bin/bash
# Author: Hake Hardware
# YouTube: https://www.youtube.com/@hakehardware


# Function to print an error message and exit the script
function error_exit {
  echo "$1" >&2
  exit 1
}

# Determine if the system is Debian or Ubuntu
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  error_exit "Cannot determine the operating system."
fi

# Remove old Docker versions based on OS
echo "Removing old Docker versions (if any)..."
if [ "$OS" = "debian" ]; then
  for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
elif [ "$OS" = "ubuntu" ]; then
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
else
  error_exit "Unsupported operating system: $OS."
fi

# Install dependencies and add Docker's official GPG key
echo "Installing prerequisites..."
sudo apt-get update || error_exit "Failed to update package list."
sudo apt-get install -y ca-certificates curl || error_exit "Failed to install required packages."

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings || error_exit "Failed to create keyrings directory."
sudo curl -fsSL https://download.docker.com/linux/$OS/gpg -o /etc/apt/keyrings/docker.asc || error_exit "Failed to add Docker's GPG key."

# Set permissions
echo "Setting appropriate permissions for Docker's official GPG key"
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Set up the stable repository for Docker based on OS
echo "Setting up the Docker repository..."
if [ "$OS" = "debian" ]; then
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || error_exit "Failed to add Docker repository for Debian."
elif [ "$OS" = "ubuntu" ]; then
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || error_exit "Failed to add Docker repository for Ubuntu."
else
  error_exit "Unsupported operating system: $OS."
fi

# Update package index and install Docker Engine
echo "Installing Docker Engine..."
sudo apt-get update || error_exit "Failed to update package list after adding Docker repository."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error_exit "Failed to install Docker Engine."

# Verify that Docker is installed correctly
echo "Verifying Docker installation..."
sudo docker run --rm hello-world || error_exit "Docker installation verification failed."

echo "Docker installation completed successfully."