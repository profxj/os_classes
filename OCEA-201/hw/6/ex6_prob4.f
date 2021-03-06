        PROGRAM INDPAC
        PARAMETER(IM=61)
        PARAMETER(JM=61)
        PARAMETER(MMI=im-1)
        PARAMETER(MMJ=jm-1)
        CHARACTER*85 CDUM
        CHARACTER*4 CFIL,CRAP,CCCC
C
       REAL GDH1X(IM,JM),GDH2X(IM,JM),GDH1Y(IM,JM),
     Z GDH2Y(IM,JM),US1(IM,JM),US2(IM,JM),VS1(IM,JM),VS2(IM,JM),
     1    ECOM(JM)
        DIMENSION U1(IM,JM,3),U2(IM,JM,3),V1(IM,JM,3),V2(IM,JM,3),
     X H1(IM,JM,3),H2(IM,JM,3)
     2  ,IHM(IM,JM),IUM(IM,JM),IVM(IM,JM),WXS(IM,JM),WYS(IM,JM)
     6  ,U1MEAN(MMI,MMJ),RUS1(IM,JM),RVS1(IM,JM),V1MEAN(MMI,MMJ)
     7    ,TAUX(84,30),TAUY(84,30),IDAY(12),DUM(IM,JM)
        DIMENSION TPH(IM,JM),POTE(7),AKINE(7),ALAT1(7),ALAT2(7),
     1   ALONG1(7),ALONG2(7),IX1(7),IX2(7),IY1(7),IY2(7),ITM(IM,JM),
     2   STRKX(6),STRKY(6),TRGT(6),TRACKW(6),RMSTK(6),RMSREG(7),
     3   DAY(12),DOBS(IM,JM),TISO(6),IOBS(IM,JM),NOTAU(400),
     4   BY(IM,JM),VECW(IM,IM),H1P(IM,JM),DIFCORD(IM,JM),RHO(IM,JM),
     5   NOBS(7),NNOBS(6),DIFH(IM,JM),DINM(12),BX(IM,JM)
     6    ,WEIGHT(IM,JM),VARREG(7),VARTRK(6),IPOS(400),JPOS(400)
     7     ,ERR(IM,JM),ERRREG(7),ERRTK(6)
     8   ,TH1(IM,JM),TH2(IM,JM),TU1(IM,JM),TU2(IM,JM),TV1(IM,JM),
     9   TV2(IM,JM),DEX1(IM),STUA(IM),STUB(IM),STVA(IM),STVB(IM)
     9   ,DEY1(IM),IUP(IM,JM)
C
         DIMENSION HKM(IM,JM),HK(IM,JM),HKP(IM,JM),UKM(IM,JM),
     1    UK(IM,JM),UKP(IM,JM),VKM(IM,JM),VK(IM,JM),VKP(IM,JM)
     2   ,AMEAN(IM,JM),WXT(169,61),WYT(169,61),TIX(94,58),
     3    TIY(94,58),SUPOT(6),SUKIN(6)
c
	real hp(im,jm),up(im,jm),vp(im,jm)
c
	real wvert(im,jm),wupy(jm)
C
c
	common/vars/beta,dx,dy,fh(jm),fv(jm),wx(im,jm),wy(im,jm)
c
c.......open plot file......
c
	call newdev('prob4.ps',8)
	call psinit(.true.)
c
	open(unit=15,file='ex6_prob4.input',status='old')
c
c	open(unit=8,file='plottest.out',form='unformatted')
	open(unit=27,file='restart.dat',form='unformatted')
c
c.......read input parameters.......
c
        iftype=2
        ifnonl=0
        phi0=0.0
c
	read(15,*)itstop
c	read(15,*)iftype
c	read(15,*)phi0
	read(15,*)ipltm
	read(15,*)asubh
c	read(15,*)ifnonl
C
        itstop=12.*itstop
        asubh=1.e4*asubh
C
        IMAX=IM
        JMAX=JM
        IMJM=IM*JM
        IMIM=IM*IM
        IR=IMAX-2
C
C
       KTAU=0
C.......ISTART=START UP TIMESTEP FOR NEXT RUN...
        ISTART=16*30*12
C.......JJSTOP=STOP TIMESTEP FOR THIS RUN.....
        JJSTOP=16*30*itstop
C......IDSTR=START UP DAY....
        IDSTR=15
C......MTHSTR=START UP MONTH.......
        MTHSTR=1
C........IYR=START UP YEAR........
        IYR=77
        MONTH1=MTHSTR
        IYEAR1=IYR
        IMTH=MTHSTR
        JMTH=MTHSTR
        ITAU=KTAU
        ISTOP=0
          LNUP=0
        CFIL='FILE'
        JSUP=0
C
C.......DEFINE MEAN ISOTHERM DEPTH IN METRES....
C
        AMLD=200
C
C......CLEAR NVAL= NO. OF TIMESTEPS USED TO DETERMINE MEAN DEPTH OF
C      LAYER AT EACH GRIDPOINT...
C
       NVAL=0
C
       DO 22 I=1,IMAX
       DO 22 J=1,JMAX
        DO 23 KK=1,3
        V1(I,J,KK)=0.
        V2(I,J,KK)=0.
        U1(I,J,KK)=0.
        U2(I,J,KK)=0.
        H1(I,J,KK)=0.
        H2(I,J,KK)=0.
 23      CONTINUE
 22      CONTINUE
       KM=1
       K=2
       KP=3
       DO 24 I=1,IM
       DO 24 J=1,JM
        AMEAN(I,J)=0.0
        WEIGHT(I,J)=0.0
        ERR(I,J)=0.0
        DIFH(I,J)=0.0
        TPH(I,J)=0.0
        ITM(I,J)=0
        DOBS(I,J)=0.0
        IOBS(I,J)=0
        IUP(I,J)=0
        BX(I,J)=0.0
        BY(I,J)=0.0
        H1P(I,J)=0.0
        DIFCORD(I,J)=0.0
        RHO(I,J)=1.0
       US1(I,J)=0
      US2(I,J)=0
      VS1(I,J)=0
      VS2(I,J)=0
      GDH1X(I,J)=0.
      GDH2X(I,J)=0.
      GDH1Y(I,J)=0.
      GDH2Y(I,J)=0.
        WX(I,J)=0.0
        WY(I,J)=0.0
      WXS(I,J)=0.0
        WYS(I,J)=0.0
        DUM(I,J)=0.0
 24    CONTINUE
C        CALL SETRAR(WXT,10309,0.0)
C        CALL SETRAR(WYT,10309,0.0)
C        CALL SETRAR(TIX,5452,0.0)
C        CALL SETRAR(TIY,5452,0.0)
C        CALL SETRAR(NOTAU,400,0)
C        CALL SETRAR(IPOS,400,1)
C        CALL SETRAR(JPOS,400,1)
C
        DO 759 J=1,30
        DO 759 I=1,84
        TAUX(I,J)=0.0
 759    TAUY(I,J)=0.0
      ITAPE=100
 98    FORMAT(I5)
 97    FORMAT(1X,' KTAPE=',I5,' KTAU=',I5)
C*******************************
C......SET UP G12 SUCH THAT C=280 CM/S WITH ANY HH1.......
C
       G12=0.075
c       G12=0.4
C*******************************
       G23=0.0
        SCV=1.0E3
        SCH=1.0E2
        DX=1.E7/0.9
        DY=1.E7/0.9
C*******DEEPEN LAYER IF NECESSARY********
c       HH1=100000.
       HH1=400000.
       HH2=10000.
       BETA=2.E-13
       DO 765 I=1,IM
       DEX1(I)=HH1
       DEY1(I)=HH1
       STUA(I)=0.0
       STUB(I)=0.0
       STVA(I)=0.0
       STVB(I)=0.0
 765   CONTINUE
       TDX=2.*DX
       TDY=2.*DY
       DX2=DX*DX
       DY2=DY*DY
        RDX=1.0/DX
        RDY=1.0/DY
        RDX2=1.0/DX2
        RDY2=1.0/DY2
        DXDY=DX*DY
        RDXDY=1.0/DXDY
c        DAMP=1.0E4
        DAMP=0.
      DD=0.0
c      DD=1./(36.*30.*24.*3600.)
       IMAXM=IMAX-1
       JMAXM=JMAX-1
       ISMTH=31
       IPR=365
      DVT=0.0
c      DVT=1./(30.*24.*3600.)
      DVB=0.0
       DT=86400./16.
       TDT=2.*DT
C.....DEFINE VECTOR WORK SPACE
        CALL SETRAR(VECW,IMIM,0.0)
        DO 341 I=1,IM
        DO 341 II=1,IM
  341   VECW(II,I)=(I-II)
C
C******************************
C        JE=(jm-1)/2+1
C  Set JE to be at j=36
        JE=36
        IE=(im-1)/2+1
C********************************
c
c......f-plane...
c
       if(iftype.eq.1)then
c
	f0=2.*7.292e-5*sin(phi0*2.*4.*atan(1.0)/360.)
c
       DO J=2,JMAXM
        FH(J)=f0
        FV(J)=f0
       ENDDO
c
       endif
c
c......mid-latitude beta-plane...
c
       if(iftype.eq.2)then
c
	f0=2.*7.292e-5*sin(phi0*2.*4.*atan(1.0)/360.)
c
       DO 15 J=2,JMAXM
        FH(J)=f0+(J-JE-0.5)*DY*BETA
        FV(J)=f0+(J-JE)*DY*BETA
 15     CONTINUE
c
       endif
c
c......equatorial beta-plane...
c
       if(iftype.eq.3)then
c
       DO J=2,JMAXM
        FH(J)=(J-JE-0.5)*DY*BETA
        FV(J)=(J-JE)*DY*BETA
       ENDDO
c
       endif
c
	do j=2,jmaxm
c	  ecom(j)=2.e8
	  ecom(j)=asubh
	enddo
c
C********READ IN GEOMETRY*********
c
	do j=1,jm
	do i=1,im
	  ihm(i,j)=1
	enddo
	enddo
c
	do j=1,jm
	  ihm(1,j)=0
	  ihm(im,j)=0
	enddo
c
	do i=1,im
	  ihm(i,1)=0
	  ihm(i,jm)=0
	enddo
c
c......Add a ridge........
c
c	goto 8899
c
	iridge=30
c
c  Indian continent.
	do j=46,jm
	   ihm(iridge,j)=0
	   ihm(iridge+1,j)=0
	enddo
c
 8899   continue
c
        DO 43 J=1,JM
       DO 43 I=1,IMAXM
 43     IUM(I,J)=IHM(I,J)*IHM(I+1,J)
       DO 46 J=1,JMAXM
       DO 46 I=1,IM
 46     IVM(I,J)=IHM(I,J)*IHM(I,J+1)
C
c
c########################################
c
c	skip read!!!
c
c########################################
c
c
c.......set up the upwelling array.....
c
	do j=1,jm
	  do i=1,im
	    wvert(i,j)=0.0
	  enddo
	enddo
c
	do j=1,jm
c	   wupy(j)=sin(4.*atan(1.0)*float(j-1)/float(jm-1))
           wupy(j)=1.0
	enddo
c
	print *,'wupy=',wupy
c
c.......set a source in the SW corner....
c
c........vtrans is the source strength in cm^3/s
c
c	vtrans=0.5*1.e6*1.e6
	vtrans=10.*1.e6*1.e6
	npcnt=0
	do j=2,4
	   do i=2,4
	    npcnt=npcnt+ihm(i,j)
	   enddo
	enddo
c
	npland=0.
	do j=2,jm-1
	do i=2,im-1
	  npland=npland+ihm(i,j)
	enddo
	enddo
c
	print *,'npcnt=',npcnt,' npland=',npland
c
	wdown=-1.*vtrans/(float(npcnt)*dx*dy)
c
c	wup=vtrans/((npland-npcnt)*dx*dy)
c
	print *,'wdown=',wdown,' wup=',wup
c
	do j=2,jm-1
	 do i=2,im-1
c	   wvert(i,j)=wup
	   wvert(i,j)=wupy(j)
	 enddo
	enddo
c
	wtrans=0.
	do j=5,jm-1
	do i=2,im-1
	   wtrans=wtrans+wvert(i,j)*dx*dy
	enddo
	enddo
c
	do i=5,im-1
	  do j=2,4
	   wtrans=wtrans+wvert(i,j)*dx*dy
	  enddo
	enddo
c
	do j=2,jm-1
	  do i=2,im-1
	    wvert(i,j)=vtrans*wvert(i,j)/wtrans
	  enddo
	enddo
c
	do j=2,4
	   do i=2,4
	    wvert(i,j)=wdown
	   enddo
	enddo
c
	print *,'wvert=',(wvert(2,j),j=1,im)
c
c
	wtrans=0.
	do j=2,jm-1
	do i=2,im-1
	   wtrans=wtrans+wvert(i,j)*dx*dy
	enddo
	enddo
c
	print *,'wtrans over whole domain=',wtrans
c
C
 500    CONTINUE
c
       KTAU=KTAU+1
c
c	print *,'ktau=',ktau
c
       TDT=2.*DT
       IF(KTAU.EQ.1)TDT=DT
C
c
c#######################################
c
c       skip the wind read and interpolation
c
c######################################
c
c	if(ktau.le.16*30*2)then
c	do j=27,37
c	do i=154,164
c	  wx(i,j)=0.1
c	  wy(i,j)=0.
c	enddo
c	enddo
c	endif
c
c	if(ktau.gt.16*30*2)then
c	do j=27,37
c	do i=154,164
c	  wx(i,j)=0.
c	  wy(i,j)=0.
c	enddo
c	enddo
c	endif
c
C
C     *****
C     IF YOU CHANGE FORCING AMPLITUDE, CHANGE THE SCALING
C
      SCV=1.0E3
      SCH=1.0E2
       DO 20 J=2,JMAXM
       DO 20 I=2,IMAXM
       GDH2X(I,J)=-G23*(H2(I+1,J,K)-H2(I,J,K))/DX
       GDH2Y(I,J)=-G23*(H2(I,J+1,K)-H2(I,J,K))/DY
 20     CONTINUE
       DO 21 J=2,JMAXM
       DO 21 I=2,IMAXM
       GDH1X(I,J)=GDH2X(I,J)-G12*(H1(I+1,J,K)-H1(I,J,K))/DX
       GDH1Y(I,J)=GDH2Y(I,J)-G12*(H1(I,J+1,K)-H1(I,J,K))/DY
 21     CONTINUE
       DO 128 J=2,JMAXM
      DO 28 I=2,IMAXM
      H1AX=HH1+(H1(I,J,K)+H1(I+1,J,K))/2.
      H2AX=HH2+(H1(I,J,K)+H1(I+1,J,K))/2.-(H2(I,J,K)+H2(I+1,J,K))/2.
      H1AY=HH1+(H1(I,J,K)+H1(I,J+1,K))/2.
      H2AY=HH2+(H1(I,J,K)+H1(I,J+1,K))/2.-(H2(I,J,K)+H2(I,J+1,K))/2.
      US1(I,J)=U1(I,J,K)/H1AX
      VS1(I,J)=V1(I,J,K)/H1AY
      US2(I,J)=U2(I,J,K)/H2AX
      VS2(I,J)=V2(I,J,K)/H2AY
 399     FORMAT(1X,2I5,8E12.3)
 28      CONTINUE
 128    CONTINUE
C
C
C........DEFINE TEMPORARY ARRAYS....
C
         DO 6789 J=1,JM
         DO 6789 I=1,IM
         HKM(I,J)=H1(I,J,KM)
         HK(I,J)=H1(I,J,K)
         HKP(I,J)=H1(I,J,KP)
         UKM(I,J)=U1(I,J,KM)
         UK(I,J)=U1(I,J,K)
         UKP(I,J)=U1(I,J,KP)
         VKM(I,J)=V1(I,J,KM)
         VK(I,J)=V1(I,J,K)
         VKP(I,J)=V1(I,J,KP)
 6789    CONTINUE
C
C
       DO 30 J=2,JMAXM
CDIR$ IVDEP
       DO 30 I=2,IMAXM
      DEX1(I)=HH1+(HK(I,J)+HK(I+1,J))/2.
C     DEX2=HH2-(H2(I,J,K)+H2(I+1,J,K)-H1(I,J,K)-H1(I+1,J,K))/2.
      STUA(I)=DVT*(UKM(I,J) - U2(I,J,KM))
C      STUB(I)=DVB*U2(I,J,KM)
       UKP(I,J)=UKM(I,J)+TDT*IUM(I,J)*(
     1 0.25*( FV(J)*(VK(I,J)+VK(I+1,J))
     1  +FV(J-1)*(VK(I,J-1)+VK(I+1,J-1))) +GDH1X(I,J)*DEX1(I)
     2 + WX(I,J) - STUA(I)
     3 +ECOM(J)*((UKM(I+1,J)-2.*UKM(I,J)+UKM(I-1,J))/DX2+
     5  ((UKM(I,J+1)-UKM(I,J))/DY*IUM(I,J)*IUM(I,J+1)
     5  +(UKM(I,J-1)-UKM(I,J))/DY*IUM(I,J)*IUM(I,J-1))/DY)
     9         )
30    CONTINUE
C
c.......switch on nonlinear terms if required....
c
	if(ifnonl.ne.0)then
c
	do j=2,jmaxm
	do i=2,imaxm
c
       UKP(I,J)=UKP(I,J)+TDT*IUM(I,J)*(
     5  -(((UK(I+1,J)+UK(I,J))*(US1(I+1,J)+US1(I,J))-
     6  (UK(I-1,J)+UK(I,J))*(US1(I-1,J)+US1(I,J)))/DX
     7  +((VK(I+1,J)+VK(I,J))*(US1(I,J+1)+US1(I,J))-
     8   (VK(I+1,J-1)+VK(I,J-1))*(US1(I,J)+US1(I,J-1)))/DY)/4.
     9         )
c
	enddo
	enddo
c
	endif
c
       DO 31 J=2,JMAXM
CDIR$ IVDEP
       DO 31 I=2,IMAXM
      DEY1(I)=HH1+(HK(I,J)+HK(I,J+1))/2.
C     DEY2=HH2-(H2(I,J,K)+H2(I,J+1,K)-H1(I,J,K)-H1(I,J+1,K))/2.
      STVA(I)=DVT*(V1(I,J,KM) - V2(I,J,KM))
C      STVB(I)=DVB*V2(I,J,KM)
      VKP(I,J)=VKM(I,J)+TDT*IVM(I,J)*(
     1 -0.25*(FH(J+1)*(UK(I,J+1)+UK(I-1,J+1))
     1  +FH(J)*(UK(I,J)+UK(I-1,J)))+GDH1Y(I,J)*DEY1(I)
     2  +WY(I,J) - STVA(I)
     3 +ECOM(J)*(((VKM(I+1,J)-VKM(I,J))/DX*IVM(I,J)*IVM(I+1,J)+
     3 (VKM(I-1,J)-VKM(I,J))/DX*IVM(I,J)*IVM(I-1,J))/DX+
     4         (VKM(I,J+1)-2.*VKM(I,J)+VKM(I,J-1))/DY2)
     9         )
31     CONTINUE
c
c......switch on nonlinear terms if required....
c
	if(ifnonl.ne.0)then
c
	do j=2,jmaxm
	do i=2,imaxm
c
      VKP(I,J)=VKP(I,J)+TDT*IVM(I,J)*(
     5  -(((UK(I,J)+UK(I,J+1))*(VS1(I,J)+VS1(I+1,J))-
     6   (UK(I-1,J)+UK(I-1,J+1))*(VS1(I-1,J)+VS1(I,J)))/DX
     7  +((VK(I,J+1)+VK(I,J))*(VS1(I,J+1)+VS1(I,J))-
     8  (VK(I,J-1)+VK(I,J))*(VS1(I,J-1)+VS1(I,J)))/DY)/4.
     9         )
c
	enddo
	enddo
c
	endif
C
C
       DO 32 J=2,JMAXM
       DO 32 I=2,IMAXM
       HKP(I,J)=HKM(I,J)+TDT*IHM(I,J)*(
     1 -1.*((UK(I,J)-UK(I-1,J))/DX+
     1 (VK(I,J)-VK(I,J-1))/DY) - DD*HKM(I,J)
     2   +DAMP*(((HKM(I+1,J)-HKM(I,J))*IHM(I,J)*IHM(I+1,J)
     3   +(HKM(I-1,J)-HKM(I,J))*IHM(I,J)*IHM(I-1,J))*RDX2
     4   +((HKM(I,J+1)-HKM(I,J))*IHM(I,J)*IHM(I,J+1)
     5   +(HKM(I,J-1)-HKM(I,J))*IHM(I,J-1)*IHM(I,J))*RDY2)
     6   -wvert(i,j)
     6           )
  32    CONTINUE
C
C......RESET H1, U1 AND V1 ARRAYS...........
C
       DO 6790 J=1,JM
       DO 6790 I=1,IM
       H1(I,J,KP)=HKP(I,J)
       U1(I,J,KP)=UKP(I,J)
       V1(I,J,KP)=VKP(I,J)
 6790  CONTINUE
C
       IF(KTAU/ISMTH*ISMTH.NE.KTAU) GO TO 700
       DO 600 J=1,JMAX
       DO 600 I=1,IMAX
       U1(I,J,KP)=.5*(U1(I,J,KP)+U1(I,J,K))
       U1(I,J,K )=.5*(U1(I,J,KM)+U1(I,J,K))
       V1(I,J,KP)=.5*(V1(I,J,KP)+V1(I,J,K))
       V1(I,J,K )=.5*(V1(I,J,KM)+V1(I,J,K))
C      U2(I,J,KP)=.5*(U2(I,J,KP)+U2(I,J,K))
C      U2(I,J,K )=.5*(U2(I,J,KM)+U2(I,J,K))
C      V2(I,J,KP)=.5*(V2(I,J,KP)+V2(I,J,K))
C      V2(I,J,K )=.5*(V2(I,J,KM)+V2(I,J,K))
       H1(I,J,KP)=.5*(H1(I,J,KP)+H1(I,J,K))
       H1(I,J,K )=.5*(H1(I,J,KM)+H1(I,J,K))
C      H2(I,J,KP)=.5*(H2(I,J,KP)+H2(I,J,K))
C      H2(I,J,K )=.5*(H2(I,J,KM)+H2(I,J,K))
 600    CONTINUE
 700    CONTINUE
C
C.....PREVENT THERMOCLINE FROM SURFACING........
C
c        DO 9191 J=1,JM
c        DO 9191 I=1,IM
c 9191   H1(I,J,KP)=AMIN1(H1(I,J,KP),0.9*HH1)
c 9191   H1(I,J,KP)=AMIN1(H1(I,J,KP),1.65E4)
c
	do j=1,jm
	do i=1,im
	  if(h1(i,j,kp).gt.0.95*hh1)h1(i,j,kp)=0.95*hh1
	enddo
	enddo
C
C
C......WRITE OUT FIELDS FOR START UP..........
        IF(KTAU.NE.JJSTOP)GOTO 3132
C        KMTH=IMTH-1
C       IF(KTAU.NE.ITAU)GOTO 3132
C       IF(KMTH.NE.3.AND.KMTH.NE.6.AND.KMTH.NE.
C    1   9.AND.KMTH.NE.10.AND.KMTH.NE.11.AND.
C    2   KMTH.NE.12)GOTO 3132
C       REWIND 27
        ISTOP=KTAU-ITAU
        WRITE(27)MONTH1,IYEAR1,ISTOP,KTAU
        WRITE(27)((H1(I,J,K),I=1,IM),J=1,JM)
        WRITE(27)((H1(I,J,KP),I=1,IM),J=1,JM)
        WRITE(27)((U1(I,J,K),I=1,IM),J=1,JM)
        WRITE(27)((U1(I,J,KP),I=1,IM),J=1,JM)
        WRITE(27)((V1(I,J,K),I=1,IM),J=1,JM)
        WRITE(27)((V1(I,J,KP),I=1,IM),J=1,JM)
C       WRITE(27)(NOTAU(I),I=1,400)
C       WRITE(27)((DIFH(I,J),I=1,IM),J=1,JM)
 3132   CONTINUE
C
c
c##############################
c
c.......write h1 for plotting........
c
c##############################
c
	if(mod(ktau,16*30*ipltm).eq.0)then
c
c	  write(8)ihm
c	  write(8)((h1(i,j,k),i=1,im),j=1,jm)
c
	do j=1,jm
	  do i=1,im
	    hp(i,j)=h1(i,j,k)
	    up(i,j)=us1(i,j)
	    vp(i,j)=vs1(i,j)
	  enddo
	enddo
c
	  call resplt(ktau,hh1,hp,up,vp,ihm,ium,ivm)
c
	endif
c
	if(mod(ktau,2880).eq.0)then
              write(77)ktau
	      write(77)((h1(i,j,k),i=1,im),j=1,jm)
	endif
C
C
        TDT=2.0*DT
       KS=KM
       KM=K
       K=KP
       KP=KS
 987    FORMAT(1X,13E8.2)
  323 CONTINUE
C
C
       IF(KTAU.LT.JJSTOP) GO TO 500
 398       CONTINUE
C
c......close plot file.....
c
	call plotnd
c
C
 8889      FORMAT(1P,8E10.3)
 8890      FORMAT(I5)
 8892     FORMAT(4I5)
 8893     FORMAT(8I10)
C
      STOP
      END
      SUBROUTINE GPRINT(ARR,IMP,JMP,SC)
       REAL ARR(169,61)
      REAL DUM(168)
       IMPM=IMP-1
       JMPM=JMP-1
       DO 20 JJ=1,JMP
      J=JMP+1-JJ
      DO 10 I=1,IMP
   10 DUM(I)=ARR(I,J)/SC
C     WRITE(6,3252)J,(DUM(I),I=1,6),(DUM(I),I=10,60,5),(DUM(I),I=61,63)
      WRITE(6,3252)J,(DUM(I),I=1,46,2)
 20    CONTINUE
      WRITE(6,528)
 3252    FORMAT(1X,I2,23F5.2)
 528    FORMAT(//)
      RETURN
       END
        SUBROUTINE TRKVAR(A,ITM,IOBS,IUA,VAR)
C
        REAL A(169,61)
C
        INTEGER IUA(169,61),ITM(169,61),IOBS(169,61)
C
        IM=169
        JM=61
        VAR=0.0
        N=0
        SUMSQ=0.0
C
        DO 100 J=1,JM
        DO 100 I=1,IM
        SUMSQ=SUMSQ+A(I,J)*A(I,J)*IUA(I,J)*IOBS(I,J)*ITM(I,J)
 100    N=N+ITM(I,J)*IUA(I,J)*IOBS(I,J)
        IF(N.EQ.0)GOTO 110
        AN=N
        SUMSQ=SUMSQ/AN
 110    VAR=SQRT(SUMSQ)
        RETURN
        END
        SUBROUTINE REGVAR(A,I1,I2,J1,J2,IUA,IOBS,VAR)
C
        REAL A(169,61)
C
        INTEGER IUA(169,61),IOBS(169,61)
C
        VAR=0.0
        SUMSQ=0.0
        N=0
C
        DO 100 J=J1,J2
        DO 100 I=I1,I2
        SUMSQ=SUMSQ+A(I,J)*A(I,J)*IUA(I,J)*IOBS(I,J)
 100    N=N+IUA(I,J)*IOBS(I,J)
        IF(N.EQ.0)GOTO 110
        AN=N
        SUMSQ=SUMSQ/AN
 110    VAR=SQRT(SUMSQ)
        RETURN
        END
        SUBROUTINE CALRMS(A,I1,I2,J1,J2,IUA,IOBS,N,RMS)
C
        REAL A(169,61)
        INTEGER IUA(169,61),IOBS(169,61)
C
        RMS=0.0
        N=0
        DO 100 J=J1,J2
        DO 100 I=I1,I2
        RMS=RMS+A(I,J)*A(I,J)*IUA(I,J)*IOBS(I,J)
 100    N=N+IUA(I,J)*IOBS(I,J)
        IF(N.EQ.0)GOTO 110
        AN=N
        RMS=SQRT(RMS/AN)
 110     CONTINUE
        RETURN
        END
        SUBROUTINE RMSTRK(A,ITM,IOBS,IUA,N,RMS)
C
        REAL A(169,61)
C
        INTEGER IUA(169,61),ITM(169,61),IOBS(169,61)
C
        IM=169
        JM=61
        RMS=0.0
        N=0
        DO 100 J=1,JM
        DO 100 I=1,IM
        RMS=RMS+A(I,J)*A(I,J)*ITM(I,J)*IOBS(I,J)*IUA(I,J)
 100    N=N+ITM(I,J)*IOBS(I,J)*IUA(I,J)
        IF(N.EQ.0)GOTO 110
        AN=N
        RMS=SQRT(RMS/AN)
 110      CONTINUE
        RETURN
        END
       SUBROUTINE SETRAR(A,LEN,VALUE)
       REAL A(LEN)
       DO 320 I=1,LEN
  320  A(I)=VALUE
       RETURN
       END
        SUBROUTINE STRESS(WX,WY,IUM,IVM,IM,JM,IDATE)
C
        REAL WX(IM,JM),WY(IM,JM),DUM(169,61)
        INTEGER IUM(IM,JM),IVM(IM,JM)
C
C.....DUMMY ARRAY.....
C
        DO 100 J=1,JM
        DO 100 I=1,IM
 100     DUM(I,J)=0.0
         ITEST=IDATE
C
C
C.......SET UP CORRECT WIND DATA INPUT CHANNEL...
C
        IF(IDATE.EQ.820110)NIN=3
        GOTO 998
 999    NP=NIN
        IF(NP.EQ.3)NIN=90
        IF(NP.GT.80)NIN=NIN+1
        IF(NP.EQ.96)STOP 7777
 998    CONTINUE
         READ(NIN,310,END=999)IDATE,IDTYP,
     1  ((DUM(I,J),I=2+(J/60),168),J=60,2,-1)
            READ(NIN,300,END=999)IDATE,IDTYP,
     2                      ((DUM(I,J),I=2,168),J=60,2,-1)
            READ(NIN,300,END=999)IDATE,IDTYP,
     2                      ((WX(I,J),I=2,168),J=60,2,-1)
            READ(NIN,300,END=999)IDATE,IDTYP,
     2                      ((WY(I,J),I=2,168),J=60,2,-1)
 300    FORMAT(I6,I1,35X,13F6.1/(20F6.1))
 310      FORMAT(I6,I1,41X,12F6.1/(20F6.1))
        WRITE(6,800)IDATE
 800   FORMAT(1X,'WIND READ AT   ',I7)
C
C
C.......CONVERT PSEUDO WIND STRESS TO REAL WIND STRESS IN
C       NEWTONS PER SQUARE METRE USING THE DRAG EQUATION....
C
        RHO=1.25
        DO 766 J=1,JM
        DO 766 I=1,IM
        AMODV=(WX(I,J)*WX(I,J)+WY(I,J)*WY(I,J))**0.25
        CD=1.0E-3*(0.61+0.063*AMODV)
        IF(AMODV.LE.7.8)CD=1.1E-3
        WX(I,J)=CD*RHO*WX(I,J)*IUM(I,J)
 766    WY(I,J)=CD*RHO*WY(I,J)*IVM(I,J)
C
C.......CONVERT WIND UNITS TO DYNES PER SQUARE CENTIMETRE....
        DO 767 J=1,JM
        DO 767 I=1,IM
        WX(I,J)=WX(I,J)*10.0
 767    WY(I,J)=WY(I,J)*10.0
C
        RETURN
        END
C
        SUBROUTINE TOTWIND(WX,WY,IM,JM,MONTH,IYEAR,KTAU)
C
        REAL WX(IM,JM),WY(IM,JM),TAUX(84,30),TAUY(84,30),
     1  TIX(94,58),TIY(94,58),WXT(169,61),WYT(169,61)
C
C
C.......READ IN PACIFIC WIND AND CONVERT TO STRESS
C
        NIN=3
        IF(KTAU.GE.39664)NIN=10
        READ(NIN,7614)MONTH,IYEAR,TAUX,TAUY
        WRITE(6,757)MONTH,IYEAR
 7614   FORMAT(2I5,14F5.1/(16F5.1))
 757    FORMAT(1X,'WIND READ ON MONTH=',I3,' YEAR=19',I2)
        CALL WIND(TAUX,TAUY,WXT,WYT,169,61)
C
C.......READ IN INDIAN WIND AND CONVERT TO STRESS....
C
        READ(8,7614)INDM,INDY,TIX,TIY
        IF(INDM.NE.MONTH)PRINT *,'WIND MONTHS DONT MATCH'
        IF((INDY-1900).NE.IYEAR)PRINT *,'WIND YEARS DONT MATCH'
        IF(INDM.NE.MONTH)STOP 8888
        IF((INDY-1900).NE.IYEAR)STOP 9999
C
        DO 680 J=1,58
        DO 680 I=1,94
        IF(TIX(I,J).GT.980.0)TIX(I,J)=0.0
 680    IF(TIY(I,J).GT.980.0)TIY(I,J)=0.0
C
        RHO=1.25
        DO 681 J=1,58
        DO 681 I=1,93
        AMODV=(TIX(I,J)*TIX(I,J)+TIY(I,J)*TIY(I,J))**0.25
        CD=1.0E-3*(0.61+0.063*AMODV)
        IF(AMODV.LE.7.8)CD=1.1E-3
        WX(I,J)=CD*RHO*TIX(I,J)
 681    WY(I,J)=CD*RHO*TIY(I,J)
C
C........CONVERT INDIAN WINDS TO DYNES/CM2....
C
        DO 684 J=1,58
        DO 684 I=1,93
        WX(I,J)=WX(I,J)*10.0
  684   WY(I,J)=WY(I,J)*10.0
C
C........MAP PACIFIC WIND STRESS INTO WX AND WY.....
C
        DO 682 J=1,61
        DO 682 I=2,169
        WX(I+92,J+2)=WXT(I,J)
 682    WY(I+92,J+2)=WYT(I,J)
C
C.......LINEARLY INTERPOLATE BETWEEN INDIAN AND PACIFIC WINDS
C       ALONG I=93
C
        DO 683 J=1,JM
        WX(93,J)=0.5*(WX(92,J)+WX(94,J))
 683    WY(93,J)=0.5*(WY(92,J)+WY(94,J))
        RETURN
        END
C
        SUBROUTINE WIND(TAUX,TAUY,WX,WY,IM,JM)
C
        REAL TAUX(84,30),TAUY(84,30),WX(IM,JM),WY(IM,JM)
C
        IMAX=IM
        JMAX=JM
C.......SET TAUX AND TAUY TO ZERO OVER LAND....
        DO 758 J=1,30
        DO 758 I=1,84
        IF(TAUX(I,J).GT.998.0)TAUX(I,J)=0.0
  758   IF(TAUY(I,J).GT.998.0)TAUY(I,J)=0.0
C
C.......PUT PSEUDO WIND STRESS ONTO A 2 DEGREE GRID....
C
        DO 760 J=1,30
        DO 760 I=1,84
        WX(2*I,2*J)=TAUX(I,J)
 760    WY(2*I,2*J)=TAUY(I,J)
C.......SET WX AND WY TO ZERO AT BOUNDARIES...
        DO 761 J=1,JM
        WX(1,J)=0.0
        WX(IM,J)=0.0
        WY(1,J)=0.0
 761    WY(IM,J)=0.0
C
        DO 762 I=1,IM
        WX(I,1)=0.0
        WX(I,JM)=0.0
        WY(I,1)=0.0
  762   WY(I,JM)=0.0
C......LINEARLY INTERPOLATE PSEUDO WIND STRESS ONTO A I DEGREE GRID..
C
        JMAXM2=JMAX-2
        IMAXM2=IMAX-2
        JMAXM=JMAX-1
        IMAXM=IMAX-1
        DO 763 J=2,JMAXM,2
        DO 763 I=3,IMAXM2,2
        WX(I,J)=0.5*(WX(I+1,J)+WX(I-1,J))
 763    WY(I,J)=0.5*(WY(I+1,J)+WY(I-1,J))
C
        DO 764 J=3,JMAXM2,2
        DO 764 I=2,IMAXM,2
        WX(I,J)=0.5*(WX(I,J+1)+WX(I,J-1))
 764    WY(I,J)=0.5*(WY(I,J+1)+WY(I,J-1))
C
        DO 765 J=3,JMAXM2,2
        DO 765 I=3,IMAXM2,2
        WX(I,J)=0.25*(WX(I-1,J-1)+WX(I-1,J+1)+WX(I+1,J-1)+WX(I+1,J+1))
 765    WY(I,J)=0.25*(WY(I-1,J-1)+WY(I-1,J+1)+WY(I+1,J-1)+WY(I+1,J+1))
C
C.......CONVERT PSEUDO WIND STRESS TO REAL WIND STRESS IN
C       NEWTONS PER SQUARE METRE USING THE DRAG EQUATION....
C
        RHO=1.25
        DO 766 J=1,JM
        DO 766 I=1,IM
        AMODV=(WX(I,J)*WX(I,J)+WY(I,J)*WY(I,J))**0.25
        CD=1.0E-3*(0.61+0.063*AMODV)
        IF(AMODV.LE.7.8)CD=1.1E-3
        WX(I,J)=CD*RHO*WX(I,J)
 766    WY(I,J)=CD*RHO*WY(I,J)
C
C.......CONVERT WIND UNITS TO DYNES PER SQUARE CENTIMETRE....
        DO 767 J=1,JM
        DO 767 I=1,IM
        WX(I,J)=WX(I,J)*10.0
 767    WY(I,J)=WY(I,J)*10.0
C
        RETURN
        END
        SUBROUTINE ENERGY(H1,US1,VS1,HBAR,G12
     1                   ,POTE,AKINE,IHM,IUM,IVM,IM,JM)
C
        REAL H1(IM,JM),US1(IM,JM),VS1(IM,JM),POTEGY(63),AKEGY(63)
     1       ,POTE(7),AKINE(7),ALAT1(7),ALAT2(7),ALONG1(7)
     2      ,ALONG2(7)
        INTEGER IHM(IM,JM),IUM(IM,JM),IVM(IM,JM)
     1          ,IX1(7),IX2(7),JY1(7),JY2(7)
C
        DATA ALAT1/5.,5.,-5.,-5.,-17.,-17.,-24./
        DATA ALAT2/20.,20.,5.,5.,-5.,-5.,-17./
        DATA ALONG1/144.,176.,150.,235.,154.,202.,165./
        DATA ALONG2/160.,220.,205.,280.,198.,260.,275./
C........CALC. INDICES FOR TRAPEZOIDAL SUMMATIONS.....
C
        DO 800 LMN=1,7
        IX1(LMN)=ALONG1(LMN)-122.5
        IX2(LMN)=ALONG2(LMN)-122.5
        JY1(LMN)=ALAT1(LMN)+31.5
        JY2(LMN)=ALAT2(LMN)+31.5
 800    CONTINUE
C
        DO 111 II=1,7
C
        DO 101 J=1,JM
        POTEGY(J)=0.0
 101    AKEGY(J)=0.0
        I1=IX1(II)
        I2=IX2(II)
        J1=JY1(II)
        J2=JY2(II)
C
        I1P1=I1+1
        I2M1=I2-1
        J1P1=J1+1
        J2M1=J2-1
C........CALC. PE AND KE ALONG LINES OF CONSTANT LAT...
C
        DO 10 J=J1,J2
        SUMETA2=0.0
        SUMVEL2=0.0
        DO 11 I=I1P1,I2M1
        SUMETA2=SUMETA2+H1(I,J)*H1(I,J)*IHM(I,J)
        SUMVEL2=SUMVEL2+US1(I,J)*US1(I,J)*IUM(I,J)
     1         +VS1(I,J)*VS1(I,J)*IVM(I,J)
  11       CONTINUE
        POTEGY(J)=0.25*G12*(H1(I1,J)*H1(I1,J)*IHM(I1,J)
     1           +2.*SUMETA2+H1(I2,J)*H1(I2,J)*IHM(I2,J))
        AKEGY(J)=0.25*HBAR*(US1(I1,J)*US1(I1,J)*IUM(I1,J)
     1          +VS1(I1,J)*VS1(I1,J)*IVM(I1,J)+2.*SUMVEL2
     2          +US1(I2,J)*US1(I2,J)*IUM(I2,J)
     3          +VS1(I2,J)*VS1(I2,J)*IVM(I2,J))
 10     CONTINUE
C
C......CALC. PE AND KE OVER MODEL DOMAINS.....
C
        SUMPE=0.0
        SUMKE=0.0
        DO 12 J=J1P1,J2M1
        SUMPE=SUMPE+POTEGY(J)
        SUMKE=SUMKE+AKEGY(J)
 12     CONTINUE
        POTE(II)=0.5*(POTEGY(J1)+2.*SUMPE+POTEGY(J2))
        AKINE(II)=0.5*(AKEGY(J1)+2.*SUMKE+AKEGY(J2))
 111    CONTINUE
        RETURN
        END
C
        SUBROUTINE SPINUP(H1,US1,VS1,HBAR,G12
     1                   ,POTE,AKINE,IHM,IUM,IVM,IM,JM)
C
        REAL H1(IM,JM),US1(IM,JM),VS1(IM,JM),POTEGY(63),AKEGY(63)
     1       ,POTE(6),AKINE(6),ALAT1(6),ALAT2(6),ALONG1(6)
     2      ,ALONG2(6)
        INTEGER IHM(IM,JM),IUM(IM,JM),IVM(IM,JM)
     1          ,IX1(6),IX2(6),JY1(6),JY2(6)
C
        DATA ALAT1/1.,28.,38.,1.,28.,38./
        DATA ALAT2/27.,37.,63.,27.,37.,63./
        DATA ALONG1/1.,1.,1.,93.,93.,93./
        DATA ALONG2/94.,94.,94.,261.,261.,261./
C........CALC. INDICES FOR TRAPEZOIDAL SUMMATIONS.....
C
        DO 800 LMN=1,6
        IX1(LMN)=ALONG1(LMN)
        IX2(LMN)=ALONG2(LMN)
        JY1(LMN)=ALAT1(LMN)
        JY2(LMN)=ALAT2(LMN)
 800    CONTINUE
C
        DO 111 II=1,6
C
        DO 101 J=1,JM
        POTEGY(J)=0.0
 101    AKEGY(J)=0.0
        I1=IX1(II)
        I2=IX2(II)
        J1=JY1(II)
        J2=JY2(II)
C
        I1P1=I1+1
        I2M1=I2-1
        J1P1=J1+1
        J2M1=J2-1
C........CALC. PE AND KE ALONG LINES OF CONSTANT LAT...
C
        DO 10 J=J1,J2
        SUMETA2=0.0
        SUMVEL2=0.0
        DO 11 I=I1P1,I2M1
        SUMETA2=SUMETA2+H1(I,J)*H1(I,J)*IHM(I,J)
        SUMVEL2=SUMVEL2+US1(I,J)*US1(I,J)*IUM(I,J)
     1         +VS1(I,J)*VS1(I,J)*IVM(I,J)
  11       CONTINUE
        POTEGY(J)=0.25*G12*(H1(I1,J)*H1(I1,J)*IHM(I1,J)
     1           +2.*SUMETA2+H1(I2,J)*H1(I2,J)*IHM(I2,J))
        AKEGY(J)=0.25*HBAR*(US1(I1,J)*US1(I1,J)*IUM(I1,J)
     1          +VS1(I1,J)*VS1(I1,J)*IVM(I1,J)+2.*SUMVEL2
     2          +US1(I2,J)*US1(I2,J)*IUM(I2,J)
     3          +VS1(I2,J)*VS1(I2,J)*IVM(I2,J))
 10     CONTINUE
C
C......CALC. PE AND KE OVER MODEL DOMAINS.....
C
        SUMPE=0.0
        SUMKE=0.0
        DO 12 J=J1P1,J2M1
        SUMPE=SUMPE+POTEGY(J)
        SUMKE=SUMKE+AKEGY(J)
 12     CONTINUE
        POTE(II)=0.5*(POTEGY(J1)+2.*SUMPE+POTEGY(J2))
        AKINE(II)=0.5*(AKEGY(J1)+2.*SUMKE+AKEGY(J2))
 111    CONTINUE
        RETURN
        END
c
	subroutine resplt(ktau,hh1,h,u,v,ihm,ium,ivm)
c
         parameter(im=61,jm=61,imm=im-2,jmm=jm-2)
c
	 parameter(nval=15)
c
	real h(im,jm),hp(imm,jmm)
c
	real u(im,jm),up(im,jm)
c
	real v(im,jm),vp(im,jm)
c
	real spv(2),cfill(3),grylev(3),cval(nval),cval1(1)
c
	real conp(nval)
	real conm(nval)
c
	real xlrr(4),ylrr(4)
c
	integer ihm(im,jm)
c
	integer ium(im,jm)
c
	integer ivm(im,jm)
c
	real sver1(im,jm),wcurl(im,jm)
c
	real sum1(im,jm),sumc(im,jm)
c
	common/vars/beta,dxm,dym,fh(jm),fv(jm),wx(im,jm),wy(im,jm)
c
	character carrow*10,char1*3,char2*7,char4*7,char3*17
c
      COMMON/CONPAR/ISPEC,IOFFPP,SPVALL,ILEGG,ILABB,NHII,NDECCN,NLBLL,
     .              LSCAL,LDASH,HGTLAB
c
      DATA ISPEC,IOFFPP,SPVALL,ILEGG,ILABB,NHII,NDECCN,NLBLL,
     .   LSCAL,LDASH,HGTLAB
     1  /   1 ,     1,  -99999., 1,    1,   -1,    1,     2, 1, 0, 0/
c
	ch1=0.25
	ch2=0.2
c
c.......compute the sverdrup transport and wind stress curl....
c
	do j=1,jm-1
	 do i=1,im-1
	    hfl1=hh1-0.25*(h(i,j)+h(i+1,j)+h(i,j+1)+h(i+1,j+1))
	    vfl1=0.5*(v(i,j)+v(i+1,j))
	    wcurl(i,j)=(wy(i+1,j)-wy(i,j))/dxm-(wx(i,j+1)-wx(i,j))/dym
	    sver1(i,j)=beta*hfl1*vfl1
	 enddo
	enddo
c
c.......zonally integrate the Sverdrup transport and wind stress curl....
c
	do j=1,jm-1
	   do i=im,1,-1
	      sum1(i,j)=0.0
	      sumc(i,j)=0.0
	      do ii=im,i+1,-1
	         sum1(i,j)=sum1(i,j)+sver1(ii,j)*dxm
	         sumc(i,j)=sumc(i,j)+wcurl(ii,j)*dxm
	      enddo
	   enddo
	enddo
c
	do j=1,jm
	  do i=1,im
	    sver1(i,j)=-1.*sum1(i,j)
	    wcurl(i,j)=-1.*sumc(i,j)
	  enddo
	enddo
c
c
	char1='t= '
	char4=' months'
	ptime=float(ktau)/(16.*30.)
	write(char2,'(f7.1)')ptime
	char3=char1//char2//char4
c
	cval1(1)=0.5
c
	do i=1,nval
	   cval(i)=float(i-1)*0.2
	enddo
c
        xlen=5.
        ylen=float(jm)*xlen/float(im)
c
	call factor(3./5.)
c
        call plot(1.,9.,-3)
c
	chh1=hh1/100.
c
c......convert h to m......
c
	do j=1,jm
	  do i=1,im
	    h(i,j)=h(i,j)/100.
	  enddo
	enddo
c
c########set SW corner to zero for plotting######
c
	do j=2,7
	   do i=2,7
	    h(i,j)=0.0
	   enddo
	enddo
c
c......find the largest value of h and compute the
c      contour interval
c
	bigh=-1.e20
	do j=1,jm
	  do i=1,im
	   if(abs(h(i,j)).gt.bigh)bigh=abs(h(i,j))
	  enddo
	enddo
c
c########set SW corner to zero for plotting######
c
	do j=2,7
	   do i=2,7
	    h(i,j)=spvall
	   enddo
	enddo
c
c
	print *,'bigh=',bigh
c
	bigh=bigh
c
c	dc=abs(chh1-bigh)/float(nval)
	dc=bigh/float(nval)
	do i=1,nval
c	  conp(i)=float(i)*dc+chh1
c	  conm(i)=-1.*abs(chh1-bigh)+float(i-1)*dc+chh1
	  conp(i)=float(i)*dc
	  conm(i)=-1.*bigh+float(i-1)*dc
	enddo
c
c
	do j=1,jm
	 do i=1,im
	  if(ihm(i,j).eq.0)h(i,j)=spvall
	 enddo
	enddo
c
	do j=2,jm-1
	   jj=j-1
	   do i=2,im-1
           ii=i-1
	   hp(ii,jj)=h(i,j)
	   enddo
	enddo
c
        cfill(1)=-1.e20
        cfill(2)=conp(1)
        cfill(3)=1.e20
        grylev(1)=1.0
        grylev(2)=1.0
        grylev(3)=0.75
c
c        call confill(hp,imm,imm,jmm,xlen,ylen,
c     &    cfill,grylev,3,ioffpp,spvall)
c
        call confill(h,im,im,jm,xlen,ylen,
     &    cfill,grylev,3,ioffpp,spvall)
c
c
c        call conrec(hp,imm,imm,jmm,xlen,ylen,conp,nval)
c        call conrec(hp,imm,imm,jmm,xlen,ylen,conm,nval)
c
        call conrec(h,im,im,jm,xlen,ylen,conp,nval)
        call conrec(h,im,im,jm,xlen,ylen,conm,nval)
c
        call border(xlen,ylen,-1111,1111,1,1,2,1)
c
	call keksym(0.5*xlen,1.05*ylen,ch1,1Hh,0.,1,1)
c
	call keksymc(xlen+0.5,1.2*ylen,1.2*ch1,char3,0.,17,1)
c
c
	call coast(xlen,ylen)
c
	call plot(0.,-1.*(ylen+1.5),-3)
c
	do j=1,jm
	 do i=1,im
	   up(i,j)=0.0
	   vp(i,j)=0.0
	 enddo
	enddo
c
	do j=2,jm-1
	   do i=2,im-1
	   up(i,j)=0.5*(u(i,j)+u(i-1,j))
	   vp(i,j)=0.5*(v(i,j)+v(i-1,j))
	   enddo
	enddo
c
        call border(xlen,ylen,-1111,1111,1,1,1,1)
c
c########set SW corner to zero for plotting######
c
	do j=2,7
	   do i=2,7
	    up(i,j)=0.0
	    vp(i,j)=0.0
	   enddo
	enddo
c
	bigwn=-1.e20
	do j=1,jm
	  do i=1,im
	   spd=sqrt(up(i,j)*up(i,j)+vp(i,j)*vp(i,j))
	   if(spd.gt.bigwn)bigwn=spd
	  enddo
	enddo
c
        dx=xlen/float(im-1)
        dy=ylen/float(jm-1)
        scale=0.3
        do j=2,jm-1
        y=float(j-1)*dy
        do i=2,im-1
        x=float(i-1)*dx
        spd=sqrt(up(i,j)*up(i,j)+vp(i,j)*vp(i,j))
        alen=scale*spd
	x1=x
	y1=y
	if(bigwn.gt.0.0)then
        x1=x+up(i,j)*scale/bigwn
        y1=y+vp(i,j)*scale/bigwn
	endif
c
c	if(spd.gt.0.)then
c           x1=x+up(i,j)*scale
c           y1=y+vp(i,j)*scale
c	endif
c
c        if(spd.ge.0.3*bigwn)call arrow(x,y,x1,y1,0.08,20.,0)
c        if(spd.ge.1.e-6)call arrow(x,y,x1,y1,0.08,20.,0)
c        if(spd.ge.0.1*bigwn)then
        if(spd.gt.1.e-3)then
        ang=atan2((y1-y),(x1-x))
	pi=4.*atan(1.0)
        ang=0.5*pi-ang
        ang=360.*ang/(2.*pi)
        call sldlin(x,y,x1,y1,0.01)
        call farohed(x1,y1,ang,0.08,20.,0,.true.)
        endif
        enddo
        enddo
c
        call sldlin(0.,-0.3,scale,-0.3,0.01)
        call farohed(scale,-0.3,90.,0.08,20.,0,.true.)
c
	write(carrow,'(1p,1e10.3)')bigwn
c
	call keksymc(scale+0.1,-0.3,ch2,carrow,0.,10,0)
c
	call keksym(0.5*xlen,1.05*ylen,ch1,1HV,0.,1,1)
c
	call coast(xlen,ylen)
c
	lscal=0
c
        call plot(xlen+1.,ylen+1.5,-3)
c
c########set SW corner to zero for plotting######
c
	do j=2,7
	   do i=2,7
	    sver1(i,j)=0.0
	   enddo
	enddo
c
c......find the largest value of sver1 and sver2, etc and compute the
c      contour interval
c
	bigs1=-1.e20
	bigwc=-1.e20
	do j=1,jm
	  do i=1,im
	   if(abs(sver1(i,j)).gt.bigs1)bigs1=abs(sver1(i,j))
	   if(abs(wcurl(i,j)).gt.bigwc)bigwc=abs(wcurl(i,j))
	  enddo
	enddo
c
c########set SW corner to zero for plotting######
c
	do j=2,7
	   do i=2,7
	    sver1(i,j)=spvall
	   enddo
	enddo
c
	do j=2,jm-1
	do i=2,im-1
	   isum=(ihm(i,j)+ihm(i+1,j)+ihm(i,j+1)+ihm(i+1,j+1))/4
	   if(isum.ne.1)sver1(i,j)=spvall
	enddo
	enddo
c
c
	print *,'bigs1=',bigs1
	print *,'bigwc=',bigwc
c
	bigh=bigs1
	dc=bigh/float(nval)
	do i=1,nval
	  conp(i)=float(i)*dc
	  conm(i)=-1.*bigh+float(i-1)*dc
	enddo
c
        cfill(1)=-1.e20
        cfill(2)=conp(1)
        cfill(3)=1.e20
        grylev(1)=1.0
        grylev(2)=1.0
        grylev(3)=0.75
c
        call confill(sver1,im,im,jm,xlen,ylen,
     &    cfill,grylev,3,ioffpp,spvall)
c
        call conrec(sver1,im,im,jm,xlen,ylen,conp,nval)
        call conrec(sver1,im,im,jm,xlen,ylen,conm,nval)
c
        call border(xlen,ylen,-1111,1111,1,1,2,1)
c
	call keksym(0.5*xlen,1.05*ylen+0.3,0.7*ch1,
     &         28HZonally Integrated Northward,0.,28,1)
	call keksym(0.5*xlen,1.05*ylen,0.7*ch1,
     &       30HTransport from East in Layer 1,0.,30,1)
c
	call coast(xlen,ylen)
c
	goto 1789
c
	call plot(0.,-1.*(ylen+1.5),-3)
c
c	bigh=bigwc
c	dc=bigh/float(nval)
c	do i=1,nval
c	  conp(i)=float(i)*dc
c	  conm(i)=-1.*bigh+float(i-1)*dc
c	enddo
c
        call confill(wcurl,im,im,jm,xlen,ylen,
     &    cfill,grylev,3,ioffpp,spvall)
c
        call conrec(wcurl,im,im,jm,xlen,ylen,conp,nval)
        call conrec(wcurl,im,im,jm,xlen,ylen,conm,nval)
c
        call border(xlen,ylen,-1111,1111,1,1,2,1)
c
	call keksym(0.5*xlen,1.05*ylen+0.3,0.7*ch1,
     &         18HZonally Integrated,0.,18,1)
	call keksym(0.5*xlen,1.05*ylen,0.7*ch1,
     &       16HWind Stress Curl,0.,16,1)
c
	call coast(xlen,ylen)
c
 1789   continue
c
	call chopit(0.,0.)
c
	lscal=1
c
c
	return
        end
c
	subroutine coast(xlen,ylen)
c
        PARAMETER(IM=61)
        PARAMETER(JM=61)
c
	real xlrr(4),ylrr(4)
c
c       west coast
c
         dlx=xlen/(float(im-1))
         dly=ylen/float(jm-1)
	 xlrr(1)=0.0
	 ylrr(1)=0.0
	 xlrr(2)=0.5*dlx
	 ylrr(2)=ylrr(1)
	 xlrr(3)=xlrr(2)
	 ylrr(3)=ylen
	 xlrr(4)=0.
	 ylrr(4)=ylrr(3)
         call filrgn(xlrr,ylrr,4,0.)
c
c       east coast
c
	 xlrr(1)=xlen-0.5*dlx
	 ylrr(1)=0.0
	 xlrr(2)=xlen
	 ylrr(2)=ylrr(1)
	 xlrr(3)=xlrr(2)
	 ylrr(3)=ylen
	 xlrr(4)=xlen-0.5*dlx
	 ylrr(4)=ylrr(3)
         call filrgn(xlrr,ylrr,4,0.)
c
	 xlrr(1)=0.0
	 ylrr(1)=0.0
	 xlrr(2)=xlen
	 ylrr(2)=ylrr(1)
	 xlrr(3)=xlrr(2)
	 ylrr(3)=0.5*dly
	 xlrr(4)=0.
	 ylrr(4)=ylrr(3)
         call filrgn(xlrr,ylrr,4,0.)
c
	 xlrr(1)=0.0
	 ylrr(1)=ylen-0.5*dly
	 xlrr(2)=xlen
	 ylrr(2)=ylrr(1)
	 xlrr(3)=xlrr(2)
	 ylrr(3)=ylen
	 xlrr(4)=0.
	 ylrr(4)=ylrr(3)
         call filrgn(xlrr,ylrr,4,0.)
c
	return
	end
