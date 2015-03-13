c ce programme calcule le coefficient d'ang. et interPAUL l'AOD pour les longueurs d'ondes cibles.
c
c
c
c  declaration des variables
       real aod400,aod500,aod675,ang45,ang56,a435,a498,a546,a569,a615

c initialisation des var.
       

c lecture des donnees
       open(unit=1,file='input.tmp',status='unknown')
           read(1,*) aod400,aod500,aod675
       close(unit=1) 
c calcul coeff ang      
       ang45=log(aod400/aod500)/log(500./400.)
       ang56=log(aod500/aod675)/log(675./500.)
c Interpolation
       a435=aod400*(400./435.5)**ang45
       a498=aod500*(500./498.)**ang45
       a546=aod500*(500./546.)**ang56
       a569=aod500*(500./569.)**ang56
       a615=aod675*(675./615.5)**ang56


c ecriture des resultats
       open(unit=1,file='output.tmp',status='unknown')
           write(1,*) ang45,ang56,a435,a498,a546,a569,a615
       close(unit=1)
       stop
       end
       