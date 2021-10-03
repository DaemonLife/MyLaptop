# MyArchLaptop Installing and setup Arch at Lenovo Ideapad 5 15are05
(EFI, btrfs, encrypt, grub)
https://telegra.ph/Arch--EFI--btrfs-encrypted-09-22
## First steps

Power off terrible laptop sound 

```rmmod pcspkr```

Unblockinf wifi module
```nrfkill unblock wifi```
or
```nrfkill unblock all```

Connect to wifi
```
iwctl
help
device list
station {device} scan
station {device} connect {SSID}
exit
```

Time and keys
```
timedatectl set-ntp true 
loadkeys ru; loadkeys us
```
Создание дисков. Два раздела: EFI (типа EFI) и root (типа Linux 86_64x)
```
cfdisk
```

Crypt root
~~~
cryptsetup luksFormat /dev/sda2
cryptsetup open /dev/sda2 luks
~~~

Format all partitions:
~~~
mkfs.vfat -F32 -n EFI /dev/sda1
mkfs.btrfs -L ROOT /dev/mapper/luks
~~~

Mounting root and create btrfs subvolums 
~~~
mount /dev/mapper/luks /mnt

btrfs sub create /mnt/@
btrfs sub create /mnt/@home

umount /mnt
~~~

Mounting btrfs subvolums
~~~
mkdir /mnt/home

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@ /dev/mapper/luks /mnt

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home /dev/mapper/luks /mnt/home
~~~
Mounting EFI partition:
~~~
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
~~~
Pacstrap
~~~
pacstrap /mnt linux base base-devel btrfs-progs amd-ucode nano linux-firmware iwd networkmanager neovim btrfs-progs
~~~
Fstab
~~~
genfstab -U /mnt >> /mnt/etc/fstab
~~~
## System configuration
~~~
arch-chroot /mnt
~~~
Timezone
~~~
ln -sf /usr/share/zoneinfo/Регион/Город /etc/localtime
hwclock --systohc
~~~

Your locales. Edit /etc/locale.gen, uncomment US, RU (UTF-8). Next:
~~~
echo LANG=en_US.UTF-8 >> /etc/locale.conf
locale-gen
~~~

Your hostname
~~~
echo arch >> /etc/hostname
~~~
Edit /etc/hosts and add:
~~~
127.0.0.1  localhost

::1        localhost

127.0.1.1  arch.localdomain  arch
~~~
Admin password
~~~
passwd
~~~
Install programs to system (I think without grub...)
~~~
pacman -S grub efibootmgr base-devel linux-headers networkmanager network-manager-applet wpa_supplicant dialog os-prober mtools dosfstools reflector git snapper bluez bluez-utils alsa-utils pulseaudio pulseaudio-bluetooth
~~~
Change file /etc/mkinitcpio.conf:
~~~
...
MODULES = (btrfs)
...
HOOKS="base keyboard udev autodetect modconf block keymap encrypt btrfs filesystems"
...
~~~
~~~
mkinitcpio -p linux
~~~
## Boot install
~~~
bootctl --path=/boot install
~~~
Check your UUID
~~~
blkid -s UUID -o value /dev/sda2
~~~
Create file /boot/loader/entries/arch.conf, including UUID (It is simple: blkid -s UUID -o value /dev/sda2 >> /boot/loader/entries/arch.conf):
~~~
title Arch Linux
linux /vmlinuz-linux
initrd /amd-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=<UUID-OF-ROOT-PARTITION>:luks:allow-discards root=/dev/mapper/luks rootflags=subvol=@ rd.luks.options=discard rw
~~~
Change file boot/loader/loader.conf:
~~~
default arch.conf
timeout 4
console-mode max
editor  no
~~~
Add user
~~~
useradd -mG wheel {username}
passwd {username}
EDITOR=nvim visudo
~~~
![270f12c4b9b0c6b946659](https://user-images.githubusercontent.com/52444457/135730210-da2931b0-83f2-44db-b522-8712537a0d3d.png)
~~~
systemctl enable NetworkManager
sudo chmod u+s /usr/bin/light # для яркости экрана на Sway
exit
umount -R /mnt
reboot
~~~ 
