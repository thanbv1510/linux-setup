#! /bin/bash
echo -e "# /** Fix bug never die :)
#   _______   _    _              __    _
#  |__   __| | |  | |     /\     |  \  | |
#     | |    | |__| |    /^^\    |   \ | |
#     | |    |  __  |   / /\ \   | |\ \| |
#     | |    | |  | |  / /  \ \  | | \   |
#     |_|    |_|  |_| /_/    \_\ |_|  \__|
# */\n"

# Variable config
disk='/dev/sda'
root_partition="${disk}3"

# Update package
sudo pacman -Syyu git --noconfirm

# Install yay
git clone https://aur.archlinux.org/yay.git
cd yay || exit
makepkg -si --noconfirm
cd .. && rm -rf yay/

# Install Official package
sudo pacman -S \
xorg-server \
xorg-xinit \
xorg-xsetroot \
xorg-xbacklight \
xf86-video-intel \
bspwm \
sxhkd \
terminator \
rofi \
htop \
neofetch \
firefox-developer-edition \
alsa-utils \
picom \
maim \
xclip \
ntfs-3g \
man \
feh \
ranger \
vlc \
thunar \
papirus-icon-theme \
lxappearance \
materia-gtk-theme \
code \
noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont ttf-liberation ttf-droid ttf-inconsolata ttf-roboto terminus-font ttf-font-awesome ttf-anonymous-pro ttf-jetbrains-mono \
docker \
docker-compose \
jdk8-openjdk jdk11-openjdk jdk-openjdk \
dbeaver \
intel-ucode \
i3lock \
--noconfirm

# Install AUR package
yay -S drawio-desktop intellij-idea-ultimate-edition postman-bin ibus-bamboo polybar robo3t-bin wps-office

# Setup docker
systemctl start docker.service

groupadd docker
gpasswd -a thanbv1510 docker

# Setup JDK
sudo archlinux-java set java-11-openjdk # Because some app need java > 8

# Apply config
git clone https://github.com/thanbv1510/dotfiles.git
cp dotfiles/.config ~/.config -r
sudo cp dotfiles/etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/
cp dotfiles/.gitconfig ~/ -r
cp dotfiles/.xinitrc ~/ -r

rm -rf dotfiles/
rm config.sh

# Install Linux LTS
sudo pacman -S linux-lts linux-lts-headers --noconfirm

# Uninstall Linux
sudo pacman -Rs linux --noconfirm

# ReConfig file
echo 'title   Arch Linux' | sudo tee /boot/loader/entries/arch.conf
echo 'linux   /vmlinuz-linux-lts' | sudo tee -a  /boot/loader/entries/arch.conf
echo 'initrd /intel-ucode.img' | sudo tee -a /boot/loader/entries/arch.conf
echo 'initrd  /initramfs-linux-lts.img' | sudo tee -a /boot/loader/entries/arch.conf
echo "options root=$root_partition rw quiet" | sudo tee -a /boot/loader/entries/arch.conf

# Remove unused packaged and Clean cache
sudo pacman -Rns $(pacman -Qtdq)
rm -rf ~/.cache/*

# Start BSPWM
startx
