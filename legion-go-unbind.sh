#!/usr/bin/env bash
# Script to disable or enable Lenovo Legion-Controller interfaces
# Usage: ./controller.sh 0   → disable (unbind and save)
#        ./controller.sh 1   → enable (bind from saved list)

set -e  # Exit immediately if a command fails

# Configuration
controller_name="Legion-Controller 1-78"
usb_base="/sys/bus/usb/devices"
saved_list="/tmp/legion_interfaces.txt"

# Get action argument
action="$1"

if [[ -z "$action" ]]; then
  echo "No action provided. Usage: $0 0 (disable) or 1 (enable)"
  exit 0
fi

# Decide unbind/bind
if [[ "$action" == "0" ]]; then
  action_str="unbind"
elif [[ "$action" == "1" ]]; then
  action_str="bind"
else
  echo "Invalid argument: must be 0 (unbind) or 1 (bind)"
  exit 1
fi

# Disable (unbind) logic
if [[ "$action_str" == "unbind" ]]; then
  for dev in "$usb_base"/*; do
    [[ -f "$dev/product" ]] || continue
    prod_name=$(< "$dev/product")
    [[ "$prod_name" == "$controller_name" ]] || continue

    dev_name=$(basename "$dev")

    # Find all usbhid interfaces for the controller
    mapfile -t interfaces < <(ls /sys/bus/usb/drivers/usbhid/ | grep "^$dev_name:")

    if [[ "${#interfaces[@]}" -eq 0 ]]; then
      echo "Nothing found. Nothing to unbind."
      exit 1
    fi

    echo "Found controller: $dev_name"
    : > "$saved_list"  # Empty the file before writing
    for iface in "${interfaces[@]}"; do
      echo "$iface" > "/sys/bus/usb/drivers/usbhid/unbind"
      echo "$iface" >> "$saved_list"
      echo "Unbound: $iface"
    done
  done

# Enable (bind) logic
elif [[ "$action_str" == "bind" ]]; then
  if [[ ! -f "$saved_list" ]]; then
    echo "No saved interface list found. Nothing to bind."  
    exit 1
  fi

  mapfile -t interfaces < "$saved_list"
  for iface in "${interfaces[@]}"; do
    echo "$iface" > "/sys/bus/usb/drivers/usbhid/bind"
    echo "Rebound: $iface"
  done

  rm -f "$saved_list"
  echo "Cleaned up saved list."
fi
