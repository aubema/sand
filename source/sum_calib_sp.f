c programme sum_calib_sp pour moyenner les lignes puis faire le calibrage
c spectral d'un fichier texte spectre de obsand-2
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
        real gain,oorigin,lambda,out(400000),vect(400000),quad
        real sigma,a(510),x
        integer n,j,nlines,pos,longueur,nmean,i
        open(unit=1,file='nlines.tmp',status='unknown')
           read(1,*) nlines
           read(1,*) quad
	   read(1,*) gain
	   read(1,*) oorigin
	close(unit=1)
        open(unit=1,file='imagetxt.tmp',status='unknown')
           longueur=764+766*nlines
           read(1,*) (vect(n),n=1,longueur)
        close(unit=1)
        close(unit=2)
        do n=1,765
           out(n)=0.
c
c removing cosmic rays  
c filling vector
           do j=1,nlines
              pos=n+766*j
              a(j)=vect(pos)
           enddo 
c sorting           
           DO 30 i=2,nlines
              x=a(i)
              j=i
   10         j=j-1
              IF(j.EQ.0 .OR. a(j).LE.x) GO TO 20
              a(j+1)=a(j)
              GO TO 10
   20         a(j+1)=x
   30      CONTINUE  
c median
           median=a(nlines/2)
c estimating std deviation from the median
           sigma=0.
           do j=1,nlines
              sigma=sigma+(median-a(j))**2.
           enddo
           sigma=sigma/real(nlines)
           sigma=sqrt(sigma)
c removing cosmic rays apart by more that 2 sigma
           nmean=0
           do j=1,nlines
              if (abs(a(j)-median).le.2.*sigma) then
                 nmean=nmean+1
                 out(n)=out(n)+a(j)
              endif
           enddo           
           out(n)=out(n)/real(nmean)          
        enddo
	open(unit=2,file='sp.tmp',status='unknown')
	open(unit=3,file='cs.tmp',status='unknown')
        do n=1,765
             write(2,*) n,out(n)
	     lambda=real(n)**2.*quad+real(n)*gain+oorigin
	     write(3,*) lambda,out(n)
        enddo
	close(unit=3)
	close(unit=2)
	stop
	end 
