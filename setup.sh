#!/bin/bash

# exit if ANY steps in this process fails
set -e
export DEBIAN_FRONTEND=noninteractive

# echo "Adding Meshtastic repository to apt sources"
# echo 'deb http://download.opensuse.org/repositories/network:/Meshtastic:/beta/Raspbian_12/ /' | sudo tee /etc/apt/sources.list.d/network:Meshtastic:beta.list
# curl -fsSL https://download.opensuse.org/repositories/network:Meshtastic:beta/Raspbian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/network_Meshtastic_beta.gpg > /dev/null

echo "Running apt update and upgrade"
sudo apt update -qq && sudo apt upgrade -y -o Dpkg::Options::="--force-confnew" -qq

echo "Cleaning up unneeded installs"
sudo apt remove -y iptables exim4-base exim4-config exim4-daemon-light -qq
sudo apt purge -y exim4-base exim4-config exim4-daemon-light -qq

echo "Installing dependencies"
sudo apt install wget lunzip jq git zsh pipx -y -qq

if [ ! -f "/root/.oh-my-zsh" ]; then
  echo "Installing oh my zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  chsh -s $(which zsh) $USER
else
  echo "Oh My Zsh is already installed"
fi

echo "Installing Meshtastic CLI and Contact TUI"
pipx install meshtastic && pipx install contact && pipx ensurepath

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

if ! command -v docker &> /dev/null; then
  echo "Docker not found. Installing Docker..."
  # Install Docker using the official installation script
  curl -sSL https://get.docker.com | sh
else
  echo "Docker is already installed: $(docker --version)"
fi

# check if current user is in the docker group
if ! groups $USER | grep -q "\bdocker\b"; then
  echo "Adding current user to the docker group"
  sudo usermod -aG docker $USER
else
  echo "Current user is already in the docker group"
fi

echo "Cleaning up unused dependencies"
sudo apt autoremove -y -qq
sudo apt clean -y -qq

echo "Script complete. Rebooting..."
sudo reboot now
