c       Effectuer un reechantillonnage de spectre
c       M. Aube 2007
c       program resample spectrum
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
        real lambda1(2068),int1(2068),deltal,lambda0
        real lambda(4096)
        real intout(4096)
        real intensite, bidon,C2,limitinf
        real limitsup,lambdaf,lambdai,largeref,large
	integer conteur,ndat,iinf,isup,m,j,i,ndat1
        real bidon4,bidon6,bidon8,tinteg,tref,valmin
c
        character*80 fileout,bid,file1
        character*9 bidon1,bidon2
        character*3 bidon3,bidon5,bidon7
        character*19 bidon9
c
c   limitinf et limitsup sont les bornes extremes du spectre
c   au dela de ces limites la sensibilite de l'appareil est
c   trop faible.
c

        do i=1,4096
          lambda(i)=0
          intout(i)=0.
        enddo
        do i=1,2068
          lambda1(i)=0.
          int1(i)=0.
        enddo
c
c
c       ouverture du fichiers contenant les coefficients
c

	open(24,file='resamplesp.in',status='unknown')

		read(24,*) deltal
                read(24,*) limitinf
                read(24,*) limitsup
                read(24,*) ndat1
		read(24,*) file1
                read(24,*) fileout
	close(24)


        open (unit=25,file=file1, status='unknown')
c	 read (25,*) ndat1,bidon1,bidon2,bidon3,bidon4,bidon5,bidon6,
c     +   bidon7,bidon8,bidon9
         valmin=65536.
         do i=1,ndat1
 	  read (25,*) lambda1(i), int1(i)
          if (int1(i).ge.0.) then
             if ((int1(i).lt.valmin).and.(i.gt.2)) valmin=int1(i)
          endif
         enddo
	close (25)
 
c   reechantillonner
c
c calcul du nombre de donnees
c
        ndat=nint((limitsup-limitinf)/deltal)+1
        do i=1,ndat
           lambda(i)=real(i-1)*deltal+limitinf
           do j=1,ndat1
              if ((lambda1(j).lt.lambda(i)).and.(lambda1(j+1).gt.
     +        lambda(i))) then

                 intout(i)=(1./(lambda(i)-lambda1(j))*int1(j)+
     +           1./(lambda1(j+1)-lambda(i))
     +           *int1(j+1))/(1./(lambda(i)-lambda1(j))+1./
     +           (lambda1(j+1)-lambda(i)))
              endif
           enddo
        enddo
        do i=1,ndat
           if (intout(i).eq.0.) intout(i)=intout(i+1)
           if (intout(i).eq.0.) intout(i)=intout(i-1)
        enddo
        open (27,file=fileout, status='unknown')
c         write (27,2000) ndat,bidon1,bidon2,bidon3,bidon4,bidon5,
c     +   bidon6,bidon7,bidon8,bidon9,large
         do j=1,ndat
           write (27,1000) lambda(j),intout(j)
         enddo              
        close(27)
 1000     format(f6.2,1x,E15.6)
 2000     format(i4,1x,a9,1x,a9,1x,a3,1x,e15.4,1x,a3,1x,e15.4,1x,a3,
     +    1x,e15.4,1x,a20,1x,'sigma(pixel)=',1x,f7.4)
c
	stop
	end
