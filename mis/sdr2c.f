      SUBROUTINE SDR2C        
C        
C     SDR2C PROCESSES OUTPUT REQUESTS FOR SINGLE-POINT FORCES OF        
C     CONSTRAINT, LOADS, DISPLACEMENTS, VELOCITIES, ACCELERATIONS AND   
C     EIGENVECTORS.        
C        
      LOGICAL         ANYOUT,AXIC  ,DDRMM ,AXSINE,AXCOSI        
      INTEGER         APP   ,SORT2 ,SPCF  ,DISPL ,VEL   ,ACC   ,STRESS, 
     1                FORCE ,CSTM  ,CASECC,EQEXIN,SIL   ,BGPDT ,PG    , 
     2                QG    ,UGV   ,PHIG  ,EIGR  ,OPG1  ,OQG1  ,OUGV1 , 
     3                PUGV1 ,OCB   ,SORC  ,DTYPE ,FILE  ,BUF1  ,BUF2  , 
     4                BUF3  ,BUF4  ,BUF5  ,SYMFLG,OUTFL ,STA   ,REI   , 
     5                DS0   ,DS1   ,FRQ   ,TRN   ,BK0   ,DATE  ,SYSBUF, 
     6                BRANCH,PLOTS ,QTYPE2,EOL   ,BK1   ,TIME  ,SETNO , 
     7                FSETNO,Z     ,RETX  ,FORMT ,FLAG  ,EOF   ,CEI   , 
     8                PLA   ,OHARMS,BLANKS,HARMS ,XSETNO,XSET0 ,DEST  , 
     9                PBUFF(4)     ,EXTRA ,AXIF  ,EDT   ,PLATIT(12)   , 
     O                BUF(50)        
      REAL            ZZ(1) ,BUFR(11)     ,PBUFR(4)        
      DIMENSION       DATE(3)        
      COMMON /BLANK / APP(2),SORT2        
      COMMON /SDR2X1/ IEIGEN,IELDEF,ITLOAD,ISYMFL,ILOADS,IDISPL,ISTR  , 
     1                IELF  ,IACC  ,IVEL  ,ISPCF ,ITTL  ,ILSYM ,IFROUT, 
     2                ISLOAD,IDLOAD,ISORC        
      COMMON /SDR2X2/ CASECC,CSTM  ,MPT   ,DIT   ,EQEXIN,SIL   ,GPTT  , 
     1                EDT   ,BGPDT ,PG    ,QG    ,UGV   ,EST   ,PHIG  , 
     2                EIGR  ,OPG1  ,OQG1  ,OUGV1 ,OES1  ,OEF1  ,PUGV1 , 
     3                OEIGR ,OPHIG ,PPHIG ,ESTA  ,GPTTA ,HARMS        
      COMMON /SDR2X4/ NAM(2),END   ,MSET  ,ICB(7),OCB(7),MCB(7),DTYPE(8)
     1,               ICSTM ,NCSTM ,IVEC  ,IVECN ,TEMP  ,DEFORM,FILE  , 
     2                BUF1  ,BUF2  ,BUF3  ,BUF4  ,BUF5  ,ANY   ,ALL   , 
     3                TLOADS,ELDEF ,SYMFLG,BRANCH,KTYPE ,LOADS ,SPCF  , 
     4                DISPL ,VEL   ,ACC   ,STRESS,FORCE ,KWDEST,KWDEDT, 
     5                KWDGPT,KWDCC ,NRIGDS,STA(2),REI(2),DS0(2),DS1(2), 
     6                FRQ(2),TRN(2),BK0(2),BK1(2),CEI(2),PLA(22)      , 
     7                NRINGS,NHARMS,AXIC  ,KNSET ,ISOPL ,STRSPT,DDRMM   
CZZ   COMMON /ZZSDC2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /CONDAS/ PI    ,TWOPI ,RADDEG,DEGRA ,S4PISQ        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /UNPAKX/ QTYPE2,I2    ,J2    ,INCR2        
      COMMON /ZNTPKX/ XX(4),IXX    ,EOL   ,EOR        
      COMMON /ZBLPKX/ Y(4) ,IY        
      EQUIVALENCE     (KSYSTM( 1),SYSBUF) ,(KSYSTM(15),DATE(1)) ,       
     1                (KSYSTM(18),TIME  ) ,(KSYSTM(20),PLOTS  ) ,       
     2                (KSYSTM(38),AXIF  ) ,(KSYSTM(56),IHEAT  ) ,       
     3                (BUF(1),BUFR(1)),(Z(1),ZZ(1)),(PBUFF(1),PBUFR(1)) 
      DATA    BUF   / 50*0     /        
      DATA    BLANKS/ 4H       /        
      DATA    XSET0 / 100000000/        
      DATA    PLATIT/ 4HLOAD,4H FAC,4HTOR ,9*0/        
      DATA    MMREIG/ 4HMMRE   /        
C        
C     IF THIS IS A DYNAMIC-DATA-RECOVERY-MATRIX-METHOD REIG PROBLEM     
C     THEN ALL EIGENVECTORS ARE TO BE OUTPUT FOR THE DDRMM MODULE.      
C        
      SETNO = 0        
      IF (DDRMM .AND. IREQ.EQ.IDISPL) SETNO = -1        
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      BUF1  = KORSZ(Z) - SYSBUF + 1        
      BUF2  = BUF1 - SYSBUF        
      BUF3  = BUF2 - SYSBUF        
      BUF4  = BUF3 - SYSBUF        
      BUF5  = BUF4 - SYSBUF        
      ISEQ  = 1        
      M8    =-8        
      I2    = 1        
      INCR2 = 1        
      KPLOT = 0        
      EXTRA = 0        
      AXSINE = .FALSE.        
      AXCOSI = .FALSE.        
C        
C     READ SECOND RECORD OF EQEXIN OR EQDYN INTO CORE.        
C        
      FILE = EQEXIN        
      CALL GOPEN (EQEXIN,Z(BUF1),0)        
      CALL SKPREC (EQEXIN,1)        
      CALL READ (*1320,*30,EQEXIN,Z,BUF5,1,NEQEX)        
      CALL MESAGE (M8,0,NAM)        
   30 CALL CLOSE (EQEXIN,CLSREW)        
      ITABL= 1        
      KN   = NEQEX/2        
      ICC  = NEQEX        
      ILIST= NEQEX + 1        
C        
C     INITIALIZE FOR PROCESSING SPECIFIC REQUEST.        
C        
   40 IF (ISEQ-2) 50,60,70        
C        
C     LOAD VECTOR.        
C        
   50 IF (LOADS.EQ.0 .OR. APP(1).EQ.REI(1) .OR. APP(1).EQ.CEI(1) .OR.   
     1    APP(1).EQ.BK1(1)) GO TO 1180        
      INFIL = 115        
      OUTFL = OPG1        
      IREQ  = ILOADS        
      GO TO 90        
C        
C     SINGLE-POINT FORCES OF CONSTRAINT.        
C        
   60 IF (SPCF .EQ. 0) GO TO 1180        
      INFIL = QG        
      OUTFL = OQG1        
      IREQ  = ISPCF        
      GO TO 90        
C        
C     DISPLACEMENT VECTOR OR EIGENVECTOR        
C        
   70 IF (DISPL.NE.0 .OR. VEL.NE.0 .OR. ACC.NE.0 .OR. PLOTS.NE.0)       
     1    GO TO 80        
      GO TO 1180        
   80 INFIL = UGV        
      OUTFL = OUGV1        
      JTJ   = VEL + ACC        
      IF (.NOT.(APP(1).EQ.MMREIG .AND. DISPL.EQ.0 .AND. JTJ.NE.0))      
     1    GO TO 88        
      IF (VEL .EQ. 0) GO TO 84        
      IREQ = IVEL        
      GO TO 90        
   84 IREQ = IACC        
      GO TO 90        
   88 IREQ = IDISPL        
C        
C     READ TRAILER ON INPUT FILE. SET PARAMETERS.        
C        
   90 ICB(1) = INFIL        
      CALL RDTRL (ICB)        
      IF (ICB(1) .NE. INFIL) GO TO 1200        
      NVECTS = ICB(2)        
      IF (ICB(5) .GT. 2) GO TO 100        
C        
C     REAL VECTOR.        
C        
      KTYPE  = 1        
      QTYPE2 = 1        
      KTYPE1 = 2        
      NWDS   = 8        
      KTYPEX = 0        
      GO TO 110        
C        
C     COMPLEX VECTOR.        
C        
  100 KTYPE  = 2        
      QTYPE2 = 3        
      KTYPE1 = 3        
      NWDS   = 14        
      KTYPEX = 1000        
C        
C     OPEN CASE CONTROL AND SKIP HEADER. THEN BRANCH ON APPROACH.       
C        
  110 CALL GOPEN (CASECC,Z(BUF1),0)        
      PBUFF(2) = 1        
      GO TO (190,120,190,150,160,160,190,150,120,190), BRANCH        
C        
C     EIGENVALUES - READ LIST OF MODE NOS. AND EIGENVALUES INTO CORE.   
C        
  120 FILE = EIGR        
      CALL GOPEN (EIGR,Z(BUF2),0)        
      CALL SKPREC (EIGR,1)        
      IF (APP(1) .EQ. CEI(1)) PBUFF(2) = 5        
      IF (APP(1) .EQ. REI(1)) PBUFF(2) = 4        
      I = ILIST        
      M = 8 - KTYPE        
      ISKIP = 0        
      INDEX = 2        
      IF (APP(1) .NE. REI(1)) GO TO 130        
C        
C     CHECK TO SEE IF ALL GENERALIZED MASS VALUES ARE ZERO        
C        
  125 CALL READ (*1320,*127,EIGR,BUF,M,0,FLAG)        
      IF (BUF(6) .EQ. 0.0) GO TO 125        
      INDEX = 0        
  127 CALL SKPREC (EIGR,-1)        
  130 CALL READ (*1320,*140,EIGR,BUF,M,0,FLAG)        
      IF (APP(1) .NE. REI(1)) GO TO 135        
      IF (INDEX .EQ. 2) GO TO 135        
C        
C     MATCH CORRECT MODE NOS. AND EIGENVALUES WITH PROPER        
C     EIGENVECTORS WHEN USING GIVENS METHOD WITH F1.GT.0.0        
C        
      IF (INDEX  .EQ.  1) GO TO 135        
      IF (BUF(6) .NE. 0.) GO TO 133        
      ISKIP = ISKIP + 1        
      GO TO 130        
  133 INDEX = 1        
  135 Z(I  ) = BUF(1) - ISKIP        
      Z(I+1) = BUF(3)        
      Z(I+2) = BUF(4)        
      I = I + KTYPE1        
      GO TO 130        
  140 CALL CLOSE (EIGR,CLSREW)        
      NLIST = I - KTYPE1        
      ICC   = I        
      GO TO 190        
C        
C     DIFF. STIFF. PHASE 1 OR BUCKLING PHASE 1 - SKIP 1ST DATA RECORD ON
C     CC.        
C        
  150 CALL SKPREC (CASECC,1)        
      PBUFF(2) = 4        
      IF (APP(1) .EQ. BK1(1)) GO TO 120        
      PBUFF(2) = 1        
      GO TO 190        
C        
C     FREQUENCY OR TRANSIENT RESPONSE - READ LIST INTO CORE.        
C        
  160 FILE = PG        
      CALL OPEN (*1310,FILE,Z(BUF2),RDREW)        
      I  = ILIST        
      M  = 3        
      IX = 1        
      PBUFF(2) = 3        
      IF (APP(1) .EQ. FRQ(1)) PBUFF(2) = 2        
      IF (APP(1).EQ.FRQ(1) .OR. APP(1).EQ.TRN(1)) IX = 2        
  170 CALL READ (*1320,*180,FILE,BUF,M,0,FLAG)        
      Z(I  ) = BUF(M)        
      Z(I+1) = 0        
      I = I + IX        
      M = 1        
      GO TO 170        
  180 CALL CLOSE (FILE,CLSREW)        
      NLIST = I - IX        
      ICC   = I        
C        
C     OPEN OUTPUT FILE. WRITE HEADER RECORD.        
C        
  190 FILE   = OUTFL        
      ANYOUT = .FALSE.        
      CALL OPEN (*1200,OUTFL,Z(BUF2),WRTREW)        
      OCB(1) = OUTFL        
      CALL FNAME (OUTFL,BUF)        
      DO 200 I = 1,3        
  200 BUF(I+2) =  DATE(I)        
      BUF(6) = TIME        
      BUF(7) = 1        
      CALL WRITE (OUTFL,BUF,7,1)        
C        
C     OPEN INPUT FILE. SKIP HEADER RECORD.        
C        
      FILE   = INFIL        
      CALL OPEN (*1190,INFIL,Z(BUF3),RDREW)        
      CALL FWDREC (*1320,INFIL)        
C        
C     SET PARAMETERS TO KEEP CASE CONTROL AND VECTORS IN SYNCH.        
C        
      EOF    = 0        
      JCOUNT = 0        
      KCOUNT = 1        
      JLIST  = ILIST        
      KFRQ   = 0        
      INCORE = 0        
      KWDS   = 0        
C        
C     READ A RECORD IN CASE CONTROL. SET SYMMETRY FLAG.        
C        
  230 CALL READ (*1160,*240,CASECC,Z(ICC+1),BUF5-ICC,1,NCC)        
      CALL MESAGE (M8,0,NAM)        
  240 IX     = ICC + ISYMFL        
      ITEMP  = ICC + HARMS        
C        
C     OHARMS WILL BE 1 GREATER THAN THE MAXIMUM OUTPUT HARMONIC        
C        
      OHARMS = Z(ITEMP)        
      IF (OHARMS.LT.0 .AND. AXIF.NE.0) OHARMS = AXIF        
      IF (OHARMS .LT. 0) OHARMS = NHARMS        
C        
C     IF A FLUID PROBLEM CONVERT USER HARMONIC TO INTERNAL HARMONIC MAX.
C        
      IF (OHARMS .EQ. 0) GO TO 243        
      IF (AXIF   .EQ. 0) GO TO 243        
      OHARMS = OHARMS - 1        
      OHARMS = 2*OHARMS + 3        
  243 SYMFLG = Z(IX)        
      IF (SYMFLG .EQ. 0) SORC = Z(ICC+ISORC)        
      IF (SORC .EQ. 1) AXSINE = .TRUE.        
      IF (SORC .EQ. 2) AXCOSI = .TRUE.        
      IFLAG  = 0        
      IF (AXIC .AND. AXSINE .AND. AXCOSI .AND. JCOUNT.EQ.2) IFLAG = 1   
      IVEC   = ICC + NCC + 1        
C        
C     DETERMINE IF OUTPUT REQUEST IS PRESENT.        
C     IF NOT, TEST FOR RECORD SKIP ON INFIL  THEN GO TO END OF THIS     
C     REQUEST.        
C     IF SO, SET POINTERS TO SET DEFINING REQUEST.        
C        
  250 IREQX  = ICC + IREQ        
      SETNO  = Z(IREQX  )        
      DEST   = Z(IREQX+1)        
      FORMT  = IABS(Z(IREQX+2))        
      XSETNO = -1        
      IF (SETNO) 300,260,280        
  260 IF (SYMFLG .NE. 0) GO TO 1000        
      IF (APP(1) .NE. FRQ(1)) GO TO 270        
      IF (ISEQ  .EQ. 3) GO TO 300        
  270 IF (PLOTS .NE. 0) GO TO 300        
      CALL FWDREC (*1320,INFIL)        
      JCOUNT = JCOUNT + 1        
      GO TO 1000        
  280 IX     = ICC + ILSYM        
      ISETNO = IX + Z(IX) + 1        
  290 ISET   = ISETNO + 2        
      NSET   = Z(ISETNO+1) + ISET - 1        
      IF (Z(ISETNO) .EQ. SETNO) GO TO 295        
      ISETNO = NSET + 1        
      IF (ISETNO .LT. IVEC) GO TO 290        
      SETNO  = -1        
      GO TO 300        
C        
C     IF REQUIRED, LOCATE PRINT/PUNCH SUBSET.        
C        
  295 IF (SETNO .LT. XSET0) GO TO 300        
      XSETNO = DEST/10        
      DEST   = DEST - 10*XSETNO        
      IF (XSETNO .EQ. 0) GO TO 300        
      IXSETN = IX + Z(IX) + 1        
  296 IXSET  = IXSETN + 2        
      NXSET  = Z(IXSETN+1) + IXSET - 1        
      IF (Z(IXSETN) .EQ. XSETNO) GO TO 300        
      IXSETN = NXSET + 1        
      IF (IXSETN .LT. IVEC) GO TO 296        
      XSETNO = -1        
C        
C     UNPACK VECTOR INTO CORE (UNLESS VECTOR IS ALREADY IN CORE).       
C        
  300 IF (INCORE .NE. 0) GO TO 400        
      IVECN = IVEC + KTYPE*ICB(3) - 1        
      IF (IVECN  .GE. BUF5) CALL MESAGE (M8,0,NAM)        
      IF (SYMFLG .EQ. 0) GO TO 360        
C        
C     SYMMETRY SEQUENCE - BUILD VECTOR IN CORE.        
C        
      IX   = ICC + ILSYM        
      LSYM = Z(IX)        
C        
C     IF SYMFLG IS NEGATIVE THIS IS A REPEAT SUBCASE. BCKREC VECTOR     
C     AND READ IT INTO CORE.        
C        
      IF (SYMFLG.LT.0 .AND. APP(1).EQ.STA(1)) GO TO 358        
      IF (SYMFLG .LT. 0) GO TO 230        
      DO 310 I = IVEC,IVECN        
  310 ZZ(I) = 0.        
      DO 320 I = 1,LSYM        
  320 CALL BCKREC (INFIL)        
      ISYMN = IX + LSYM        
      I = IX + 1        
  330 COEF = ZZ(I)        
      CALL INTPK (*350,INFIL,0,QTYPE2,0)        
  340 CALL ZNTPKI        
      IX = IVEC + IXX - 1        
      ZZ(IX) = ZZ(IX) + COEF*XX(1)        
      IF (KTYPE .EQ. 2) ZZ(IX+1) = ZZ(IX+1) + COEF*XX(2)        
      IF (EOL .EQ. 0) GO TO 340        
  350 I = I + 1        
      IF (I .LE. ISYMN) GO TO 330        
      GO TO 400        
C        
C     REPEAT SUBCASE        
C        
  358 JCOUNT = JCOUNT - 1        
      CALL BCKREC (INFIL)        
C        
C     NOT SYMMETRY - UNPACK VECTOR.        
C        
  360 J2= ICB(3)        
      IF (JCOUNT .GE. NVECTS) GO TO 1170        
      CALL UNPACK (*370,INFIL,Z(IVEC))        
      GO TO 390        
  370 DO 380 I = IVEC,IVECN        
  380 ZZ(I)  = 0.        
  390 JCOUNT = JCOUNT + 1        
C        
C     TEST FOR CONTINUATION FROM HERE.        
C        
  400 IF (SETNO .NE. 0) GO TO 410        
      IF (APP(1) .EQ. FRQ(1)) GO TO 1040        
C        
C     PREPARE TO WRITE ID RECORD ON OUTPUT FILE.        
C        
  410 GO TO (420,430,420,420,440,560,420,430,430,420), BRANCH        
C        
C     NORMAL STATICS OR DIFF.STIFF. PHASE O OR 1 OR BUCKLING PHASE 0.   
C        
  420 BUF(2) = DTYPE(ISEQ)        
      IX = ICC + ISLOAD        
      BUF(5) = Z(ICC+1)        
      BUF(6) = 0        
      BUF(7) = 0        
      BUF(8) = Z(IX)        
      PBUFF(2) = 1        
      PBUFF(3) = Z(IX)        
      PBUFF(4) = 0        
      IF (BRANCH .NE. 10) GO TO 610        
      IX = ICC + ITTL + 84        
      Z(IX  ) = PLATIT(1)        
      Z(IX+1) = PLATIT(2)        
      Z(IX+2) = PLATIT(3)        
      CALL INT2AL (JCOUNT,Z(IX+3),PLATIT(4))        
      GO TO 610        
C        
C     EIGENVALUES OR BUCKLING PHASE 1.        
C        
  430 IF (ISEQ .EQ. 2) BUF(2) = KTYPEX + 3        
      IF (ISEQ .EQ. 3) BUF(2) = KTYPEX + 7        
      BUF(5) = Z(JLIST  )        
      BUF(6) = Z(JLIST+1)        
      BUF(7) = Z(JLIST+2)        
      BUF(8) = 0        
C     PBUFF(2) = 2  THIS CARD WAS REMOVED SINCE LEVEL 16. NO LONGER NEED
      PBUFF(3) = BUF(5)        
      IF (APP(1) .EQ. BK1(1)) PBUFF(3) = -BUF(5)        
      PBUFF(4) = BUF(6)        
      IF (APP(1).NE.BK1(1) .AND. APP(1).NE.CEI(1))        
     1   PBUFR(4) = SQRT(ABS(BUFR(6)))/TWOPI        
      IF (APP(1) .EQ. CEI(1)) PBUFR(4) = ABS(BUFR(7))/TWOPI        
      GO TO 610        
C        
C     FREQUENCY RESPONSE.        
C        
  440 IX = ICC + IDLOAD        
      BUF(8) = Z(IX)        
      BUF(6) = 0        
      BUF(7) = 0        
      PBUFF(2) = 2        
      PBUFF(3) = BUF(8)        
      IF (ISEQ .EQ. 3) GO TO 520        
      BUF(2) = DTYPE(ISEQ) + KTYPEX        
      GO TO 441        
  520 IF (KCOUNT-2) 530,540,550        
  530 BUF(2) = 1001        
      GO TO 441        
  540 BUF(2) = 1010        
      GO TO 441        
  550 BUF(2) = 1011        
      GO TO 441        
  441 CONTINUE        
      IF (KFRQ .NE. 0) GO TO 510        
C        
C     FIRST TIME FOR THIS LOAD VECTOR ONLY - MATCH LIST OF USER        
C     REQUESTED FREQS WITH ACTUAL FREQS. MARK FOR OUTPUT EACH ACTUAL    
C     FREQ WHICH IS CLOSEST TO USER REQUEST.        
C        
      KFRQ   = 1        
      IX     = ICC + IFROUT        
      FSETNO = Z(IX)        
      IF (FSETNO .LE. 0) GO TO 460        
      IX     = ICC + ILSYM        
      ISETNF = IX  + Z(IX) + 1        
  450 ISETF  = ISETNF + 2        
      NSETF  = Z(ISETNF+1) + ISETF - 1        
      IF(Z(ISETNF) .EQ. FSETNO) GO TO 480        
      ISETNF = NSETF + 1        
      IF (ISETNF .LT. IVEC) GO TO 450        
      FSETNO = -1        
  460 DO 470 J = ILIST,NLIST,2        
  470 Z(J+1) = 1        
      GO TO 510        
  480 DO 500 I = ISETF,NSETF        
      K    = 0        
      DIFF = 1.E25        
      BUFR(1) = ZZ(I)        
      DO 490 J = ILIST,NLIST,2        
      IF (Z(J+1) .NE. 0) GO TO 490        
      DIFF1 = ABS(ZZ(J)-BUFR(1))        
      IF (DIFF1 .GE. DIFF) GO TO 490        
      DIFF = DIFF1        
      K = J        
  490 CONTINUE        
      IF (K .NE. 0) Z(K+1) = 1        
  500 CONTINUE        
C        
C     DETERMINE IF CURRENT FREQ IS MARKED FOR OUTPUT.        
C        
  510 IF (Z(JLIST+1) .EQ. 0) GO TO 1000        
      BUF(5)   = Z(JLIST)        
      PBUFF(4) = BUF(5)        
      GO TO 610        
C        
C     TRANSIENT RESPONSE.        
C        
  560 BUF(5) = Z(JLIST)        
      IF (KCOUNT - 2) 570,580,590        
  570 BUF(2) = 1        
      GO TO 600        
  580 BUF(2) = 10        
      GO TO 600        
  590 BUF(2) = 11        
  600 IF (IREQ .EQ. ILOADS) BUF(2) = 2        
      IF (IREQ .EQ. ISPCF ) BUF(2) = 3        
      IX = ICC + IDLOAD        
      BUF(8) = Z(IX)        
      BUF(6) = 0        
      BUF(7) = 0        
      PBUFF(2) = 3 + 10*(KCOUNT-1)        
      PBUFF(3) = BUF(8)        
      PBUFF(4) = BUF(5)        
      GO TO 441        
C        
C     WRITE ID RECORD ON OUTPUT FILE.        
C        
  610 IF (SETNO.EQ.0 .AND. PLOTS.NE.0) GO TO 880        
      BUF(1) = DEST + 10*BRANCH        
      BUF(3) = 0        
C        
C     IF CONICAL SHELL PROBLEM, SET MINOR ID = 1000 FOR USE BY OFP      
C        
      IF (AXIC) BUF(3) = 1000        
      BUF(4) = Z(ICC+1)        
      IF (DDRMM) BUF(4) = 9999        
      BUF(9) = IABS(Z(IREQX+2))        
      IF (BUF(9).EQ.1 .AND. KTYPE.EQ.2) BUF(9) = 2        
      FORMT  = BUF(9)        
      BUF(10)= NWDS        
      CALL WRITE (OUTFL,BUF,50,0)        
      IX = ICC + ITTL        
      CALL WRITE (OUTFL,Z(IX),96,1)        
C        
C     BUILD DATA RECORD ON OUTPUT FILE.        
C        
      IF (SETNO .NE. -1) GO TO 650        
C        
C     SET .EQ. ALL  -  OUTPUT ALL POINTS DEFINED IN EQEXIN.        
C        
      KX = 1        
      N  = NEQEX - 1        
      ASSIGN 640 TO RETX        
      GO TO 700        
  640 KX = KX + 2        
      IF (KX .LE. N) GO TO 700        
      GO TO 880        
C        
C     SET .NE. ALL  -  OUTPUT ONLY POINTS DEFINED IN SET.        
C        
  650 JHARM = 0        
  651 I = ISET        
  660 IF (I   .EQ. NSET) GO TO 680        
      IF (Z(I+1) .GT. 0) GO TO 680        
      N = -Z(I+1)        
      BUF(1) = Z(I)        
      IBUFSV = BUF(1)        
      I = I + 1        
      ASSIGN 670 TO RETX        
      GO TO 1210        
  670 BUF(1) = IBUFSV + 1        
      IBUFSV = BUF(1)        
      IF (BUF(1) .LE. N) GO TO 1210        
      GO TO 690        
  680 BUF(1) = Z(I)        
      ASSIGN 690 TO RETX        
      GO TO 1210        
  690 I = I + 1        
      IF (I .LE. NSET) GO TO 660        
      JHARM = JHARM + 1        
      IF (.NOT.AXIC .AND. AXIF.EQ.0) GO TO 880        
      IF (JHARM .LE. OHARMS) GO TO 651        
      GO TO 880        
C        
C     PICK UP POINTER TO GRID POINT DATA AND GRID POINT TYPE.        
C        
  700 BUF(1) = Z(KX)        
      IF (IFLAG.EQ.1 .AND. BUF(1).GE.1000000) GO TO RETX, (640,670,690) 
      J = Z(KX+1)/10        
      BUF(2) = Z(KX+1) - 10*J        
      J = IVEC + KTYPE*(J-1)        
      IF (BUF(2) .EQ. 1) GO TO 770        
C        
C     SCALAR OR EXTRA POINT.        
C        
      BUF(3) = Z(J)        
      IF (KTYPE .EQ. 2) GO TO 720        
      IF (ISEQ.LE.2 .AND. BUFR(3).EQ.0.0 .AND. SORT2.LT.0)        
     1    GO TO RETX, (640,670,690)        
      DO 710 K = 4,8        
  710 BUF(K) = 0        
      GO TO 840        
C        
C     COMPLEX SCALAR OR EXTRA POINT.        
C        
  720 BUF(4) = Z(J+1)        
      IF (ISEQ.LE.2 .AND. BUFR(3).EQ.0.0 .AND. BUFR(4).EQ.0.0 .AND.     
     1    SORT2.LT.0) GO TO RETX, (640,670,690)        
      DO 730 K = 5,14        
  730 BUF(K) = 0        
      IF (FORMT .NE. 3) GO TO 840        
      REDNER = SQRT(BUFR(3)**2 + BUFR(4)**2)        
      IF (REDNER) 750,740,750        
  740 BUFR(4) = 0.0        
      GO TO 760        
  750 BUFR(4) = ATAN2(BUFR(4),BUFR(3))*RADDEG        
      IF (BUFR(4) .LT. -0.00005) BUFR(4) = BUFR(4) + 360.0        
  760 BUFR(3) = REDNER        
      GO TO 840        
C        
C     GRID POINT.        
C        
  770 FLAG = 0        
      IF (KTYPE .EQ. 2) GO TO 790        
      DO 780 K = 1,6        
      BUFR(K+2) = ZZ(J)        
      IF (BUFR(K+2).NE.0.0 .OR. SORT2.GE.0) FLAG = 1        
  780 J = J + 1        
      IF (ISEQ.LE.2 .AND. FLAG.EQ.0) GO TO RETX, (640,670,690)        
      GO TO 840        
C        
C     COMPLEX GRID POINT.        
C        
  790 DO 830 K = 1,11,2        
      BUFR(K+2) = ZZ(J  )        
      BUFR(K+3) = ZZ(J+1)        
      IF (BUFR(K+2).NE.0. .OR. BUFR(K+3).NE.0. .OR. SORT2.GE.0) FLAG = 1
      IF (FORMT .NE. 3) GO TO 830        
      REDNER = SQRT(BUFR(K+2)**2 + BUFR(K+3)**2)        
      IF (REDNER) 810,800,810        
  800 BUFR(K+3) = 0.0        
      GO TO 820        
  810 BUFR(K+3) = ATAN2( BUFR(K+3),BUFR(K+2) )*RADDEG        
      IF (BUFR(K+3) .LT. -0.00005) BUFR(K+3) = BUFR(K+3) + 360.0        
  820 BUFR(K+2) = REDNER        
  830 J = J + 2        
      IF (ISEQ.LE.2 .AND. FLAG.EQ.0) GO TO RETX, (640,670,690)        
C        
C     WRITE ENTRY ON OUTPUT FILE.        
C        
C     IF COMPLEX  TRANSPOSE DATA FOR OFP (REAL TOP, IMAG BOTTOM)        
C        
  840 IF (NWDS .NE. 14) GO TO 850        
      ITEMP   = BUF( 4)        
      BUF( 4) = BUF( 5)        
      BUF( 5) = BUF( 7)        
      BUF( 7) = BUF(11)        
      BUF(11) = BUF( 8)        
      BUF( 8) = BUF(13)        
      BUF(13) = BUF(12)        
      BUF(12) = BUF(10)        
      BUF(10) = BUF( 6)        
      BUF( 6) = BUF( 9)        
      BUF( 9) = ITEMP        
C        
  850 ANYOUT = .TRUE.        
C        
C     IF CONICAL SHELL DECODE GRID POINT NUMBER IF GREATER THAN 1000000.
C        
      IF (.NOT.AXIC) GO TO 870        
      IF (BUF(1) .GE. 1000000) GO TO 860        
      BUF(2) = BLANKS        
      GO TO 870        
  860 ITEMP = BUF(1)/1000000        
C        
C     STOP OUTPUT WHEN PRESENT HARMONIC EXCEEDS OUTPUT HARMONIC SIZE REQ
C        
      IF (ITEMP .GT. OHARMS) GO TO 880        
      BUF(1) = BUF(1) - ITEMP*1000000        
      BUF(2) = ITEMP - 1        
      GO TO 876        
C        
C     IF A FLUID PROBLEM THEN A CHECK IS MADE ON THE HARMONIC ID        
C        
  870 IF (AXIF) 876,876,861        
  861 IF (BUF(1) .LT. 500000) GO TO 876        
      ITEMP = BUF(1) - MOD(BUF(1),500000)        
      ITEMP = ITEMP/500000        
C        
C     STOP THE OUTPUT IF THE HARMONIC IS GREATER THAN THE OUTPUT        
C     REQUEST FOR HARMONICS        
C        
      IF (ITEMP .GE. OHARMS) GO TO 880        
C        
C     DETERMINE DESTINATION FOR ENTRY.        
C        
  876 ID = BUF(1)        
      BUF(1) = 10*ID + DEST        
      IF (XSETNO) 878,871,872        
  871 BUF(1) = 10*ID        
      GO TO 878        
  872 IX = IXSET        
  873 IF (IX .EQ.  NXSET) GO TO 874        
      IF (Z(IX+1) .GT. 0) GO TO 874        
      IF (ID.GE.Z(IX) .AND. ID.LE.-Z(IX+1)) GO TO 878        
      IX = IX + 2        
      GO TO 875        
  874 IF (ID .EQ. Z(IX)) GO TO 878        
      IX = IX + 1        
  875 IF (IX .LE. NXSET) GO TO 873        
      GO TO 871        
C        
C     NOW WRITE ENTRY.        
C        
  878 CALL WRITE (OUTFL,BUF(1),NWDS,0)        
      BUF(1) = ID        
      KWDS = KWDS + NWDS        
      GO TO RETX, (640,670,690)        
C        
C     IF PLOTS ARE REQUESTED, READ THE CSTM INTO CORE.        
C     IF FIRST VECTOR, OPEN PUGV1 AND WRITE HEADER RECORD.        
C        
  880 CONTINUE        
      EXTRA = 0        
      IF (ISEQ.NE.3 .OR. PLOTS.EQ.0 .OR. (KCOUNT.NE.1 .AND.        
     1    APP(1).NE.TRN(1))) GO TO 990        
      IF (SYMFLG .LT. 0) GO TO 990        
      FILE = CSTM        
      CALL OPEN (*900,CSTM,Z(BUF5),RDREW)        
      CALL FWDREC (*1320,CSTM)        
      ICSTM = IVECN + 1        
      CALL READ (*1320,*890,CSTM,Z(ICSTM),BUF5-ICSTM,1,NCSTM)        
      CALL MESAGE (M8,0,NAM)        
  890 CALL CLOSE (CSTM,CLSREW)        
      CALL PRETRS (Z(ICSTM),NCSTM)        
  900 IF (JCOUNT .NE. 1) GO TO 902        
      CALL MAKMCB (MCB,PUGV1,J2,2,QTYPE2)        
      FILE = PUGV1        
      CALL OPEN (*902,PUGV1,Z(BUF4),WRTREW)        
      KPLOT = 1        
      CALL FNAME (PUGV1,BUF)        
      CALL WRITE (PUGV1,BUF,2,1)        
C        
C     IF PLOT FILE IS PURGED, NO PLOT FILE CAN BE PREPARED.        
C     IF TRANSIENT PROBLEM, REMOVE EXTRA POINTS FROM VECTOR        
C     NOW IN CORE THUS CREATING A G-SET VECTOR.        
C        
  902 EXTRA = 0        
      IF (KPLOT .EQ. 0) GO TO 990        
      IF (APP(1).NE.TRN(1) .AND. APP(1).NE.FRQ(1) .AND. APP(1).NE.CEI(1)
     1   ) GO TO 910        
      DO 903 I = 1,NEQEX,2        
      J = Z(I+1)/10        
      K = Z(I+1) - 10*J        
      IF (K .NE. 3) GO TO 903        
      EXTRA = 1        
      J = KTYPE*J + IVEC - KTYPE        
      Z(J) = 1        
      IF (KTYPE .EQ. 2) Z(J+1) = 1        
  903 CONTINUE        
      IF (EXTRA .EQ. 0) GO TO 910        
      J = IVEC        
      DO 905 I = IVEC,IVECN        
      IF (Z(I) .EQ. 1) GO TO 905        
      Z(J) = Z(I)        
      J = J + 1        
  905 CONTINUE        
      IVECN = J - 1        
C        
C     PASS THE BGPDT. FOR EACH ENTRY, ROTATE THE TRANSLATION COMPONENTS 
C     OF UGV TO BASIC (IF REQUIRED). WRITE THESE COMPONENTS ON PUGV1.   
C        
  910 FILE = BGPDT        
      CALL OPEN (*990,BGPDT,Z(BUF5),RDREW)        
      CALL FWDREC (*1320,BGPDT)        
      K = 0        
      I = IVEC        
      PBUFF(1) = Z(ICC+1)        
      CALL WRITE (PUGV1,PBUFF,4,1)        
      L = 3*KTYPE        
      CALL BLDPK (QTYPE2,QTYPE2,PUGV1,0,0)        
  920 CALL READ (*1320,*980,BGPDT,BUF(7),4,0,FLAG)        
      ITEMP = 0        
      DO 925 J = 1,L        
      LL = I + J - 1        
  925 BUFR(J) = ZZ(LL)        
      IF (BUF(7)) 950,940,930        
C        
C     TRANSFORM TO BASIC        
C        
  930 IF (QTYPE2 .EQ. 1) GO TO 935        
      J = BUF(2)        
      BUF(2) = BUF(3)        
      BUF(3) = BUF(5)        
      BUF(5) = BUF(4)        
      BUF(4) = J        
  935 ITEMP  = 19        
      CALL TRANSS (BUFR(7),BUFR(11))        
      CALL GMMATS (BUFR(11),3,3,0,BUFR(1),3,1,0,BUF(ITEMP+1))        
      IF (QTYPE2 .EQ. 1) GO TO 940        
      CALL GMMATS (BUFR(11),3,3,0,BUFR(4),3,1,0,BUF(ITEMP+4))        
      J       = BUF(21)        
      BUF(21) = BUF(23)        
      BUF(23) = BUF(24)        
      BUF(24) = BUF(22)        
      BUF(22) = J        
  940 IY = (I-IVEC+K)/KTYPE        
      DO 945 J = 1,L,KTYPE        
      IY = IY + 1        
      LL = ITEMP + J        
      Y(1) = BUFR(LL)        
      IF (KTYPE .EQ. 2) Y(2) = BUFR(LL+1)        
      CALL ZBLPKI        
  945 CONTINUE        
      I = I + 6*KTYPE        
      GO TO 920        
C        
C     CHECK FOR FLUID POINTS        
C        
  950 I = I + KTYPE        
      IF (BUF(7) .NE. -2) GO TO 920        
      IY = (I-IVEC+K)/KTYPE + 2        
      Y(1) = BUFR(1)        
      IF (QTYPE2 .EQ. 3) Y(2) = BUFR(2)        
      CALL ZBLPKI        
      K = K + 5*KTYPE        
      GO TO 920        
  980 CALL BLDPKN (PUGV1,0,MCB)        
      CALL CLOSE (BGPDT,CLSREW)        
C        
C     CONCLUDE PROCESSING OF THIS VECTOR.        
C        
  990 IF (SETNO .NE. 0) CALL WRITE (OUTFL,0,0,1)        
 1000 GO TO (1010,1020,1170,1020,1040,1110,1170,1020,1020,1020), BRANCH 
C        
C     NORMAL STATICS.        
C        
 1010 IF (JCOUNT .LT. NVECTS) GO TO 230        
      IF (EOF .EQ. 0) GO TO 230        
      GO TO 1170        
C        
C     EIGENVALUES OR DIFF. STIFF PHASE1 OR BUCKLING PHASE 1.        
C        
 1020 JLIST = JLIST + KTYPE1        
 1030 IF (JCOUNT .GE. NVECTS) GO TO 1170        
      IF (EOF .EQ. 0) GO TO 230        
      GO TO 250        
C        
C     FREQUENCY RESPONSE.        
C        
 1040 IF (ISEQ   .LE. 2) GO TO 1090        
      IF (KCOUNT .EQ. 3) GO TO 1080        
      N = IVECN - 1        
      IF (EXTRA .EQ. 0) GO TO 1045        
      CALL BCKREC (INFIL)        
      CALL UNPACK (*1041,INFIL,Z(IVEC))        
      GO TO 1045        
 1041 DO 1042 I = IVEC,N        
 1042 ZZ(I) = 0.0        
      GO TO 1055        
 1045 CONTINUE        
      OMEGA = TWOPI*ZZ(JLIST)        
      DO 1050 I = IVEC,N,2        
      BUFR(1) = -OMEGA*ZZ(I+1)        
      ZZ(I+1) =  OMEGA*ZZ(I  )        
 1050 ZZ(I  ) =  BUFR(1)        
 1055 IF (KCOUNT .EQ. 2) GO TO 1060        
      IREQ   = IVEL        
      GO TO 1070        
 1060 IREQ   = IACC        
 1070 KCOUNT = KCOUNT + 1        
      INCORE = 1        
      GO TO 250        
 1080 KCOUNT = 1        
      IREQ   = IDISPL        
 1090 INCORE = 0        
      JLIST  = JLIST + 2        
      IF (JLIST.LE.NLIST .AND. JCOUNT.LT.NVECTS) GO TO 250        
      KFRQ   = 0        
      JLIST  = ILIST        
      DO 1100 I = ILIST,NLIST,2        
 1100 Z(I+1) = 0        
      IF (JCOUNT .LT. NVECTS) GO TO 230        
      GO TO 1170        
C        
C     TRANSIENT RESPONSE.        
C        
 1110 IF (ISEQ .LE. 2) GO TO 1150        
      IF (KCOUNT - 2) 1120,1130,1140        
 1120 IREQ   = IVEL        
      KCOUNT = 2        
      GO TO 250        
 1130 IREQ   = IACC        
      KCOUNT = 3        
      GO TO 250        
 1140 IREQ   = IDISPL        
      KCOUNT = 1        
 1150 JLIST  = JLIST + 2        
      IF (JLIST.LE.NLIST .AND. JCOUNT.LT.NVECTS) GO TO 250        
      GO TO 1170        
C        
C     HERE WHEN END-OF-FILE ENCOUNTERED ON CASE CONTROL.        
C        
 1160 EOF = 1        
      GO TO (1170,1030,1170,1030,1170,1170,1170,1030,1030,1030), BRANCH 
C        
C     CONCLUDE PROCESSING OF CURRENT INPUT FILE.        
C        
 1170 CALL CLOSE (CASECC,CLSREW)        
      CALL CLOSE (INFIL ,CLSREW)        
      CALL CLOSE (OUTFL ,CLSREW)        
      IF (KPLOT .NE. 0) CALL CLOSE (PUGV1,CLSREW)        
      IF (KPLOT .NE. 0) CALL WRTTRL (MCB)        
      OCB(2) = KWDS/65536        
      OCB(3) = KWDS - 65536*OCB(2)        
      IF (.NOT.ANYOUT) GO TO 1180        
      CALL WRTTRL (OCB)        
C        
C     TEST FOR ALL INPUT FILES PROCESSED.        
C        
 1180 ISEQ = ISEQ + 1        
      IF (ISEQ .LE. 3) GO TO 40        
      CALL CLOSE (CASECC,CLSREW)        
      RETURN        
C        
C     HERE IF ABNORMAL CONDITION.        
C     CLOSE ALL FILES, JUST TO BE SURE        
C        
 1190 CALL CLOSE (OUTFL ,CLSREW)        
 1200 CALL CLOSE (INFIL ,CLSREW)        
      CALL CLOSE (CASECC,CLSREW)        
      IX = ISEQ + 75        
      CALL MESAGE (30,IX,0)        
      GO TO 1180        
C        
C     BINARY SEARCH ROUTINE.        
C     =====================        
C        
 1210 KLO = 1        
      KHI = KN        
      IF (AXIC) BUF(1) = JHARM*1000000 + BUF(1)        
      IF (AXIF) 1220,1220,1213        
 1213 BUF(1) = JHARM*500000 + BUF(1)        
 1220 K  = (KLO+KHI+1)/2        
 1230 KX = 2*K - 1        
      IF (BUF(1)-Z(KX)) 1240,700,1250        
 1240 KHI = K        
      GO TO 1260        
 1250 KLO = K        
 1260 IF (KHI-KLO-1) 1300,1270,1220        
 1270 IF (K .EQ. KLO) GO TO 1280        
      K = KLO        
      GO TO 1290        
 1280 K = KHI        
 1290 KLO = KHI        
      GO TO 1230        
 1300 GO TO RETX, (640,670,690)        
C        
C     FATAL FILE ERRORS        
C        
 1310 N = -1        
      GO TO 1330        
 1320 N = -2        
      GO TO 1330        
 1330 CALL MESAGE (N,FILE,NAM)        
      GO TO 1330        
      END        
