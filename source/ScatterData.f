c fortran program to compute a scatterogram for one night of sky brightness measurements
c
       integer ndat,nbin,ntbin,scatter(1000,1000),posx,posy
       integer histonight(1000),scamax
       real calib,yy,mm,dd,h,m,s,ovalue,cvalue(100000),time(100000)
       real maxi,mini,dbin,tmaxi,tmini,tbin,mean,pond,onesigma
       real twosigma,xcm,ycm,tot,sigma,x,y,valprob,tprob
       character*80 filename
       read*, filename, ndat, calib
       print*,'Number of data points=',ndat
       nbin=200
         maxi=-100000000.
         mini=100000000.
         tmaxi=-100000000.
         tmini=100000000.
         mean=0.
         pond=0.
         sigma=0.
         onesigma=0.
         twosigma=0.
         xcm=0.
         ycm=0.
         tot=0.
         scamax=0
         valprob=0.
         tprob=0.
         do i=1,1000
            histonight(i)=0
            do j=1,1000
               scatter(i,j)=0
            enddo
         enddo
       open(unit=1,file=filename,status='old')
         do i=1,ndat
            read(1,*) yy,mm,dd,h,m,s,ovalue
            cvalue(i)=ovalue
            
            time(i)=h+m/60.+s/3600.
            if (time(i).gt.12.) then
               time(i)=time(i)-24.
            endif
            if (cvalue(i).gt.maxi) then
               maxi=cvalue(i)
            endif
            if (cvalue(i).lt.mini) then
               mini=cvalue(i)
            endif
            if (time(i).gt.tmaxi) then
               tmaxi=time(i)
            endif
            if (time(i).lt.tmini) then
               tmini=time(i)
            endif
         enddo
c         tmini=real(int(tmini))
c         tmaxi=real(int(tmaxi+1.))
c         mini=real(int(mini))
c         maxi=real(int(maxi+1.))
       close(unit=1)
c compiler sur un intervalle de 30 min
       ntbin=2*(nint(tmaxi-tmini))
       dbin=(maxi-mini)/real(nbin)
       tbin=(tmaxi-tmini)/real(ntbin)
c filling bins
       do i=1,ndat
          posx=int((time(i)-tmini)/tbin)+1
          posy=int((cvalue(i)-mini)/dbin)+1
          scatter(posx,posy)=scatter(posx,posy)+1
          if (scatter(posx,posy).gt.scamax) then
             scamax=scatter(posx,posy)
             valprob=dbin*(real(posy)-0.5)+mini
             tprob=tbin*(real(posx)-0.5)+tmini
          endif
c night histogram
          histonight(posy)=histonight(posy)+1
       enddo
       print*,'Most probable value:',valprob
c normality test
c calculation of the mean
       do j=1,nbin+1
          y=dbin*(real(j)-0.5)+mini
          mean=mean+real(histonight(j))*y
          pond=pond+real(histonight(j))
       enddo 
       mean=mean/pond
c calculation of the center of mass
       do i=1,ntbin+1
          do j=1,nbin+1
          x=tbin*(real(i)-0.5)+tmini
          y=dbin*(real(j)-0.5)+mini
          
          xcm=xcm+x*real(scatter(i,j))
          ycm=ycm+y*real(scatter(i,j))
          tot=tot+real(scatter(i,j))
          enddo
       enddo
       cm=xcm/tot
       ycm=ycm/tot
c calculation of the standard deviation
       do j=1,nbin+1
          y=dbin*(real(j)-0.5)+mini
          sigma=sigma+real(histonight(j))*(y-mean)**2.
       enddo
       sigma=sigma/pond
       sigma=sqrt(sigma)
       print*,'mean=',mean,' sigma=',sigma
c testing statistics in the center of the distribution (+/- 1 sigma)
c Back-of-the-envelope test
c for a normal distribution this fraction = 0.6827
c +/- 2 sigma gives 0.9545
c +/- 3 sigma gives 0.9973
       do j=1,nbin+1
          y=dbin*(real(j)-0.5)+mini
          if (abs(y-mean).le.sigma) then
             onesigma=onesigma+real(histonight(j))
          endif
          if (abs(y-mean).le.2.*sigma) then
             twosigma=twosigma+real(histonight(j))
          endif
       enddo       
       onesigma=onesigma/pond
       twosigma=twosigma/pond
       print*,'Fraction falling inside one standard deviation:',
     + onesigma,'/0.6827'
       print*,'Fraction falling inside two standard deviation:',
     + twosigma,'/0.9545'
       open(unit=2,file='ScatterData.out',status='unknown')
       write(2,*) 
       do i=1,ntbin+1
          do j=1,nbin+1
             x=tbin*(real(i)-0.5)+tmini
             y=dbin*(real(j)-0.5)+mini
             write(2,*) x,y,scatter(i,j)
          enddo
       write(2,*)
       enddo
       close(unit=2)
       open(unit=5,file='ScatterData.res',status='unknown')
         write(5,*) int(yy),int(mm),valprob,mean,sigma,ndat
       close(unit=5)
       open(unit=2,file='ScatterHisto.out',status='unknown')
       do j=1,nbin+1
          y=dbin*(real(j)-0.5)+mini
          write(2,*) y,histonight(j)
       enddo
       close(unit=2)
       stop
       end
       
         
            
         
