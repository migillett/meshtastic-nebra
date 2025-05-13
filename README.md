# Meshtastic Nebra Experiments
Documentation for experimenting with the Nebra Helium Miners and Meshtastic

## Finding Your USB Path
You'll need to modify the [Docker Compose](docker-compose.yml) file `devices:` field to whatever the USB path is on your device. Here's how to find that:
1. run `lsusb` on your machine. You'll see an output that looks like this:
```
Bus 001 Device 007: ID 1a86:5512 QinHeng Electronics CH341 in EPP/MEM/I2C mode, EPP/I2C adapter
[...]
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```
2. Look for the device that says `QinHeng Electronics CH341 in EPP/MEM/I2C mode, EPP/I2C adapter`. You'll want to write down the Bus number and Device number.
3. Run `ls /dev/bus/usb/{busDeviceFromStep1}` to make sure that the device exists.
4. Go to the [Docker Compose](docker-compose.yml) file and modify the devices line to say: `- "/dev/bus/usb/{Bus}/{Device}:/dev/bus/usb/{Bus}/{Device}"`

## Node Configuration Example
I included the current configuration of my node as well in the [Node Preferences](node_prefs.yml) file (excluding my private keys and position data) as an example of what I have working.
