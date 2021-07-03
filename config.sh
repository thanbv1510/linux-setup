#! /bin/bash
echo -e "# /** Fix bug never die :)
#   _______   _    _              __    _
#  |__   __| | |  | |     /\     |  \  | |
#     | |    | |__| |    /^^\    |   \ | |
#     | |    |  __  |   / /\ \   | |\ \| |
#     | |    | |  | |  / /  \ \  | | \   |
#     |_|    |_|  |_| /_/    \_\ |_|  \__|
# */\n"

# Update package
pacman -Syyu git --noconfirm

# Intall yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd .. && rm -rf yay/

# Install Offical package
pacman -S \
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
--noconfirm

# Install AUR package
yay -S drawio-desktop intellij-idea-ultimate-edition postman-bin ibus-bamboo polybar robo3t-bin

### Setup docker
systemctl start docker.service

groupadd docker
gpasswd -a thanbv1510 docker

### Setup JDK
archlinux-java set java-11-openjdk # Because some app need java > 8

# Apply config
git clone https://github.com/thanbv1510/dotfiles.git
cp dotfiles/.config ~/.config -r
sudo cp dotfiles/etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/
cp dotfiles/.gitconfig ~/ -r
cp dotfiles/.xinitrc ~/ -r

rm -rf dotfiles/
rm -rf config.sh
startx
