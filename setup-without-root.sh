#!/bin/bash

chsh -s `which zsh`

# Set up yay
echo "===== Setting up yay ====="
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd

# Install mkinitcpio firmwares
echo "===== Installing mkinitcpio firmwares ====="
yay -S mkinitcpio-firmware

# Install Ibus Bamboo
echo "===== Installing IBus Bamboo ====="
bash -c "$(curl -fsSL https://raw.githubusercontent.com/BambooEngine/ibus-bamboo/master/archlinux/install.sh)"
