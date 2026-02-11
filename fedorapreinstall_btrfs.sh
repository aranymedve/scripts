#!/bin/bash
#!/usr/bin/env bash
set -e

DISK="/dev/nvme0n1"

echo ">>> WIPING disk $DISK ..."
wipefs -a "$DISK"
sgdisk -o "$DISK"

echo ">>> Creating partitions..."
# EFI partition
sgdisk -n 1:0:+1G -t 1:ef00 "$DISK"
# Btrfs partition
sgdisk -n 2:0:0    -t 2:8300 "$DISK"

sleep 2

EFI="${DISK}p1"
ROOT="${DISK}p2"

echo ">>> Formatting EFI partition..."
mkfs.vfat -F32 "$EFI" -n EFI

echo ">>> Creating Btrfs filesystem..."
mkfs.btrfs -f "$ROOT" -L fedora

echo ">>> Mounting the new Btrfs filesystem..."
mount "$ROOT" /mnt

echo ">>> Creating Timeshift-compatible subvolumes..."
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@tmp

echo ">>> Subvolumes created:"
btrfs subvolume list /mnt

echo ">>> Unmounting temporary mount..."
umount /mnt

echo ">>> Remounting with proper layout..."
mount -o subvol=@ "$ROOT" /mnt
mkdir -p /mnt/{boot/efi,home,var/log,var/cache,var/tmp}

mount -o subvol=@home "$ROOT" /mnt/home
mount -o subvol=@log "$ROOT" /mnt/var/log
mount -o subvol=@cache "$ROOT" /mnt/var/cache
mount -o subvol=@tmp "$ROOT" /mnt/var/tmp

mount "$EFI" /mnt/boot/efi

echo ">>> DONE!"
echo "Now return to the graphical installer and choose:"
echo "  - Custom partitioning"
echo "  - DO NOT format the Btrfs partition"
echo "  - Set mountpoints like this:"
echo "        /  -> Btrfs subvol=@"
echo "        /home -> Btrfs subvol=@home"
echo "        /var/log -> Btrfs subvol=@log"
echo "        /var/cache -> Btrfs subvol=@cache"
echo "        /var/tmp -> Btrfs subvol=@tmp"
echo "        /boot/efi -> EFI partition"