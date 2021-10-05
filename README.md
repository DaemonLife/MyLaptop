Linux

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

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@ /dev/mapper/luks /mnt


mkdir /mnt/home


mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home /dev/mapper/luks /mnt/home

~~~

Mounting EFI partition:

~~~

mkdir /mnt/boot

mount /dev/sda1 /mnt/boot

~~~

Pacstrap

~~~

pacstrap /mnt linux base base-devel btrfs-progs amd-ucode nano linux-firmware iwd networkmanager neovim

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

ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

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

127.0.0.1 localhost


::1       localhost


127.0.1.1 arch.localdomain arch

~~~

Admin password

~~~

passwd

~~~

Install programs to system

~~~

pacman -S grub efibootmgr network-manager-applet wpa_supplicant os-prober mtools dosfstools reflector git bluez bluez-utils alsa-utils pulseaudio pulseaudio-bluetooth

~~~

Change file /etc/mkinitcpio.conf:

~~~

...

MODULES = (btrfs)

...

HOOKS="base keyboard udev autodetect modconf block keymap encrypt btrfs filesystems fsck"

...

~~~


~~~

mkinitcpio -p linux

~~~


## Boot install

Check your UUID

~~~

blkid -s UUID -o value /dev/sda2

~~~

blkid -s UUID -o value /dev/sda2 >> /etc/default/grub

~~~

Change xxxx to your UUID

~~~

GRUB_CMDLINE_LINUX="cryptdevice=UUID=xxxx:cryptroot"

~~~


Install grub

~~~

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB


grub-mkconfig -o /boot/grub/grub.cfg

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

# umount -R /mnt

reboot

~~~ 


