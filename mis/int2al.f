      SUBROUTINE INT2AL (INT,ALF,CH)        
C     ----------        
C     THIS ROUTINE CONVERTS AN INTEGER TO ALPHA-NUMERIC WORD. THE       
C     NUMBER IS LEFT JUSTIFIED WITH NO BLANKS.        
C        
C     INPUT/OUTPUT        
C        
C     INT - INTEGER - INPUT - NOT CHANGED        
C     ALF - BCD 2 WORDS - OUTPUT - 2A4 MAY BE USED FOR PRINTING        
C     CH  - BCD 9 WORDS - OUTPUT - CH(1) .EQ. NUMBER OF CHARACTERS      
C           NEEDED TO CREATE INT. MAY BE PRINTED BY CH(I), I=2,CH(1)    
C           IN A1 FORMAT.        
C        
C     NOTE - ANY INPUT NUMBER OUTSIDE THE RANGE OF -9999999 AND +9999999
C            (I.E. MORE THAN 8 DIGITS) IS SET TO ZERO IN OUTPUT.        
C     ----------        
C        
      INTEGER     INT,    ALF(2),  CH(9),  ZERO,   BLANK        
      CHARACTER*8 K8        
      DATA        BLANK,  ZERO /   1H ,    1H0 /        
C        
      IF (INT.LT.-9999999 .OR. INT.GT.+99999999) GO TO 50        
      CALL INT2K8 (*50,INT,K8)        
      READ (K8,10) ALF        
      READ (K8,20) (CH(J),J=2,9)        
 10   FORMAT (2A4)        
 20   FORMAT (8A1)        
      DO 30 J=2,9        
      IF (CH(J) .EQ. BLANK) GO TO 40        
 30   CONTINUE        
      J=10        
 40   CH(1)=J-2        
      RETURN        
C        
 50   CH(1) =1        
      CH(2) =ZERO        
      ALF(1)=ZERO        
      ALF(2)=BLANK        
      RETURN        
      END        