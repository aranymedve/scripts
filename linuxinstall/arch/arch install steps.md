```
localectl list-keymaps
loadkeys hu
setfont ter-132b
cat /sys/firmware/efi/fw_platform_size
ip link
# wifi
iwctl
  device list
  device __name__ set-property Powered on
  adapter __adapter__ set-property Powered on
  station __name__ scan
  station__name__ get-networks
  station __name__ connect __SSID__

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
|     |     |     |     |
| --- | --- | --- | --- |UEFI with [GPT](https://wiki.archlinux.org/title/GPT "GPT")
| Mount point on the installed system | Partition | [Partition type](https://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_type_GUIDs "wikipedia:GUID Partition Table") | Suggested size |
| `/boot`^1^ | `/dev/_efi_system_partition_` | [EFI system partition](https://wiki.archlinux.org/title/EFI_system_partition "EFI system partition") | 1 GiB |
| `[SWAP]` | `/dev/_swap_partition_` | Linux swap | At least 4 GiB |
| `/` | `/dev/_root_partition_` | Linux x86-64 root (/) | Remainder of the device. At least 23–32 GiB. |

```
mkfs.ext4 /dev/_root_partition_
mkfs.fat -F 32 /dev/_efi_system_partition_
mkswap /dev/_swap_partition_
mount /dev/_root_partition_ /mnt
mount --mkdir /dev/_efi_system_partition_ /mnt/boot
swapon /dev/_swap_partition_

archinstall
```