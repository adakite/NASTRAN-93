      INTEGER FUNCTION KHRFN3 (WORD1,WORD2,MOVE,IDIR)        
C        
C     CHARACTER FUNCTION KHRFN3 MERGES TWO WORDS, WORD1 AND WORD2, BY   
C     BYTES        
C        
C     (+)MOVE IS NO. OF BYTES INVOLVED PRELIMINARY SHIFTING        
C     (-)MOVE IS NO. OF BYTES IN MERGING, NO PRELIMINARY SHIFTING.      
C     IDIR IS LEFT OR RIGHT SHIFT OF WORD2. THE VACANT BYTES ARE THEN   
C     FILLED IN BY WORD1.  (LEFT SHIFT IF IDIR=1, RIGHT SHIFT OTHERWISE)
C        
C     NOTE - KHRFN3 HANDLES ONLY 4 BYTES OF WORD. IF MACHINE WORD HAS   
C     MORE THAN 4 BYTES PER WORD, KHRFN3 DOES NOT ZERO-FILL NOR BLANK-  
C     FILL THE REST OF THE WORD. THE CALLER SHOULD MAKE THE PROPER      
C     CHOICE BY ZERO-FILL OR BLANK-FILL THE INPUT WORDS, WORD1 ADN WORD2
C        
C     THE FOLLOWING TABLE GIVES THE RESULTS OF KHRFN3 FOR VARIOUS INPUT 
C     VALUES OF MOVE AND IDIR:        
C        
C        GIVEN:    WORD1=ABCD  AND  WORD2=1234  (IN BCD)        
C                 IDIR=1   IDIR.NE.1            IDIR=1   IDIR.NE.1      
C                --------------------          --------------------     
C        MOVE= 0:   1234     1234      MOVE=-0:   1234     1234        
C        MOVE= 1:   234D     A123      MOVE=-1:   123D     A234        
C        MOVE= 2:   34CD     AB12      MOVE=-2:   12CD     AB34        
C        MOVE= 3:   4BCD     ABC1      MOVE=-3:   1BCD     ABC4        
C        MOVE= 4:   ABCD     ABCD      MOVE=-4:   ABCD     ABCD        
C        
C     THIS ROUTINE WAS WRITTEN BY G.CHAN TO REPLACE THE ORIGINAL VAX    
C     ROUTINE WHICH WAS VERY VERY INEFFICIENT.        
C        
      INTEGER         WORD1(1),WORD2(1),WORD3        
C        
      NCPW  = 4        
      IMOVE = IABS(MOVE)        
      IEND  = NCPW - IMOVE        
      WORD3 = WORD2(1)        
      IF (MOVE) 50,90,10        
 10   WORD3 = WORD1(1)        
      IF (IMOVE .GE. NCPW) GO TO 90        
      IF (IDIR  .EQ.    1) GO TO 30        
      DO 20 I = 1,IEND        
      WORD3 = KHRFN1(WORD3,I+IMOVE,WORD2(1),I)        
 20   CONTINUE        
      GO TO 90        
 30   DO 40 I = 1,IEND        
      WORD3 = KHRFN1(WORD3,I,WORD2(1),I+IMOVE)        
 40   CONTINUE        
      GO TO 90        
 50   IF (IDIR .EQ. 1) GO TO 70        
      DO 60 I = 1,IMOVE        
      WORD3 = KHRFN1(WORD3,I,WORD1(1),I)        
 60   CONTINUE        
      GO TO 90        
 70   DO 80 I = 1,IMOVE        
      WORD3 = KHRFN1(WORD3,I+IEND,WORD1(1),I+IEND)        
 80   CONTINUE        
 90   KHRFN3 = WORD3        
      RETURN        
      END        
