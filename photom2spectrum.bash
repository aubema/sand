#!/bin/bash
# programm that infer the spectral properties of the night sky from
# 12 narroband filters radiometer
#
#    copyright Martin Aube, June 2017
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
then  echo "Usage: photom2spectrum.bash photometerdatafile"
      echo "Specify the photometer file name (1st parameter) " 
      exit 1
fi
# number of points to fit
npts=4
#
outname=$1"_analysed"
gplotfile="gplot.tmp"
# determine the number of lines of the photometer file
nlines=`grep -c "" $1`
npts=4
nl=0
gapl=8
gapr=9
echo "Date       Time      SQM   Rad_Hg_405 Rad_Hg_436  Rad_Na_498  Rad_Hg_546  Rad_OI_557  Rad_Na_569  Rad_OI_630  Rad_error      Stars_polynomial" > $outname
while [ $nl -le $nlines ]
do let nl=nl+1
   cat $1 | head -$nl | tail -1 > dataline.tmp
#  wavelengths 0:= vide ,1:= 420 2:= 435.8 ,3:= 460 ,4:= 500 ,5:= 530 ,6:= 546.1 ,7:= 560 ,8:= 568.2 ,9:= 630 ,10:= 660 ,11:= 405 ,12:= vide
   read dat tim sqm b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 < dataline.tmp
echo $dat $tim $b1
#  transforming the integrated band flux in radiance per nanometer
   b1=`echo  $b1 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   b2=`echo  $b2 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   b3=`echo  $b3 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   b4=`echo  $b4 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   b5=`echo  $b5 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   b6=`echo  $b6 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   b7=`echo  $b7 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   b8=`echo  $b8 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   b9=`echo  $b9 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   b10=`echo  $b10 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   b11=`echo  $b11 | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
   pb1=`/bin/echo "scale=30;"$b1"/10." | /usr/bin/bc`
   pb3=`/bin/echo "scale=30;"$b3"/10." | /usr/bin/bc`
   pb5=`/bin/echo "scale=30;"$b5"/10." | /usr/bin/bc`
   pb10=`/bin/echo "scale=30;"$b10"/10." | /usr/bin/bc`

#   /bin/echo $1 $npts $gapl $gapr > continium.tmp 


#  building the data file to fit
   /bin/echo "420.0" $pb1 > continium.tmp  #1
   /bin/echo "460.0" $pb3 >> continium.tmp  #2
   /bin/echo "530.0" $pb5 >> continium.tmp  #3
   /bin/echo "660.0" $pb10 >> continium.tmp  #4


   echo "set term none" > $gplotfile
   echo "h(x)=a+b*x+c*x**2" >> $gplotfile
   echo "a=1" >> $gplotfile
   echo "b=1" >> $gplotfile
   echo "c=1" >> $gplotfile
   echo "FIT_LIMIT = 1e-99" >> $gplotfile
   echo "FIT_MAXITER=100" >> $gplotfile
   echo "fit h(x) 'continium.tmp' using 1:2  via a,b,c" >> $gplotfile
   echo "set xrange [400:730]" >> $gplotfile
   echo "set style data lines" >> $gplotfile
   echo "set grid" >> $gplotfile
   echo "set mxtics " >> $gplotfile
   echo "set mytics " >> $gplotfile
   echo "save functions 'fit.txt'">> $gplotfile
   echo "save variables 'var.txt'">> $gplotfile
   echo "plot h(x)" >> $gplotfile
   echo "replot 'continium.tmp' with points pt 6 ps 2 lc 1" >> $gplotfile
   echo "replot '"$1"'"  >> $gplotfile
   echo "replot '"$1"' using 1:(\$2-h(\$1)) " >> $gplotfile
   echo "running gnuplot"
   /usr/bin/gnuplot  < $gplotfile 
   echo "end of gnuplot"

#  lecture des parametres du polynome fitte
   /bin/grep "a =" var.txt > fitvar.tmp
   read bidon bidon a < fitvar.tmp
   /bin/grep "b =" var.txt > fitvar.tmp
   read bidon bidon b < fitvar.tmp
   /bin/grep "c =" var.txt > fitvar.tmp
   read bidon bidon c < fitvar.tmp
   form=`echo  $a"+"$b"*x+"$c"*x^2"`
   formule=`echo  $form | sed -e 's/e+/\*10\^/g' | sed -e 's/e-/\*10\^-/g'`
#  flux continu pour chaque bande   
   localform=`echo $formule | sed -e 's/x/'420.'/g'`
   contb1=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`
   localform=`echo $formule | sed -e 's/x/'435.8'/g'`
   contb2=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`
   localform=`echo $formule | sed -e 's/x/'460.'/g'`
   contb3=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`
   localform=`echo $formule | sed -e 's/x/'500.'/g'`
   contb4=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`
   localform=`echo $formule | sed -e 's/x/'530.'/g'`
   contb5=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`
   localform=`echo $formule | sed -e 's/x/'546.1'/g'`
   contb6=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`
   localform=`echo $formule | sed -e 's/x/'560.'/g'`
   contb7=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`
   localform=`echo $formule | sed -e 's/x/'568.2'/g'`
   contb8=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`  
   localform=`echo $formule | sed -e 's/x/'630.'/g'`
   contb9=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`
   localform=`echo $formule | sed -e 's/x/'660.'/g'`
   contb10=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`
   localform=`echo $formule | sed -e 's/x/'405.'/g'`
   contb11=`/bin/echo "scale=30;10.*("$localform")" | /usr/bin/bc`

#  soustraction du continu pour chaque bande
   line1=`/bin/echo "scale=30;"$b1"-"$contb1 | /usr/bin/bc`
   line2=`/bin/echo "scale=30;"$b2"-"$contb2 | /usr/bin/bc`
   line3=`/bin/echo "scale=30;"$b3"-"$contb3 | /usr/bin/bc`
   line4=`/bin/echo "scale=30;"$b4"-"$contb4 | /usr/bin/bc`
   line5=`/bin/echo "scale=30;"$b5"-"$contb5 | /usr/bin/bc`
   line6=`/bin/echo "scale=30;"$b6"-"$contb6 | /usr/bin/bc`
   line7=`/bin/echo "scale=30;"$b7"-"$contb7 | /usr/bin/bc`
   line8=`/bin/echo "scale=30;"$b8"-"$contb8 | /usr/bin/bc`
   line9=`/bin/echo "scale=30;"$b9"-"$contb9 | /usr/bin/bc`
   line10=`/bin/echo "scale=30;"$b10"-"$contb10 | /usr/bin/bc`
   line11=`/bin/echo "scale=30;"$b11"-"$contb11 | /usr/bin/bc`


# estimating error with line1 line3 line5 line10
   error=`/bin/echo "scale=30;sqrt(("$line1"^2.0+"$line3"^2.0+"$line5"^2.0+"$line10"^2.0)/4.0)" | /usr/bin/bc`
   echo "error="$error
   lines=`printf "%0.4e " $line1 $line2 $line4 $line6 $line7 $line8 $line9`
   rms=`printf "%0.4e " $error`
   echo $lines $rms
# writing output
   if [ $rms != "0.0000e+00" ]
   then echo $dat $tim $sqm $lines " | " $rms " | " $a "+ " $b " x lambda + " $c " x lambda^2" >> $outname
   fi
# fin du while

#if [ $nl -eq 60 ] ; then exit 0 ; fi
done

# cleaning
rm -f dataline.tmp
rm -f continium.tmp
