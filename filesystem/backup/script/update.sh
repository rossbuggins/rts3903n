#!/bin/sh

showError()
{
	echo -e "\033[0;32;31m$1\033[m"
	exit 1
}

SD_FW_NAME=/tmp/sd/home_r10m
is_sd_update=0

#usage : download_firmware
download_firmware()
{
	/backup/download_upgrade
	if [ $? -eq 0 ]; then
		echo download firmware success
	else
		echo download firmware fail
	fi
}

update_file()
{
	echo "Updating dir $1......"
	for file in $1/*
	do
		if [ -d $file ] ; then
			[ ! -d /$file ] && mkdir -p /$file
			update_file $file
		else
			echo -n "    Updating $file..."
			if [ -f $file ]; then
				oldmd5=$(md5sum $file | awk {'print $1'})
				#echo $oldmd5
				if [ -f /$file ]; then
					newmd5=$(md5sum /$file | awk {'print $1'})
					#echo file=$file, newmd5=$newmd5, oldmd5=$oldmd5
					if [ "$oldmd5" != "$newmd5" ]; then
						cp $file /$file -P
						echo "Done."
					else
						echo "Same."
					fi
				else
					cp $file /$file -P
					echo "New."
				fi
			else
				echo "not a regex file,Skip"
			fi
		fi
	done
}

killall watch_process oss cloud mp4record
mkdir -p /tmp/update
[ $# -gt 0 ]  && {
	firmware=$1
} || {
	if [ -f $SD_FW_NAME ]; then
		firmware=$SD_FW_NAME
	else
		download_firmware
		firmware=/tmp/update/firmware_m.bin
	fi
}
[ "$firmware" = "$SD_FW_NAME" ] && is_sd_update=1
[ ! -f "$firmware" ] && showError "Firmware [$firmware] not exits!"
dst_ver=`dd if=$firmware bs=24 count=1 2>/dev/null`
src_ver=`cat /home/homever`
[ "$src_ver" = "$dst_ver" ] && showError "Version is same,skip!"

/backup/script/decpkg.sh $firmware /tmp/update/firmware.tgz || showError "decpkg [$firmware] fail!"
rm -rf $firmware
cd /tmp/update
tar xf firmware.tgz || showError "tar xf [firmware.tgz] fail!"
rm -rf firmware.tgz

[ ! -f home.bin ] && showError "home.bin not exist!"
[ $is_sd_update -eq 0 ] && touch /backup/do_update
update_file backup
umount -l /home
sleep 1
/backup/mtd_img 4 home.bin || showError "update home fail!"
echo "Update success!"
sync
rm -f /backup/do_update
sync
[ $is_sd_update -eq 1 ] && mv $SD_FW_NAME ${SD_FW_NAME}.done
#mount -t squashfs /dev/mtdblock4 /home
#src_ver=`cat /home/homever`
#if [ "$src_ver" = "$dst_ver" ]; then
#	rm -fr /backup/do_update
#	sync
#else
#	echo "Update fail!"
#	exit 1
#fi
sleep 1
killall watchdog
echo "update finish, reboot"
reboot
