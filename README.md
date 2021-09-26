# MyArchLaptop Installing and setup Arch at Lenovo Ideapad 5 15are05
(EFI, btrfs, encrypt, grup)

## Первичные шаги

Выключить звуки ноутбука до перезагрузки. 

```rmmod pcspkr```

Подлкючение к Wifi. Для начала выключим блокировку модуля, если она имеется:

```nrfkill unblock wifi```

Подключаемся.
```
iwctl
help
device list
station {device} scan
station {device} connect {SSID}
exit
```

Время и раскладка клавиатуры
```
timedatectl set-ntp true 
loadkeys ru; loadkeys us
```
Подготовка к шифрованию
```
modprobe dm-crypt
modprobe dm-mod
```

Создание дисков. EFI (указать тип) на 256М, Boot 512М, Root all
```
cfdisk
```

Шифрование
~~~
cryptsetup luksFormat -v -s 512 -h sha512 /dev/sda3
cryptsetup open /dev/sda3 luks_root
~~~

Format all partitions:
~~~
mkfs.vfat -n "EFI" /dev/sda1

mkfs.ext4 -L boot /dev/sda2

mkfs.btrfs -L root /dev/mapper/luks_root
~~~

Монтирование корня и создание пространств / и home 
~~~
mount /dev/mapper/luks_root /mnt

btrfs sub create /mnt/@
btrfs sub create /mnt/@home

umount /mnt
~~~


Работа с разделами btrfs
~~~
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@
/dev/mapper/luks_root /mnt

mkdir /mnt/home 

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home
/dev/mapper/luks /mnt/home
~~~


Now mount them:

~~~
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
~~~

~~~
pacstrap -i /mnt base base-devel efibootmgr grub linux linux-firmare networkmanager sudo vi vim bash-completion nano
~~~
~~~
genfstab -U /mnt >> /mnt/etc/fstab
~~~
~~~
arch-chroot /mnt
~~~

Локализация. Отредактируйте файл /etc/locale.gen, раскомментировав en_US.UTF-8 UTF-8 и другие необходимые локали (например ru_RU.UTF-8 UTF-8), после чего сгенерируйте их: 
~~~

echo LANG=en_US.UTF-8 >> /etc/locale.conf
locale-gen
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
~~~

Запись хоста в файлы
```
echo arch >> /etc/hostname

nvim /etc/hosts

127.0.0.1  localhost

::1        localhost

127.0.1.1  arch.localdomain  arch
```
Задать пароль администратору
```
passwd
```
~~~
nvim /etc/default/grub
// GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda3:luks_root"

nvim /etc/mkinitcpio.conf 
// HOOK=(.block encrypt.....)
~~~
~~~
mkinitcpio -p linux
~~~
~~~
grub-install --boot-directory=/boot --efi-directory=/boot/efi /dev/sda2

grub-mkconfig -o /boot/grub/grub.cfg

grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg
~~~
Reboot
~~~
exit
reboot
~~~
-------------------------------------------------------------------
~~~
sudo pacman -S amd-ucode
~~~
~~~
sudo install tlp tlp-rw
sudo systemctl enable --now tlp.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

// Run ‘tlp-stat’ and install other recommended packages
~~~

    
