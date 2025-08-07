#!/bin/bash

# exit if ANY steps in this process fails
set -e

# echo "Adding Meshtastic repository to apt sources"
# echo 'deb http://download.opensuse.org/repositories/network:/Meshtastic:/beta/Raspbian_12/ /' | sudo tee /etc/apt/sources.list.d/network:Meshtastic:beta.list
# curl -fsSL https://download.opensuse.org/repositories/network:Meshtastic:beta/Raspbian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/network_Meshtastic_beta.gpg > /dev/null

echo "Running apt update and upgrade"
sudo apt update && sudo apt upgrade -y

echo "Cleaning up unneeded installs"
apt remove -y iptables exim4-base exim4-config exim4-daemon-light
apt purge -y exim4-base exim4-config exim4-daemon-light

echo "Installing dependencies"
sudo apt install wget lunzip jq git zsh pipx -y

echo "Installing Meshtastic CLI and Contact TUI"
pipx install meshtastic && pipx install contact && pipx ensurepath

echo "Installing oh my zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# echo "Pulling config.yml file for Nebra hat"
# sudo wget -O /etc/meshtasticd/config.d/NebraHat_2W.yaml https://github.com/migillett/Meshtastic-Hardware/raw/refs/heads/main/NebraHat/NebraHat_2W.yaml

# echo "Appending General configuration parameters to config file"
# sudo tee -a /etc/meshtasticd/config.d/NebraHat_2W.yaml << 'EOF'
# Logging:
#   LogLevel: info

# General:
#   MACAddressSource: eth0
#   MaxNodes: 200
#   MaxMessageQueue: 100
#   ConfigDirectory: /etc/meshtasticd/config.d/
# EOF

echo "Installing Docker"
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $USER

echo "Cleaning up unused dependencies"
sudo apt autoremove -y

echo "Script complete. Rebooting..."
sudo reboot now
