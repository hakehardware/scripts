#!/bin/bash

# Function to check if the drive is the OS drive
is_os_drive() {
    local drive=$1

    # Check if any partitions from this drive are mounted as /boot or /
    if mount | grep -q "^/dev/${drive}p.* on /boot" || mount | grep -q "^/dev/${drive}p.* on / "; then
        return 0  # It's an OS drive
    else
        return 1  # It's not an OS drive
    fi
}

# Function to check if the drive is already mounted
is_mounted() {
    local drive=$1
    if mount | grep -q "^/dev/$drive "; then
        return 0  # Drive is mounted
    else
        return 1  # Drive is not mounted
    fi
}

# Function to prepare a drive for Autonomys
prepare_drive() {
    local drive=$1
    local create_fstab=$2
    echo "Preparing $drive for Autonomys..."

    # Check if the drive is the OS drive
    if is_os_drive "$drive"; then
        echo "WARNING: $drive appears to be the OS drive (contains /boot or /). Skipping..."
        return
    fi

    # Check if the drive is already mounted
    if is_mounted "$drive"; then
        echo "WARNING: $drive is currently mounted."
        read -p "Do you want to unmount /dev/$drive and continue? (Y/N): " unmount_choice
        if [[ "$unmount_choice" == "Y" || "$unmount_choice" == "y" ]]; then
            echo "Unmounting /dev/$drive..."
            sudo umount /dev/$drive
        else
            echo "Skipping $drive."
            return
        fi
    fi

    # Check if partitions exist and remove them
    if lsblk | grep -q "${drive}p"; then
        echo "Removing partitions on $drive..."
        for part in $(lsblk -n -o NAME | grep "${drive}p"); do
            echo "Deleting partition $part..."
            wipefs --all /dev/$part
        done
    fi

    # Create ext4 file system
    echo "Creating ext4 file system on /dev/$drive..."
    mkfs -t ext4 -F /dev/$drive

    # Remove reserved space
    echo "Removing reserved space on /dev/$drive..."
    tune2fs -r 0 /dev/$drive

    # Get the UUID of the formatted drive
    uuid=$(blkid -s UUID -o value /dev/$drive)
    last_five=${uuid: -5}

    # Create the mount point directory
    mount_point="/media/autonomys/farm-$last_five"
    mkdir -p "$mount_point"

    # Mount the drive
    echo "Mounting /dev/$drive to $mount_point..."
    mount /dev/$drive $mount_point

    # Set ownership to nobody:nogroup
    echo "Setting ownership of $mount_point to nobody:nogroup..."
    chown -R nobody:nogroup $mount_point

    # If the user wants to create FSTAB entries
    if [[ "$create_fstab" == "Y" || "$create_fstab" == "y" ]]; then
        # Generate the fstab entry
        fstab_entry="UUID=$uuid $mount_point ext4 defaults,noatime,nofail  0 0"
        echo "Adding fstab entry for $drive..."
        
        # Add to fstab with a comment
        echo -e "\n# Autonomys\n$fstab_entry" | sudo tee -a /etc/fstab
        echo "FSTAB entry added for $drive."
    fi

    echo "$drive prepared, mounted, and ownership set successfully!"
}

# Ask user if they want to create FSTAB entries
read -p "Do you want to create FSTAB entries for the drives? (Y/N): " create_fstab

# Loop through NVMe drives
for drive in /dev/nvme*n1; do
    read -p "Do you want to prepare $drive for Autonomys? (Y/N): " choice
    if [[ "$choice" == "Y" || "$choice" == "y" ]]; then
        prepare_drive "$(basename $drive)" "$create_fstab"
    else
        echo "Skipping $drive."
    fi
done

echo "Script completed."
