# Legion-Go_Disable_controller
A script to disable the Lenovo Legion Go Controllers so they do not disrupt gaming sessions when using external controllers.

This implementation is thought to be implemented on [Bazzite](https://bazzite.gg/), but it might work with other Linux distros or it should be easy to adapt.

Right now my implementation disables the controllers on boot (using the system service), because I don't use the controllers at all. Maybe something like a Decky plugin would be better, but for me and for now, the issue is solved. I will search a better solution on the future.

## Installation
The `legion-go-unbind.sh` script can be used by itself by running it with sudo using the argument 0 to disable and 1 to enable the controls

### Disable on boot
but if you want to disable on boot like me, you should place `legion-go-unbind.sh` in `/var/usrlocal/bin` and `legion-ban-controller.service` to `/etc/systemd/system/`. Then run the commands:

```
sudo systemctl daemon-reload
sudo systemctl enable legion-ban-controller.service
```

## How does it works
This script can disable and enable the Legion Controllers with unbid, it will search for the interface automatically, so it should work on any device "called Legion-Controller 1-78"

This will disable the controller by adding the interface to "/sys/bus/usb/drivers/usbhid/unbind", enable works the same but with "/sys/bus/usb/drivers/usbhid/bind"
