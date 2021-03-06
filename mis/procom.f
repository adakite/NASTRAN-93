      SUBROUTINE PROCOM (PROCOS,PROCOF,CASECC,NCOEFS,NGRIDS)        
C        
C     PROCOM COMBINES PROCOF CASES FOR SUBCOM-S AND REPCASES        
C        
      INTEGER         PROCOF,CASECC,BUF1,BUF2,BUF3,FILE,PROCOS,INFO(7), 
     1                IZ(1),NAM(2)        
      COMMON /SYSTEM/ IBUF        
CZZ   COMMON /ZZPROL/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (Z(1),IZ(1))        
      DATA    I166  , I16  ,NAM   / 166, 16, 4HPROC,4HOM  /        
C        
      LCORE = KORSZ(Z)        
      BUF1  = LCORE - IBUF + 1        
      BUF2  = BUF1  - IBUF        
      BUF3  = BUF2  - IBUF        
      LCORE = BUF3  - 1        
      IF (LCORE.LT.NCOEFS .OR. LCORE.LT.NGRIDS) GO TO 108        
      CALL GOPEN (PROCOS,Z(BUF1),0)        
      CALL GOPEN (PROCOF,Z(BUF2),1)        
C        
C     CHECK EACH SUBCASE FOR REPCASE OR SUBCOM-IF NONE(JUST COPY SET OF 
C     5 RECORDS FROM PROCOS TO PROCOF        
C        
      FILE = CASECC        
      CALL GOPEN (CASECC,Z(BUF3),0)        
   10 FILE = CASECC        
      CALL READ (*90,*20,CASECC,Z(1),LCORE,0,IWORDS)        
      GO TO 108        
   20 IF (IZ(I16) .NE. 0) GO TO 30        
C        
C     NOT A SUBCOM - MIGHT BE REPCASE        
C        
   25 FILE = PROCOS        
      CALL FREAD (PROCOS,Z,103,1)        
      CALL WRITE (PROCOF,Z,103,1)        
      CALL FREAD (PROCOS,Z,NCOEFS,1)        
      CALL WRITE (PROCOF,Z,NCOEFS,1)        
      CALL FREAD (PROCOS,Z,NCOEFS,1)        
      CALL WRITE (PROCOF,Z,NCOEFS,1)        
      CALL FREAD (PROCOS,Z,NGRIDS,1)        
      CALL WRITE (PROCOF,Z,NGRIDS,1)        
      CALL FREAD (PROCOS,Z,NGRIDS,1)        
      CALL WRITE (PROCOF,Z,NGRIDS,1)        
C        
C     GO BACK FOR ANOTHER CASE CONTROL RECORD        
C        
      GO TO 10        
C        
C     REPCASE OR SUBCOM        
C        
   30 IF (IZ(I16) .GT. 0) GO TO 45        
C        
C     REPCASE        
C        
      DO 40 I = 1,5        
      CALL BCKREC (PROCOS)        
   40 CONTINUE        
      GO TO 25        
C        
C     SUBCOM        
C        
   45 LCC  = IZ(I166)        
      LSYM = IZ(LCC)        
      DO 50 I = 1,LSYM        
      DO 50 J = 1,5        
      CALL BCKREC (PROCOS)        
   50 CONTINUE        
      NTOT = 2*(NCOEFS+NGRIDS)        
      IF (IWORDS+2*NTOT .GT. LCORE) GO TO 108        
      INEW = IWORDS + NTOT        
      DO 60 I = 1,NTOT        
   60 Z(INEW+I) = 0.        
      DO 80 I = 1,LSYM        
      COEF = Z(LCC+I)        
      IF (COEF .EQ. 0.) GO TO 75        
      CALL FREAD (PROCOS,INFO,103,1)        
      CALL FREAD (PROCOS,Z(IWORDS+1),NCOEFS,1)        
      CALL FREAD (PROCOS,Z(IWORDS+NCOEFS+1),NCOEFS,1)        
      CALL FREAD (PROCOS,Z(IWORDS+2*NCOEFS+1),NGRIDS,1)        
      CALL FREAD (PROCOS,Z(IWORDS+2*NCOEFS+NGRIDS+1),NGRIDS,1)        
      DO 70 J = 1,NTOT        
      Z(INEW+J) = Z(INEW+J) + COEF*Z(IWORDS+J)        
   70 CONTINUE        
      GO TO 80        
   75 DO 76 K = 1,5        
      CALL FWDREC (*102,PROCOS)        
   76 CONTINUE        
C        
   80 CONTINUE        
C        
C     WRITE TO PROCOF- 1ST BE SURE THAT ISYM IS 0 TO ACCOUNT FOR        
C     POSSIBLE SYMMETRY-ANTISYMMETRY COMBINATION        
C        
      INFO(6) = 0        
      CALL WRITE (PROCOF,INFO,103,1)        
      CALL WRITE (PROCOF,Z(INEW+1),NCOEFS,1)        
      CALL WRITE (PROCOF,Z(INEW+NCOEFS+1),NCOEFS,1)        
      CALL WRITE (PROCOF,Z(INEW+2*NCOEFS+1),NGRIDS,1)        
      CALL WRITE (PROCOF,Z(INEW+2*NCOEFS+NGRIDS+1),NGRIDS,1)        
C        
C     GO BACK FOR ANOTHER SUBCASE        
C        
      GO TO 10        
C        
C     DONE        
C        
   90 CALL CLOSE (CASECC,1)        
      CALL CLOSE (PROCOS,1)        
      CALL CLOSE (PROCOF,1)        
      INFO(1) = PROCOS        
      CALL RDTRL (INFO)        
      INFO(1) = PROCOF        
      CALL WRTTRL (INFO)        
      RETURN        
C        
  102 CALL MESAGE (-2,0,NAM)        
  108 CALL MESAGE (-8,0,NAM)        
      RETURN        
      END        
