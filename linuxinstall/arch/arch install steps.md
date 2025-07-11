```
localectl list-keymaps
loadkeys hu
setfont ter-132b
cat /sys/firmware/efi/fw_platform_size
ip link
# wifi
iwctl
  device list
  device _name_ set-property Powered on
  adapter _adapter_ set-property Powered on
  station _name_ scan
  station_name_ get-networks
  station _name_ connect _SSID_

iwctl --passphrase _passphrase_ station _name_ connect _SSID_
```
for DHCP
edit /etc/iwd/main.conf

```
[General]
EnableNetworkConfiguration=true

[Network]
RoutePriorityOffset=300

[Network]
EnableIPv6=false

[Network]
NameResolvingService=systemd
```
```
ip link
ping archlinux.org
timedatectl
fdisk -l
```

| Mount point on the installed system | Partition | Partition type | Suggested size |
| :--- | :--- | :--- | :--- |
| /boot| /dev/_efi_system_partition_ | EFI system partition | 1 GiB |
| SWAP | /dev/_swap_partition_ | Linux swap | At least 4 GiB |
| / | /dev/_root_partition_ | Linux x86-64 root (/) | Remainder of the device. At least 23–32 GiB. |

```
mkfs.ext4 /dev/_root_partition_
mkfs.fat -F 32 /dev/_efi_system_partition_
mkswap /dev/_swap_partition_
mount /dev/_root_partition_ /mnt
mount --mkdir /dev/_efi_system_partition_ /mnt/boot
swapon /dev/_swap_partition_
```
```
# szimuláció
archinstall --dry-run

archinstall

# előre elkészített jsonból
archinstall --config https://domain.lan/config.json
```

