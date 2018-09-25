#!/bin/bash
echo `date` starting progress: >>output.log
#Edit script to use these values for wget and preseedfile location USB location is where we will have the final boot device
targetVersion=$1
targetSystem=$2
usbLocation=$3

echo `date` starting download deb9 >>output.log
wget -c https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-9.5.0-amd64-DVD-1.iso
echo `date` download completed>>output.log

echo `date` extracting initrd>>output.log
#find  *.iso -exec 7z x -oDESTINATION {} :\
find *.iso -print | while read f; do 
	udevil mount "$f"
	cp -rT "/media/$f" extracted/
done
#find *.iso -print | while read f; do
#	mountpoint=/media/"$f"
#done

#This section below works
#find *.iso -print | while read f; do
#	7z x -o./extracted/ "$f" 
#done
echo `date` package has been extracted changing permissions>>output.log
chmod +w -R ./extracted/install.amd/initrd.gz
gunzip ./extracted/install.amd/initrd.gz
#lets write some test file to amdinstall folder
echo test>./extracted/install.amd/fortesting
#echo ~/preseed/dt-kvm01/preseed.cfg | cpio -H newc -o -A -F ./extracted/install.amd/initrd
gzip ./extracted/install.amd/initrd
chmod -w -R ./extracted/install.amd/
echo `date` fixing checksums
cd ./extracted
md5sum `find -follow -type f` > md5sum.txt
cd ..

echo `date` rebuilding ISO

#genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "seeded-$targetSystem-$targetVersion".iso extracted

xorriso -as mkisofs -o ./preseed-debian.9.5.0-amd64-DVD-1.iso -r -J -c isolinux/boot.cat -b isolinux/isolinux.bin -boot-load-size 4 -boot-info-table -no-emul-boot -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot extracted
#
chmod +w -R extracted
#rm -r extracted
#cd ./preseedtesti
#echo "$mountpoint"
find *1.iso -print | while read f; do
sudo udevil unmount "/media/$f"
done
echo `date` cleaning up >>output.log
echo `date` writing iso to usb media>>output.log
#change this echo to cat
echo `date` "seeded-$targetSystem-$targetVersion".iso to "$usbLocation">>output.log 
sync

echo `date` ending progress >> output.log
