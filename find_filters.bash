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
 


echo "Start scnanning filters"
rm -f filters_pos.txt
grep filter_channel /home/sand/localconfig > toto
read bidon channel bidon < toto
grep filter_offset /home/sand/localconfig > toto
read bidon offset bidon < toto
grep sqmIP /home/sand/localconfig > toto
read bidon sqmip bidon < toto
grep filter_gain /home/sand/localconfig > toto
read bidon gain  bidon < toto

#Variables

let scanpoint=offset-60
let park=scanpoint
let maxpoint=offset+gain*12+60
let pointavd=350000
let pointav=350000

#scaning_filters


while [ $scanpoint -le $maxpoint ]
do /usr/local/bin/MoveFilterWheel.py $scanpoint $channel $park 
   /usr/local/bin/sqmleread.pl $sqmip 10001 1 > sqmdata.tmp      
      read sqm < sqmdata.tmp
      echo $sqm | sed 's/,/ /g' | sed 's/m//g' > toto.tmp
      read toto sbdec toto < toto.tmp


read sqm < sqmdata.tmp
echo $sqm | sed 's/,/ /g' | sed 's/s//g' > toto.tmp
read toto sb toto toto toto toto < toto.tmp
echo $sb | sed 's/\./ /g'  > toto.tmp
echo $sb | sed 's/\m/ /g'  > toto.tmp
read sbe sbd toto < toto.tmp
echo $sbe $sbd

let sb=$sbe*100+$sbd

      if [[ $sb -gt $pointav && $pointav -lt $pointavd ]] 
then echo $scanpointp >> /home/sand/filters_pos.txt
fi
let pointavd=pointav
let pointav=$sb
let scanpointp=scanpoint
let scanpoint=scanpoint+20

done


echo "Scnanning filters finished"







