# MyArchLaptop
Installing and setup Arch at Lenovo Ideapad 5 15are05 (EFI, btrfs, encrypt)

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
Обновление системного времени.
```
timedatectl set-ntp true
timedatectl status
```
Клавиатура
~~~
loadkeys ru
loadkeys us
~~~
Создание разделов диска
```
cfdisk # создаем два раздела: EFI (sda1) и корневой типа Linux 86_64x (sda2)
```
Шифрование корневого раздела
```
cryptsetup luksFormat /dev/sda2
cryptsetup open /dev/sda2 luks
```
Форматирование
```
mkfs.vfat -F32 -n EFI /dev/sda1
mkfs.btrfs -L ROOT /dev/mapper/luks
```
Монтирование разделов
```
mount /dev/mapper/luks /mnt
```
```
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
```
```
umount /mnt
```
Работа с разделами btrfs
```
mkdir /mnt/home

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@ /dev/mapper/luks /mnt

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home /dev/mapper/luks /mnt/home
```
Монтирование EFI
```
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```
Pacstrap:
```
pacstrap /mnt linux base base-devel btrfs-progs amd-ucode nano linux-firmware iwd networkmanager neovim btrfs-progs
```
Fstab
```
genfstab -U /mnt >> /mnt/etc/fstab
````
Конфигурация системы
```
arch-chroot /mnt
```
Часовой пояс
```
ln -sf /usr/share/zoneinfo/Регион/Город /etc/localtime
hwclock --systohc
```
Локализация. Отредактируйте файл /etc/locale.gen, раскомментировав en_US.UTF-8 UTF-8 и другие необходимые локали (например ru_RU.UTF-8 UTF-8), после чего сгенерируйте их: 
```
echo LANG=en_US.UTF-8 >> /etc/locale.conf
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
locale-gen
```
Запись хоста в файлы
```
echo {myhostname} >> /etc/hostname

nvim /etc/hosts

127.0.0.1  localhost

::1        localhost

127.0.1.1  myhostname.localdomain  myhostname
```
Задать пароль администратору
```
passwd
```
Установка пакетов
```
pacman -S grub efibootmgr base-devel linux-headers networkmanager network-manager-applet wpa_supplicant dialog os-prober mtools dosfstools reflector git snapper bluez bluez-utils alsa-utils pulseaudio pulseaudio-bluetooth
```
Изменить строку в /etc/mkinitcpio.conf и добавить модуль btrfs в MODULES:
```
HOOKS="base keyboard udev autodetect modconf block keymap encrypt btrfs filesystems"
```
![image](https://user-images.githubusercontent.com/52444457/134767266-00c88cde-cd1c-4a67-908c-676140d0cb07.png)

```mkinitcpio -p linux```

Установка загрузчика

```bootctl --path=/boot install```

Узнаем свой UUID
```
blkid -s UUID -o value /dev/sda2
```
Создаем и заполняем файл /boot/loader/entries/arch.conf, включая свой UUID:
```
title Arch Linux
linux /vmlinuz-linux
initrd /amd-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=<UUID-OF-ROOT-PARTITION>:luks:allow-discards root=/dev/mapper/luks rootflags=subvol=@ rd.luks.options=discard rw
```
Очищаем файл boot/loader/loader.conf и добавляем свои строки:
```
default arch.conf
timeout 4
console-mode max
editor  no
```
Добавляем пользователя
```
useradd -mG wheel {username}
passwd {username}
EDITOR=nvim visudo
```
![image](https://user-images.githubusercontent.com/52444457/134767277-1f450e84-73a0-45b8-b5c1-130a086d938a.png)
```
systemctl enable NetworkManager
```
```
exit
umount -R /mnt
reboot
```

## After install
```
nrfkill unblock all
nmtui
sudo pacmna -Syu sway
```
...
