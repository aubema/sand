#!/bin/bash 
# script pour extraire l'integrale sous une raie des spectres contenus dans
# le repertoire d'execution
# 
# usage:  getLine.bash spectrum_file wavelength
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
if [ ! $1 ]
then echo "Usage: getLine.bash spectrum_file wavelength"
     exit 1
fi
if [ ! $2 ]
then echo "Usage: getLine.bash spectrum_file wavelength"
     exit 1
fi
nom=`echo $1 | /bin/sed 's/\.cxy/_wl/g'`
width=4.
if [ ! -f $2"nm-time.serie" ] 
then  echo "DOY INT_"$2"+-"$width > $2"nm-time.serie"
fi
echo $2 $width > Line.tmp
npix=`grep -c "" $1`
echo $npix > Line_in.tmp
# extraire les date et heure
echo $1 | sed -e 's/_/ /g' | sed -e 's/-dark/ /g' > getdate.tmp
read bid bid bid bid bid jj ss bidon < getdate.tmp
jour=`date --date=$jj +%j`
fractime=`date --date=$jj" "$ss +%s`
fractime0=`date --date=$jj +%s`   
let ds=fractime-fractime0
fraction=`echo "scale=5;"$ds"/(24*3600)" | bc`
echo "Integrating lambda="$2"+-"$width "in" $1
cp -f $1 sp.tmp
integLine
read value < integLine.tmp

echo "Writing integrated line flux at " $2 " into time serie file"
echo $jour$fraction $value >> $2"nm-time.serie"
mv -f integLine.tmp $nom"_"$2

if [ ${value:0:1} = "-" ]
then  echo "Bad background substraction on file" $1" at wavelength" $2"nm ("$value"). Probably contaminated by sun, moon of twilight." >> error.log
#    echo "1" > moonflag.tmp
fi


