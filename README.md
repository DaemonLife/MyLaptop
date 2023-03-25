# MyArchLaptop Installing and setup

## 1.0 First steps

Power off a terrible laptop sound 
```rmmod pcspkr```

Unblockinf wifi module
```rfkill unblock wifi```
or
```rfkill unblock all```

Connect to wifi
```
iwctl
help
device list
station {device} scan
station {device} connect {SSID}
exit
ping archlinux.org
```

## 1.1 The Easy Way 

Just run Archinstall and jump to chapter 3.0 - it's easy!!! or do it all suffering...

## 2.0

Time and keys
```
timedatectl set-ntp true
timedatectl
loadkeys ru; loadkeys us
```

Volumes setup
```
fdisk -l
fdisk /dev/the_disk_to_be_partitioned
```
1GiB for boot (/boot mounpoint)
8GiB for swap
All for root (/ mountpoint)
partition type for:
1. EFI - uefi
2. root - linux
3. swap - swap

Format partitions:
~~~
mkfs.btrfs -L ROOT /dev/partition
mkswap /dev/swap_partition
mkfs.fat -F 32 /dev/efi_system_partition
~~~
Mounting root and create btrfs subvolums 
~~~
mount /dev/root_partition /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
umount /mnt
~~~

Mounting btrfs subvolums
~~~
mount -o compress=zstd,ssd,subvol=@ /dev/root_partitio /mnt
mkdir /mnt/home

mount -o compress=zstd,ssd,subvol=@home /dev/root_partitio /mnt/home
~~~

Mounting EFI partition and swapon:
~~~
mount --mkdir /dev/efi_system_partition /mnt/boot
swapon /dev/swap_partition
~~~

Pacstrap
~~~
pacstrap -K /mnt base linux linux-firmware btrfs-progs amd-ucode nano iwd networkmanager neovim sudo grub efibootmgr man iwd dhcpcd os-prober ufw
~~~

Fstab
~~~
genfstab -U /mnt >> /mnt/etc/fstab
~~~

### 2.1 System configuration
~~~
arch-chroot /mnt
~~~

Timezone
~~~
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
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
127.0.0.1     localhost
::1           localhost
127.0.1.1     arch
~~~
Initramfs (skip it?)
~~~
# mkinitcpio -P 
~~~
root password
~~~
passwd
~~~

### 2.2 Boot install
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
Uncomment Allow people in group wheel...

![135730210-da2931b0-83f2-44db-b522-8712537a0d3d](https://user-images.githubusercontent.com/52444457/136027126-a52079ac-54a8-424c-99b6-0d3f34ade081.png)

~~~
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable dhcpcd
systemctl enable ufw
ufw default deny
ufw limit ssh
ufw enable
exit
# umount -R /mnt
reboot
~~~ 

## 3.0 Post install
~~~
pacman -Syu sway waybar bemenu mako swayidle swaylock udiskie wl-clipboard light tlp tlp-rdw alacritty git zsh which

sudo chmod u+s /usr/bin/light # to have ability to changing your screen brightness 
~~~

Adequate touchpad, mouse 
~~~
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad tap-and-drag false
gsettings set org.gnome.desktop.peripherals.mouse accel-profile adaptive
~~~

Installing Vim-Plug plugin
~~~
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
~~~

Run this command in nvim
~~~
:PlugInstall
~~~

Qogir icons and cursor.
~~~
mkdir ~/.themes ~/.icons
cd ~/Downloads && git clone https://github.com/vinceliuice/Qogir-icon-theme.git
cd ~/Downloads/Qogir-icon-theme && ./install.sh -d "/home/$(whoami)/.icons"
gsettings set org.gnome.desktop.interface icon-theme Qogir-dark
gsettings set org.gnome.desktop.interface cursor-theme Qogir-dark
~~~

Time to zzZsh setup
~~~
No | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"gentoo\"/g' ~/.zshrc
sed -i 's/plugins\=(.*)/plugins\=(git\ zsh-autosuggestions\ zsh-completions\ zsh-syntax-highlighting)/g' ~/.zshrc
echo 'alias vi="nvim"' >> ~/.zshrc
echo 'alias rg="ranger"' >> ~/.zshrc
chsh -s $(which zsh)
sudo chsh -s $(which zsh)
~~~
