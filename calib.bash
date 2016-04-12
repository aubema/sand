# !/bin/bash/ 

grep mountmodel /home/sand/localconfig > /home/sand/public_html/cgi-bin/ligne.tmp
read bidon mountmodel bidon < /home/sand/public_html/cgi-bin/ligne.tmp
star_list="Sirius Arcturus Altair Vega Polaris Mimosa Achernar Canopus Rigel Antares Betelgeuse Pollux Fomalhaut"

# these star are the possiblities offered  by pyephem 
#there are more possiblities if needed
# ajust it in star.py
echo "which star do you want to calibrate with. Choose in the list below: "
echo "Sirius"
echo "Arcturus"
echo "Altair"
echo "Vega"
echo "Polaris"
echo "Mimosa"
echo "Achernar"
echo "Canopus"
echo "Rigel"
echo "Antares"
echo "Betelgeuse"
echo "Pollux"
echo "Fomalhaut"
read star1
flag=`echo $star_list |grep -c $star1`
for n in $star_list
do m=`echo $n | grep -c $star1`
if [ $m = 1 ] 
 then star=$n 
fi 
done 
echo $star
if [ $flag = 0 ]
 then echo "not in the list"
 exit 0
fi 

#a 60 second delay is permitted to move mannualy the spectrometer and the mount with the star chosen

echo $star > star.tmp
let delay=60
let i=0
 while [ $i -le 2 ]; do 
/home/sand/hg/sand/star.py < star.tmp | sed 's/:/ /g' | sed 's/\./ /g' > calib.tmp
read altd altm alts bidon azd azm azs bidon < calib.tmp
echo "alt"$altd $altm $alts "az"$azd $azm $azs
if [ $mountmodel = "LXD-75" ] 
then 
  echo "#:Sz$azd*$azm'$azs#" > /dev/ttyS0                 #    theses commands are not totaly exact
  sleep 2                                                 #    therfore, they are not working propely
  echo "#:Sa$altd*$altm'$alts#" > /dev/ttyS0              #    work with LXD-75 to find the exact command to make it move
  sleep 2                                                 #    to the right position
  echo "#:MA#" > /dev/ttyS0                               #
elif [ $mountmodel = "PT785S+Pololu" ] 
#
#              read channels, gain and offset for angle to servo position conversion
#              servo_pos = elev_gain * angle(deg) + elev_offset
then 
echo "Mount model inside=" $mountmodel
               grep "elev_gain" /home/sand/localconfig > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon elev_gain bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
               grep "elev_offset" /home/sand/localconfig > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon elev_offset bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
               grep "azim_gain" /home/sand/localconfig > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon azim_gain bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
               grep "azim_offset" /home/sand/localconfig > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon azim_offset bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
               grep "elev_channel" /home/sand/localconfig  > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon elev_channel bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
               grep "azim_channel" /home/sand/localconfig  > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon azim_channel bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
              echo $elev_gain $elev_offset $azim_gain $azim_offset $elev_channel $azim_channel

#
#              goto park position
#
if [ $i -eq 0 ] 
then  
               sel=`/bin/echo "scale=0;180.*"$elev_gain"+"$elev_offset |/usr/bin/bc -l`
               saz=`/bin/echo "scale=0;0.*"$azim_gain"+"$azim_offset |/usr/bin/bc -l`
               servoel=`echo $sel | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               servoaz=`echo $saz | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               echo "init" $eled $sel $servoel $azid $saz $servoaz
               mono /usr/local/bin/UscCmd --servo $elev_channel","$servoel 
               mono /usr/local/bin/UscCmd --servo $azim_channel","$servoaz
               /bin/sleep $movetime2
fi
#
#              goto observing position
#
if [ $altm -ge 30 ]; then
   let altd=$altd+1 
else 
   let altd=$altd
fi
if [ $azm -ge 30 ]; then
  let azd=$azd+1 
else 
  let azd=$azd
fi
echo  "az"$azd "alt"$altd

               sel=`/bin/echo "scale=0;"$altd"*"$elev_gain"+"$elev_offset |/usr/bin/bc -l`
               saz=`/bin/echo "scale=0;"$azid"*"$azim_gain"+"$azim_offset |/usr/bin/bc -l`
               servoel=`echo $sel | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               servoaz=`echo $saz | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               echo "posi" $eled $sel $servoel $azid $saz $servoaz 
               mono /usr/local/bin/UscCmd --servo $elev_channel,$servoel 
               mono /usr/local/bin/UscCmd --servo $azim_channel,$servoaz
               /bin/sleep $movetime2
fi
let i=i+1

# delay is reduced since the mount and the spectrometer is already close to the star, it is just that the star as moved and so,
# a new position is needed to be precise
if [ $i -gt 1 ]; 
 then let delay=15
fi
echo "Align the mount on" $star
sleep $delay 
done

# a second star is used to make sure of the precision of the mount's movements, if the mount is precise, it should 
# not need to be move again

echo "Choose another different star from the list below:"
echo "Sirius"
echo "Arcturus"
echo "Altair"
echo "Vega"
echo "Polaris"
echo "Mimosa"
echo "Achernar"
echo "Canopus"
echo "Rigel"
echo "Antares"
echo "Betelgeuse"
echo "Pollux"
echo "Fomalhaut"
read n_star
flag=`echo $star_list |grep -c $n_star`
if [ $flag = 0 ]
 then echo "not in the list"
 exit 0
fi
if [ $n_star == $star ]
 then echo " choose a different star than the first one"
 exit 0
fi
star=$n_star
echo $star > star.tmp
let delay=30

let i=0
 while [ $i -le 2 ]; do 
/home/sand/hg/sand/star.py < star.tmp | sed 's/:/ /g' | sed 's/\./ /g' > calib.tmp
read altd altm alts bidon azd azm azs bidon < calib.tmp
echo "alt"$altd $altm $alts "az"$azd $azm $azs
if [ $mountmodel = "LXD-75" ]
then 
  echo "#:Sz$azd*$azm'$azs#" > /dev/ttyS0                 #    theses commands are not totaly exact
  sleep 2                                                 #    therfore, they are not working propely
  echo "#:Sa$altd*$altm'$alts#" > /dev/ttyS0              #    work with LXD-75 to find the exact command to make it move
  sleep 2                                                 #    to the right position
  echo "#:MA#" > /dev/ttyS0                               #
elif  [ $mountmodel = "PT785S+Pololu" ] 
#
#              read channels, gain and offset for angle to servo position conversion
#              servo_pos = elev_gain * angle(deg) + elev_offset
  then 
  echo "Mount model inside=" $mountmodel
               grep "elev_gain" /home/sand/localconfig > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon elev_gain bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
               grep "elev_offset" /home/sand/localconfig > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon elev_offset bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
               grep "azim_gain" /home/sand/localconfig > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon azim_gain bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
               grep "azim_offset" /home/sand/localconfig > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon azim_offset bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
               grep "elev_channel" /home/sand/localconfig  > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon elev_channel bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
               grep "azim_channel" /home/sand/localconfig  > /home/sand/public_html/cgi-bin/ligne.tmp 
               read bidon azim_channel bidon < /home/sand/public_html/cgi-bin/ligne.tmp  
              echo $elev_gain $elev_offset $azim_gain $azim_offset $elev_channel $azim_channel

#
#              goto park position
#
if [ $i -eq 0 ]  
then
               sel=`/bin/echo "scale=0;180.*"$elev_gain"+"$elev_offset |/usr/bin/bc -l`
               saz=`/bin/echo "scale=0;0.*"$azim_gain"+"$azim_offset |/usr/bin/bc -l`
               servoel=`echo $sel | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               servoaz=`echo $saz | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               echo "init" $eled $sel $servoel $azid $saz $servoaz
               mono /usr/local/bin/UscCmd --servo $elev_channel","$servoel 
               mono /usr/local/bin/UscCmd --servo $azim_channel","$servoaz
               /bin/sleep $movetime2
fi
#
#              goto observing position
#

# the mount precision is not good enough for minute of arc, so we have to round the numbers to the degree precision
  if [ $altm -ge 30 ] 
  then
   let altd=$altd+1 
  else 
   let altd=$altd
  fi
  if [ $azm -ge 30 ]
 then
  let azd=$azd+1 
  else 
  let azd=$azd
  fi
  echo  "az"$azd "alt"$altd
               sel=`/bin/echo "scale=0;"$altd"*"$elev_gain"+"$elev_offset |/usr/bin/bc -l`
               saz=`/bin/echo "scale=0;"$azid"*"$azim_gain"+"$azim_offset |/usr/bin/bc -l`
               servoel=`echo $sel | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               servoaz=`echo $saz | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
               echo "posi" $eled $sel $servoel $azid $saz $servoaz 
               mono /usr/local/bin/UscCmd --servo $elev_channel,$servoel 
               mono /usr/local/bin/UscCmd --servo $azim_channel,$servoaz
               /bin/sleep $movetime2
fi
let i=i+1
if [ $i -gt 1 ]; 
 then let delay=15
fi
echo "Align the mount on" $star
sleep $delay 
done
