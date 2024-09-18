#!/bin/sh

# Function to display help message
display_help() {
    echo "Usage: $0 [side]"
    echo "Mounts the nice!nano MCU for flashing the specified side (left/left-reset or right/right-reset) of the keyboard."
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
if [ "$1" != "left" ] && [ "$1" != "left-reset" ]  && [ "$1" != "right-reset" ] && [ "$1" != "right" ]; then
    echo "Error: Invalid side specified"
    display_help
fi

# Give some time to the user to mount the device.
sleep 5

# Create a mount point
mkdir -p /media/usb

# Define the USB device paths
LEFT_DEVICE="/dev/disk/by-id/usb-Adafruit_nRF_UF2_902003A32A806BD7-0:0"
RIGHT_DEVICE="/dev/disk/by-id/usb-Adafruit_nRF_UF2_97A391CF144F945C-0:0"

# Mount the USB drive based on the specified side
if [ "$1" == "left" ]; then
    sudo mount $LEFT_DEVICE /media/usb
    sudo cp build/left/zephyr/zmk.uf2 /media/usb/
elif [ "$1" == "left-reset" ]; then
    sudo mount $LEFT_DEVICE /media/usb
    sudo cp build/reset/zephyr/zmk.uf2 /media/usb/
elif [ "$1" == "right" ]; then
    sudo mount $RIGHT_DEVICE /media/usb
    sudo cp build/right/zephyr/zmk.uf2 /media/usb/
elif [ "$1" == "right-reset" ]; then
    sudo mount $RIGHT_DEVICE /media/usb
    sudo cp build/reset/zephyr/zmk.uf2 /media/usb/
fi

# End message
echo "Flashing to $1 side completed."

# Exit script
exit 0
