#!/bin/sh

RED="\033[0;32;31m"
GREEN="\033[0;32;32m"
YELLOW="\033[1;33m"
NONE="\033[m"

do_update()
{
	if [ -f /tmp/sd/home_r10m ]; then
		echo "---/tmp/sd/home_r10m exist, update begin---"
		/backup/script/update.sh /tmp/sd/home_r10m
	else
		echo "---update file(home_r10m) Not exist---"
	fi
}

set_audio_switch()
{
	echo 9 > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio9/direction

	dd of=/tmp/hw if=/dev/mtdblock6 bs=1 skip=168 count=32
	hw=`cat /tmp/hw`
	if [ ${hw:6:1} -eq '1' ]
	then
		echo "high level enable"
		echo 1 > /sys/class/gpio/gpio9/value
	else
		echo "low level enable"
		echo 0 > /sys/class/gpio/gpio9/value
	fi
	rm /tmp/hw
}

echo -e ${GREEN}Start ${RED}/home/app/init.sh...${NONE}

export LD_LIBRARY_PATH=/lib:/home/lib:/home/rt/lib:/home/app/locallib:$LD_LIBRARY_PATH

insmod /home/rt/ko/rlx_dma.ko
insmod /home/rt/ko/rlx_i2s.ko
insmod /home/rt/ko/rlx_codec.ko
insmod /home/rt/ko/rlx_snd_intern.ko

insmod /backup/8188fu.ko

insmod /home/rt/ko/rtsx-icr.ko

insmod /home/rt/ko/rts_cam.ko
insmod /home/rt/ko/rts_cam_mem.ko
insmod /home/rt/ko/rts_cam_lock.ko
insmod /home/rt/ko/rts_camera_soc.ko
insmod /home/rt/ko/rts_camera_hx280enc.ko
insmod /home/rt/ko/rts_camera_jpgenc.ko
insmod /home/rt/ko/rts_camera_osd2.ko
insmod /home/rt/ko/rtstream.ko

#mount tmpfs /tmp -t tmpfs -o size=32m
mkdir -p /tmp/sd

#fsck.fat need memory, so put checkdisk at the begining
/home/base/tools/checkdisk
rm -fr /tmp/sd/FSCK*.REC

set_audio_switch
/home/app/aacplay /home/app/audio_file/common/poweron.aac 1400 &

ifconfig wlan0 up
ethmac=d2:`ifconfig wlan0 |grep HWaddr|cut -d' ' -f10|cut -d: -f2-`
ifconfig eth0 hw ether $ethmac
ifconfig eth0 up

#ifconfig eth0 192.168.0.168 netmask 255.255.255.0 hw ether 00:11:22:33:44:55

#multi sensor compatible
########################################################################
#try_count=3
#echo 1 > /sys/devices/platform/rts_soc_camera/loadfw
#echo 2 > /sys/devices/platform/rts_soc_camera/loadfw
#sensor_id=
##try 3 times
#while ([ -z "$sensor_id" ] && [ $try_count -ge 0 ])
#do
#let try_count--
#sensor_id=$(cat /sys/devices/platform/rts_soc_camera/sensor)
#done
#
#if [ -z "$sensor_id" ]
#####old version, use system/lib/isp.fw
#then
#	echo -e "use default isp.fw=============== \n"
#	echo 1 > /sys/devices/platform/rts_soc_camera/loadfw
#else
#####new version,load conrrespond isp.fw depend on sensor_id
#	echo -e "Sensor ===============  $sensor_id\n"
#	if [ "$sensor_id" == "SC1245" ]
#	then
#		echo -n "/home/lib/sc1245/isp.fw" > /sys/devices/platform/rts_soc_camera/loadfw
#	elif [ "$sensor_id" == "SC2235" ]
#	then
#		echo -n "/home/lib/sc2235/isp.fw" > /sys/devices/platform/rts_soc_camera/loadfw
#	elif [ "$sensor_id" == "SC2232" ]
#	then
#		echo -n "/home/lib/sc2232/isp.fw" > /sys/devices/platform/rts_soc_camera/loadfw
#	elif [ "$sensor_id" == "SC2230" ]
#	then
#		echo -n "/home/lib/sc2230/isp.fw" > /sys/devices/platform/rts_soc_camera/loadfw
#	fi
#fi
#######################################################################

#capture DGain
amixer cset numid=8 127
#speaker
amixer cset numid=1 109
#AGain max:69
amixer cset numid=11 30

#checkdisk will mount sd on /tmp/sd
do_update

#touch /etc/resolv.conf
echo nameserver 8.8.8.8 > /etc/resolv.conf
mDNSRespoderPosix -n -t _http._tcp. -p 80 -b

echo "/tmp/sd/core.%e.%p" > /proc/sys/kernel/core_pattern

echo 2048 > /proc/sys/vm/min_free_kbytes
echo 100 > /proc/sys/vm/extfrag_threshold
echo 1 > /proc/sys/vm/compact_memory
cd /home/app

./log_server &

if [ -f "/tmp/sd/Factory/factory_test.sh" ]; then
	echo -e ${YELLOW}detect /tmp/sd/Factory/factory_test.sh${NONE}
	/tmp/sd/Factory/config.sh
	exit
fi
./load_cpld_ssp
./dispatch &

./cloud &
./p2p_tnp &
./mp4record &
./oss &
./rmm &
./watch_process &

#start watchdog
watchdog -t 2 -T 5 /dev/watchdog &
