      SUBROUTINE MPY4T (IZ,Z,DZ)        
C        
C     INNER LOOP FOR MPYAD, METHOD 4 WITH TRANSPOSE        
C        
C          T        
C         A * B + C = D        
C        
C     THIS ROUTINE IS CALLED ONLY BY MPYAD WHEN METHOD 2 TRANSPOSE,     
C     MPY2T, IS SELECTED, AND DIAG 41 IS NOT TURNED ON BY USER.        
C        
C     MPY4T IS ABOUT 5 TIMES FASTER THAN MPY2T AS TESTED ON VAX        
C        
C     THERE IS A PICTORIAL DISCRIPTION ABOUT MPY4T IN MPYAD SUBROUTINE  
C        
C     THIS MACHINE INDEPENDENT ROUTINE CAN ACTUALLY BE INCORPORATED     
C     INTO MPYQ, WHICH IS PRESENTLY A .MDS ROUTINE        
C        
C     IF MATRIX A, OR B, OR BOTH,  IS COMPLEX, MATRIX D IS COMPLEX.     
C     MATRIX D CAN NOT BE COMPLEX, IF BOTH MATRICES A AND B ARE REAL.   
C        
C        
C     WRITTEN BY G.CHAN/UNISYS   1/92        
C        
      IMPLICIT INTEGER (A-Z)        
      REAL             Z(1)    ,SUMR    ,SUMI        
      DOUBLE PRECISION DZ(1)   ,DSUMR   ,DSUMI   ,DZERO        
      DIMENSION        IZ(1)   ,NAM(2)        
      COMMON /MPYADX/  FILEA(7),FILEB(7),FILEC(7),FILED(7)        
      COMMON /TYPE  /  PRC(2)  ,NWDS(4) ,RC(4)        
      COMMON /MACHIN/  MACH    ,IHALF   ,JHALF        
      COMMON /UNPAKX/  TYP     ,II      ,JJ        
      COMMON /MPYADZ/  RCB     ,RCD     ,LL      ,LLL     ,JBB   ,      
     1                 NBX(3)  ,AROW    ,AROW1   ,AROWN   ,ACORE ,      
     2                 APOINT  ,BCOL    ,CROW    ,FIRSTL  ,NA(3) ,      
     3                 NWDA        
      COMMON /MPYQT4/  RCA     ,PRCA    ,ALL     ,JUMP    ,PRCD        
      EQUIVALENCE      (DSUMR  ,SUMR  ) ,(DSUMI  ,SUMI)        
      DATA    NAM   /  4HMPY4  ,1HT   / ,DZERO   / 0.0D+0 /        
C        
C*****        
C     ANDF(I,J)   = IAND(I,J)        
C     RSHIFT(I,J) = ISHFT(I,-J)        
C     WHERE         ISHFT(I,-J) IS RIGHT-SHIFT I BY J BITS, ZERO FILL   
C     AND           ISHFT IS SYSTEM ROUTINE        
C        
C UNIX:        
C     REMOVE ABOVE 2 ON-LINE FUNCTIONS IF IAND AND ISHFT SYSTEM        
C     FUNCTIONS ARE NOT AVAILABLE. ANDF AND RSHIFT ARE ALREADY ENTRY    
C     POINTS IN SUBROUTINE MAPFNS.        
C*****        
C        
C     METHOD 4T TRANSPOSE CASE        
C        
C     ARRAY Z(JBB) THRU Z(ACORE-1) HOLDS THE CURRENT COLUMN OF MATRIX B 
C     ARRAY Z(1) THRU Z(JBB-1) IS A WORKING COLUMN SPACE FOR MATRIX D   
C        
C     ON EACH ROW OF A, WE WANT TO MULTIPLY        
C        
C        A(ROW,J)*B(J,COL) + C(ROW,COL) = D(ROW,COL)        
C        
C     NOTICE B(J,COL) RUNS FROM B(II,COL) THRU B(JJ,COL) WITHOUT        
C     SKIPPING,        
C     WHILE A(ROW,J) RUNS IN MULTIPLE STRING SEGMENTS ALONG J.        
C     ALSO THE BEGINING OF J IN A(ROW,J) AND THE BEGINING OF J IN       
C     B(J,COL) MOST LIKELY START DIFFERNTLY        
C        
C     NOW, ON EACH ROW, WE START FROM FIRST STRING. SKIP THIS STRING    
C     IF IT IS NOT WITHIN B(II,) AND B(JJ,) RANGE. (ALSO, WE HAVE       
C     SAVED PREVIOUSLY THE LAST TERM OF THE LAST STRING, AND THEREFORE  
C     IF THE WHOLE ROW OF A(,J) WITH ITS STRINGS IS NOT WITHIN II,JJ    
C     RANGE OF COLUMN B, WE SKIP THE WHOLE ROW-AND-COLUMN COMPUTATION.) 
C     IF IT IS WITHIN THE RANGE, WE NEED TO SYNCHRONIZE THE J INDEX FOR 
C     BOTH A(ROW,J) AND B(J,COL), THEN MULTIPLY, AND SUM ON AN ELEMENT  
C     OF MATRIX D. THEN MOVE ON TO THE NEXT STRING, AND DO THE SAME.    
C     REPEAT THIS PROCESS UNTIL J IS EXHAUST EITHER ON A(ROW,J) OR ON   
C     B(J,COL).        
C     WHEN ALL ROWS OF MATRIX A CURRENTLY IN CORE HAVE PASSED THRU, WE  
C     HAVE ONE COLUMN OF MATRIX D DONE, FROM AROW1 THRU AROWN.        
C        
C     SINCE TRANSPOSE OF MATRIX A IS WHAT WE WANT, THE TERM 'ROW' IS    
C     ACTUALLY 'COLUMN' WHEN THE DATA WAS MOVED INTO Z SPACE IN MPYAD   
C        
C     RCA,RCB    = 1, MATRIX A,B  IS REAL, = 2 MATRIX A,B IS COMPLEX    
C     PRCA       = 1, MATRIX A IS IN S.P., = 2 MATRIX A IS IN D.P.      
C     PRCD       = 0, MATRIX D IS IN S.P., = 1 MATRIX A IS IN D.P.      
C     NWDA       = NUMBER OF WORDS PER ELEMENT OF MATRIX A        
C     JBB        = POINTER TO FIRST WORD OF COLUMN B        
C     II,JJ      = FIRST TO LAST NON-ZERO TERMS IN CURRENT COLUMN OF B  
C     ALL        = 1,2,3,4 ALL MATRICES ARE OF THE SAME TYPE - S.P.,    
C                  D.P., C.S.P., OR C.D.P. RESPECTIVELY        
C                = 5, MATRICES ARE OF MIXED TYPES        
C     JUMP       = BRANCHING INDEX TO MIXED TYPE MATRICES COMPUTATION.  
C        
C     APOINT     = POINTER TO STRING CONTROL WORD        
C                = 0, CURRENT ROW OF A IS EXHAULTED        
C     IZ(APOINT) = LEFT HALF OF WORD IS NBR, RIGHT HALF IS NBRSTR       
C     NBR        = NO. OF WORDS   IN THIS STRING        
C     NBRSTR     = NO. OF STRINGS IN THIS ROW A        
C     INIT       = COLUMN POSITION OF 1ST STRING WORD        
C     IF (INIT .GT. JJ) = 1ST STRING WORD IS BEYOND LAST WORD IN COLN B 
C     IF (INIT+NBR .LT. II) = LAST STRING WORD IS BEFORE 1ST WORD IN    
C                  COLUMN OF B        
C     JB,JE      = BEGINNING AND ENDING J-INDEX FOR COLUMN A AND ROW B  
C     IPOINT     = THE JB WORD POSITION IN ROW A        
C     JA         = POINTER TO ROW A ELEMENT        
C     KB         = POINTER TO COLUMN B ELEMENT        
C     LAST       = POSITION OF LAST NON-ZERO COLUMN TERM IN ROW OF A    
C        
C        
C     WE START FROM FIRST ROW AROW1, AND WILL RUN THRU TO LAST ROW AROWN
C        
      AROW = AROW1        
      L    = FIRSTL        
   10 APOINT = IZ(L)        
      IF (APOINT .EQ. 0) GO TO 510        
      LAST = RSHIFT(IZ(L-1),IHALF)        
      INIT = ANDF(IZ(APOINT),JHALF)        
      IF (INIT.GT.JJ .OR. LAST.LT.II) GO TO 510        
      NBRSTR = ANDF(IZ(L-1),JHALF)        
      GO TO 30        
   20 INIT = ANDF(IZ(APOINT),JHALF)        
   30 NBR  = RSHIFT(IZ(APOINT),IHALF)        
      IF (INIT .GT. JJ) GO TO 510        
      IF (INIT+NBR .LT. II) GO TO 500        
      JB   = MAX0(INIT,II)        
      JE   = MIN0(INIT+NBR-1,JJ)        
      IF (JB .GT. JE) GO TO 500        
C     ICOL = (JB-1)*RCD + 1        
C     NCOL = JE*RCD        
      IPOINT = APOINT + (JB-INIT+1)*PRCA        
      JA   = (IPOINT-1)/PRCA + 1        
      KB   = (JB-II)*RCB + JBB        
      DSUMR= DZERO        
      GO TO (40,60,80,100,120,520), ALL        
C        
   40 DO 50 J = JB,JE        
      SUMR = SUMR + Z(JA)*Z(KB)        
C            SUMMING   A * B        
C        
C     DON'T BE SUPRISED TO SEE SOME Z(JA) ARE ZEROS        
C     (VAX PACKING ROUTINE ALLOWS UP TO 3 ZEROS BETWEEN STRINGS)        
C        
      JA   = JA + RCA        
   50 KB   = KB + RCB        
      Z(AROW) = Z(AROW) + SUMR        
C           D = C       +  SUM        
      GO TO 500        
C        
   60 DO 70 J = JB,JE        
      DSUMR = DSUMR + DZ(JA)*DZ(KB)        
      JA    = JA + RCA        
   70 KB    = KB + RCB        
      DZ(AROW) = DZ(AROW) + DSUMR        
      GO TO 500        
C        
   80 SUMI = 0.0        
      DO 90 J = JB,JE        
C     DO 90 J = ICOL,NCOL,RCD        
      SUMR = SUMR + Z(JA)*Z(KB  ) - Z(JA+1)*Z(KB+1)        
      SUMI = SUMI + Z(JA)*Z(KB+1) + Z(JA+1)*Z(KB  )        
      JA   = JA + RCA        
   90 KB   = KB + RCB        
      Z(AROW  ) = Z(AROW  ) + SUMR        
      Z(AROW+1) = Z(AROW+1) + SUMI        
      GO TO 500        
C        
  100 DSUMI = DZERO        
      DO 110 J = JB,JE        
      DSUMR = DSUMR + DZ(JA)*DZ(KB  ) - DZ(JA+1)*DZ(KB+1)        
      DSUMI = DSUMI + DZ(JA)*DZ(KB+1) + DZ(JA+1)*DZ(KB  )        
      JA    = JA + RCA        
  110 KB    = KB + RCB        
      DZ(AROW  ) = DZ(AROW  ) + DSUMR        
      DZ(AROW+1) = DZ(AROW+1) + DSUMI        
      GO TO 500        
C        
C        
  120 GO TO (130,150,170,190, 210,230,250,270,        
     1       290,310,330,350, 370,390,410,430), JUMP        
C        
C                      +--------------- MATRIX  B -----------------+    
C        MATRIX          REAL        REAL       COMPLEX     COMPLEX     
C          A            SINGLE      DOUBLE      SINGLE      DOUBLE      
C     ---------------  ----------  ---------  ----------  ----------    
C     REAL SINGLE         130         150         170         190       
C     REAL DOUBLE         210         230         250         270       
C     COMPLEX SINGLE      290         310         330         350       
C     COMPLEX DOUBLE      370         390         410         430       
C        
C        
  130 DO 140 J = JB,JE        
      DSUMR = DSUMR + DBLE(Z(JA)*Z(KB))        
      JA    = JA + RCA        
  140 KB    = KB + RCB        
      GO TO 460        
C        
  150 DO 160 J = JB,JE        
      DSUMR = DSUMR + DBLE(Z(JA))*DZ(KB)        
      JA    = JA + RCA        
  160 KB    = KB + RCB        
      IF (PRCD) 470,470,460        
C        
  170 DSUMI = DZERO        
      DO 180 J = JB,JE        
      DSUMR = DSUMR + DBLE(Z(JA)*Z(KB  ))        
      DSUMI = DSUMI + DBLE(Z(JA)*Z(KB+1))        
      JA   = JA + RCA        
  180 KB   = KB + RCB        
      IF (PRCD) 490,490,480        
C        
  190 DSUMI = DZERO        
      DO 200 J = JB,JE        
      DSUMR = DSUMR + DBLE(Z(JA))*DZ(KB  )        
      DSUMI = DSUMI + DBLE(Z(JA))*DZ(KB+1)        
      JA    = JA + RCA        
  200 KB    = KB + RCB        
      IF (PRCD) 490,490,480        
C        
  210 DO 220 J = JB,JE        
      DSUMR = DSUMR + DZ(JA)*DBLE(Z(KB))        
      JA    = JA + RCA        
  220 KB    = KB + RCB        
      IF (PRCD) 470,470,460        
C        
  230 DO 240 J = JB,JE        
      DSUMR = DSUMR + DZ(JA)*DZ(KB)        
      JA    = JA + RCA        
  240 KB    = KB + RCB        
      GO TO 470        
C        
  250 DSUMI = DZERO        
      DO 260 J = JB,JE        
      DSUMR = DSUMR + DZ(JA)*DBLE(DZ(KB  ))        
      DSUMI = DSUMI + DZ(JA)*DBLE(DZ(KB+1))        
      JA    = JA + RCA        
  260 KB    = KB + RCB        
      IF (PRCD) 490,490,480        
C        
  270 DSUMI = DZERO        
      DO 280 J = JB,JE        
      DSUMR = DSUMR + DZ(JA)*DZ(KB  )        
      DSUMI = DSUMI + DZ(JA)*DZ(KB+1)        
      JA    = JA + RCA        
  280 KB    = KB + RCB        
      IF (PRCD) 490,490,480        
C        
  290 DSUMI = DZERO        
      DO 300 J = JB,JE        
      DSUMR = DSUMR + DBLE(Z(JA  )*Z(KB))        
      DSUMI = DSUMI + DBLE(Z(JA+1)*Z(KB))        
      JA   = JA + RCA        
  300 KB   = KB + RCB        
      IF (PRCD) 490,490,480        
C        
  310 DSUMI = DZERO        
      DO 320 J = JB,JE        
      DSUMR = DSUMR + DBLE(Z(JA  ))*DZ(KB)        
      DSUMI = DSUMI + DBLE(Z(JA+1))*DZ(KB)        
      JA    = JA + RCA        
  320 KB    = KB + RCB        
      IF (PRCD) 490,490,480        
C        
  330 DSUMI = DZERO        
      DO 340 J = JB,JE        
      DSUMR = DSUMR + DBLE(Z(JA)*Z(KB  )) - DBLE(Z(JA+1)*Z(KB+1))       
      DSUMI = DSUMI + DBLE(Z(JA)*Z(KB+1)) + DBLE(Z(JA+1)*Z(KB  ))       
      JA    = JA + RCA        
  340 KB    = KB + RCB        
      GO TO 480        
C        
  350 DSUMI = DZERO        
      DO 360 J = JB,JE        
      DSUMR = DSUMR + DBLE(Z(JA  ))*DZ(KB)        
      DSUMI = DSUMI + DBLE(Z(JA+1))*DZ(KB)        
      JA    = JA + RCA        
  360 KB    = KB + RCB        
      IF (PRCD) 490,490,480        
C        
  370 DSUMI = DZERO        
      DO 380 J = JB,JE        
      DSUMR = DSUMR + DZ(JA  )*DBLE(Z(KB))        
      DSUMI = DSUMI + DZ(JA+1)*DBLE(Z(KB))        
      JA    = JA + RCA        
  380 KB    = KB + RCB        
      IF (PRCD) 490,490,480        
C        
  390 DSUMI = DZERO        
      DO 400 J = JB,JE        
      DSUMR = DSUMR + DZ(JA  )*DZ(KB)        
      DSUMI = DSUMI + DZ(JA+1)*DZ(KB)        
      JA    = JA + RCA        
  400 KB    = KB + RCB        
      IF (PRCD) 490,490,480        
C        
  410 DSUMI = DZERO        
      DO 420 J = JB,JE        
      DSUMR = DSUMR + DZ(JA)*DBLE(Z(KB  )) - DZ(JA+1)*DBLE(Z(KB+1))     
      DSUMI = DSUMI + DZ(JA)*DBLE(Z(KB+1)) + DZ(JA+1)*DBLE(Z(KB  ))     
      JA    = JA + RCA        
  420 KB    = KB + RCB        
      IF (PRCD) 490,490,480        
C        
  430 DSUMI = DZERO        
      DO 440 J = JB,JE        
      DSUMR = DSUMR + DZ(JA)*DZ(KB  ) - DZ(JA+1)*DZ(KB+1)        
      DSUMI = DSUMI + DZ(JA)*DZ(KB+1) + DZ(JA+1)*DZ(KB  )        
      JA    = JA + RCA        
  440 KB    = KB + RCB        
      GO TO 490        
C        
  460 DZ(AROW) = DZ(AROW) + DSUMR        
      GO TO 500        
  470 Z(AROW)  = Z(AROW)  + SNGL(DSUMR)        
      GO TO 500        
  480 DZ(AROW  ) = DZ(AROW  ) + DSUMR        
      DZ(AROW+1) = DZ(AROW+1) + DSUMI        
      GO TO 500        
  490 Z(AROW  ) = Z(AROW  ) + SNGL(DSUMR)        
      Z(AROW+1) = Z(AROW+1) + SNGL(DSUMI)        
C        
C        
C     END OF STRING DATA. IF THIS IS NOT THE LAST STRING OF CURRENT     
C     ROW OF A, RETURN FOR NEXT STRING        
C        
  500 NBRSTR = NBRSTR - 1        
      APOINT = APOINT + NBR*NWDA + PRCA        
      IF (NBRSTR .GT. 0) GO TO 20        
C        
C     END OF A ROW OF MATRIX A.        
C     RETURN FOR NEXT ROW IF THIS IS NOT THE LAST ROW IN OPEN CORE.     
C     IF IT IS THE LAST ROW, RETURN TO CALLER FOR PACKING OUT THE       
C     CURRENT COLUMN OF MATRIX D (IN C ARRAY)        
C        
  510 L    = L - 2        
      AROW = AROW + 1        
      IF (AROW .LE. AROWN) GO TO 10        
      RETURN        
C        
  520 CALL MESAGE (-37,0,NAM)        
      RETURN        
      END        
