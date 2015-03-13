# !/bin/bash/ 
# tout ce fait avec la monture 
read eled elem eles azid azim azis imtyp inttime < /home/sand/public_html/cgi-bin/ligne.tmp
echo $eled $elem $eles $azid $azim $azis $imtyp $inttime
if [ $imtyp == "moon" ]
then START=`date +"%s"` 
      while [ $(( $(date "+%s") - $inttime )) -lt $START ]; do
           /usr/local/bin/moon.py | sed 's/:/ /g' | sed 's/\./ /g' > moon.tmp
           read mooned moonem moones bidon moonad moonam moonas bidon < moon.tmp
           echo "Az moon" $moonad":" $moonam":" $moonas "El moon" $mooned":" $moonem":" $moones 
           let altd=eled+mooned ; let altm=elem+moonem ; let alts=eles+moones
          let azd=azid+moonad ; let azm=azim+moonam ; let azs=azis+moonas
          echo "Az" $azd ":" $azm ":" $azs  "EL" $altd ":" $altm ":" $alts

echo "#:Sz$azd*$azm'$azs#" > /dev/ttyS0  
sleep 2                                                                                 #set azimuth   # verify if the commands 
echo "#:Sa$altd*$altm'$alts#" > /dev/ttyS0                                                             # are correctly working with
sleep 2                                                                             # set elevation    # mount LXD-75
echo "#:MA#" > /dev/ttyS0                                                          #goto               #
  
sleep 60 
done    

else 
echo "Az" $azid ":" $azim ":" $azis  "EL" $eled ":" $elem ":" $eles
echo "#:Sz$azid*$azim'$azis#" > /dev/ttyS0
sleep 2
echo "#:Sa$altd*$altm'$alts#" > /dev/ttyS0   
sleep 2
echo "#:MA#" > /dev/ttyS0
sleep $inttime
fi
