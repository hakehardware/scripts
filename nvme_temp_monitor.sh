#!/bin/bash

# CSV File path
output_file="/var/log/nvme_temps.csv"

# Initialize CSV file with headers if not present
if [ ! -f "$output_file" ]; then
    # Create the CSV header dynamically based on the detected NVMe devices
    header="datetime"
    for nvme_device in $(ls /dev/nvme[0-9]*); do
        header="${header},$(basename $nvme_device)_temp"
    done
    header="${header},average_temp"
    echo "$header" > "$output_file"
fi

# Function to fetch NVMe temperature and remove the °C symbol
get_nvme_temp() {
    device=$1
    temp=$(nvme smart-log $device | grep "temperature" | awk '{print $3}' | sed 's/[^0-9.]//g')
    echo "$temp"
}

# Main loop to log temperature every 5 seconds
while true; do
    # Get the current timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Initialize variables to store temperatures and calculate the average
    total_temp=0
    num_devices=0
    temp_values=""

    # Loop through each NVMe device and fetch its temperature
    for nvme_device in $(ls /dev/nvme[0-9]*); do
        nvme_temp=$(get_nvme_temp $nvme_device)
        temp_values="${temp_values},$nvme_temp"
        total_temp=$(awk "BEGIN {print $total_temp + $nvme_temp}")
        num_devices=$((num_devices + 1))
    done

    # Calculate the average temperature
    average_temp=$(awk "BEGIN {print $total_temp / $num_devices}")

    # Append the data to the CSV file
    echo "$timestamp$temp_values,$average_temp" >> "$output_file"

    # Print the data to the screen
    echo "$timestamp - NVMe Temperatures: $temp_values, Avg Temp: $average_temp°C"

    # Wait for 5 seconds before next iteration
    sleep 5
done
