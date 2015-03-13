#!/bin/bash
#Usage DelContinium.bash txt_file_name 
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
then  echo "Usage: DelContinium.bash cxy_file_name"
      echo "Specify the file name (1st parameter) " 
      exit 1
fi
npts=13
gapl=8
gapr=9
outname=`echo $1 | sed 's/\_re.cxy/_re_li\.cxy/g'`
gplotfile=`echo $1 | sed 's/\_re.cxy/_re_li\.gplot/g'`
echo "nom cont"
contmin=`echo $1 | sed 's/\_re.cxy/_re_li\.cmin/g'`
echo $contmin
nflux=`/bin/grep -c "" $1`
echo $1 $npts $nflux $gapl $gapr > continium.tmp 
#filtering main Fraunhofer lines
/bin/grep "416\.0" $1 >> continium.tmp  #1
/bin/grep "420\.0" $1 >> continium.tmp  #2
/bin/grep "445\.0" $1 >> continium.tmp  #3
/bin/grep "455\.5" $1 >> continium.tmp  #4
/bin/grep "463\.0" $1 >> continium.tmp  #5
/bin/grep "478\.0" $1 >> continium.tmp  #6
/bin/grep "508\.0" $1 >> continium.tmp  #7
/bin/grep "527\.0" $1 >> continium.tmp  #8
# large HPS feature 541nm-700nm
/bin/grep "665\.0" $1 >> continium.tmp  #9
/bin/grep "703\.0" $1 >> continium.tmp  #10
/bin/grep "711\.0" $1 >> continium.tmp  #11
/bin/grep "717\.0" $1 >> continium.tmp  #12
/bin/grep "721\.0" $1 >> continium.tmp  #13
# keepminonwin
echo "execute keepmoyonwin"
/usr/local/bin/keepmoyonwin
echo "renaming continium file"
mv ./continium-min.tmp  ./$contmin
#
base=`echo $1 | sed 's/\.cxy//g'`
echo $base
# echo "set termimal png" > $gplotfile
echo "h(x)=a+b*x+c*x**2+d*x**3+e*x**4+f*x**5" > $gplotfile
echo "a=1" >> $gplotfile
echo "b=1" >> $gplotfile
echo "c=1" >> $gplotfile
echo "d=1" >> $gplotfile
echo "e=1" >> $gplotfile
echo "f=1" >> $gplotfile
echo "g=1" >> $gplotfile
echo "FIT_LIMIT = 1e-99" >> $gplotfile
echo "FIT_MAXITER=100" >> $gplotfile
echo "fit h(x) '"$contmin"' using 1:2  via a,b,c,d,e,f" >> $gplotfile
echo "set xrange [400:730]" >> $gplotfile
echo "set style data lines" >> $gplotfile
echo "set grid" >> $gplotfile
echo "set mxtics " >> $gplotfile
echo "set mytics " >> $gplotfile
echo "save functions 'fit.txt'">> $gplotfile
echo "save variables 'var.txt'">> $gplotfile
echo "running gnuplot"
/usr/bin/gnuplot < $gplotfile 
echo "end of gnuplot"

echo "plot h(x)" >> $gplotfile
echo "replot '"$contmin"' with points pt 6 ps 2 lc 1" >> $gplotfile
echo "replot '"$1"'"  >> $gplotfile
echo "replot '"$1"' using 1:(\$2-h(\$1)) " >> $gplotfile

# lecture des parametres du polynome fitte
/bin/grep "a =" var.txt > fitvar.tmp
read bidon bidon a < fitvar.tmp
/bin/grep "b =" var.txt > fitvar.tmp
read bidon bidon b < fitvar.tmp
/bin/grep "c =" var.txt > fitvar.tmp
read bidon bidon c < fitvar.tmp
/bin/grep "d =" var.txt > fitvar.tmp
read bidon bidon d < fitvar.tmp
/bin/grep "e =" var.txt > fitvar.tmp 
read bidon bidon e < fitvar.tmp
/bin/grep "f =" var.txt > fitvar.tmp 
read bidon bidon f < fitvar.tmp
form=`echo  $a"+"$b"*x+"$c"*x^2+"$d"*x^3+"$e"*x^4+"$f"*x^5" | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
rm -f $outname
   # soustraction du continu
   while read line
   do echo $line | sed -e 's/E+/\*10\^/g' | sed -e 's/E-/\*10\^-/g' > ligne.tmp
      read lambda intens < ligne.tmp
      formule=`echo $form | sed -e 's/x/'$lambda'/g'`
      bg=`/bin/echo "scale=25;"$formule | /usr/bin/bc`
      newint=`/bin/echo "scale=25;"$intens"-1.0*"$bg | /usr/bin/bc`
      echo $lambda $newint  >> $outname
   done < $1
# cleaning
rm -f var.txt
rm -f fit.txt
rm -f fit.log
