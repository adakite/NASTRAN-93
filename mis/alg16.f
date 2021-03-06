      SUBROUTINE ALG16 (IX,LOG1,X1,Y1,X2,Y2)
C
      REAL LINE
C
      DIMENSION X1(1), Y1(1), X2(1), Y2(1), LINE(121), XNUM(13)
C
      DATA SYMBOL/1H*/,DASH/1H-/,CROSS/1H+/,BLANK/1H /,XI/1HI/          
C                                                                       
      YMIN=Y1(1)
      XMIN=X1(1)
      YMAX=YMIN
      XMAX=XMIN
      DO 10 I=1,IX
      IF (Y2(I).LT.YMIN) YMIN=Y2(I)
      IF (Y2(I).GT.YMAX) YMAX=Y2(I)
      IF (X2(I).LT.XMIN) XMIN=X2(I)
      IF (X2(I).GT.XMAX) XMAX=X2(I)
      IF (Y1(I).GT.YMAX) YMAX=Y1(I)
      IF (X1(I).GT.XMAX) XMAX=X1(I)
10    CONTINUE
      IF (XMAX.EQ.XMIN.OR.YMIN.EQ.YMAX) GO TO 170
      YH=YMAX+(YMAX-YMIN)/25.0
      YL=YMIN-(YMAX-YMIN)/25.0
      XH=XMAX+(XMAX-XMIN)/38.3333
      XL=XMIN-(XMAX-XMIN)/38.3333
      IF ((YH-YL)/(XH-XL).GT.0.75) XH=1.3333*(YH-YL)+XL
      IF ((YH-YL)/(XH-XL).LT.0.75) YH=0.75*(XH-XL)+YL
      XMAX=(XMIN+XMAX-XH+XL)/2.0
      XH=XH-XL+XMAX
      XL=XMAX
      XMAX=(YMIN+YMAX-YH+YL)/2.0
      YH=YH-YL+XMAX
      YL=XMAX
      XMAX=ABS(XH)
      XMIN=ABS(XL)
      YMIN=ABS(YL)
      YMAX=ABS(YH)
      IF (XMIN.GT.XMAX) XMAX=XMIN
      IF (YMIN.GT.YMAX) YMAX=YMIN
      XMAX=ALOG10(XMAX)
      YMAX=ALOG10(YMAX)
      IF (XMAX.LT.0.0) XMAX=XMAX-1.0
      IF (YMAX.LT.0.0) YMAX=YMAX-1.0
      MX=-XMAX
      MY=-YMAX
      WRITE (LOG1,20) MX,MY
20    FORMAT (20X,46HSCALES -  X  IS SHOWN TIMES 10 TO THE POWER OF,I3,4
     10H    Y  IS SHOWN TIMES 10 TO THE POWER OF,I3,/)                  
      YINC=(YH-YL)/54.0
      YINC2=YINC/2.0
      XRANGE=XH-XL
      DO 140 KLINE=1,55
      IF (KLINE.EQ.1.OR.KLINE.EQ.55) GO TO 50
      DO 30 L=2,120
30    LINE(L)=BLANK
      IF (KLINE.EQ.7.OR.KLINE.EQ.13.OR.KLINE.EQ.19.OR.KLINE.EQ.25.OR.KLI
     1NE.EQ.31.OR.KLINE.EQ.37.OR.KLINE.EQ.43.OR.KLINE.EQ.49) GO TO 40
      LINE(1)=XI
      LINE(121)=XI
      GO TO 80
40    LINE(1)=DASH
      LINE(121)=DASH
      GO TO 80
50    DO 60 L=2,120
60    LINE(L)=DASH
      LINE(1)=CROSS
      LINE(121)=CROSS
      DO 70 L=11,111,10
70    LINE(L)=XI
      GO TO 120
80    DO 100 I=1,IX
      IF (Y2(I).GT.YH+YINC2.OR.Y2(I).LE.YH-YINC2) GO TO 90
      L=(X2(I)-XL)/XRANGE*120.0+1.5
      LINE(L)=SYMBOL
90    IF (Y1(I).GT.YH+YINC2.OR.Y1(I).LE.YH-YINC2) GO TO 100
      L=(X1(I)-XL)/XRANGE*120.0+1.5
      LINE(L)=SYMBOL
100   CONTINUE
      IF (KLINE.EQ.1.OR.KLINE.EQ.7.OR.KLINE.EQ.13.OR.KLINE.EQ.19.OR.KLIN
     1E.EQ.25.OR.KLINE.EQ.31.OR.KLINE.EQ.37.OR.KLINE.EQ.43.OR.KLINE.EQ.4
     29.OR.KLINE.EQ.55) GO TO 120
      WRITE (LOG1,110) LINE
110   FORMAT (8X,121A1)                                                 
      GO TO 140
120   YNUM=YH*10.0**MY
      WRITE (LOG1,130) YNUM,LINE
130   FORMAT (1X,F6.3,1X,121A1)                                         
140   YH=YH-YINC
      XNUM(1)=XL*10.0**MX
      XINC=((XH-XL)/12.0)*10.0**MX
      DO 150 I=2,13
150   XNUM(I)=XNUM(I-1)+XINC
      WRITE (LOG1,160) XNUM
160   FORMAT (6X,12(F6.3,4X),F6.3)                                      
      RETURN
170   WRITE (LOG1,180)
180   FORMAT (//,35X,54HNO PLOT HAS BEEN MADE BECAUSE  X  OR  Y  RANGE I
     1S ZERO)                                                           
      RETURN
      END
