#!/bin/bash
# Run using: `bash setup.sh`

# Borrowed from the harden_meshtasticd project
# https://github.com/pinztrek/harden_meshtasticd/blob/main/harden.sh

REBOOT=false
# exit if ANY steps in this process fails
set -e

### FUNCTIONS
system_dependencies(){
  echo "Running apt update and upgrade"
  sudo apt update -qq && sudo apt upgrade -y -o Dpkg::Options::="--force-confnew" -qq

  echo "Installing dependencies"
  sudo apt install wget lunzip jq git zsh pipx rpi-connect-lite i2c-tools -y -qq

  echo "Cleaning up unused dependencies"
  sudo apt purge -y exim4-base exim4-config exim4-daemon-light -qq
  sudo apt autoremove -y -qq
  sudo apt clean -y -qq

  echo "Installing Meshtastic CLI and Contact TUI"
  pipx install meshtastic && pipx install contact && pipx ensurepath
}


check_spi(){
  ### Enable SPI if not already enabled
  echo "Checking if SPI is enabled..."
  if command -v raspi-config &> /dev/null; then
    SPI=$(raspi-config nonint get_spi)
    if [ "$SPI" -eq 0 ]; then
      echo "SPI is already enabled"
    else
      echo "SPI is not enabled, enabling now"
      raspi-config nonint do_spi 0
      REBOOT=true
    fi
  else
    echo "raspi-config command not found. Please ensure you are running this on a Raspberry Pi OS."
    exit 1
  fi
}


oh_my_zsh_install(){
  if [ -d "/home/$USER/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed"
  else
    echo "Installing oh my zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    sudo chsh -s $(which zsh) $USER
    REBOOT=true
  fi
}


docker_setup(){
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
}


rpi_connect_setup(){
  ### TURN ON RASPBERRY PI CONNECT
  loginctl enable-linger
  rpi-connect on
  ### SIGNIN TO RPI CONNECT
  rpi-connect signin
}


stop_unneeded_services(){
  for service in bluetooth ModemManager
  do
    sudo systemctl stop "$service" # Quote $service for safety
    sudo systemctl disable "$service" # Quote $service for safety
    echo "Disabled $service service"
  done
}

### NON-INTERACTIVE CHECK
if [ -z "${DEBIAN_FRONTEND}" ]; then
    export DEBIAN_FRONTEND=noninteractive
fi

### SYSTEM UPDATE & DEPENDENCIES
system_dependencies()

### SPI
check_spi()

### OH MY ZSH INSTALLATION
oh_my_zsh_install()

### DOCKER INSTALLATION
docker_setup()

### RPI CONNECT SETUP
rpi_connect_setup()

### DISABLE UNNEEDED SERVICES
stop_unneeded_services()

### FINISHING UP
echo "Setup complete!"

if [ "$REBOOT" = true ]; then
  echo "Rebooting system..."
  sudo reboot now
else
  echo "No reboot required."
fi
