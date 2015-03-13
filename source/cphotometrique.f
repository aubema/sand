c       Calibration photometrique des spectres
c       M. Aube 2005
c       program cphotometrique
c
c   
c    Copyright (C) 2010  Martin Aube
c
c    This program is free software: you can redistribute it and/or modify
c    it under the terms of the GNU General Public License as published by
c    the Free Software Foundation, either version 3 of the License, or
c    (at your option) any later version.
c
c    This program is distributed in the hope that it will be useful,
c    but WITHOUT ANY WARRANTY; without even the implied warranty of
c    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
c    GNU General Public License for more details.
c
c    You should have received a copy of the GNU General Public License
c    along with this program.  If not, see <http://www.gnu.org/licenses/>.
c
c    Contact: martin.aube@cegepsherbrooke.qc.ca
c
        real lambda1(2068),int1(2068),lambda(69),coef(69)
        real intensite, bidon,C2,limitinf
        real limitsup,lambdaf,lambdai
	integer conteur,ndat,iinf,isup,m,j,i
        real bidon4,bidon6,bidon8,tinteg,tref,valmin,valmax
c
        character*80 filecxy,bid,filecp,filecalib
        character*9 bidon1,bidon2
        character*3 bidon3,bidon5,bidon7
        character*20 bidon9
c
c   limitinf et limitsup sont les bornes extremes du spectre
c   au dela de ces limites la sensibilite de l'appareil est
c   trop faible.
c
        limitinf=400.
        limitsup=730.
c ndat est le nombre de colonne du fichier fits 
c a changer si on utilise un ccd plus grand
        ndat=765
c
c
c       ouverture du fichiers contenant les coefficients
c

	open(24,file='cphotometrique.in',status='unknown')

		read(24,*) filecalib
		read(24,*) filecxy 
		read(24,*) filecp
                read(24,*) tinteg
c                read(24,*) valmin
c valmin is the value for 0 lux (between outside the spectral region
c of the imageit is calculated by taking imstat minimum on original 
c image and dark frame (i.e. min_img-min_dark)

	close(24)

        open (25,file=filecalib, status="unknown")
         read (25,*) bidon, bidon, tref
         rewind 25
	 do j=1,67
          read (25,*) lambda(j), coef(j)
         enddo

        close (25)

c
        open (unit=26,file=filecxy, status='unknown')
c  iinf et isup sont les entiers qui definissent les bornes 
c  significative du spectre. Seules les donnees comprises dans 
c  ces bornes seront retenues
c	 read (26,*) ndat,bidon1,bidon2,bidon3,bidon4,bidon5,bidon6,
c     +   bidon7,bidon8,bidon9

         valmin=65536.
         valmax=0.
         iinf=1
         isup=ndat
         do i=1,ndat
 	  read (26,*) lambda1(i), int1(i)
          if (int1(i).ge.0.) then
             if ((int1(i).lt.valmin).and.(i.gt.2)) valmin=int1(i)
             if ((int1(i).gt.valmax).and.(i.gt.2)) valmax=int1(i)
          endif
          if ((lambda1(i).gt.limitinf).and.(iinf.eq.1)) iinf=i
          if ((lambda1(i).ge.limitsup).and.(isup.eq.ndat)) isup=i-1
          
         enddo

	close (26)

        open (27,file=filecp, status='unknown')
	 do j=iinf,isup-1
           m=int((lambda1(j)-limitinf)/5.)+1
	   lambdai=lambda(m)
           lambdaf=lambda(m+1)

           C2=coef(m)+(lambda1(j)-lambdai)*(coef(m+1)-coef(m))/
     +     (lambdaf-lambdai)
c           Intensite=(int1(j)-valmin)*C2*tref/tinteg
           Intensite=int1(j)*C2*tref/tinteg
           write (27,*) lambda1(j),Intensite

	  enddo
         close(27)
         open(1,file='minimum.out',status='unknown')
            write(1,*) int(valmin)/10*10, int(valmax+10.)/10*10
         close(1)
 2000     format(i3,1x,a9,1x,a9,1x,a3,1x,e12.4,1x,a3,1x,e12.4,1x,a3,
     +    1x,e12.4,1x,a20,1x,'sigma(pixel)=',1x,f7.4)
          print*,'tref=',tref,'valmin=',valmin
c
	stop
	end
