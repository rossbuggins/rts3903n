# rts3903n
Custom Firmware for floureon camera


Serial 57600-8-N-1
Use GTKTerm

Used usb serial from ebay
3.3 Volts

Root is there once booted

Busybox is there with tftp

manually set ip

ifconfig eth0 x.x.x.x
ifconfig eth0 netmask 255.255.255.0

on tftp server set create flag
sudo sed -i '/^TFTP_OPTIONS/s/"$/ --create"/' /etc/default/tftpd-hpa

Give the /srv/tftp folder user (tftp) write access to folder
need to create file structure manually

then eg:

/bin/busybox tftp -p -l  /home/lib/sc2230/isp_jin.fw -r ./home/lib/sc2230/isp_jin.fw 10.98.7.107
/bin/busybox tftp -p -l ./update.sh -r ./update.sh 10.98.7.107
/bin/busybox tftp -p -l ./init.sh -r ./home/app/init.sh 10.98.7.107

/bin/busybox tftp -p -l /backup/script/factory_test.sh -r ./backup/script/factory_test.sh 10.98.7.107


/bin/busybox tftp -p -l /tmp/sd/test/factory_test.sh -r ./tmp/sd/test/factory_test.sh 10.98.7.107

/bin/busybox tftp -p -l /backup/script/info.sh -r ./backup/script/info.sh 10.98.7.107

Copy files to this repo
cp -R /srv/tftp/* /home/ross/source/rts3903n/filesystem 


mkdir -p ./home/lib/load
mkdir -p ./home/lib/sc1245
mkdir -p ./home/lib/sc2230
mkdir -p ./home/lib/sc2232
mkdir -p ./home/lib/sc2235
mkdir -p ./home/lib/sc2390

/bin/busybox tftp -p -l  /home/lib/load/isp.fw -r ./home/lib/load/isp.fw  10.98.7.107
/bin/busybox tftp -p -l  /home/lib/sc1245/isp.fw -r ./home/lib/sc1245/isp.fw 10.98.7.107
/bin/busybox tftp -p -l  /home/lib/sc2232/isp.fw -r ./home/lib/sc2232/isp.fw 10.98.7.107
/bin/busybox tftp -p -l  /home/lib/sc2235/isp.fw -r ./home/lib/sc2235/isp.fw 10.98.7.107
/bin/busybox tftp -p -l  /home/lib/sc2390/isp.fw -r ./home/lib/sc2390/isp.fw 10.98.7.107


/bin/busybox tftp -p -l   ./home/lib/c2230 -r ./home/lib/