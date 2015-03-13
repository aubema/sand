#!/bin/bash 
# This script find the lineup and linedown position of a spectrum of order nordre
# on the fits image given in argument
# usage: findspectrum.bash fits_file approx_upper_line approx_lower_line
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
# decal is the increse of the search window (up and down) relative to the 1st guess limits given in 2nd and 3rd argument
decal=40
#
let uplimit=$2-decal
let downlimit=$3+decal
#
# searching first spectrum upper gap encontered
meanmin=65535
let pos=downlimit
let 'posf=downlimit-(downlimit-uplimit)/2'
while [ $pos -gt $posf ]
do let pos1=510-pos-4
   let pos2=510-pos+4
imstat $1[10:760,$pos1:$pos2] | grep mean | sed 's/\./ /g' > mean.tmp
read bidon bidon bidon mean bidon < mean.tmp
if [ $mean -lt $meanmin ]
then let meanmin=mean
     let posmin=pos
fi
   let pos=pos-1
done
let linedown=posmin-11
#
# searching first spectrum upper gap encontered
meanmin=65535
let pos=uplimit
let 'posf=uplimit+(downlimit-uplimit)/2'
while [ $pos -lt $posf ]
do let pos1=510-pos-4
   let pos2=510-pos+4
imstat $1[10:760,$pos1:$pos2] | grep mean | sed 's/\./ /g' > mean.tmp
read bidon bidon bidon mean bidon < mean.tmp
if [ $mean -lt $meanmin ]
then let meanmin=mean
     let posmin=pos
fi
   let pos=pos+1
done
let lineup=posmin+11
echo $lineup $linedown