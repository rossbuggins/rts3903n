if [ -e /dev/mmcblk0p1 ]; then	
	cp /etc/mtab /tmp/sd/mtab.info
	ls /bin -lR > /tmp/sd/ls_info.txt;
	ls /etc -lR >> /tmp/sd/ls_info.txt;
	ls /lib -lR >> /tmp/sd/ls_info.txt;
	ls /mnt -lR >> /tmp/sd/ls_info.txt;
	ls /root -lR >> /tmp/sd/ls_info.txt;
	ls /usr -lR >> /tmp/sd/ls_info.txt;
	ls /dev -lR >> /tmp/sd/ls_info.txt;
	ls /home -lR >> /tmp/sd/ls_info.txt;
	ls /sbin -lR >> /tmp/sd/ls_info.txt;
	ls /var -lR >> /tmp/sd/ls_info.txt;

	du /bin > /tmp/sd/du_info.txt
	du /etc >> /tmp/sd/du_info.txt
	du /lib >> /tmp/sd/du_info.txt
	du /mnt >> /tmp/sd/du_info.txt
	du /root >> /tmp/sd/du_info.txt
	du /usr >> /tmp/sd/du_info.txt
	du /dev >> /tmp/sd/du_info.txt
	du /home >> /tmp/sd/du_info.txt
	du /sbin >> /tmp/sd/du_info.txt
	du /var >> /tmp/sd/du_info.txt
	du /sys >> /tmp/sd/du_info.txt
	du /proc >> /tmp/sd/du_info.txt
fi

