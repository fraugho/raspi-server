#!/bin/bash

# Script to automate the mounting of a hard drive

# Display the block devices and their mount points
echo "Listing block devices:"
lsblk

# Prompt the user to enter the device path
echo "Enter the device path (e.g., /dev/sda1):"
read device_path

# Format the device - CAUTION, this will erase data on the disk
# Uncomment the line below to enable this - dangerous!
#sudo mkfs -t ext4 $device_path

# Create the mount directory
echo "Enter the mount point directory name (e.g., hd1):"
read mount_name
sudo mkdir /mnt/$mount_name

# Change ownership of the mount point (optional, depends on use case)
#sudo chown pi:pi /mnt/$mount_name

# Get the UUID of the disk
uuid=$(sudo blkid -s UUID -o value $device_path)

# Update /etc/fstab with the new mount entry
echo "Adding entry to /etc/fstab"
echo "UUID=$uuid /mnt/$mount_name ext4 defaults 0 1" | sudo tee -a /etc/fstab

# Mount all filesystems in /etc/fstab
sudo mount -a

# Adjust permissions as needed (be careful with 777 permissions)
# Uncomment the line below to enable this
#sudo chmod -R 777 /mnt/$mount_name

echo "Drive $device_path has been formatted (if enabled), mounted at /mnt/$mount_name, and is ready for use."

# Setup WiFi
function setup_wifi() {
    echo "Configuring WiFi Connection..."

    # Navigate to netplan directory
    cd /etc/netplan/

    # Append WiFi setup to the yaml configuration
    echo "Please enter your WiFi SSID:"
    read ssid
    echo "Please enter your WiFi password:"
    read wifi_password

    # Be careful with the following command. It's appending to a system configuration file.
    cat <<EOF | sudo tee -a /etc/netplan/50-cloud-init.yaml
wifis:
    wlan0:
        dhcp4: true
        optional: true
        access-points:
            "$ssid":
                password: "$wifi_password"
EOF

    # Apply changes
    sudo netplan apply
    echo "WiFi configured."
}

# Overclocking Raspberry Pi
function overclock_pi() {
    echo "Starting Overclocking..."

    # This assumes that the config.txt is in this specific directory.
    # Append overclocking configuration to the file
    cat <<EOF | sudo tee -a /boot/firmware/config.txt

# Overclocking settings
over_voltage=6
arm_freq=2000
gpu_freq=700
gpu_mem=320
EOF

    echo "Overclocking settings have been configured. A reboot will be required."
}

# Install CasaOS
function install_casaos() {
    echo "Installing CasaOS..."
    curl -fsSLk https://get.casaos.io | sudo bash
}

# Main script execution
function main() {
    # Call functions defined above (uncomment below lines to enable their execution)
    setup_wifi
    overclock_pi
    setup_hard_drive
    install_casaos

    # It's recommended to reboot after these changes, especially after overclocking
    # Uncomment the line below to enable automatic rebooting
    sudo reboot
}

# Execute the script
main
