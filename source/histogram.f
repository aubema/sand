c  Prog pour calculer un histogramme a partir d'une image fits
c
c
          integer ncols,nlines,longueur
          integer ii,i,j,pos
          real vmoy,vmini,vmaxi,mode,valmode,vect(1000000)
          real histo(65535),out(900,900),nbmoy
          ncols=765
          nlines=510
          do i=1,1000000
            vect(i)=0.
          enddo
          open(unit=2,file='histo.in',status='unknown')
             longueur=(ncols-1)+(ncols+1)*nlines+1
             read(2,*) (vect(ii),ii=1,longueur)
          close(unit=2)
          do i=1,65535
              histo(i)=0.
          enddo
          vmoy=0.
          valmode=0.
          vmini=1.e10
          vmaxi=0.
          nbmoy=0.
          do i=1,ncols
             do j=1,nlines
                pos=i+(ncols+1)*j
                out(i,j)=vect(pos)
                histo(nint(out(i,j)))=histo(nint(out(i,j)))+1.
              if ((out(i,j).lt.vmini).and.(out(i,j).ge.0.)) then
                 vmini=out(i,j)
              endif
            
              if (out(i,j).gt.vmaxi) then
                 vmaxi=out(i,j)
              endif
              if ((out(i,j).ge.1.)) then
                vmoy=vmoy+out(i,j)
                nbmoy=nbmoy+1.
              endif


             enddo
           enddo
           vmoy=vmoy/nbmoy
          do i=1,65535
              if (histo(i).gt.valmode) then
                 valmode=histo(i)
                 mode=real(i)
              endif
          enddo
              print*,nint(mode), nint(vmini), nint(vmaxi), nint(vmoy), nint(nbmoy)
          end
