# Usage: bash LPRad_to_Posch.bash year month
# 
#
mkdir IR
mkdir CL
mkdir CO
mkdir HA
mkdir DS
rm -f $yy$mm"_IR.txt"
rm -f $yy$mm"_DS.txt"
rm -f $yy$mm"_CO.txt"
rm -f $yy$mm"_HA.txt"
rm -f $yy$mm"_CL.txt"
list=`du -ax | grep "\.fits" | grep $1"/"$2`
for i in $list
do if [ `echo $i | grep "/"` ]
   then echo $i | sed s'/\// /g' | sed s'/_/ /g' | sed s'/\.fits/ /g' | sed s'/:/ /g' | sed s'/\. / /g' | sed s'/-/ /g' > toto
        read toto toto toto toto toto filter bidon bidon bidon bidon bidon yy mm dd  h m s bidon < toto
        echo $filter $yy $mm $dd $h $m $s $i
        julian=`/bin/date -d "$yy-$mm-$dd $h:$m:$s" +%s`
        if [ $julian -ge 1262322000 ]
        then if [ ! `grep 65535 $i` ] ; then 
#               Julian day
                JJ=`echo "scale=6; ("$julian"-18000)/86400.0+2440587.5" | bc`             # julian day
                MJD=`echo "scale=6; ("$julian"-18000)/86400.0+2440587.5-2400000.5" | bc`  # modified julian day

                bash ./histo.bash $i > stats.tmp
                read mode min max moy toto < stats.tmp
 
#               assurer un bon S/B value > 255
                if [ $filter = "IR" ] ; then
                   if [ $mode -gt 255 ] ; then 
                      echo $h:$m:$s $MJD $mode $min $max $moy  $yy"/"$mm"/"$dd $i >> $yy$mm$dd"_IR.txt"
                   fi
                fi
                if [ $filter = "DeepSky" ] ; then
                   if [ $mode -gt 255 ] ; then 
                      echo $h:$m:$s $MJD $mode $min $max $moy  $yy"/"$mm"/"$dd $i >> $yy$mm$dd"_DS.txt"
                   fi
                fi
                if [ $filter = "Comet" ] ; then
                   if [ $mode -gt 255 ] ; then 
                      echo $h:$m:$s $MJD $mode $min $max $moy  $yy"/"$mm"/"$dd $i >> $yy$mm$dd"_CO.txt"
                   fi
                fi
                if [ $filter = "Halpha" ] ; then
                   if [ $mode -gt 255 ] ; then 
                      echo $h:$m:$s $MJD $mode $min $max $moy  $yy"/"$mm"/"$dd $i >> $yy$mm$dd"_HA.txt"
                   fi
                fi
                if [ $filter = "Clear" ] ; then
                   if [ $mode -gt 255 ] ; then 
                      echo $h:$m:$s $MJD $mode $min $max $moy  $yy"/"$mm"/"$dd $i >> $yy$mm$dd"_CL.txt"
                   fi
                fi
             fi
        fi
   fi
done  
mv *CL.txt CL
mv *IR.txt IR
mv *DS.txt DS
mv *CO.txt CO
mv *HA.txt HA
