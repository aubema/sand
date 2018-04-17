#!/bin/bash 
#   
#    Copyright (C) 2018  Martin Aube Mia Caron
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
homed=/home/sand

nobs=1
waittime=10             # at a mag of about 24 the integration time is around 60s
#
# set band list
# wavelengths 0:= Clear ,1:= Red 2:= Green ,3:= Blue ,4:= Yellow
#
filters=( 0 1 2 3 4 )
calib=( 1.0 1.0 1.0 1.0 1.0 )
grep filter_gain $homed/localconfig > toto
read bidon gain bidon < toto
grep filter_offset $homed/localconfig > toto
read bidon offset bidon < toto
grep sqmIP $homed/localconfig > toto # sqmIP est le mot cle cherche dans le localconfig 
read bidon sqmip bidon < toto
# find the clear filter
# one complete rotation in half step mode (mode 1) is 4096 i.e. 1 step = 0.087890625 deg
# if you use the full step mode (mode 0) then 1028 is the number of steps i.e. 1 step = 0.17578125
pos=0
memoi=0
n=0
while [ $n -le 128 ] 
# 128 steps of 32 count =  4096
do sudo MoveStepFilterWheel.py 32 1
   let pos=pos+32
   /usr/local/bin/sqmleread.pl $sqmip 10001 1 > sqmdata.tmp    
   read sqm < sqmdata.tmp
   echo $sqm | sed 's/,/ /g' | sed 's/m/ /g' | sed 's/\./ /g' > toto.tmp
   read bidon sqmm sqmd bidon < toto.tmp
   # remove leading zero to the sky brightness
   if [ ${sqmm:0:1} == 0 ]
   then sqmm=`echo $sqmm | sed 's/0//g'`
   fi
   if [ ${sqmd:0:1} == 0 ]
   then sqmd=`echo $sqmd | sed 's/0//g'`
   fi
   let meas=sqmm*100+sqmd
   if [ $meas -gt $memoi ]
   then let memoi=meas
        let possqm=pos
        # en supposant 128 steps (4096/128=32)
        echo "Found darker position = " $possqm
   fi
   let n=n+1
done
echo "Clear filter position +- 32 = " $possqm


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
# it is suggested to use filter 1 (Red) to estimate the waittime
# waittime must be at least twice that time
# moving the filter wheel to the Red filter
# 72 degrees between filter i.e. 4096/5 = 819

increment=819
let ang=pos-possqm-1*increment)
if [ ang -ge 4096 ] let ang=ang-4096
if [ ang -le -4086 ] let ang=ang+4096
echo "Moving wheel to" $ang
#
/usr/local/bin/MoveStepFilterWheel.py $ang 1
let pos=pos+ang
echo "Waiting " $waittime " s to estimate final acquisition time"
/bin/sleep $waittime
/usr/local/bin/sqmleread.pl $sqmip 10001 1 > sqmdata.tmp
read sqm < sqmdata.tmp
echo $sqm | sed 's/,/ /g' | sed 's/s//g' > toto.tmp
read bidon bidon bidon bidon tim bidon < toto.tmp
echo "Decimal readout time: " $tim
echo $tim | sed 's/\./ /g'  > toto.tmp
read tim timd toto < toto.tmp
echo $tim | sed 's/000//g'  > toto.tmp
read tim toto < toto.tmp
if [ $timd -ge 500 ]
then let tim=tim+1
fi
# EST CE VRAIMENT NECESSAIRE DE MULTIPLIER PAR DEUX?
let waittime=2*tim
echo "Required acquistion time:" $waittime
#
# Main loop
#
i=0
while [ $i -lt $nobs ]
do n=0
   echo "Start"
   let i=i+1
   echo "Observation number: " $i
   while [ $n -lt ${#filters[*]} ]
   do filter=${filters[$n]}
      let ang=pos-possqm-n*increment)
      if [ ang -ge 4096 ] let ang=ang-4096
      if [ ang -le -4086 ] let ang=ang+4096
      # moving filter wheel
      echo "Moving the filter wheel to filter " $n
      let pos=pos+ang
      /usr/local/bin/MoveStepFilterWheel.py $ang 1  
      echo "Reading sqm, Filter: " $n
      echo "Waiting time:" $waittime
      /bin/sleep $waittime         # let enough time to be sure that the reading comes from this filter
      /usr/local/bin/sqmleread.pl $sqmip 10001 1 > sqmdata.tmp
      echo "End of reading"      
      read sqm < sqmdata.tmp
      echo $sqm | sed 's/,/ /g' | sed 's/m//g' > toto.tmp
      read bidon sb bidon < toto.tmp
      if [ $n -eq 0 ]
      # keep the sqm clear value in mag per square arc second
      then sqmreading=$sb
      fi
      echo "Sky brightness = " $sb
      # convert mag par sq arc second to flux
      sbcal[$n]=`/bin/echo "e((-1*"$sb"/2.5000000)*l(10))*"${calib[$n]} |/usr/bin/bc -l`
      sbcals[$n]=`printf "%0.6e\n" ${sbcal[$n]}`
      echo "Flux in band " $n " = "${sbcals[$n]}
      let n=n+1
   done
   nomfich=`date -u +"%Y-%m-%d"`
   nomfich=$nomfich".txt"
   time=`date +%Y-%m-%d" "%H:%M:%S`
   echo $time $sqmreading ${sbcals[0]} ${sbcals[1]} ${sbcals[2]} ${sbcals[3]} ${sbcals[4]}>> $homed/$nomfich
done
echo "Finish observe-sqm-stepper.bash"
