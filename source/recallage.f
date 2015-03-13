c programme pour recaller un spectre calibre spectralement mais non reechantillone
c
c
c    Copyright (C) 2011  Martin Aube
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
       real lamref(5),lamb(608),flux(608),ecart(5),fmax,lmax,b
       integer i,j,ndat
       lamref(1)=435.8
       lamref(2)=498.0
       lamref(3)=546.1
       lamref(4)=568.6
       lamref(5)=615.8
       b=0.
       ndat=0
       open(unit=1,file='spectrum-in.tmp',status='old')
       do i=1,607
          ndat=ndat+1
          read(1,*,end=100) lamb(i),flux(i)
       enddo
 100   close(unit=1)
       do j=1,5
          fmax=0.
          do i=1,ndat
              if (abs(lamb(i)-lamref(j)).lt.4.) then
                 if (flux(i).gt.fmax) then 
                     fmax=flux(i)
                     lmax=lamb(i)
                     ecart(j)=lamref(j)-lmax
                  endif
              endif
          enddo
          b=b+ecart(j)
       enddo
       b=b/5.
       print*,ecart,b
c write the new spectrum
       open(unit=1,file='spectrum-out.tmp',status='unknown')
          do i=1,ndat
             write(1,*) lamb(i)+b,flux(i)
          enddo
       close(unit=1)
       stop
       end