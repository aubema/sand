#!/bin/bash
echo "Content-type: text/html"
echo ""
# possible choice for the webcam dlink or linksys
camsky="dlink"
cammount="linksys"
# read in our parameters
MODE=`echo "$QUERY_STRING" | sed -n 's/^.*mode=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
CMD=`echo "$QUERY_STRING" | sed -n 's/^.*cmd=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
FOLDER=`echo "$QUERY_STRING" | sed -n 's/^.*folder=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"| sed "s/%2F/\//g"`
DATE=`echo "$QUERY_STRING" | sed -n 's/^.*date=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g" `
POSEPHEMS=`echo "$QUERY_STRING" | sed -n 's/^.*posephems=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g" `
AZIM=`echo "$QUERY_STRING" | sed -n 's/^.*azimuth=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g" `
ELEV=`echo "$QUERY_STRING" | sed -n 's/^.*elevation=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g" `
NLOOP=`echo "$QUERY_STRING" | sed -n 's/^.*nloop=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g" `
AT=`echo "$QUERY_STRING" | sed -n 's/^.*sayat=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g" `
ITIME=`echo "$QUERY_STRING" | sed -n 's/^.*intime=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g" `
CCDT=`echo "$QUERY_STRING" | sed -n 's/^.*ccdtemp=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g" `
ITYP=`echo "$QUERY_STRING" | sed -n 's/^.*type=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g" `

#
# our html header
echo "<html>"
echo "<head><title>SAND control internet interface</title></head>"
echo "<body bgcolor="550000" text="FFCC00" link="FFFFFF" vlink="AAAAAA" background="../back.jpg">"
echo "<center><h3>Execution output</h3></center>"
echo "Mount operation mode: " $MODE "<br>"
# test if any parameters were passed
if [ $CMD ]
then
  case "$CMD" in
    initmount)
      echo "initmount :<center><table border=1 width=480 bgcolor="171612"><tr><td><font color="ffffff"></center><pre>"
      doinitmount(){
      initmount
      echo "Ready"
      }
      date | tee -a data/output.log
      doinitmount | tee -a data/output.log 
      echo "</pre></font></td></tr></table>"
      ;;

    observen)
      echo "observe N nights :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
      doobserven(){
      echo "observe -m "$MODE" -a "$AT" -l "$NLOOP" -i sp"
      observe -m $MODE -a $AT -l $NLOOP -i sp
      echo "Ready"
      }
      date | tee -a data/output.log
      doobserven | tee -a data/output.log
      echo "</pre></font></td></tr></table>"
      ;;

    ephems)
      echo "ephems :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
      doephems(){
      ephems $POSEPHEMS
      echo "Ready"
      }
      date | tee -a data/output.log
      doephems | tee -a data/output.log
      echo "</pre></font></td></tr></table>"
      ;;

    goto)
      if [ $MODE = "-d" ]
      then echo "goto :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
           dogoto(){
           movetoel $ELEV
           movetoaz $AZIM
           echo "Ready"
           }
           date | tee -a data/output.log
           dogoto | tee -a data/output.log
           echo "</pre></font></td></tr></table>"
      fi
      ;;

    
webcam)
      echo "webcam sky :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
      dowebcam(){
      noname=`date +%Y-%m-%d_%H:%M:%S`
      y=`date +%Y`
      mo=`date +%m`
      echo "Taking sky webcam image sky-"$noname".jpg"
      if [ $camsky = "linksys" ]
      then /usr/bin/mplayer http://sand:memo123@192.168.1.102/img/video.asf -frames 1 -vo pnm > /dev/null
           convert 00000001.ppm 00000001.jpg
           chmod a+rx 00000001.jpg
           cp 00000001.jpg ../lastwebcam.jpg
           rm -f /home/sand/public_html/cgi-bin/000*.ppm
      fi
      if [ $camsky = "dlink" ]
      then /usr/bin/wget http://sand:memo123@192.168.1.102/IMAGE.JPG
           chmod a+rx IMAGE.JPG
           /bin/mv -f IMAGE.JPG ../lastwebcam.jpg
      fi
      cp ../lastwebcam.jpg "data/"$y"/"$mo"/sky-"$noname".jpg"
      rm -f core.*
#     mesurer le niveau de gris moyen (mean)
      identify -verbose ../lastwebcam.jpg | grep mean | sed 's/mean://g' |  tr -d '\n' > /home/sand/public_html/mean.tmp
      read r rr g gg b bb < /home/sand/public_html/mean.tmp 
      echo $r $g $b
      mean=`echo "scale=0;("$r"+"$g"+"$b")/3." |bc -l` 
      if [ ! $mean ] ; then mean=0 ; fi
      echo $mean > /home/sand/public_html/cgi-bin/webcam-mean
      chmod a+rx "data/"$y"/"$mo"/sky-"$noname".jpg"
      echo "Ready"
      }
      date | tee -a data/output.log
      dowebcam | tee -a data/output.log
      echo "</pre></font></td></tr></table>"
      ;;
      
     webcammount)
      echo "webcam mount :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
      dowebcammount(){
      noname=`date +%Y-%m-%d_%H:%M:%S`
      y=`date +%Y`
      mo=`date +%m`
      echo "Taking mount webcam image mount-"$noname".jpg"
#      if [ $cammount = "linksys" ]
#      then /usr/bin/mplayer http://sand:memo123@192.168.0.101/img/video.asf -frames 1 -vo pnm > /dev/null
#           convert 00000001.ppm 00000001.jpg
#           chmod a+rx 00000001.jpg
#           cp 00000001.jpg ../lastmount.jpg
#           rm -f /home/sand/public_html/cgi-bin/000*.ppm
#      fi
#      if [ $cammount = "dlink" ]
#      then /usr/bin/wget http://sand:memo123@192.168.0.101/IMAGE.JPG
#           chmod a+rx IMAGE.JPG
#           /bin/mv -f IMAGE.JPG ../lastmount.jpg
#      fi

fswebcam -d /dev/video0 --png 0 --save lastmount.jpg

      cp lastmount.jpg "data/"$y"/"$mo"/mount-"$noname".jpg"
      chmod a+rx "data/"$y"/"$mo"/mount-"$noname".jpg"
      rm -f core.*
      echo "Ready"
      }
      date | tee -a data/output.log
      dowebcammount | tee -a data/output.log
      echo "</pre></font></td></tr></table>"
      ;;     

    ccd)
       echo "ccd :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
       doccd(){
       largeur=${#CCDT}
#       if [ ${CCDT:0:1} = "-" ]
#       then largeur=3 
#            zero=0
#       else largeur=2
#            zero=1
#       fi 
       ccdt=`night_temperature get -t`
       night_temperature set -t $CCDT 
       echo "Waiting while cooling CCD to "$CCDT"C..."
       let count=0
       while [ "${ccdt:0:$largeur}" != $CCDT -a $count -ne 360 ]
       do ccdt=`night_temperature get -t`
          ccdp=`night_temperature get -r`
          echo $count "s, Temp.="$ccdt "Power="$ccdp "Desired="$CCDT 
          sleep 5
          let count="$count"+5
       done
       echo "CCD temperature is ok" 
# set image name
        noname=`date +%Y-%m-%d_%H:%M:%S`
        name=$ITYP"-"$noname".fits"
# take image
        if [ $ITYP = "dark" ]
        then shutter="off"
            echo "Dark frame acquisition" 
        else shutter="on"
            echo "Sky image acquisition" 
        fi
# get ccd temperature
        ccdt=`night_temperature get -t`
        airt=`night_temperature get -ta`
        ccdp=`night_temperature get -r`
        echo "    Air temperature: " $airt "C" 
        echo "    CCD temperature: " $ccdt "C" 
        echo "    Temperature setpoint: " $CCDT "C" 
        echo "    CCD cooling power: " $ccdp  
# taking picture
      night_exposure -t $ITIME -pn -s $shutter -b 1 -o $name   
      chmod a+rx *.fits 
      chmod u+w *.fits
      o=`echo $name | sed "s/\.fits/\.jpg/"`
      convert -equalize $name  $o
      chmod a+rx *.jpg  
      convert  $o last-ccd-img.jpg
      mv -f  $name data
      mv -f last-ccd-img.jpg /home/sand/public_html/ 
      mv -f $o data
      chmod a+rx /home/sand/public_html/last-ccd-img.jpg
      echo $noname > last-ccd-img-date
      night_temperature set -off
# stop ccd cooling
      night_temperature set -off 
      echo "Ready" 
      }
      date | tee -a data/output.log
      doccd | tee -a data/output.log
      echo "</pre></font></td></tr></table>" 
      ;;
    gps)
      echo "gps :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
      dogps(){
      echo "Waiting 5 sec for GPS reading..."
      gpspipe -w -n 10 > coords.tmp
      tail -1 coords.tmp > bidon.tmp
      rm -f coords.tmp
      read bidon bidon bidon lat lon altitude bidon1 < bidon.tmp
      if [ "${bidon1:0:1}" != "" ]
      then echo "GPS is connected, reading lat lon data."
           lon=`echo $lon"/-1" |bc -l`
           DD=`echo "scale=0;"$lon"/1" |bc -l`
           dd=`echo "scale=0;"$lat"/1" |bc -l`
           MMM=`echo "("$lon"-"$DD")*60" |bc -l`
           MM=${MMM:0:2}
           mmm=`echo "("$lat"-"$dd")*60" |bc -l`
           mm=${mmm:0:2}
           SSS=`echo "(("$lon"-"$DD")-"$MM"/60)*3600" |bc -l`
           SS=${SSS:0:2}
           sss=`echo "(("$lat"-"$dd")-"$mm"/60)*3600" |bc -l`
           ss=${sss:0:2}
           echo "GPS give Latitude:" $dd $mm $ss ", Longitude:" $DD $MM $SS "and Altitude:" $altitude
      else echo "GPS not working: using coords. from localconfig"
           echo "Latitude:" $dd $mm $ss ", Longitude:" $DD $MM $SS
      fi
      echo "Ready"
      }
      date | tee -a data/output.log
      dogps | tee -a data/output.log
      echo "</pre></font></td></tr></table>"
      ;;

    ls)
      echo "ls $FOLDER :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
      dols(){
      /bin/ls -l "$FOLDER"
      echo "Ready"
      }
      date | tee -a data/output.log
      dols | tee -a data/output.log
      echo "</pre></font></td></tr></table>"
      ;;
    position)
      echo "Mount position :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
      doposition(){
      echo "Mount azimuth:"
      readmount AZ 
      echo "Mount elevation:"
      readmount EL 
      echo "Ready"
      }
      date | tee -a data/output.log
      doposition | tee -a data/output.log
      echo "</pre></font></td></tr></table>"
      ;;
    timedate)
      echo "Time and date :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
      dotimedate(){
      date +%Y-%m-%d" ("%H:%M:%S")"
      echo "Ready"
      }
      date | tee -a data/output.log
      dotimedate | tee -a data/output.log
      echo "</pre></font></td></tr></table>"
      ;;
    sensors)
      echo "System temperature :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
      dosensors(){
      echo ""
      echo "System Temperature:"
      sensors | grep emp
      echo ""
      echo "CCD Temperature:"
      night_temperature get -t
      echo ""
      echo "Ready"
      }
      date | tee -a data/output.log
      dosensors | tee -a data/output.log
      echo "</pre></font></td></tr></table>"
      ;;
    scool)
      echo "Stop CCD cooling :<center><table border=1 width=480 bgcolor="171612" ><tr><td><font color="ffffff"></center><pre>"
      doscool(){
      night_temperature set -off
      echo "Ready"
      }
      date | tee -a data/output.log
      doscool | tee -a data/output.log
      echo "</pre></font></td></tr></table>"
      ;;
    *)
      echo "Unknown command $CMD<br>"
      ;;
  esac
fi

echo "</form>"
echo "</body>"
echo "</html>"

