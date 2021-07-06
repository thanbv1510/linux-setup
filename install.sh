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
boot_partition="${disk}1"
swap_partition="${disk}2"
root_partition="${disk}3"
swap_size='8' # in GiB

# Set up network connection
echo "==> Check network connection ..."
res=$(ping github.com -c 1 -q -W 2 -w 2 | grep '1 packets transmitted, 1 received, 0% packet loss' | wc -l)
if [ "$res" -eq "1" ]; then
  echo "connected network!"
else
  echo "please connect Wifi use iwctl"
  exit
fi
echo "==> Check network connection done!"

# Filesystem mount warning
echo "This script will create and format the partitions as follows:"
echo -e "\t$boot_partition - 512M will be mounted as /boot"
echo -e "\t$swap_partition - $swap_size will be mounted as swap"
echo -e "\t$root_partition - rest of space will be mounted as /"
echo -e "\n"
read -p 'Continue? [y/n]:' isOkFs
if ! [ "$isOkFs" = 'y' ] && ! [ "$isOkFs" = 'Y' ]; then
  echo -e "\nPlease edit the script to countinue...\n"
  exit
fi

# Create the partitions
echo "==> Create the partitions ..."
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<EOF | fdisk "$disk"
g
n # new partition
1 # partition number 1
# default - start at beginning of disk
+512M # 512 MB boot parttion
n # new partition
2 # partition number 2
# default, start immediately after preceding partition
+8G # 8 GB swap partition
n # new partition
3 # partition number 3
# default, start immediately after preceding partition
# default, extend partition to end of disk
t change type of partition
1 partition number need change type
1 type partition
w # write the partition table
q # and we're done
EOF
echo "==> Create the partitions done!"

# Format the partitions
echo "==> Format the partitions ..."
mkfs.fat -F32 $boot_partition
mkswap $swap_partition
mkfs.ext4 $root_partition
echo "==> Format the partitions done!"

# Mount the partitions
echo "==> Mount the partitions ..."
mount $root_partition /mnt
swapon $swap_partition
mkdir /mnt/boot
mount $boot_partition /mnt/boot
echo "==> Mount the partitions done!"

# Setup time
timedatectl set-ntp true

# Install Arch linux
echo "Setup done. Starting install ..."
echo "Install Arch linux and package: sudo"
pacstrap /mnt base base-devel linux linux-firmware sudo

# Generate fstab
genfstab -U /mnt >>/mnt/etc/fstab

if [[ ! -f chroot.sh ]]; then
  echo "Missing chroot.sh, Downloading..."
  curl -O https://raw.githubusercontent.com/thanbv1510/linux-setup/master/chroot.sh
fi

cp -rfv chroot.sh /mnt
chmod +x /mnt/chroot.sh
arch-chroot /mnt /chroot.sh
