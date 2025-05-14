# Meshtastic Nebra Experiments
Documentation for experimenting with the [Nebra Helium Miners](https://www.ebay.com/itm/205168616664) and [Meshtastic](https://meshtastic.org).

## Finding Your USB Path
You'll need to modify the [Docker Compose](docker-compose.yml) file `devices:` field to whatever the USB path is on your device. Here's how to find that:
1. run `lsusb` on your machine. You'll see an output that looks like this:
```
Bus 001 Device 007: ID 1a86:5512 QinHeng Electronics CH341 in EPP/MEM/I2C mode, EPP/I2C adapter
[...]
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```
2. Look for the device that says `QinHeng Electronics CH341 in EPP/MEM/I2C mode, EPP/I2C adapter`. You'll want to write down the Bus number.
3. Run `ls /dev/bus/usb/{busDeviceFromStep1}` to make sure that the device exists.
4. Go to the [Docker Compose](docker-compose.yml) file and modify the devices line to say: `- "/dev/bus/usb/{Bus}:/dev/bus/usb/{Bus}"`

## Node Configuration Example
I included the current configuration of my node as well in the [Node Preferences](node_prefs.yml) file (excluding my private keys and position data) as an example of what I have working.

## USB Auto-shutoff
One thing we've discovered in our testing is that the USB device stops responding after a period of time (I estimate it to be about 3 hours). My currenty hypothesis is that it's a USB auto-shutoff configuration. See [this article](https://hamwaves.com/usb.autosuspend/en/) for more information.

One way to tackle this issue is to disable USB power/control for all devices. You can be specific and target the brandId and vendorId, but this is a way to do it for all devics.

Make a udev rule that any device plugged into the computer will have power control disabled.
```bash
# Create a file called /etc/udev/rules.d/50-usb-power-control.rules
# with the following content:
ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
```

Reload the udev rules by running the following commands:
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=usb
```

Reboot the system then check for the change using:
```bash
grep -l "auto" /sys/bus/usb/devices/*/power/control
```
