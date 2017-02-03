channel=5
sqmip="192.168.0.200"
nobs=10
    mono /usr/local/bin/UscCmd --accel $channel,40
    mono /usr/local/bin/UscCmd --speed $channel,40
gain=1 
#43,64 gain normal
waittime=1
offset=3600 

# set angles list
#         1    2     3       4       5     6       7       8        9       10       11        12
angles=( 0.9 70*15 55*30 48.5*45 48.5*60 47*75 46.5*90 45.5*105 45.5*120 44.5*135 44.5*150 43.84*165 )
calib=( 0.3079628655 0.0610003776 0.0240134349 0.0475081568 0.0324283742 0.0196314445 0.0181267619 0.0178495913 0.0222421521 0.0228081498 0.013580985 1.0 )
i=0
while [ $i -lt $nobs ]
do n=0
     echo "Start"
     let i=i+1
    echo "observation numéro: " $i
   sudo mono /usr/local/bin/UscCmd --servo 5,4200
   
   while [ $n -lt ${#angles[*]} ]
   do angle=${angles[$n]}

      ang=`/bin/echo "scale=0;"$angle"*"$gain"+"$offset |/usr/bin/bc -l`
      servoang=`echo $ang | awk -F\. '{if(($2/10^length($2)) >= .5) printf("%d\n",$1+1);else printf("%d\n",$1)}'`
      echo "deplacement de la roue" $channel $servoang

      mono /usr/local/bin/UscCmd --servo $channel","$servoang 
      echo "lecture du sqm, "  "Filtre: "  $(($n+1))
      ./sqmleread.pl $sqmip 10001 1 > sqmdata.tmp
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
