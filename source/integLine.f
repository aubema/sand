c routine pour calculer la difference relative d'un
c spectre par rapport a un autre
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
       real valref(1024),valout,lambda(1024),
     + maxi, wavelen,width,min,max
       integer len,i
       maxi=0.
       open(unit=1,file='Line_in.tmp',status='unknown')
          read(1,*) len
       close(unit=1)
       open(unit=1,file='Line.tmp',status='unknown')
          read(1,*) wavelen , width
       close(unit=1)
       open(unit=1,file='sp.tmp',status='unknown')
          do i=1,len-1
            read(1,*) lambda(i), valref(i)
            if (valref(i).gt.maxi) then
               maxi=valref(i)
            endif
          enddo
          cut=maxi/10.
          min=wavelen-width
          max=wavelen+width
          valout=0.
          do i=1,len-1
             if (lambda(i).ge.min) then
               if (lambda(i).le.max) then
                  valout=valout+valref(i)*(lambda(i+1)-lambda(i))
               endif
             endif
          enddo     
       close(unit=1)
       open(unit=2,file='integLine.tmp',status='unknown')
          write(2,*) valout
       close(unit=2)
       stop
       end
          
