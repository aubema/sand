c routine pour conserver le minimum sur un fenetre autour des
c points contenus dans le continium.tmp (provenant de DelContinium.bash
c 
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
       real wavelen(1024),flux(1024),width,fluxmin(1024),wavemin(1024)
       integer ndat,i,j,nflux,gapl,gapr                                  ! gapr and gapl are the integer position of the high pressure sodium gap in continium.tmp file (see DelContinium.bash)
       character*80 nom
       width=3.
       open(unit=1,file='continium.tmp',status='unknown')
          read(1,*) nom,ndat,nflux,gapl,gapr
          do i=1,ndat
            read(1,*) wavemin(i),fluxmin(i)
 
          enddo
 100   close(unit=1)
       open(unit=1,file=nom,status='unknown')
          do i=1,nflux
             read(1,*) wavelen(i), flux(i)
          enddo
       close(unit=1)
c finding minimum in the window
       do i=1,ndat
          do j=1,nflux
             if (abs(wavemin(i)-wavelen(j)).le.width) then
                if (flux(j).lt.fluxmin(i)) then
                   fluxmin(i)=flux(j)
                   wavemin(i)=wavelen(j)
                endif
             endif   
          enddo
        enddo
c add a interpolated point in the center of the HPS gap 
c
       wavemin(ndat+1)=(wavemin(gapl)+wavemin(gapr))/2.
       fluxmin(ndat+1)=(fluxmin(gapl)+fluxmin(gapr))/2.
       open(unit=2,file='continium-min.tmp',status='unknown')
          do i=1,ndat+1      
             write(2,*) wavemin(i),fluxmin(i)
          enddo
       close(unit=2)
       stop
       end
          
