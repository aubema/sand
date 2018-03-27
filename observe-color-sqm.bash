#!/bin/bash 
# SAND observation script. The script need the $homed/public_html/cgi-bin/observation_list file
# as an input see the online documentation for setting this file
# 
# http://cegepsherbrooke.qc.ca/~aubema/index.php/Prof/SandcontrolEn
#
#
# Usage: observe [-m value] [-a value] [-l value] [-d value]
# -m is the mount mode flag. If you do not have a mount or just do not want
#    and displacement set value to off otherwise set it to on
# -a is the "beginning at" flag. value may be sun for sunset, ast for astronomical 
#    twilight or any time H:M 
# -l is the loop flag. value give the number of consecutive observing night. 0 = infinity
# -d begin after given delay and stopping before the same delay
# -o only one sequence (i.e. observe only once the observation_list) this option need to be the last
#
# If you want to operate in mount mode off, begin at sunset, with the spectrometer and 
# for every night until the end of the world just type "observe"
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
#
# ===========================
# home directory
homed=$HOME
# activate gps option 0=off 1=on
gpsf=0
# default luminosity 
# if this value remains unchanged, the webcam is down
lumino=512
# webcam darkness threshold
grep darkness_threshold $homed/localconfig > obs.tmp
read bidon darkness bidon < obs.tmp
echo "Threshold darkness level=" $darkness
grep cammodel1 $homed/localconfig > obs.tmp
read bidon cam1 bidon < obs.tmp
if [ $cam1 = "none" ]
   then darkness=513         # is no camera is installed to monitor ambient brightness then the system will consider the ambien light as very low
fi
# refresh delay between 2 webcam acquisition (be shure to be equal to delai given by crontab -l
delaym=15
# an estimate of the moving time for PT785S+Pololu
movetime2=20
#
      myFile="observation_list"
# ======
# using getopts
#
mflag=  
aflag=
lflag=
dflag=
oflag=
mval="off"  # set to static mode by default
lval=0    # set the number of observation night to infinity by default
aval="sun" # set the automatic observation beginning time a sunset
dval=0  # delay beginning and end to reduce the night duration (minutes)
# -a for 'at" possible values ast = astronomical twilight sun = sunset H:M = hour and minutes
# determining mount model
grep mountmodel $homed/localconfig > $homed/public_html/cgi-bin/ligne.tmp
read bidon mountmodel bidon < $homed/public_html/cgi-bin/ligne.tmp
while getopts 'm:a:l:d:o' OPTION
do
  case $OPTION in
    m)  mflag=1
        mval="$OPTARG"
        if [ $mval != "off" ]  
        then if [ $mval != "on" ]
             then echo "Unsupported mode: valid choices are off or on"
                  echo "                  off = without mount on = with mount"
                  exit 1
             fi
        fi
    ;;
    a)  aflag=1
        aval="$OPTARG"  # accepted values at or ss for astronomical twilight of sunset
    ;;
    l)  lflag=1
        lval="$OPTARG"
    ;;
    d)  dflag=1
        dval="$OPTARG"
    ;;
    o)  oflag=1
    ;;
    ?)  printf "Usage: %s: [-m value] [-a value] [-l value] [-i value] [-d value] [-t value] [-o ] args\n" $(basename $0) >&2
        exit 2
    ;;
  esac
done


# min delay on startup = 1 min in the case of sunset to allow the time for cooling and scan filters during twilight
if [ $aval == "sun" ]
then if [ $dval -lt 1 ]
     then let dval=1
          echo "Setting delay to ist minimum value in sunset mode (1 min)"
     fi
fi












shift $(($OPTIND - 1))
echo "Starting observation with:"
echo "   mount mode =" $mval " (off = mount off, on = mount on)"
echo "   begin night at" $aval "+ " $dval" min (sun = sunset, ast = astronomical twilight, H:M = other time)" 
echo "   Number of nights =" $lval " (0 = infinity)"
# checking if there is an instance of observe already running
ninstance=`ps -A | grep -c observe-color-sqm.bash`
if [ $ninstance -gt 1 ] 
then echo "ERROR! No more than one instance of observe can run!"
     echo "Exiting the script."
     exit 0
fi
# be sure you are not root
qui=`whoami | grep -c root`
if [ $qui -gt 0 ] 
then echo "ERROR! Attempt to run observe as root!"
     echo "Be sure to launch observe as sand."
     echo "Exiting the script."
     exit 1
fi
# ======
chmod -R u+rwx $homed/public_html/cgi-bin
nl=0
let delay=delaym*60
if [ $lval -eq 0 ] 
   then echo "Entering the never ending loop!"
        nl=-1
fi
while [ $nl -lt  $lval ]
do let nl=nl+1
   if [ $lval -eq 0 ] 
   then  nl=-1
#
#  Neverending loop if lval=0
#
   fi
#
#  searching for gps port
#
   if [ $gpsf -eq 1 ] 
   then echo "GPS mode activated"
        if [ `ls /dev | grep ttyUSB0`  ] 
        then echo "GPS look present." 
#
#            reading 10 gps transactions
#
             /bin/echo "Waiting 5 sec for GPS reading..."
             /usr/bin/gpspipe -w -n 10 > $homed/public_html/cgi-bin/coords.tmp
             /usr/bin/tail -1 $homed/public_html/cgi-bin/coords.tmp > $homed/public_html/cgi-bin/bidon.tmp
             /bin/rm -f $homed/public_html/cgi-bin/coords.tmp
             read bidon bidon bidon lat lon altitude bidon1 < $homed/public_html/cgi-bin/bidon.tmp
             if [ "${bidon1:0:1}" != "" ]
             then /bin/echo "GPS is connected, reading lat lon data."
                  lon=`/bin/echo $lon"/-1" |/bin/bc -l`
                  DD=`/bin/echo "scale=0;"$lon"/1" |/usr/bin/bc -l`
                  dd=`/bin/echo "scale=0;"$lat"/1" |/usr/bin/bc -l`
                  MMM=`/bin/echo "("$lon"-"$DD")*60" |/usr/bin/bc -l`
                  MM=${MMM:0:2}
                  mmm=`/bin/echo "("$lat"-"$dd")*60" |/usr/bin/bc -l`
                  mm=${mmm:0:2}
                  SSS=`/bin/echo "(("$lon"-"$DD")-"$MM"/60)*3600" |/usr/bin/bc -l`
                  SS=${SSS:0:2}
                  sss=`/bin/echo "(("$lat"-"$dd")-"$mm"/60)*3600" |/usr/bin/bc -l`
                  ss=${sss:0:2}
                  /bin/echo "GPS give Latitude:" $dd $mm $ss ", Longitude:" $DD $MM $SS "and Altitude:" $altitude
             else /bin/echo "GPS not working: using coords. from localconfig"
                  /bin/echo "Latitude:" $dd $mm $ss ", Longitude:" $DD $MM $SS
             fi    
        else /bin/echo "GPS not present: using coords. from localconfig"
             /bin/echo "Latitude:" $dd $mm $ss ", Longitude:" $DD $MM $SS
        fi
   else  echo "GPS mode off"
   fi
   /bin/grep "Site_name" $homed/localconfig > $homed/public_html/cgi-bin/ligne.tmp
   read bidon NAME bidon < $homed/public_html/cgi-bin/ligne.tmp
#
#  reading longitude and latitude from observation schedule
#
   if [ `grep -c " " $homed/public_html/cgi-bin/$myFile` -ne 0 ]
   then /bin/grep Longitude $homed/localconfig > $homed/public_html/cgi-bin/ligne.tmp
        read bidon DD MM SS bidon < $homed/public_html/cgi-bin/ligne.tmp
        /bin/grep Latitude $homed/localconfig > $homed/public_html/cgi-bin/ligne.tmp
        read bidon dd mm ss bidon < $homed/public_html/cgi-bin/ligne.tmp
   else 
        echo "Please put something in $homed/public_html/cgi-bin/observation_list and restart observe."
        if [ $ival = "sp" ] || [ $ival = "ra" ] ; then
           /usr/local/bin/night_temperature set -off
        fi
        exit 1
   fi

#
#  computing ephemerides
#
   /usr/local/bin/ephems $DD $MM $SS $dd $mm $ss $NAME
   /usr/local/bin/ephems $DD $MM $SS $dd $mm $ss $NAME > $homed/public_html/cgi-bin/last_ephemerides
   if [ $aval = "ast" ]
   then /bin/grep "Evening astronomical twilight" $homed/public_html/cgi-bin/last_ephemerides > $homed/public_html/cgi-bin/toto.tmp
        read bidon bidon bidon  hour min bidon < $homed/public_html/cgi-bin/toto.tmp
        /bin/grep  "Morning astronomical twilight" $homed/public_html/cgi-bin/last_ephemerides > $homed/public_html/cgi-bin/toto.tmp
        read bidon bidon bidon  fhour fmin bidon < $homed/public_html/cgi-bin/toto.tmp
   elif [ $aval = "sun" ]
   then /bin/grep "Sunset" $homed/public_html/cgi-bin/last_ephemerides > $homed/public_html/cgi-bin/toto.tmp
        read bidon bidon bidon bidon bidon hour min bidon < $homed/public_html/cgi-bin/toto.tmp
        /bin/grep  "Sunrise" $homed/public_html/cgi-bin/last_ephemerides > $homed/public_html/cgi-bin/toto.tmp
        read bidon fhour fmin bidon < $homed/public_html/cgi-bin/toto.tmp
   else
        echo $aval | sed 's/:/ /g' > $homed/public_html/cgi-bin/toto.tmp
        read hour min < $homed/public_html/cgi-bin/toto.tmp  
        /bin/grep  "Sunrise" $homed/public_html/cgi-bin/last_ephemerides > $homed/public_html/cgi-bin/toto.tmp
        read bidon fhour fmin bidon < $homed/public_html/cgi-bin/toto.tmp
   fi
   /bin/rm -f $homed/public_html/cgi-bin/toto.tmp
#  finding time of sunset
   /bin/grep "Sunset" $homed/public_html/cgi-bin/last_ephemerides > $homed/public_html/cgi-bin/toto.tmp
   read bidon bidon bidon bidon bidon sshour ssmin bidon < $homed/public_html/cgi-bin/toto.tmp
   ty=`/bin/date +%Y`
   tmo=`/bin/date +%m`
   tj=`/bin/date +%d`
   tm=$ssmin
   th=$sshour
   ts=0
   actsec=`/bin/date +%s`
   actdate=`/bin/date`
   /bin/echo "/bin/date --date='"$ty-$tmo-$tj $th:$tm:$ts"' +%s" > $homed/public_html/cgi-bin/toto.bash
   sunset=`/bin/bash $homed/public_html/cgi-bin/toto.bash`
#  adding 5 min to sunset
   let sunset=sunset+300
#  waiting until 5 min after sunset
   if [ $sunset -lt $actsec ]
#  meaning that sunset is after midnight while we are before midnight
#  adding 24h to sunset as a first approximation
   then let sunset=sunset+86400
   fi
   let dsec=sunset-actsec

   if [ "$dsec" -lt 0 ]
   then /bin/echo "Sunset is in the past (dsec=" $dsec ")"
        /bin/echo "Exiting observe"
        exit 0
   fi
   if [ "$dsec" -gt 43200 ]
   then /bin/echo "Sunset far in time (>12h)! Cannot perform the filter scan at sunset, trying to do it right now. "
        if [ "$dsec" -gt 86400 ]
        then /bin/echo "Sunset in more than 24h from now! Please start it tomorrow."
             /bin/echo "Exiting observe"
             exit 0
        fi
        let dsec=0
   fi
#
#  Wait for beginning of observation sequence
#
   let sleeprem=dsec
   while  [ $sleeprem -gt  0 ]
   do let sleephr=sleeprem/60/60
      let sleepmin=(sleeprem-sleephr*60*60)/60
      /bin/echo "Sleeping for " $sleeprem " sec (" $sleephr "h " $sleepmin "m ) until 5 min after sunset"
      let sleeprem=sleeprem-60
      /bin/sleep 60
   done
#
#  setting beginning time and duration of the night
#

   ty=`/bin/date +%Y`
   tmo=`/bin/date +%m`
   tj=`/bin/date +%d`
   tm=$min
   th=$hour
   ts=0
   actsec=`/bin/date +%s`
   actdate=`/bin/date`
   echo "Time used to compute actsec= " $actdate
   /bin/echo "/bin/date --date='"$ty-$tmo-$tj $th:$tm:$ts"' +%s" > $homed/public_html/cgi-bin/toto.bash
   debsec=`/bin/bash $homed/public_html/cgi-bin/toto.bash`
   tm=$fmin
   th=$fhour
   ts=0
   /bin/echo "/bin/date --date='"$ty-$tmo-$tj $th:$tm:$ts"' +%s" > $homed/public_html/cgi-bin/toto.bash
   finsec=`/bin/bash $homed/public_html/cgi-bin/toto.bash`
   let finsec=finsec-dval*60
   let debsec=debsec+dval*60+30   # plus 30 sec to be sure that the delay between the actsec determination and le calculation of debsec is not yet over.
   if [ $finsec -lt $actsec ]
#  meaning that finsec is after midnight while we are before midnight
#  adding 24h to finsec as a first approximation
   then let finsec=finsec+86400
   fi
   let dsec=debsec-actsec
   if [ $debsec -lt $actsec ] && [ $dsec -lt -43200 ]
#  can be that debsec is after midnight while we are before midnight
#  adding 24h to debsec as a first approximation
   then let debsec=debsec+86400
   else
#     meaning that the night has already begun then start immediately
#     i.e. setting debsec to actsec
      let debsec=actsec
      /bin/echo "Observing date should be in the future!"
      /bin/echo "Starting run almost immediately"
   fi
   if [ $finsec -lt $debsec ]
   then let debsec=debsec-86400
   fi
   let duration=finsec-debsec
   echo "debug:  actsec=" $actsec " duration=" $duration "finsec=" $finsec " debsec=" $debsec
#
#  computing waiting time before beginning of run
#
   let dsec=debsec-actsec
   echo "debug: dsec=" $dsec
   if [ "$dsec" -lt 0 ]
   then /bin/echo "Observation beginning is in the past (dsec=" $dsec ")"
        /bin/echo "Exiting observe"
        exit 0
   fi
   if [ "$dsec" -gt 43200 ]
   then /bin/echo "Observing far in time (>12h)!"
        if [ "$dsec" -gt 86400 ]
        then /bin/echo "Observing in more than 24h from now! Please start is tomorrow."
             /bin/echo "Exiting observe"
             exit 0
        fi
   fi
#
#  Analysing observation list file and creation full night observation sequence
#
   nligne=`/bin/grep -c " " $homed/public_html/cgi-bin/$myFile`
   let nimgtot=nligne-1
   if [ ! $oflag ]
   then rm -f $homed/public_html/cgi-bin/observation_sequence
        echo "Duration of the observing sequence:" $duration "sec" 
        eled=90
        elem=0
        eles=0
        azid=0
        azim=0
        azis=0
        olisttime=0
        nacqui=0
        while [ $olisttime -lt $duration ]
        do # myLine=""
           n=0
           while [ $n -lt  $nligne ]
           do let n=n+1
              let poset=eled*60+elem
              let posat=azid*60+azim
              head -$n $homed/public_html/cgi-bin/$myFile | tail -1 > $homed/public_html/cgi-bin/ligne.tmp
              if [ $n -gt 1 ]
              then read eled elem eles azid azim azis imtyp inttime < $homed/public_html/cgi-bin/ligne.tmp
                   let posea=eled*60+elem+eles
                   let posaa=azid*60+azim+azis
                   if [ $mval = "on" ]
                   then if [ $mountmodel = "PT785S+Pololu" ] ; then movetime=$movetime2 ; fi
                        let olisttime=olisttime+movetime
                   fi
                   let itime=inttime
                   let dtime=downltime
                   let olisttime=olisttime+dtime+ghosttime
                   if [ $olisttime -lt $duration ]
                   then echo $eled $elem $eles $azid $azim $azis $imtyp $inttime >> $homed/public_html/cgi-bin/observation_sequence
                        let nacqui=nacqui+1
                        let olisttime=olisttime+itime # this allow to complete an image when the end of the observation occur during the last acquisition
                   fi
              fi
           done
        done
        if [ $nimgtot -gt $nacqui ]
        then let ndestroy=nimgtot-nacqui 
             echo "Warning: The last "$ndestroy" images of the observation_list will not be taken "
            echo "         because the night duration is shorter than observation_list "
        fi
   else 
        tail -$nimgtot $homed/public_html/cgi-bin/$myFile > $homed/public_html/cgi-bin/observation_sequence
   fi
   echo "Desired starting time:" $hour":"$min"+"$dval"min" 
#
#  Wait for beginning of observation sequence
#
   let sleeprem=dsec
   while  [ $sleeprem -gt  0 ]
   do let sleephr=sleeprem/60/60
      let sleepmin=(sleeprem-sleephr*60*60)/60
      /bin/echo "Sleeping for " $sleeprem " sec (" $sleephr "h " $sleepmin "m )"
      let sleeprem=sleeprem-60
      /bin/sleep 60
   done
#  read current time
   y=`/bin/date +%Y`
   mo=`/bin/date +%m`
   j=`/bin/date +%d`
   m=`/bin/date +%M`
   h=`/bin/date +%H`
   s=`/bin/date +%S`
#
#  creating current night directory
#
   if [ ! -d "$homed/public_html/data/"$y ]
   then /bin/mkdir "$homed/public_html/data/"$y
        /bin/chmod a+rx "$homed/public_html/data/"$y
   fi
   if [ ! -d "$homed/public_html/data/"$y"/"$mo ] 
   then /bin/mkdir "$homed/public_html/data/"$y"/"$mo
        /bin/chmod a+rx "$homed/public_html/data/"$y"/"$mo
   fi
   if [ ! -d "$homed/public_html/data/"$y"/"$mo"/"$j ]
   then /bin/mkdir "$homed/public_html/data/"$y"/"$mo"/"$j
        /bin/chmod a+rx "$homed/public_html/data/"$y"/"$mo"/"$j
   fi
   outdir="$homed/public_html/data/"$y"/"$mo"/"$j
   photoname=`/bin/date +%Y-%m-%d`".txt"
   /bin/echo "Output directory: " $outdir
   logname=`/bin/date +%Y-%m-%d`".log"
   /bin/echo "Log file name: " $logname
   if [ ! -f $homed/public_html/data/$logname ] 
   then /bin/echo "" >$homed/public_html/data/$logname
   fi
   /bin/chmod a+rx $homed/public_html/data/$logname
   nligne=`/bin/grep -c " " $homed/public_html/cgi-bin/observation_sequence`
   /bin/echo "Number of line in observation sequence: " $nligne
   begin=`/bin/date +%T" "%Y-%m-%d`
   /bin/echo "=======================================================" >> $homed/public_html/data/$logname
   /bin/echo " Beginning observing run @ " $begin  >> $homed/public_html/data/$logname
   /bin/echo "=======================================================" >> $homed/public_html/data/$logname
   /bin/echo " Basic paramaters values:" >> $homed/public_html/data/$logname
   /bin/echo " Output directory:" $outdir >> $homed/public_html/data/$logname
   /bin/echo " Ephemerides:" >> $homed/public_html/data/$logname
   /usr/local/bin/ephems $DD $MM $SS $dd $mm $ss $NAME >> $homed/public_html/data/$logname
#  line data variable
#  myLine=""
#
#  Loop over each observation line
#
   let n=0
   let nimgtot=nligne
   let cursec=0
   while [ $n -lt  $nligne ] && [ $cursec -lt $finsec ]                      
   do let n=n+1
      /bin/echo "/bin/date +%s" > $homed/public_html/cgi-bin/toto.bash
      cursec=`/bin/bash $homed/public_html/cgi-bin/toto.bash`            # this is the current time in seconds
      curdate=`/bin/date`
      echo "Current date= " $curdate
      echo "Debug: reading line n=" $n "from a total of " $nligne "lines"
      head -$n $homed/public_html/cgi-bin/observation_sequence | tail -1 > $homed/public_html/cgi-bin/ligne.tmp
      read eled elem eles azid azim azis imtyp inttime < $homed/public_html/cgi-bin/ligne.tmp
      let nimg=n
      echo "Azimuth"$azid ":" $azim ":" $azis "Elevation" $eled ":" $elem ":" $eles
      if [ $mval = "on" ]
      then /bin/echo "Moving mount to Azimuth:" $azid":"$azim":"$azis "and Elevation:" $eled":"$elem":"$eles "following" $imtyp
           echo "Mount model = " $mountmodel  
           if [ $mountmodel = "LXD-75" ] 
           then echo "Mount model=" $mountmodel 
#          look tracking.bash
           $homed/public_html/cgi-bin/ligne.tmp >  $homed/public_html/cgi-bin/tracking.tmp
           /usr/local/bin/tracking.bash 
          elif [ $mountmodel = "PT785S+Pololu" ]
#
#              read channels, gain and offset for angle to servo position conversion
#              servo_pos = elev_gain * angle(deg) + elev_offset
#           
          then echo "Mount model inside=" $mountmodel
               grep "elev_gain" $homed/localconfig > $homed/public_html/cgi-bin/ligne.tmp 
               read bidon elev_gain bidon < $homed/public_html/cgi-bin/ligne.tmp  
               grep "elev_offset" $homed/localconfig > $homed/public_html/cgi-bin/ligne.tmp 
               read bidon elev_offset bidon < $homed/public_html/cgi-bin/ligne.tmp  
               grep "azim_gain" $homed/localconfig > $homed/public_html/cgi-bin/ligne.tmp 
               read bidon azim_gain bidon < $homed/public_html/cgi-bin/ligne.tmp  
               grep "azim_offset" $homed/localconfig > $homed/public_html/cgi-bin/ligne.tmp 
               read bidon azim_offset bidon < $homed/public_html/cgi-bin/ligne.tmp  
               grep "elev_channel" $homed/localconfig  > $homed/public_html/cgi-bin/ligne.tmp 
               read bidon elev_channel bidon < $homed/public_html/cgi-bin/ligne.tmp  
               grep "azim_channel" $homed/localconfig  > $homed/public_html/cgi-bin/ligne.tmp 
               read bidon azim_channel bidon < $homed/public_html/cgi-bin/ligne.tmp  
              echo $elev_gain $elev_offset $azim_gain $azim_offset $elev_channel $azim_channel
#
#              goto park position
#
               sel=`/bin/echo "scale=0;180.*"$elev_gain"+"$elev_offset |/usr/bin/bc -l`
               saz=`/bin/echo "scale=0;0.*"$azim_gain"+"$azim_offset |/usr/bin/bc -l`
               servoel=`echo $sel | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               servoaz=`echo $saz | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               echo "init" $eled $sel $servoel $azid $saz $servoaz
               mono /usr/local/bin/UscCmd --servo $elev_channel","$servoel 
               mono /usr/local/bin/UscCmd --servo $azim_channel","$servoaz
               /bin/sleep $movetime2
#
#              goto observing position
#
               sel=`/bin/echo "scale=0;"$eled"*"$elev_gain"+"$elev_offset |/usr/bin/bc -l`
               saz=`/bin/echo "scale=0;"$azid"*"$azim_gain"+"$azim_offset |/usr/bin/bc -l`
               servoel=`echo $sel | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               servoaz=`echo $saz | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               echo "posi" $eled $sel $servoel $azid $saz $servoaz 
               mono /usr/local/bin/UscCmd --servo $elev_channel,$servoel 
               mono /usr/local/bin/UscCmd --servo $azim_channel,$servoaz
               /bin/sleep $movetime2
          fi
      fi
#
#     define image name
#
      noname=`/bin/date +%Y-%m-%d_%H:%M:%S`
      posname="_el"$eled":"$elem":"$eles"_az"$azid":"$azim":"$azis
      name=$imtyp"_T_"$stmp"_t_"$inttime"_"$noname$posname".fits"
      if [ -f $homed/public_html/cgi-bin/$name ]
      then /bin/rm -f $homed/public_html/cgi-bin/$name
      fi
#     entry to log file
      begin=`/bin/date +%T" "%Y-%m-%d`
      /bin/echo "Beginning of acquisition (image " $nimg"/"$nimgtot") @ " $begin
      /bin/echo "Mount to AZ:" $azid "deg" $azim "min" $azis "sec and EL:" $eled "deg" $elem "min" $eles "sec" 
      /bin/echo " ----------------------------------------------" >> $homed/public_html/data/$logname
      /bin/echo "  Beginning of acquisition (data " $nimg"/"$nimgtot")  @ "$begin >> $homed/public_html/data/$logname
      /bin/echo " ----------------------------------------------" >> $homed/public_html/data/$logname
#
      if [ -f $homed/public_html/cgi-bin/webcam-mean ]
      then read lumino < $homed/public_html/cgi-bin/webcam-mean
      else echo "No webcam available or damaged webcam, ignoring luminosity check"
           let lumino=0
      fi
      /bin/echo "Ambient luminosity= " $lumino
      while [ $lumino -gt $darkness ]
      do /bin/echo "Waiting " $delaym " min for darkness... (luminosity level=" $lumino ">"$darkness")"
         read lumino < $homed/public_html/cgi-bin/webcam-mean
         let sleeprem=delay
         while  [ $sleeprem -gt  0 ]
         do let sleephr=sleeprem/60/60
            let sleepmin=(sleeprem-sleephr*60*60)/60
            /bin/echo "Sleeping for " $sleeprem " sec (" $sleephr "h " $sleepmin "m )"
            let sleeprem=sleeprem-60
            /bin/sleep 60
         done
      done
      /bin/echo "    Azimuth: " $azid " deg " $azim " min" $azis " sec" >> $homed/public_html/data/$logname
      /bin/echo "    Elevation: " $eled " deg " $elem " min" $eles " sec" >> $homed/public_html/data/$logname
      /bin/echo "    Integration time: " $inttime "sec">> $homed/public_html/data/$logname






      bash /usr/local/bin/observe-sqm-stepper.bash 






#
#     entry to log file
#
      end=`/bin/date +%T" "%Y-%m-%d`
      j=`/bin/date +%d`
      if [  "${j:0:2}" = "00"  ]
      then j=${j:2:1}
      else if  [  "${j:0:1}" = "0" ]
           then j=${j:1:2}
           fi
      fi
      m=`/bin/date +%M`
      if  [  "${m:0:1}" = "0" ]
      then m=${m:1:2}
      fi
      h=`/bin/date +%H`
      if  [  "${h:0:1}" = "0" ]
      then h=${h:1:2}
      fi
      let min="$m"+"$h"*60+"$j"*24*60
      /bin/echo "End of acquisition @ " $end
      /bin/echo "  End of acquisition @ " $end >> $homed/public_html/data/$logname
      /bin/echo " -----------------------------------------------" >> $homed/public_html/data/$logname
      /bin/echo $min > $homed/public_html/cgi-bin/last_image.tmp
   done
   /bin/echo "======================================================" >> $homed/public_html/data/$logname
   /bin/echo " End of observing run  "  >> $homed/public_html/data/$logname
   /bin/echo "======================================================" >> $homed/public_html/data/$logname
   /bin/echo "======================================================" 
   /bin/echo " End of observing run "  
   /bin/echo "======================================================" 
   if [ -f $outdir"/"$logname ]
   then /bin/cat $homed/public_html/data/$logname >> $outdir"/"$logname
   else /bin/cat $homed/public_html/data/$logname > $outdir"/"$logname
   fi
   /bin/chmod a+rx $outdir"/"$logname
   /bin/mv -f $homed/public_html/cgi-bin/photom.txt $outdir"/"$photoname
   /bin/rm -f $homed/public_html/cgi-bin/skycalc.*
   /bin/rm -f $homed/public_html/cgi-bin/toto.bash
   /bin/rm -f $homed/public_html/cgi-bin/ligne.tmp
   /bin/rm -f $homed/public_html/data/$logname
   /bin/rm -f $homed/public_html/cgi-bin/lastwebcam.jpg
   /bin/rm -f $homed/public_html/cgi-bin/bidon.tmp
#
#  park mount
#
   if [ $mval = "on" ] 
   then if [ $mountmodel = "PT785S+Pololu" ]
        then /bin/echo "Parking PT785S+Pololu mount"
             sel=`/bin/echo "scale=0;180.*"$elev_gain"+"$elev_offset |/usr/bin/bc -l`
             saz=`/bin/echo "scale=0;0.*"$azim_gain"+"$azim_offset |/usr/bin/bc -l`
             servoel=`echo $sel | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
             servoaz=`echo $saz | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
             mono /usr/local/bin/UscCmd --servo $elev_channel,$servoel 
             mono /usr/local/bin/UscCmd --servo $azim_channel,$servoaz 
             /bin/sleep $movetime2
             /bin/echo "Mount parked."
        fi
   fi
   if [ $lval -ne 1 ]
   then /bin/echo "Sleeping 6h before scheduling next run."
        let sleeprem=21600
        while [ $sleeprem -gt  0 ]
        do let sleephr=sleeprem/60/60
           let sleepmin=(sleeprem-sleephr*60*60)/60
           /bin/echo "Sleeping for " $sleeprem " sec (" $sleephr "h " $sleepmin "m )"
           let sleeprem=sleeprem-60
           /bin/sleep 60
        done
   fi
done
