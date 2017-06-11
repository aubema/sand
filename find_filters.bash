#!/bin/bash
#find_filters


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
 
# home directory
homed=$HOME

echo "Start scanning filters"

rm -f $homed/filters_pos.txt
grep filter_channel $homed/localconfig > toto
read bidon channel bidon < toto
grep filter_offset $homed/localconfig > toto
read bidon offset bidon < toto
grep sqmIP $homed/localconfig > toto
read bidon sqmip bidon < toto
grep filter_gain $homed/localconfig > toto
read bidon gain  bidon < toto

#Variables

let n=0
let maxpoint=offset+gain*12+200
let scanpoint=offset-100
let park=scanpoint
let pointavd=350000
let pointav=350000
let pointaavd=350000
let pointaaavd=350000
let scanpointp=scanpoint-20

/usr/local/bin/MoveFilterWheel.py $scanpoint $channel $park
sleep 3

#scaning_filters

ntentative=0
while [ $scanpoint -le $maxpoint ]
do /usr/local/bin/MoveFilterWheel.py $scanpoint $channel $park
   let ntentative=ntentative+1
   /usr/local/bin/sqmleread.pl $sqmip 10001 1 > sqmdata.tmp      
   read sqm < sqmdata.tmp
   echo $sqm | sed 's/, 0/ /g' | sed 's/,/ /g' | sed 's/m//g' > toto.tmp
   read toto sb toto toto toto toto < toto.tmp

   echo $sb | sed 's/\.//g' > toto.tmp
   read sb toto < toto.tmp
  

#  echo "finding filtre #: "$n       "pos: "$scanpoint       "magnitude: "$sb"m"
  
#   echo "______________________________________________________________________________________"

   if [[ $sb -gt $pointav && $pointav -le $pointavd && $pointavd -le $pointaavd && $pointaavd -le $pointaaavd ]]
   then echo $scanpointp >> $homed/filters_pos.txt
 #       echo "filtre # " $n ; echo "pos " $scanpointp
        let n=n+1
                 if [[ $n -eq 1 ]]     
                     then let scanpoint=maxpoint-400
                           /usr/local/bin/MoveFilterWheel.py $scanpoint $channel $park
                 fi
   fi

   let pointaaavd=pointaavd
   let pointaavd=pointavd
   let pointavd=pointav
   let pointav=sb
   let scanpointp=scanpoint
   let scanpoint=scanpoint+20
   if [ $ntentative -ge 50 ]
   then /bin/echo "find_filters: Probably a bad connection with the filter wheel"
        exit 0
   fi
done

echo "Scanning filters finished"

offset=`head -1 $homed/filters_pos.txt`
posf=`tail -1 $homed/filters_pos.txt`
gain=`/bin/echo "scale=0;("$posf"-"$offset")/12" |/usr/bin/bc -l`
echo $gain $offset > $homed/filtersconfig

#bash find_filters.bash


