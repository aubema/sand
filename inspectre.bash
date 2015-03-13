#!/bin/bash
# programme inspectre
# copyright Martin Aube, fevrier 2009
# Analyse des spectres de SAND-3
# ce programme traite une liste de fichiers spectres en prenant pour acquis que le fichier de
# calibrage spectral (DSS-7_ST-7_A01_calib.txt) est situé dans le repertoire
# ou sont contenus les fichiers a traiter. Ceci permet d'avoir une fichier qui differe selon
# une eventuelle derive du calibrage de l'appareil
# A est le numero d'unite du SAND-3 (ici A=premiere unite produite)
# 01 est le numero du calibrage de SAND-3 (ici 01= premiere calibration)
#
# usage: inspectre.bash [-s Nom_du_fichier_de_calibrage_spectral] [-p nom_fichier_sensitivity] -f -c
#   
#  the -f option if for executing an horizontal flip (left becoming right). This is useful for some
#         spectrometer mounted on the reverse side. E.G. SAND-2-OMM unit
#  the -c option indicate the you are using the script in laboratory of calibration mode. In that mode,
#       recallage program will not be used to automatically shift the wavelength in order to match the 
#
#       5 targets wavelength of the artificial night sky brightness
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
# target wavelength list (to me changed by the user)
#
verbose=0
wavelength=( 435.5 498.0 546.0 569.0 615.5 )
# ======
# using getopts
#
pflag=  
sflag=
fflag=
cflag=
while getopts 'p:s:f:c' OPTION
do
  case $OPTION in
    p)  pflag=1
        pval="$OPTARG"
        if [ ! -f $pval ]       
        then echo "Photometric calibration file not found!"
             exit 1
        fi
    ;;
    s)  sflag=1
        sval="$OPTARG"
        if [ ! -f $sval ]  
        then echo "Spectral calibration file not found!"
             exit 1
        fi
    ;;
    f)  fflag=1
    ;;
    c)  cflag=1
    ;;
    ?)  printf "Usage: %s: [-p value] [-s value] [-f value] [-c value] args\n" $(basename $0) >&2
        exit 2
    ;;
  esac
done
shift $(($OPTIND - 1))
CALDIR=`pwd`
echo "Current dir=" $CALDIR
VERSION=$sval
cphotofile=$pval
echo "Error messages" > error.log
# Repertoire a inspecter pour traiter les spectres 
#
OPDIR=$CALDIR
#echo "===== Analyse log file" > /home/sand/public_html/data/analyse.log
#
#            Lire le gain et l'ordonnee a l'origine pour le calibrage spectral 
#            sur la premiere ligne du le fichier de calibrage
#            format de cette ligne: gain= valeur_du_gain oorigin= valeur_de_l_ordonnee_a_l_origine
#            lambda=gain*pixel+oorigin
#
                  /bin/echo "Reading spectral calibration parameters from " $CALDIR/$VERSION
                  /bin/grep gain $CALDIR/$VERSION > bidon.tmp
                  read bidon gain bidon oorigin bidon quad < bidon.tmp
                  if [ ! $quad ] 
                  then quad=0
                  fi
                  /bin/echo "Gain=" $gain "Offset=" $oorigin "Quad=" $quad
#
#            Lire la zone d'extraction du spectre
#            lineup= première_ligne_du_spectre linedown= derniere_ligne_du_spectre
#
                  /bin/echo "Reading spectral line range to extract"
                  /bin/grep lineup $CALDIR/$VERSION > bidon.tmp
                  read bidon ilineup bidon ilinedown < bidon.tmp
                  /bin/echo "Initial line range=" $ilineup"-"$ilinedown
                  let nlines=ilinedown-ilineup+1
listcal=`/bin/ls -1 $OPDIR | /bin/grep "\-dark" | /bin/sed 's/-dark//g' | /bin/sed 's/_sp//g' | /bin/sed 's/_cs//g' | /bin/sed 's/_cp//g' | /bin/sed 's/\.cxy//g'`
listsky=`/bin/ls -1 $OPDIR | /bin/grep -v "\-dark" | /bin/grep sky | /bin/grep fits | /bin/sed 's/\.fits//g'`
listdark=`/bin/ls -1 $OPDIR | grep "\-dark.fits" | /bin/sed 's/-dark//g' | /bin/sed 's/\.fits//g'`
/bin/echo $listcal > listecal.tmp
let pos1=ilineup-40
if [ $pos1 -lt 1 ] ; then let pos1=1 ; fi
let pos2=ilinedown+40
if [ $pos2 -gt 509 ] ; then let pos2=509 ; fi
echo "List of files to process:" $listsky
for i in $listsky 
do echo "Checking file" $i
       satur=`imstat $i".fits"[10:760,$pos1:$pos2] | grep 65535`
       satur=`imlist $i".fits"[10:760,$pos1:$pos2] | sed 's/ /\n/g' | grep -c 65535`
       echo $satur
#       if [ "$satur" = "" ]
       if [ $satur -lt 20 ]
       then echo $i "is NOT saturated"
 
   flag=1
   for j in $listdark
   do if [ $i = $j ]
      then flag=0
      fi
   done
   if [ $flag -eq 1 ]
   then echo "============================================================="
        echo "Processing file " $i".fits"
        lo=${#i}
        let po=$lo-4
        if [ "${i:$po:4}" != "dark" ]
        then existe=`/bin/grep $i listecal.tmp`
             if [ "$existe" == ""  ] 
             then nom=$i
                  /bin/echo `/bin/date`": analysing "$nom".fits"
                  /bin/echo $i | /bin/sed 's/_/ /g' > info.tmp

#
#
#            lecture de la temperature de refroidissement et du temps d'integration 
#            (info contenues dans le nom)
#
                  read bidon bidon temp bidon tinteg bidon < info.tmp 
#  
#            petite etude statistique sur l'image
#
                  /bin/echo "Computing basic statistics on " $nom".fits"
                  /usr/local/bin/imstat $OPDIR/$nom".fits" | /bin/grep minimum > stat.tmp
                  read bidon bidon bidon minsky < stat.tmp
                  /bin/echo "Sky minimum: "$minsky
#
#            Identification du dark et soustraction
#
                  echo "Searching best suited dark"
                  listdk=`/bin/ls -1 $OPDIR | /bin/grep -v "\-dark" | /bin/grep dark | /bin/grep fits | /bin/sed  's/\.fits//g'`
                  for nd in $listdk
                  do /bin/echo $nd | /bin/sed 's/_/ /g' > info.tmp
                     read bidon bidon tempdk bidon tintegdk bidon < info.tmp
                     if  [[ "$tinteg" = "$tintegdk" ]]
                     then if [[ "$temp" = "$tempdk" ]]
                          then  nomdark=$nd
                          fi
                     fi
                  done
#
#            petite etude statistique sur l'image dark
#
                  /bin/echo "Computing basic statistics on " $nomdark".fits"
                  /usr/local/bin/imstat $OPDIR/$nomdark".fits" | /bin/grep minimum > stat.tmp
                  read bidon bidon bidon mindark < stat.tmp
                  /bin/echo "Dark minimum: "$mindark
                  let deltamin=$minsky-$mindark
                  let dmin=-1*$mindark/100
                  if [ $deltamin -lt $dmin ]
                  then /bin/echo "!!!!! Probleme potentiel, le dark semble trop brillant! "
                  fi
#	
#            soustraction du dark
#
                  /bin/echo "Removing dark "
                  /bin/rm -f $nom"-dark.fits"
                  /usr/local/bin/imarith $OPDIR/$nom".fits" $OPDIR/$nomdark".fits" s $nom"-dark.fits"

#   find spectrum to extract
                   if [ $nlines -le 200  ]
                   then /bin/echo "Searching spectrum in image:" $OPDIR/$nom".fits"
                        /bin/echo "  from line " $ilineup " to " $ilinedown
                        /usr/local/bin/findspectrum.bash $OPDIR/$nom".fits" $ilineup $ilinedown  > findspectrum.tmp
                        read newlineup newlinedown < findspectrum.tmp
                        let linedown=newlinedown
                        let lineup=newlineup
                        /bin/echo "Corrected line range=" $lineup"-"$linedown
                        let nlines=linedown-lineup+1
                        /bin/echo "Number of lines=" $nlines
                        if [ $nlines -lt 1 ] 
                        then echo "ERROR, number of lines must be greater than 1, I found " $nlines
                        fi
                   else
                        let lineup=ilineup
                        let linedown=ilinedown
                   fi

#            couper  l'image et l'inverser si l'option -f est demandee
                  let debut=510-lineup
                  let fin=510-linedown
                  /bin/echo "Extracting spectrum region from" $nom"-dark.fits"
                  imsection=$nom"-dark.fits[1:765,"$fin":"$debut"]"
                  /usr/local/bin/fitscopy $OPDIR/$imsection cut.fits
                  if [ $fflag  ]
                  then echo "flipping image..."
                       /usr/local/bin/fitscopy 'cut.fits[-*,*]' cut1.fits
                       mv -f cut1.fits cut.fits
                  fi
                  /bin/mv -f cut.fits $nom"-dark.fits"
             else echo `/bin/date`": No new files to analyse"
             fi
        fi                  
   fi
       else # this case correspond to saturated image
          echo "Image " $i".fits seems to be saturated. No analysis have been done" >> error.log
          echo "Image " $i".fits seems to be saturated. No analysis have been done"
       fi  # fin du test de saturation
done
listdark=`/bin/ls -1 $OPDIR | grep "\-dark.fits" | /bin/sed 's/-dark//g' | /bin/sed 's/\.fits//g'`
listspcs=`/bin/ls -1 $OPDIR | grep "_sp_cs.cxy" | /bin/sed 's/-dark//g' | /bin/sed 's/_sp_cs//g'  | /bin/sed 's/\.cxy//g'`
for i in $listdark
do nom=$i
   flag=1
   for j in $listspcs
   do if [ $i = $j ]
      then flag=0
      fi
   done
   if [ $flag -eq 1 ]
   then echo "============================================================="
        echo "Processing file " $i"-dark.fits"   
                  
#
#            sommer les lignes pour faire un spectre
#
        /bin/echo "Computing 1D spectrum and doing spectral calibration"
        liststruc $nom"-dark.fits" | grep NAXIS2 > size.tmp
        read bidon bidon nlines bidon < size.tmp
        /bin/echo "Number of lines to coadd=" $nlines
        rm -f $nom"-dark_sp.cxy"
        rm -f $nom"-dark_sp_cs.cxy"
        list=`/usr/local/bin/imlist $nom"-dark.fits"`
        echo $nlines > nlines.tmp
        echo $quad >> nlines.tmp
	echo $gain >> nlines.tmp
	echo $oorigin >> nlines.tmp
        echo $list > imagetxt.tmp
        /usr/local/bin/sum_calib_sp
	mv -f sp.tmp $nom"-dark_sp.cxy"
	mv -f cs.tmp $nom"-dark_sp_cs.cxy"


   fi
done
listspcs=`/bin/ls -1 $OPDIR | grep "_sp_cs.cxy" | /bin/sed 's/-dark//g' | /bin/sed 's/_sp_cs//g'  | /bin/sed 's/\.cxy//g'`
listcpre=`/bin/ls -1 $OPDIR | grep "_cp_re.cxy" | /bin/sed 's/-dark//g' | /bin/sed 's/_sp//g' | /bin/sed 's/_cs//g' | /bin/sed 's/_cp_re//g' | /bin/sed 's/\.cxy//g'`
for i in $listspcs 
do nom=$i
   flag=1
   for j in $listcpre
   do if [ $i = $j ]
      then flag=0
      fi
   done
   if [ $flag -eq 1 ]
   then echo "============================================================="
        echo "Processing file " $i"-dark_sp_cs.cxy"   
	      # calibrage photometrique
	      echo "Photometric calibration"

	      /bin/echo $i | /bin/sed 's/_/ /g' > info.tmp

#
#
#            lecture de la temperature de refroidissement et du temps d'integration 
#            (info contenues dans le nom)
#
              read bidon bidon temp bidon tinteg bidon < info.tmp 
              echo "Integration time= "$tinteg" sec"
              echo $cphotofile > cphotometrique.in
              echo $nom"-dark_sp_cs.cxy" >> cphotometrique.in
              echo $nom"-dark_sp_cs_cp.cxy" >> cphotometrique.in
              echo $tinteg >> cphotometrique.in
#              echo $deltamin >> cphotometrique.in
              /usr/local/bin/cphotometrique  
#              rm -f cphotometrique.in 
              # automatic spectral shift in case of spectral calibration shift
              if [ ! $cflag  ]
              then cp -f $nom"-dark_sp_cs_cp.cxy" spectrum-in.tmp
                   echo "Correct for eventual spectral calibration shift"
                   /usr/local/bin/recallage
                   cp -f spectrum-out.tmp $OPDIR/$nom"-dark_sp_cs_cp.cxy"
              fi

              # reechantillonage du spectre sur un base standard
              npt=`grep -c "" $nom"-dark_sp_cs_cp.cxy"`
              echo "0.5" > resamplesp.in
              echo "400" >> resamplesp.in
              echo "730" >> resamplesp.in
              echo $npt >> resamplesp.in
              echo $nom"-dark_sp_cs_cp.cxy" >> resamplesp.in
              echo $nom"-dark_sp_cs_cp_re.cxy" >> resamplesp.in
              echo "Resampling spectrum using dlambda=0.5nm from 400 to 730nm"
              /usr/local/bin/resamplespectrum
   fi
done
listcpre=`/bin/ls -1 $OPDIR | grep "_cp_re.cxy" | /bin/sed 's/-dark_sp_cs_cp_re\.cxy//g'`
listli=`/bin/ls -1 $OPDIR | grep "_re_li.cxy" | /bin/sed 's/-dark_sp_cs_cp_re_li\.cxy//g'`
for i in $listcpre 
do nom=$i
   flag=1
   for j in $listli
   do if [ $i = $j ]
      then flag=0
      fi
   done
   if [ $flag -eq 1 ]
   then echo "============================================================="
        echo "Processing file " $i"-dark_sp_cs_cp_re.cxy"   
              # remove continium
              echo "Removing continium radiation"
              /usr/local/bin/DelContinium.bash $i"-dark_sp_cs_cp_re.cxy"

   fi
done
listli=`/bin/ls -1 $OPDIR | grep "_li.cxy" | /bin/sed 's/-dark_sp_cs_cp_re_li\.cxy//g'`
for i in $listli 
do nom=$i

   echo "============================================================="
        echo "Processing file " $i"-dark_sp_cs_cp_re_li.cxy" 
        nw=0
        
        while [ $nw -lt ${#wavelength[*]} ]
        do echo "Extracting radiance at " ${wavelength[$nw]} "nm"
           /usr/local/bin/getLine.bash $i"-dark_sp_cs_cp_re_li.cxy" ${wavelength[$nw]} 
           let nw=nw+1
        done
        if [ -f moonflag.tmp ]  # remove line integration files if a negative value is encontered
        then rm -f $i*_wl*
             rm -f moonflag.tmp
        fi
done
