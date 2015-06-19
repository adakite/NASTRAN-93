      SUBROUTINE ENCODE( II )
C
C     THIS SUBROUTINE CONVERTS THE DEGREE OF FREEDOM CODES AS GIVEN
C     IN BULK DATA FORM ( INTEGERS FROM 1-6 ) TO THE BIT PATTERN
C     USED IN SUBSTRUCTURE ANALYSIS.
C
      DIMENSION IDIV(6)
      DATA IDIV/ 100000 , 10000 , 1000 , 100 , 10 , 1 /                 
C                                                                       
      ISUM = 0
      DO 1 I=1,6
      J = II/IDIV(I)
      IF( J .EQ. 0 ) GO TO 1
      ISUM = ISUM + 2 ** (J-1)
      II = II - J*IDIV(I)
 1    CONTINUE
      II = ISUM
      RETURN
      END