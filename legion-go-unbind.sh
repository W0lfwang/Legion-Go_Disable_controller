#!/usr/bin/env bash
# Script to find Lenovo Legion-Controller interfaces and unbind/bind them
# This shiould go to /var/usrlocal/bin
# Usage: ./script.sh 0   -> unbind
#        ./script.sh 1   -> bind
#        ./script.sh     -> does nothing

set -e  # Exit on any command failure

# Check for a valid argument
action="$1"

if [[ -z "$action" ]]; then
  echo "No action provided. Exiting."
  exit 0
fi

if [[ "$action" == "0" ]]; then
  action_str="unbind"
elif [[ "$action" == "1" ]]; then
  action_str="bind"
else
  echo "Invalid argument: must be 0 (unbind) or 1 (bind)"
  exit 1
fi

controller_name="Legion-Controller 1-78"
usb_base="/sys/bus/usb/devices"

for dev in "$usb_base"/*; do
  if [[ -f "$dev/product" ]]; then
    prod_name=$(< "$dev/product")
    if [[ "$prod_name" == "$controller_name" ]]; then
      dev_name=$(basename "$dev")
      echo "Found device: $dev_name"

      # Get all matching usbhid interfaces
      mapfile -t interfaces < <(ls /sys/bus/usb/drivers/usbhid/ | grep "^$dev_name:")

      echo "Interfaces found: ${interfaces[*]}"

      for iface in "${interfaces[@]}"; do
        echo "Processing $iface -> $action_str"
        # echo "$iface" > "/sys/bus/usb/drivers/usbhid/$action_str"
        echo "$iface" | sudo tee "/sys/bus/usb/drivers/usbhid/$action_str"
      done
    fi
  fi
done
