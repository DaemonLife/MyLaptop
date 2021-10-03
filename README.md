# MyArchLaptop Installing and setup Arch at Lenovo Ideapad 5 15are05
(EFI, btrfs, encrypt, grub)
https://telegra.ph/Arch--EFI--btrfs-encrypted-09-22
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
Создание дисков. Два раздела: EFI (типа EFI) и root (типа Linux 86_64x)
```
cfdisk
```

Шифрование корневого раздела
~~~
cryptsetup luksFormat /dev/sda2
cryptsetup open /dev/sda2 luks
~~~

Format all partitions:
~~~
mkfs.vfat -F32 -n EFI /dev/sda1
mkfs.btrfs -L ROOT /dev/mapper/luks
~~~

Монтирование корня и создание пространств / и home 
~~~
mount /dev/mapper/luks /mnt

btrfs sub create /mnt/@
btrfs sub create /mnt/@home

umount /mnt
~~~


Работа с разделами btrfs
~~~
mkdir /mnt/home

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@ /dev/mapper/luks /mnt

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home /dev/mapper/luks /mnt/home
~~~
Монтирование EFI:
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
## Конфигурация системы
~~~
arch-chroot /mnt
~~~
Часовой пояс
~~~
ln -sf /usr/share/zoneinfo/Регион/Город /etc/localtime
hwclock --systohc
~~~

Локализация. Отредактируйте файл /etc/locale.gen, откомментрируйте US, RU (UTF-8)
~~~
echo LANG=en_US.UTF-8 >> /etc/locale.conf
locale-gen
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
Установка пакетов
~~~
pacman -S grub efibootmgr base-devel linux-headers networkmanager network-manager-applet wpa_supplicant dialog os-prober mtools dosfstools reflector git snapper bluez bluez-utils alsa-utils pulseaudio pulseaudio-bluetooth
~~~
Изменить строку в /etc/mkinitcpio.conf (!!!) и добавить модуль btrfs в MODULES:
~~~
HOOKS="base keyboard udev autodetect modconf block keymap encrypt btrfs filesystems"
~~~
![720dcf76eb86db86fb180](https://user-images.githubusercontent.com/52444457/135730130-14fffe96-4267-48c0-8d82-875cbecc40fd.png)
~~~
mkinitcpio -p linux
~~~
##Установка загрузчика
~~~
bootctl --path=/boot install
~~~
Узнаем свой UUID
~~~
blkid -s UUID -o value /dev/sda2
~~~
Создаем и заполняем файл /boot/loader/entries/arch.conf, включая свой UUID (для удобства: blkid -s UUID -o value /dev/sda2 >> /boot/loader/entries/arch.conf):
~~~
title Arch Linux
linux /vmlinuz-linux
initrd /amd-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=<UUID-OF-ROOT-PARTITION>:luks:allow-discards root=/dev/mapper/luks rootflags=subvol=@ rd.luks.options=discard rw
~~~
Очищаем файл boot/loader/loader.conf и добавляем свои строки:
~~~
default arch.conf
timeout 4
console-mode max
editor  no
~~~
Добавляем пользователя
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
