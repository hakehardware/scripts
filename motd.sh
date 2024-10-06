#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# LAN IP address
LAN_IP=$(ip addr show $(ip route get 1.1.1.1 | awk '{print $5}' | head -n 1) | grep "inet " | awk '{print $2}' | cut -d/ -f1)

# Uptime
UPTIME=$(uptime -p)

# CPU Info with core count
CPU_MODELS=$(lscpu | grep "Model name" | awk -F: '{print $2}' | sed 's/^ *//g')
CPU_MODELS=$(echo "$CPU_MODELS" | tr '\n' ',' | sed 's/,$//')  # Make it comma-separated
CPU_CORES=$(lscpu | grep "^CPU(s):" | awk -F: '{print $2}' | sed 's/^ *//g')

# RAM Info in GB
TOTAL_RAM=$(free -g | grep Mem | awk '{print $2}') # Convert to GB

# Disk Usage on boot drive in GB
DISK_USAGE=$(df -BG / | awk 'NR==2 {print $3 " used of " $2}')

# Display the MOTD
echo -e "${GREEN}============================================="
echo -e "${CYAN}            System Information"
echo -e "${GREEN}============================================="
echo -e "${BLUE}LAN IP Address: ${YELLOW}$LAN_IP"
echo -e "${BLUE}Uptime:         ${YELLOW}$UPTIME"
echo -e "${BLUE}CPU Model(s):   ${YELLOW}$CPU_MODELS"
echo -e "${BLUE}Total Cores:    ${YELLOW}$CPU_CORES"
echo -e "${BLUE}Total RAM:      ${YELLOW}${TOTAL_RAM}GB"
echo -e "${BLUE}Disk Usage:     ${YELLOW}$DISK_USAGE"
echo -e "${GREEN}=============================================${NC}"
