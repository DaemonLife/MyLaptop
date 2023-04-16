# GNOME and SWAY setup for Fedora

Let's make the dnf fast like lynx
~~~
echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
~~~
Adequate touchpad, mouse and show battery status for GNOME DE for eyes!
~~~
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad tap-and-drag false
gsettings set org.gnome.desktop.peripherals.mouse accel-profile adaptive
gsettings set org.gnome.desktop.interface show-battery-percentage true
~~~
Enable RPM and Flatpak (do it with bash)
~~~
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
~~~
Update system. Press Alt+Ctrl+F3 to enter safe terminal mode. Alt+Ctrl+F2 to get back after all. 
~~~
sudo dnf -y upgrade
~~~
Installing battery power soft to control your battery. Useful. Save power, get status, makes lemonade, etc.
~~~
sudo dnf -y install tlp tlp-rdw smartmontools
sudo systemctl enable tlp # run this
# run sudo tlp-stat and check possible recommendations for installing
sudo tlp-stat
~~~
Installing other soft and fonts. Love it ^.^
~~~
# fonts
sudo dnf -y install jetbrains-mono-fonts-all
# soft
sudo dnf -y install neovim zsh
~~~
Cursor theme.
~~~
mkdir ~/.themes ~/.icons
cd ~/Downloads && git clone https://github.com/vinceliuice/Qogir-icon-theme.git
cd ~/Downloads/Qogir-icon-theme && ./install.sh -d "/home/$(whoami)/.icons"
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
# To Sway!
Installing Sway

- bemenu: app search.
- waybar: better bar.
- alacritty: best terminal.
- mako: notifications daemon.
- swayidle, swaylock: it's your locksreen. 
- pavucontrol: simple audio control with gui.
- NetworkManager-tui: for command nmtui, simple wifi control with gui.
- udiskie: mounting devices.
- wl-clipboard, clipman: proggrams for clipboard.
- light: control monitor brightness.
~~~
sudo dnf install sway bemenu waybar mako alacritty swayidle swaylock pavucontrol NetworkManager-tui udiskie wl-clipboard clipman light
~~~
Reboot after all and remember to login to sway in GDM.
~~~
reboot
~~~

## Now copy all configs. 

If you copied nvim configs follow this steps:
~~~
# Installing Vim-Plug plugin.
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
~~~
Run this command in nvim.
~~~
:PlugInstall
~~~
