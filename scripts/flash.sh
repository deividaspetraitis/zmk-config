#!/bin/sh

# Check if the script is run as root
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Give some time to the user to mount the device.
sleep 5

# Right
sudo mount /dev/disk/by-id/usb-Adafruit_nRF_UF2_97A391CF144F945C-0:0 /media/usb
sudo cp build/right/zephyr/zmk.uf2 /media/usb/

# Left
# sudo mount /dev/disk/by-id/usb-Adafruit_nRF_UF2_38F4230B63B3DA6E-0:0 /media/usb # old
# sudo cp build/left/zephyr/zmk.uf2 /media/usb/

# sudo cp build/reset/zephyr/zmk.uf2 /media/usb
# sudo cp ~/Downloads/zmk_clear.uf2 /media/usb
