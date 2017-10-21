#program to read and archive sqm-le data
sqmip="192.168.0.10"
/usr/local/bin/sqmleread.pl $sqmip 10001 1 > sqmdata.tmp
read sqm < sqmdata.tmp
/bin/echo $sqm | sed 's/,/ /g' | sed 's/m//g' | sed 's/\ 00000/\ /g' | sed 's/\ 0000/\ /g'| sed 's/\ 000/\ /g'| sed 's/\ 00/\ /g'| sed 's/\ 0/\ /g'> toto.tmp
read toto sb intime temp toto  < toto.tmp
y=`/bin/date -u +%Y`
mo=`/bin/date -u +%m`
j=`/bin/date -u +%d`
m=`/bin/date -u +%M`
h=`/bin/date -u +%H`
s=`/bin/date -u +%S`
/bin/mkdir /var/www/html/DATA-SAND/SQM-Saint-Camille/$y
/bin/mkdir /var/www/html/DATA-SAND/SQM-Saint-Camille/$y/$mo
/bin/mkdir /var/www/html/DATA-SAND/SQM-Saint-Camille/$y/$mo/$j
/bin/echo $y $mo $j $h $m $s $sb $intime $temp >> data-$y-$mo-$j.txt
