#!/bin/bash 
#   
#    Copyright (C) 2017  Martin Aube Jeremie Gince
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
# 

# home directory
homed=$HOME

nobs=1
waittime=10             # at a mag of about 24 the integration time is around 60s
#
# set angles list
# wavelengths 0:= vide ,1:= 420 2:= 435.8 ,3:= 460 ,4:= 500 ,5:= 530 ,6:= 546.1 ,7:= 560 ,8:= 568.2 ,9:= 630 ,10:= 660 ,11:= 405 ,12:= vide
# possibilite d'ajouter un filtre a 480 ulterieurement (creu DEL)
filters=( 0 1 2 3 4 5 6 7 8 9 10 11 12)
calib=( 1.0 2044.0 1871.0 2989.0 4199.0 1137.0 1367.0 1075.0 971.0 844.0 6250.0 2390.0 1.0 )
grep filter_channel $homed/localconfig > toto
read bidon channel bidon < toto
read gain offset  bidon < $homed/filtersconfig
grep sqmIP $homed/localconfig > toto
read bidon sqmip bidon < toto

if [ ! -f $homed/filtersconfig ]
   then echo "Error: File $homed/filtersconfig not found"
        exit 0
fi
echo "Start observe-sqm-servo.bash"
# according to unihedron here are the typical waiting time vs sky brightness
# 19.83 = 1s
# 21.97 = 6.9s
# 22.69 = 12.8s
# 23.13 = 18.7s
# 23.48 = 24.6s
# 23.76 = 30.5s
# 24.00 = 36.4s
# 24.21 = 42.3s
# 24.41 = 48.2s
# 24.60 = 54.1s
# 24.76 = 60s
#
# it is suggested to use filter 1 (420nm) to estimate the waittime
# waittime must be at least twice that time (we suggest 3x)
ang=`/bin/echo "scale=0;1*"$gain"+"$offset |/usr/bin/bc -l`

# moving filter wheel to filter 1
# echo "deplacement de la roue" $channel $ang
let park=offset
/usr/local/bin/MoveFilterWheel.py $ang $channel $park
echo "Waiting " $waittime " s to estimate acquisition time"
/bin/sleep $waittime
/usr/local/bin/sqmleread.pl $sqmip 10001 1 > sqmdata.tmp
read sqm < sqmdata.tmp
echo $sqm | sed 's/,/ /g' | sed 's/s//g' > toto.tmp
read toto toto toto toto tim toto < toto.tmp
echo "Decimal readout time: " $tim
echo $tim | sed 's/\./ /g'  > toto.tmp
read tim timd toto < toto.tmp
echo $tim | sed 's/000//g'  > toto.tmp
read tim toto < toto.tmp
# echo $tim $timd
if [ $timd -ge 500 ]
then let tim=tim+1
fi
let waittime=tim
if [ $waittime == 0 ]
   then waittime=1
 #  echo "toto" $waittime
else
   let waittime=waittime*3
fi
#angle=( $( cat $homed/filters_pos.txt ) )
# echo "Acquistion time:" $waittime
i=0
while [ $i -lt $nobs ]
do n=0
#   echo "Start"
   let i=i+1
 #  echo "observation numero: " $i
   while [ $n -lt ${#filters[*]} ]
   do filter=${filters[$n]}
      if [ $filter -le 6 ]
      then let park=gain*12+offset
      else
           let park=offset
      fi
 #     echo "Waiting time:" $waittime

ang=`/bin/echo "scale=0;"$n"*"$gain"+"$offset |/usr/bin/bc -l`
#      ang=${angle[$n]}


# moving filter wheel
 #     echo "deplacement de la roue" $channel $ang
      /usr/local/bin/MoveFilterWheel.py $ang $channel $park      
#      echo "reading sqm, "  "Filtre: "  $(($n+1))
      /bin/sleep $waittime         # let enough time to be sure that the reading comes from this filter

      /usr/local/bin/sqmleread.pl $sqmip 10001 1 > sqmdata.tmp
 #     echo "end of reading"      
      read sqm < sqmdata.tmp
      echo $sqm | sed 's/,/ /g' | sed 's/m//g' > toto.tmp
      read toto sb toto < toto.tmp
      if [ $n -eq 0 ]
      then sqmreading=$sb
      fi
 #     echo $sb
      sbcal[$n]=`/bin/echo "e((-1*"$sb"/2.5000000)*l(10))*"${calib[$n]} |/usr/bin/bc -l`
      sbcals[$n]=`printf "%0.6e\n" ${sbcal[$n]}`
 #     echo ${sbcals[$n]}
      let n=n+1
   done
nomfich=`date -u +"%m-%d-%y"`

time=`date +%Y-%m-%d" "%H:%M:%S`
echo $time $sqmreading ${sbcals[1]} ${sbcals[2]} ${sbcals[3]} ${sbcals[4]} ${sbcals[5]} ${sbcals[6]} ${sbcals[7]} ${sbcals[8]} ${sbcals[9]} ${sbcals[10]} ${sbcals[11]}>> $homed/public_html/cgi-bin/photom.txt
/bin/sleep $waittime
   
done
echo "Finish observe-sqm-servo.bash"
