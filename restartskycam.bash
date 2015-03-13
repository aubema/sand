#!/bin/bash
# script to restart skycam at every 6 hours to get rid of a bug in the video camera internal program
/bin/grep cam2pwrusbport /home/sand/localconfig > /root/cam2pt.tmp
read bidon port bidon < /root/cam2pt.tmp
/bin/grep powerusbversion /home/sand/localconfig > /root/cam2pt.tmp
read bidon version bidon < /root/cam2pt.tmp
/usr/local/bin/powerusb$version $port on
sleep 360
/usr/local/bin/powerusb$version $port off
