#!/bin/bash 
# script that check if the communication is good with the camera 
# if not the camera power will be switch off and on to reboot the camera
# and kill observe then restart it
# user should edit the file localconfig in the /home/sand directory
# and put the observe startup command (e.g. nohup observe -sun &)
# user should also edit a file named localconfig in /home/sand
# and add the following lines: 
# powerusbport 1 (or 2 or 3 for the giving outlet)
# powerusbversion 32 (or 64 for the cpu architecture)
# 
#
# this script should be run as root
# 
# usage:  checkmysystem.bash
#
#   
#    Copyright (C) 2010  Martin Aube
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Contact: martin.aube@cegepsherbrooke.qc.ca
cd /home/sand
/usr/local/bin/night_temperature get -ts > /home/sand/cameralink.tmp
ccdstate=0
datestamp=`date +%j-%Y`
now=`date`
scommand=`/bin/grep "observe" /home/sand/localconfig`
/bin/grep "powerusbport" /home/sand/localconfig > rline.tmp
read tag port bidon < rline.tmp
/bin/grep "powerusbversion" /home/sand/localconfig > rline.tmp
read tag arch bidon < rline.tmp
if [ ! `/bin/grep "nan" /home/sand/cameralink.tmp` ]
then if [ ! `/bin/grep "connected" /home/sand/cameralink.tmp` ]
     then /bin/echo $now ": Good comm with CCD"
          ccdstate=1
     fi
fi
if [ $ccdstate -eq 0 ]        
then /bin/echo $now ": Bad comm with CCD, rebooting CCD..."
     /usr/local/bin/powerusb$arch $port off                                            # power off ccd
     /bin/sleep 1                                                                      # wait before power on ccd
     /bin/echo "Rebooting CCD (20 sec)..."
     /usr/local/bin/powerusb$arch $port on                                             # power on ccd
     /bin/sleep 20                                                                     # wait for ccd to reboot
     /usr/local/bin/night_temperature set -off
     /bin/echo "Wait for CCD to reach thermal equilibrium (10 min)..."
     /bin/sleep 600
     /bin/ps -A | grep -c observe
     if [ `/bin/ps -A | /bin/grep -c observe` -gt 0 ] 
     then /bin/echo "Shutting down observe script..."
          /usr/bin/killall observe                                                          # shutdown observe
          /bin/cp -f /home/sand/checkmysystem.log /home/sand/$datestamp-checkmysytem.log    # rename previous nohup.out
          /bin/echo "" > checkmysystem.log
          /bin/echo "Restarting observe..."
          eval "$scommand"                                                     # start observe as sand
     fi
fi
if [ `/bin/ps -A | /bin/grep -c observe` -eq 0 ]  # observe is not running then start it
then /bin/echo "Starting observe script..."
     /bin/cp -f /home/sand/checkmysystem.log /home/sand/$datestamp-checkmysytem.log    # rename previous nohup.out
     /bin/echo "" > checkmysystem.log
     /bin/echo "Restarting observe..."
     eval "$scommand"                                                     # start observe as sand
fi


