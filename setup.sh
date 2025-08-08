#!/bin/bash
# Run using: `bash setup.sh`

# Borrowed from the harden_meshtasticd project
# https://github.com/pinztrek/harden_meshtasticd/blob/main/harden.sh

REBOOT=false
# exit if ANY steps in this process fails
set -e

### NON-INTERACTIVE CHECK
if [ -z "${DEBIAN_FRONTEND}" ]; then
    export DEBIAN_FRONTEND=noninteractive
fi

### SYSTEM UPDATE & DEPENDENCIES
echo "Running apt update and upgrade"
sudo apt update -qq && sudo apt upgrade -y -o Dpkg::Options::="--force-confnew" -qq

echo "Installing dependencies"
sudo apt install wget lunzip jq git zsh pipx -y -qq

echo "Cleaning up unused dependencies"
sudo apt purge -y exim4-base exim4-config exim4-daemon-light -qq
sudo apt autoremove -y -qq
sudo apt clean -y -qq

### OH MY ZSH INSTALLATION
if [ -d "/home/$USER/.oh-my-zsh" ]; then
  echo "Oh My Zsh is already installed"
else
  echo "Installing oh my zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  sudo chsh -s $(which zsh) $USER
  REBOOT=true
fi

### MESHTASTIC UTILITIES INSTALLATION
echo "Installing Meshtastic CLI and Contact TUI"
pipx install meshtastic && pipx install contact && pipx ensurepath

### DOCKER INSTALLATION
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  # Install Docker using the official installation script
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  rm get-docker.sh
  echo "Docker installed successfully: $(docker --version)"
else
  echo "Docker is already installed: $(docker --version)"
fi

# check if current user is in the docker group
if ! groups $USER | grep -q "\bdocker\b"; then
  echo "Adding current user to the docker group"
  sudo usermod -aG docker $USER
  REBOOT=true
else
  echo "Current user is already in the docker group"
fi

### DISABLE UNNEEDED SERVICES
for service in bluetooth ModemManager
do
  sudo systemctl stop "$service" # Quote $service for safety
  sudo systemctl disable "$service" # Quote $service for safety
  echo "Disabled $service service"
done

### FINISHING UP
echo "Setup complete!"

if [ "$REBOOT" = true ]; then
  echo "Rebooting system..."
  sudo reboot now
else
  echo "No reboot required."
fi
