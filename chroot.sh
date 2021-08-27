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
hostname='arch-linux'
username='thanbv1510'
fullname='Than Bui'

# Setup Time zone
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

# Run hwclock to generate /etc/adjtime
hwclock --systohc --utc

# Generate the locales
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen

# Create the locale.conf file, and set the LANG variable
echo "LANG=en_US.UTF-8" >/etc/locale.conf

# Create the hostname file
echo "$hostname" >/etc/hostname

# Add matching entries to hosts
echo "127.0.1.1 localhost.localdomain $hostname" >>/etc/hosts

# Network manager
sudo pacman -S networkmanager --noconfirm
sleep 10

package=networkmanager
if pacman -Qs networkmanager >/dev/null; then
  echo "==> The package $package is installed"
else
  echo "<== The package $package is not installed"
  sudo pacman -S networkmanager
fi
sleep 10

# Setup Network manager
systemctl enable NetworkManager

# Root password
echo "==> Set root password:"
passwd
echo "==> Set root password done!"

# Install Boot loader
bootctl --path=/boot install
sleep 10

# Edit the loader.conf file
echo 'default arch' >/boot/loader/loader.conf
echo 'timeout 0' >>/boot/loader/loader.conf
echo 'editor  0' >>/boot/loader/loader.conf

# Create the arch.conf file in the entries directory and Edit the details for the arch.conf file
echo 'title   Arch Linux' >/boot/loader/entries/arch.conf
echo 'linux   /vmlinuz-linux' >>/boot/loader/entries/arch.conf
echo 'initrd  /initramfs-linux.img' >>/boot/loader/entries/arch.conf
echo "options root=$root_partition rw quiet" >>/boot/loader/entries/arch.conf

# Add user
useradd -m -G wheel -s /bin/bash -c "$fullname" "$username"
echo "==> Set user password:"
passwd "$username"
echo "==> Set user password done!"

# Allow users in group wheel to use sudo
sed -i '/%wheel\sALL=(ALL)\sALL/s/^#\s//g' /etc/sudoers

# Cleanup
rm chroot.sh
exit
