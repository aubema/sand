# Usage: bash scatterogram-analysis.bash year month string calib_factor
# 
#  string is a word that permit to distinguish the dataset file names 
#         it can be the extension etc

# *** YOU MUST EDIT THIS SECTION ***
# Local data
#
# longitude
dlon=71  # longitude west, no support for negative longitudes
mlon=7
slon=34

# latitude
dlat=45
mlat=25
slat=24
# site name
NAME="Cosmolab"
# altitude
alt=579
# correction from standard local time to get GMT - 0 if your recorded time is already in GMT
gmtcor=0
# is your time dependant on daylight saving? saving=1 (yes) - saving=0 (no)
saving=0
# date and time of change to daylight saving
dlmonth=03
dlday=31
dlhour=02
# date and time of change to standard time
stmonth=10
stday=27
sthour=03
#
# *** DO NOT EDIT BELOW THIS LINE ***
#
# calculate date in second for daylight saving change and standard time change
daylightsec=`date -d "$1/$dlmonth/$dlday $dlhour:00:00" +%s`
standardsec=`date -d "$1/$stmonth/$stday $sthour:00:00" +%s`
rm -f $1$2*$3*_womoon*
rm -f $1$2*$3*_wmoon*
rm -f $1$2*$3*gnuplot
let tnout=0
let mnout=0
if [ ! $4 ] ; then calib="1.0" ; else calib=$4 ; fi
#echo $calib
#  Strip possible leading zero(s) from input variables
if [ ${#dlon} -eq 2 ] ; then dlon=${dlon#0} ; else dlon=$dlon ; fi
if [ ${#mlon} -eq 2 ] ; then mlon=${mlon#0} ; else mlon=$mlon ; fi
if [ ${#slon} -eq 2 ] ; then slon=${slon#0} ; else slon=$slon ; fi
if [ ${#dlat} -eq 2 ] ; then dlat=${dlat#0} ; else dlat=$dlat ; fi
if [ ${#mlat} -eq 2 ] ; then mlat=${mlat#0} ; else mlat=$mlat ; fi
if [ ${#slat} -eq 2 ] ; then slat=${slat#0} ; else slat=$slat ; fi
#
# convert longitude from deg to hours
let hourdeg=15
let deglon="$dlon"*3600+"$mlon"*60+"$slon"
let seclon="$deglon"/"$hourdeg"
let hrlon="$seclon"/3600
let mnlon=("$seclon"-"$hrlon"*3600)/60
let sclon="$seclon"-"$hrlon"*3600-"$mnlon"*60

#
# Loop over one month
filelist=`ls -1 $1$2*$3*`
echo "Number of files:" `ls -1 $1$2*$3* | grep -c ""`

for fil in $filelist
do filename=$fil
   #
   # determine the number of data
   let n=0
   ndat=`grep -c "" $filename`
   echo "Number of data points for file" $filename ":" $ndat
   while [ $n -le $ndat ]
   do let n=n+1
      rm -f moon*.tmp
      ###########
      # Thomas Posch's format
      head -$n $filename | tail -1 | sed 's/:/ /g' |sed 's/\// /g' > line.tmp
      read h m s toto data toto toto toto yy mm dd toto < line.tmp
      ###########
#      echo $yy $mm $dd $h $m $s
      actualsec=`date -d "$yy/$mm/$dd $h:$m:$s" +%s`
      if [ ${#h} -eq 2 ] ; then h=${h#0} ; else h=$h ; fi
      if [ ${#m} -eq 2 ] ; then m=${m#0} ; else m=$m ; fi
      if [ ${#s} -eq 2 ] ; then s=${s#0} ; else s=$s ; fi
      # 
      # stepping back to GMT and correcting for eventual daylight saving
      # time in sec since 1970-01-01

      if [ $actualsec -ge $daylightsec ] &&  [ $actualsec -lt $standardsec ] && [ $saving -eq 1 ]
      then let actualsec=actualsec-3600
      fi
      let actualsec=actualsec+gmtcor*3600
      yy=`date -d @$actualsec +%Y`
      mm=`date -d @$actualsec +%m`
      dd=`date -d @$actualsec +%d`
      h=`date -d @$actualsec +%H`
      if [ ${#h} -eq 2 ] ; then h=${h#0} ; else h=$h ; fi


      echo $dlon >  moonelev.in
      echo $mlon >> moonelev.in
      echo $slon >> moonelev.in
      echo $dlat >> moonelev.in
      echo $mlat >> moonelev.in
      echo $slat >> moonelev.in
      echo "0"   >> moonelev.in
      echo $yy"/"$mm"/"$dd $h":"$m":"$s >> moonelev.in
      moonline=`moonelev.py < moonelev.in` 
#      read moonline < moonelev.out
      moonup=${moonline:0:1} 

      # Determining if the moon is in the sky
      if [ "$moonup" = "-" ] 
      then let moon=0
      else let moon=1
      fi
#      echo $moonup $moonline $moon


      if [ $moon -eq 0 ]
      then echo $yy $mm $dd $h $m $s $data >> $1$2$3"_womoon"
           let mnout=mnout+1
      fi
      echo $yy $mm $dd $h $m $s $data >> $1$2$3"_wmoon"
      let tnout=tnout+1
#echo "ss" $hss $mss "sr" $hsr $msr "mr" $hmr $mmr $moonrise  "ms" $hms $mms $moonset "heure" $h $m $mintim 
#       echo "moon="$moon
   done
   
done
   echo $1 $2 $3
   #
   # creating the scatterogram without moon
   echo $1$2$3"_womoon" > ScatterData.in
   echo $mnout >> ScatterData.in
   echo $calib >> ScatterData.in
   echo "======= without moon ======="
   ScatterData < ScatterData.in
   cat ScatterData.res >> TimeSerie-without-moon
   echo "============================"
   mv ScatterData.out $1$2$3"_womoon-scatter"
   echo set pm3d map > $1$2$3"_womoon.gnuplot"
   echo set logscale y >> $1$2$3"_womoon.gnuplot"
   echo set palette rgb 21,22,23 >> $1$2$3"_womoon.gnuplot"
   echo "splot '"$1$2$3"_womoon-scatter'" >> $1$2$3"_womoon.gnuplot"
   gnuplot -persist < $1$2$3"_womoon.gnuplot"
   # creating histogram without moon
   mv ScatterHisto.out $1$2$3"_womoon-histo"
   #
   # creating the scatterogram with and without moon
   echo $1$2$3"_wmoon" > ScatterData.in
   echo $tnout >> ScatterData.in
   echo $calib >> ScatterData.in
   echo "======= with moon =========="
   ScatterData < ScatterData.in
   cat ScatterData.res >> TimeSerie-with-moon
   echo "============================"
   mv ScatterData.out $1$2$3"_wmoon-scatter"
   echo set pm3d map > $1$2$3"_wmoon.gnuplot"
   echo set logscale y >> $1$2$3"_wmoon.gnuplot"
   echo set palette rgb 21,22,23 >> $1$2$3"_wmoon.gnuplot"
   echo "splot '"$1$2$3"_wmoon-scatter'" >> $1$2$3"_wmoon.gnuplot"
   gnuplot -persist < $1$2$3"_wmoon.gnuplot"
   # creating histogram with and without moon
   mv ScatterHisto.out $1$2$3"_wmoon-histo"
   echo "set style data lines" > $1$2$3"_histo.gnuplot"
   echo "set logscale y" >> $1$2$3"_histo.gnuplot"
   echo "set xrange[0:*]" >> $1$2$3"_histo.gnuplot"
   echo "plot '"$1$2$3"_wmoon-histo' " >> $1$2$3"_histo.gnuplot"
   echo "replot '"$1$2$3"_womoon-histo' " >> $1$2$3"_histo.gnuplot"
   gnuplot -persist < $1$2$3"_histo.gnuplot"
