c routine pour conserver la moyenne sur un fenetre autour des
c points contenus dans le continium.tmp (provenant de DelContinium.bash
c le script exclu aussi les fenetre ou la difference entre le min et la max
c depasse 2x l'ecart point a point moyen afin d'eliminer les pattern de
c rayons cosmiques ou des raies spectrales non attentues
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
       real wavelen(1024),flux(1024),width,fluxmoy(1024),wavemoy(1024)
       real flmin(1024),flmax(1024),fmoy(1024),fnoise(1024),nbmoy
       integer ndat,i,j,nflux,gapl,gapr                            
c gapr and gapl are the integer position of the high pressure sodium gap
c in continium.tmp file (see DelContinium.bash)
       character*80 nom
       width=3.
       open(unit=1,file='continium.tmp',status='unknown')
          read(1,*) nom,ndat,nflux,gapl,gapr
          do i=1,ndat
            read(1,*) wavemoy(i),fluxmoy(i)
 
          enddo
 100   close(unit=1)
c lecture du spectre
       open(unit=1,file=nom,status='unknown')
          do i=1,nflux
             read(1,*) wavelen(i), flux(i)
          enddo
       close(unit=1)
c finding minimum, maximum, average and noise in the window
       do i=1,ndat
          nbmoy=0.
          fmoy(i)=0.
          flmin(i)=1.E15
          flmax(i)=0.
          fnoise(i)=0.
          do j=1,nflux-1
             if (abs(wavemoy(i)-wavelen(j)).le.width) then
                nbmoy=nbmoy+1.
                if (flux(j).lt.flmin(i)) then
                   flmin(i)=flux(j)
                endif
                if (flux(j).gt.flmax(i)) then
                   flmax(i)=flux(j)
                endif
                fmoy(i)=fmoy(i)+flux(j)
                fnoise(i)=fnoise(i)+abs(flux(j)-flux(j+1))
             endif

          enddo
             fmoy(i)=fmoy(i)/nbmoy
             fnoise(i)=fnoise(i)/nbmoy
             if ((flmax(i)-flmin(i)).lt.(4.*fnoise(i))) then
                fluxmoy(i)=fmoy(i)
                print*,'Choosing average',(flmax(i)-flmin(i))/fnoise(i)
             else
                fluxmoy(i)=flmin(i)
                print*,'Choosing minimum',(flmax(i)-flmin(i))/fnoise(i)
             endif
        enddo
c add a interpolated point in the center of the HPS gap 
c
       wavemoy(ndat+1)=(wavemoy(gapl)+wavemoy(gapr))/2.
       fluxmoy(ndat+1)=(fluxmoy(gapl)+fluxmoy(gapr))/2.
       open(unit=2,file='continium-min.tmp',status='unknown')
          do i=1,ndat+1      
             write(2,*) wavemoy(i),fluxmoy(i)
          enddo
       close(unit=2)
       stop
       end
          
