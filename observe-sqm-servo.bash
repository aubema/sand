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
nobs=10
waittime=1
#
# set angles list
# wavelengths    1    2     3       4       5     6       7       8        9       10       11        12
filters=( 0 1 2 3 4 5 6 7 8 9 10 11 12)
grep filter_channel /home/sand/localconfig > toto
read bidon channel bidon < toto
grep filter_gain /home/sand/localconfig > toto
read bidon gain  bidon < toto
grep filter_offset /home/sand/localconfig > toto
read bidon offset bidon < toto
grep sqmIP /home/sand/localconfig > toto
read bidon sqmip bidon < toto
i=0
while [ $i -lt $nobs ]
do n=0
   echo "Start"
   let i=i+1
   echo "observation numéro: " $i
   while [ $n -lt ${#filters[*]} ]
   do filter=${filters[$n]}

      ang=`/bin/echo "scale=0;"$filter"*"$gain"+"$offset |/usr/bin/bc -l`
#      servoang=`echo $ang | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`

      echo "deplacement de la roue" $channel $ang

# moving filter wheel
      /usr/local/bin/MoveFilterWheel.py $ang $channel       
      echo "lecture du sqm, "  "Filtre: "  $(($n+1))
      /usr/local/bin/sqmleread.pl $sqmip 10001 1 > sqmdata.tmp
      read sqm < sqmdata.tmp
      echo $sqm | sed 's/,/ /g' | sed 's/m//g' > toto.tmp
      read toto sb toto < toto.tmp
      echo $sb
      sbcal[$n]=`/bin/echo "e((-1*"$sb"/2.5000000)*l(10))*"${calib[$n]} |/usr/bin/bc -l`
      sbcals[$n]=`printf "%0.6e\n" ${sbcal[$n]}`
      echo ${sbcals[$n]}
      let n=n+1
      
      /bin/sleep $waittime

   done
nomfich=`date -u +"%m-%d-%y"`

time=`date -u`
echo $time ${sbcals[0]} ${sbcals[1]} ${sbcals[2]} ${sbcals[3]} ${sbcals[4]} ${sbcals[5]} ${sbcals[6]} ${sbcals[7]} ${sbcals[8]} ${sbcals[9]} ${sbcals[10]} ${sbcals[11]}>> radio-$nomfich".txt"


   echo "Retour au point initial"
   sudo mono /usr/local/bin/UscCmd --servo 5,4200
   /bin/sleep $waittime
   
done
echo "Finish"
# (# filtre/courbe de correction)| 1:=0,3079628655 2:=0,0610003776 3:=0,0240134349 4:=0,0475081568 5:=0,0324283742 6:=0,0196314445
                                 | 7:=0,0181267619 8:=0,0178495913 9:=0,0222421521 10:=0,0228081498 11:=0,013580985
# (numero angle/longueur d onde en nm) 1:= 405 ,2:= 420 3:= 435.8 ,4:= 460 ,5:= 500 ,6:= 530 ,7:= 546.1 ,8:= 560 ,9:= 568.2 ,10:= 630 ,11:= 660 ,12:= vide
#sudo mono /usr/local/bin/UscCmd --servo 5,3600
#sudo bash ./observe-sqm-servo.bash
