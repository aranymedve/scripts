#!/bin/bash
sudo pacman -Qqem > aur-pkglist.txt
sudo pacman -Qqe | grep -Fvx "$(pacman -Qqm)" > pacman-pkglist.txt
