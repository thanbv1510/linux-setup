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
boot_partition="${disk}/1"
swap_partition="${disk}/2"
root_partition="${disk}/3"
swap_size='8' # in GiB

# Set up network connection
res=`ping github.com -c 1 -q -W 2 -w 2 | grep '1 packets transmitted, 1 received, 0% packet loss' | wc -l`
#echo ">>> $res"
if [ "$res" -eq "1" ]
then
	echo "connected network!"
else
	echo "please connect Wifi use iwctl"
	exit
fi

# Filesystem mount warning
echo "This script will create and format the partitions as follows:"
echo -e "\t$boot_partition - 512M will be mounted as /boot"
echo -e "\t$swap_partition - $swap_size will be mounted as swap"
echo -e "\t$root_partition - rest of space will be mounted as /"
echo -e "\n"
read -p 'Continue? [y/n]:' isOkFs
if ! [ $isOkFs = 'y' ] && ! [ $isOkFs = 'Y' ]
then
	echo -e "\nPlease edit the script to countinue...\n"
	exit
fi

# Create the partitions
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "$disk"
o # clear the in memory partition table
n # new partition
p # primary partition
1 # partition number 1
# default - start at beginning of disk 
+512M # 512 MB boot parttion
n # new partition
p # primary partition
2 # partion number 2
# default, start immediately after preceding partition
+"$swap_size"G # 8 GB swap parttion
n # new partition
p # primary partition
3 # partion number 3
# default, start immediately after preceding partition
# default, extend partition to end of disk
a # make a partition bootable
1 # bootable partition is partition 1 -- /dev/sda1
p # print the in-memory partition table
w # write the partition table
q # and we're done
EOF

# Format the partitions
mkfs.fat -F32 $boot_partition
mkswap $swap_partition
mkfs.ext4 $root_partition

# Mount the partitions
mount $root_partition /mnt
swapon $swap_partition
mkdir /mnt/boot
mount $boot_partition /mnt/boot

# Setup time
timedatectl set-ntp true

# Install Arch linux
echo "Setup done. Starting install..."
echo "Install Arch linux and package: sudo, vi, vim"
pacstrap /mnt base linux linux-firmware sudo vi vim

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

if [[ ! -f chroot.sh ]]; then
	echo "Missing chroot.sh, Downloading..."
	curl -0 https://raw.githubusercontent.com/thanbv1510/linux-setup/master/chroot.sh --output chroot.sh
fi

cp -rfv chroot.sh /mnt/root
chmod +x /mnt/root/chroot.sh
arch-chroot /mnt /chroot.sh
