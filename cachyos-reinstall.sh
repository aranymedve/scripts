#!/usr/bin/env bash
set -e

# Pacman repo csomagok
if [[ -f pacman-pkglist.txt ]]; then
  echo "Telepítés pacman-nal..."
  sudo pacman -S --needed --noconfirm - < pacman-pkglist.txt
fi

# AUR / foreign csomagok
if [[ -f aur-pkglist.txt ]]; then
  echo "Telepítés yay-jel..."
  yay -S --needed --noconfirm - < aur-pkglist.txt
fi
