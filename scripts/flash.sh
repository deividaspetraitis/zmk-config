#!/bin/sh

# Function to display help message
display_help() {
    echo "Usage: $0 [side]"
    echo "Mounts the nice!nano MCU for flashing the specified side (left or right) of the keyboard."
    echo "Example: $0 left"
    exit 1
}

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root"
    exit 1
fi

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No side specified"
    display_help
fi

# Check if the argument is valid
if [ "$1" != "left" ] && [ "$1" != "right" ]; then
    echo "Error: Invalid side specified"
    display_help
fi

# Give some time to the user to mount the device.
sleep 5

# Create a mount point
mkdir -p /media/usb

# Mount the USB drive based on the specified side
if [ "$1" == "left" ]; then
    sudo mount /dev/disk/by-id/usb-Adafruit_nRF_UF2_38F4230B63B3DA6E-0:0 /media/usb
    sudo cp build/left/zephyr/zmk.uf2 /media/usb/
elif [ "$1" == "right" ]; then
    sudo mount /dev/disk/by-id/usb-Adafruit_nRF_UF2_97A391CF144F945C-0:0 /media/usb
    sudo cp build/right/zephyr/zmk.uf2 /media/usb/
fi

# End message
echo "Flashing to $1 side completed."

# Exit script
exit 0
