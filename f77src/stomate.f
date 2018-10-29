
      SUBROUTINE stomate(I,J,NZ,NY,NX)
C
C     THIS SUBROUTINE CALCULATES CANOPY STOMATAL RESISTANCE AT MAXIMUM
C     CANOPY TURGOR FOR USE IN ENERGY BALANCE EQUATIONS IN 'UPTAKE'
C
      include "parameters.h"
      include "blkc.h"
      include "blk1cp.h"
      include "blk1g.h"
      include "blk1n.h"
      include "blk1p.h"
      include "blk2a.h"
      include "blk3.h"
      include "blk5.h"
      include "blk8a.h"
      include "blk8b.h"
      include "blk9a.h"
      include "blk9b.h"
      include "blk9c.h"
      include "blk1u.h"
      DIMENSION FLG4Y(0:5)
      PARAMETER (QNTM=0.45,CURV=0.70,CURV2=2.0*CURV,CURV4=4.0*CURV
     2,ELEC3=4.5,ELEC4=3.0)
      PARAMETER (CNKI=1.0E+02,CPKI=1.0E+03)
      PARAMETER (RSMY=2.78E-03,ATRPZ=276.9)
      PARAMETER (COMP4=0.5,FDML=6.0,FBS=0.2*FDML,FMP=0.8*FDML
     2,C4KI=5.0E+06,FVRN=0.5)
      DATA FLG4Y/336.0,672.0,672.0,672.0,672.0,672.0/
C
C     CANOPY TEMPERATURE + OFFSET FOR THERMAL ADAPTATION FROM 'READQ'
C
C
C     CANOPY BOUNDARY LAYER RESISTANCE
C
      RI=AMAX1(-0.3,AMIN1(0.075,RIB(NY,NX)*(TKA(NY,NX)-TKCZ(NZ,NY,NX))))
      RAC=1.34*AMAX1(5.56E-03,RAZ(NZ,NY,NX)/(1.0-10.0*RI))
      FMOL(NZ,NY,NX)=1.2194E+04/TKCZ(NZ,NY,NX)
C
C     CANOPY CO2 CONCENTRATION FROM CO2 INFLUXES AND EFFLUXES
C
      CO2Q(NZ,NY,NX)=CO2E(NY,NX)-8.33E+04*CNETX(NY,NX)
     2*RAC/FMOL(NZ,NY,NX)
      CO2Q(NZ,NY,NX)=AMIN1(CO2E(NY,NX)+200.0
     2,AMAX1(0.0,CO2E(NY,NX)-200.0,CO2Q(NZ,NY,NX)))
C
C     MESOPHYLL CO2 CONCENTRATION FROM CI:CA RATIO ENTERED IN 'READQ'
C
      CO2I(NZ,NY,NX)=FCO2(NZ,NY,NX)*CO2Q(NZ,NY,NX)
      IF(SSIN(NY,NX).GT.0.0.AND.ARLFP(NZ,NY,NX).GT.ZEROP(NZ,NY,NX))THEN
C
C     CO2 AND O2 AQUEOUS SOLUBILITY
C
      TCCZ=TKCZ(NZ,NY,NX)-273.15
      SCO2(NZ,NY,NX)=EXP(-2.621-0.0317*TCCZ)
      SO2(NZ,NY,NX)=EXP(-6.175-0.0211*TCCZ)
      CO2L(NZ,NY,NX)=CO2I(NZ,NY,NX)*SCO2(NZ,NY,NX)
      O2L(NZ,NY,NX)=O2I(NZ,NY,NX)*SO2(NZ,NY,NX)
C
C     CO2 CONCENTRATION DIFFERENCE
C
      DCO2(NZ,NY,NX)=FMOL(NZ,NY,NX)*(CO2Q(NZ,NY,NX)-CO2I(NZ,NY,NX))
      CH2O=0.0
      TKCO=TKCZ(NZ,NY,NX)+OFFST(NZ,NY,NX)
      RTK=8.3143*TKCO
      STK=710.0*TKCO
C
C     ARRHENIUS FUNCTIONS FOR CARBOXYLATION AND OXYGENATION
C
      ACTV=1+EXP((197500-STK)/RTK)+EXP((STK-222500)/RTK)
      TFN1=EXP(26.237-65000/RTK)/ACTV
      TFN2=EXP(24.220-60000/RTK)/ACTV
      TFNE=EXP(17.362-43000/RTK)/ACTV
C
C     M-M CONSTANT FOR CARBOXYLATION FROM 'READQ' ADJUSTED FOR TEMPERATURE
C
      XKCO2L(NZ,NY,NX)=XKCO2(NZ,NY,NX)*EXP(16.136-40000/RTK) 
      XKO2L=XKO2(NZ,NY,NX)*EXP(8.067-20000/RTK) 
      XKCO2O(NZ,NY,NX)=XKCO2L(NZ,NY,NX)*(1.0+O2L(NZ,NY,NX)/XKO2L)
C
C     FOR EACH BRANCH
C
      DO 2900 NB=1,NBR(NZ,NY,NX)
C     IF(NZ.EQ.1.OR.NZ.EQ.4)THEN
C     WRITE(*,4242)'FDBK',I,J,NZ,NB,IDTHB(NB,NZ,NY,NX),FDBK(NB,NZ,NY,NX)
C    2,VRNS(NB,NZ,NY,NX),VRNF(NB,NZ,NY,NX),CCPOLB(NB,NZ,NY,NX)
C    3,CZPOLB(NB,NZ,NY,NX),CCPOLB(NB,NZ,NY,NX)
4242  FORMAT(A8,5I4,12E12.4)
C     ENDIF
C
C      FEEDBACK ON CO2 FIXATION
C
      IF(IWTYP(NZ,NY,NX).EQ.0
     2.OR.VRNS(NB,NZ,NY,NX).GE.VRNL(NB,NZ,NY,NX)
     3.OR.VRNF(NB,NZ,NY,NX).LT.VRNX(NB,NZ,NY,NX))THEN
C
C     FEEDBACK ON C3 CARBOXYLATION FROM NON-STRUCTURAL C:N:P
C
      IF(CCPOLB(NB,NZ,NY,NX).GT.ZERO)THEN
      FDBK(NB,NZ,NY,NX)=AMIN1(CZPOLB(NB,NZ,NY,NX)
     3/(CZPOLB(NB,NZ,NY,NX)+CCPOLB(NB,NZ,NY,NX)/CNKI)
     4,CPPOLB(NB,NZ,NY,NX)
     5/(CPPOLB(NB,NZ,NY,NX)+CCPOLB(NB,NZ,NY,NX)/CPKI))
      ELSE
      FDBK(NB,NZ,NY,NX)=1.0
      ENDIF
C
C     CHILLING 
C
C     FDBK(NB,NZ,NY,NX)=FDBK(NB,NZ,NY,NX)/(1.0+0.25*CHILL(NZ,NY,NX))
C
C     DEHARDENING OF EVERGREENS IN SPRING
C
      IF(IWTYP(NZ,NY,NX).NE.0.AND.IBTYP(NZ,NY,NX).GE.2)THEN
      FDBK(NB,NZ,NY,NX)=FDBK(NB,NZ,NY,NX)*AMAX1(0.0,AMIN1(1.0
     2,ATRP(NB,NZ,NY,NX)/(0.9*ATRPZ)))
      ENDIF
C
C     TERMINATION OF ANNUALS 
C
      IF(ISTYP(NZ,NY,NX).EQ.0.AND.FLG4(NB,NZ,NY,NX).GT.0.0)THEN
      FDBKX(NB,NZ,NY,NX)=AMAX1(0.0
     2,1.0-FLG4(NB,NZ,NY,NX)/FLG4Y(IWTYP(NZ,NY,NX)))
      ELSE
      FDBKX(NB,NZ,NY,NX)=1.0
      ENDIF
      FDBK(NB,NZ,NY,NX)=FDBK(NB,NZ,NY,NX)*FDBKX(NB,NZ,NY,NX)
C
C     FOR EACH NODE
C
      IF(IDTHB(NB,NZ,NY,NX).EQ.0)THEN
      DO 2800 K=1,25
      IF(ARLF(K,NB,NZ,NY,NX).GT.ZEROP(NZ,NY,NX)
     2.AND.WGLF(K,NB,NZ,NY,NX).GT.ZEROP(NZ,NY,NX))THEN
      WSDN=WSLF(K,NB,NZ,NY,NX)/ARLF(K,NB,NZ,NY,NX)
      ELSE
      WSDN=0.0
      ENDIF
C     IF((I/10)*10.EQ.I.AND.J.EQ.15)THEN
C     WRITE(*,2125)'WSDN',I,J,NX,NY,NZ,NB,K,WSDX,WSDN
C    2,WSDM,WGLF(K,NB,NZ,NY,NX),WSLF(K,NB,NZ,NY,NX)
C    3,ARLF(K,NB,NZ,NY,NX)
2125  FORMAT(A8,7I4,12E12.4)
C     ENDIF
      IF(WSDN.GT.ZERO)THEN
C
C     C4 PHOTOSYNTHESIS
C
      IF(ICTYP(NZ,NY,NX).EQ.4)THEN
C
C     FEEDBACK ON C4 CARBOXYLATION FROM C4 NON-STRUCTURAL C
C
      CC4M=AMAX1(0.0,0.021E+09*CPOOL4(K,NB,NZ,NY,NX)
     2/(WGLF(K,NB,NZ,NY,NX)*FMP))
      CCBS=AMAX1(0.0,0.083E+09*CO2B(K,NB,NZ,NY,NX)
     2/(WGLF(K,NB,NZ,NY,NX)*FBS))
      FDBK4(K,NB,NZ,NY,NX)=1.0/(1.0+CC4M/C4KI)
      FDBK4(K,NB,NZ,NY,NX)=FDBK4(K,NB,NZ,NY,NX)*FDBKX(NB,NZ,NY,NX)
C
C     SURFICIAL DENSITY OF PEPC AND ITS CHLOROPHYLL
C
      VCDN4=PEPC(NZ,NY,NX)*WSDN
      ETDN4=CHL4(NZ,NY,NX)*WSDN
C
C     CO2-LIMITED C4 CARBOXYLATION RATES
C
      VCGR4(K,NB,NZ,NY,NX)=VCMX4(NZ,NY,NX)*TFN1*VCDN4
      VGRO4(K,NB,NZ,NY,NX)=AMAX1(0.0,VCGR4(K,NB,NZ,NY,NX)
     2*(CO2L(NZ,NY,NX)-COMP4)/(CO2L(NZ,NY,NX)+XKCO24(NZ,NY,NX)))
C
C     C4 ELECTRON TRANSFER RATES
C
      ETGR4(K,NB,NZ,NY,NX)=ETMX(NZ,NY,NX)*TFNE*ETDN4
      CBXN4(K,NB,NZ,NY,NX)=AMAX1(0.0,(CO2L(NZ,NY,NX)-COMP4)
     2/(ELEC4*CO2L(NZ,NY,NX)+10.5*COMP4))
C
C     FOR EACH CANOPY LAYER
C
      DO 2700 L=JC,1,-1
      IF(ARLFL(L,K,NB,NZ,NY,NX).GT.ZEROP(NZ,NY,NX))THEN
C
C     FOR EACH INCLINATION AND AZIMUTH CLASS
C
      DO 2600 N=1,4
      DO 2500 M=1,4
      IF(SURFX(N,L,K,NB,NZ,NY,NX).GT.ZEROP(NZ,NY,NX))THEN
C
C     SUNLIT LEAVES
C
      IF(PAR(N,M,L,NZ,NY,NX).GT.0.0)THEN
C
C     LIGHT-LIMITED CARBOXYLATION RATES
C
      PARX=QNTM*PAR(N,M,L,NZ,NY,NX)
      PARJ=PARX+ETGR4(K,NB,NZ,NY,NX)
      ETLF4=(PARJ-SQRT(PARJ**2-CURV4*PARX*ETGR4(K,NB,NZ,NY,NX)))/CURV2
      EGRO4=ETLF4*CBXN4(K,NB,NZ,NY,NX)
C
C     C4 CARBOXYLATION RATE AND ACCUMULATED PRODUCT
C
      VL=AMIN1(VGRO4(K,NB,NZ,NY,NX),EGRO4)*FDBK4(K,NB,NZ,NY,NX)
      CH2O=CH2O+VL*SURFX(N,L,K,NB,NZ,NY,NX)*TAUS(L+1,NY,NX)
C     IF(L.GT.NC-4.AND.NB.EQ.1.AND.M.EQ.1.AND.N.EQ.3)THEN
C     WRITE(*,6789)'STO',I,J,L,M,N,K,VL,PAR(N,M,L,NZ,NY,NX),RAPS
C    2,TKCZ(NZ,NY,NX),CO2Q(NZ,NY,NX),ETGR4(K,NB,NZ,NY,NX)
C    3,CBXN4(K,NB,NZ,NY,NX),VGRO4(K,NB,NZ,NY,NX),EGRO4
C    3,FDBK4(K,NB,NZ,NY,NX),CH2O,VGRO4(K,NB,NZ,NY,NX),EGRO4
C    3,VCGR4(K,NB,NZ,NY,NX),CO2I(NZ,NY,NX),CO2L(NZ,NY,NX),TFN1,TFN2
C    4,TFNE,WSDX,WSDN,VCDN4
6789  FORMAT(A8,6I4,40E12.4)
C     ENDIF
      ENDIF
C
C     SHADED LEAVES
C
      IF(PARDIF(N,M,L,NZ,NY,NX).GT.0.0)THEN
C
C     LIGHT-LIMITED CARBOXYLATION RATES
C
      PARX=QNTM*PARDIF(N,M,L,NZ,NY,NX)
      PARJ=PARX+ETGR4(K,NB,NZ,NY,NX)
      ETLF4=(PARJ-SQRT(PARJ**2-CURV4*PARX*ETGR4(K,NB,NZ,NY,NX)))/CURV2
      EGRO4=ETLF4*CBXN4(K,NB,NZ,NY,NX)
C
C     C4 CARBOXYLATION RATE AND ACCUMULATED PRODUCT
C
      VL=AMIN1(VGRO4(K,NB,NZ,NY,NX),EGRO4)*FDBK4(K,NB,NZ,NY,NX)
      CH2O=CH2O+VL*SURFX(N,L,K,NB,NZ,NY,NX)*TAU0(L+1,NY,NX)
C     WRITE(*,6799)'STB',I,J,L,M,N,K,VL,PAR(N,M,L,NZ,NY,NX),RAPS
C    2,TKCZ(NZ,NY,NX),CO2Q(NZ,NY,NX),ETGR4(K,NB,NZ,NY,NX)
C    3,CBXN4(K,NB,NZ,NY,NX),VGRO4(K,NB,NZ,NY,NX),EGRO4
C    3,FDBK4(K,NB,NZ,NY,NX),CH2O,VGRO4(K,NB,NZ,NY,NX),EGRO4
C    3,VCGR4(K,NB,NZ,NY,NX),CO2I(NZ,NY,NX),CO2L(NZ,NY,NX)
6799  FORMAT(A8,6I4,40E12.4)
      ENDIF
      ENDIF
2500  CONTINUE
2600  CONTINUE
      ENDIF
2700  CONTINUE
C
C     VARIABLES FOR C3 PHOTOSYNTHESIS DRIVEN BY C4
C
      VCDN=RUBP(NZ,NY,NX)*WSDN
      ETDN=CHL(NZ,NY,NX)*WSDN
      VCGRO(K,NB,NZ,NY,NX)=VCMX(NZ,NY,NX)*TFN1*VCDN
      VOGRO=VOMX(NZ,NY,NX)*TFN2*VCDN
      COMPL(K,NB,NZ,NY,NX)=0.5*O2L(NZ,NY,NX)*VOGRO*XKCO2L(NZ,NY,NX)
     2/(VCGRO(K,NB,NZ,NY,NX)*XKO2L)
      VGRO(K,NB,NZ,NY,NX)=AMAX1(0.0,VCGRO(K,NB,NZ,NY,NX)
     2*(CCBS-COMPL(K,NB,NZ,NY,NX))/(CCBS+XKCO2O(NZ,NY,NX)))
      ETGRO(K,NB,NZ,NY,NX)=ETMX(NZ,NY,NX)*TFNE*ETDN
      CBXN(K,NB,NZ,NY,NX)=AMAX1(0.0,(CCBS-COMPL(K,NB,NZ,NY,NX))
     2/(ELEC3*CCBS+10.5*COMPL(K,NB,NZ,NY,NX)))
C
C     C3 PHOTOSYNTHESIS
C
      ELSE
C
C     SURFICIAL DENSITY OF RUBISCO AND ITS CHLOROPHYLL
C
      VCDN=RUBP(NZ,NY,NX)*WSDN
      ETDN=CHL(NZ,NY,NX)*WSDN
C
C     CO2-LIMITED C3 CARBOXYLATION RATES
C
      VCGRO(K,NB,NZ,NY,NX)=VCMX(NZ,NY,NX)*TFN1*VCDN
      VOGRO=VOMX(NZ,NY,NX)*TFN2*VCDN
      COMPL(K,NB,NZ,NY,NX)=0.5*O2L(NZ,NY,NX)*VOGRO*XKCO2L(NZ,NY,NX)
     2/(VCGRO(K,NB,NZ,NY,NX)*XKO2L)
      VGRO(K,NB,NZ,NY,NX)=AMAX1(0.0,VCGRO(K,NB,NZ,NY,NX)
     2*(CO2L(NZ,NY,NX)-COMPL(K,NB,NZ,NY,NX))
     5/(CO2L(NZ,NY,NX)+XKCO2O(NZ,NY,NX)))
C
C     C3 ELECTRON TRANSFER RATES
C
      ETGRO(K,NB,NZ,NY,NX)=ETMX(NZ,NY,NX)*TFNE*ETDN
      CBXN(K,NB,NZ,NY,NX)=AMAX1(0.0,(CO2L(NZ,NY,NX)
     2-COMPL(K,NB,NZ,NY,NX))/(ELEC3*CO2L(NZ,NY,NX)
     3+10.5*COMPL(K,NB,NZ,NY,NX)))
C
C     FOR EACH CANOPY LAYER
C
      DO 3700 L=JC,1,-1
      IF(ARLFL(L,K,NB,NZ,NY,NX).GT.ZEROP(NZ,NY,NX))THEN
C
C     FOR EACH INCLINATION AND AZIMUTH CLASS
C
      DO 3600 N=1,4
      DO 3500 M=1,4
      IF(SURFX(N,L,K,NB,NZ,NY,NX).GT.ZEROP(NZ,NY,NX))THEN
C
C     SUNLIT LEAVES
C
      IF(PAR(N,M,L,NZ,NY,NX).GT.0.0)THEN
C
C     LIGHT-LIMITED CARBOXYLATION RATES
C
      PARX=QNTM*PAR(N,M,L,NZ,NY,NX)
      PARJ=PARX+ETGRO(K,NB,NZ,NY,NX)
      ETLF=(PARJ-SQRT(PARJ**2-CURV4*PARX*ETGRO(K,NB,NZ,NY,NX)))/CURV2
      EGRO=ETLF*CBXN(K,NB,NZ,NY,NX)
C
C     C3 CARBOXYLATION RATE AND ACCUMULATED PRODUCT
C
      VL=AMIN1(VGRO(K,NB,NZ,NY,NX),EGRO)*FDBK(NB,NZ,NY,NX)
      CH2O=CH2O+VL*SURFX(N,L,K,NB,NZ,NY,NX)*TAUS(L+1,NY,NX)
C     IF(NB.EQ.1.AND.M.EQ.1.AND.N.EQ.1.AND.K.EQ.KLEAF(NB,NZ,NY,NX)-1
C    2.AND.J.EQ.14)THEN
C     WRITE(20,6798)'STD',I,J,L,M,N,K,NB,VL,PAR(N,M,L,NZ,NY,NX),RAPS
C    2,TKCZ(NZ,NY,NX),CO2Q(NZ,NY,NX),ETGRO(K,NB,NZ,NY,NX)
C    3,CBXN(K,NB,NZ,NY,NX),VGRO(K,NB,NZ,NY,NX),EGRO
C    3,FDBK(NB,NZ,NY,NX),CH2O,TFN1,TFN2,TFNE,WSDX,WSDN
C    3,VCGRO(K,NB,NZ,NY,NX),VCDN,CO2I(NZ,NY,NX),CO2L(NZ,NY,NX)
6798  FORMAT(A8,7I4,40E12.4)
C     ENDIF
      ENDIF
C
C     SHADED LEAVES
C
      IF(PARDIF(N,M,L,NZ,NY,NX).GT.0.0)THEN
C
C     LIGHT-LIMITED CARBOXYLATION RATES
C
      PARX=QNTM*PARDIF(N,M,L,NZ,NY,NX)
      PARJ=PARX+ETGRO(K,NB,NZ,NY,NX)
      ETLF=(PARJ-SQRT(PARJ**2-CURV4*PARX*ETGRO(K,NB,NZ,NY,NX)))/CURV2
      EGRO=ETLF*CBXN(K,NB,NZ,NY,NX)
C
C     C3 CARBOXYLATION RATE AND ACCUMULATED PRODUCT
C
      VL=AMIN1(VGRO(K,NB,NZ,NY,NX),EGRO)*FDBK(NB,NZ,NY,NX)
      CH2O=CH2O+VL*SURFX(N,L,K,NB,NZ,NY,NX)*TAU0(L+1,NY,NX)
      ENDIF
      ENDIF
3500  CONTINUE
3600  CONTINUE
      ENDIF
3700  CONTINUE
      ENDIF
      ELSE
      VCGR4(K,NB,NZ,NY,NX)=0.0
      VCGRO(K,NB,NZ,NY,NX)=0.0
      ENDIF
2800  CONTINUE
      ENDIF
      ELSE
      FDBK(NB,NZ,NY,NX)=0.0
      FDBKX(NB,NZ,NY,NX)=1.0
      DO 2805 K=1,25
      VCGR4(K,NB,NZ,NY,NX)=0.0
      VCGRO(K,NB,NZ,NY,NX)=0.0
2805  CONTINUE
      ENDIF
2900  CONTINUE
C
C     MINIMUM CANOPY STOMATAL RESISTANCE FROM CO2 CONCENTRATION
C     DIFFERENCE DIVIDED BY TOTAL CO2 FIXATION
C
      IF(CH2O.GT.ZEROP(NZ,NY,NX))THEN
      RSX=FRADP(NZ,NY,NX)*DCO2(NZ,NY,NX)
     2*AREA(3,NU(NY,NX),NY,NX)/(CH2O*3600.0)
      ELSE
      RSX=RSMH(NZ,NY,NX)*1.56
      ENDIF
      RSMN(NZ,NY,NX)=AMIN1(RSMH(NZ,NY,NX),AMAX1(RSMY,RSX*0.641))
      ELSE
      RSMN(NZ,NY,NX)=RSMH(NZ,NY,NX)
      ENDIF
C     IF(ICTYP(NZ,NY,NX).EQ.3)THEN
C     WRITE(19,3010)'CH2O',I,J,CH2O
C     ELSEIF(ICTYP(NZ,NY,NX).EQ.4)THEN
C     WRITE(20,3010)'CH2O',I,J,CH2O
C     ENDIF
3010  FORMAT(A8,2I4,1E12.4)
      RETURN
      END
