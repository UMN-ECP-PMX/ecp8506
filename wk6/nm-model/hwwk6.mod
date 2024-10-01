$PROBLEM From bbr: see 106.yaml for details

$INPUT C NUM ID TIME AMT RATE EVID MDV CMT DV BLQ WT AGE DOSE

$DATA ../data/nmdat1.csv IGNORE=@  IGNORE(BLQ=1)

$SUBROUTINE ADVAN13 TRANS1 TOL=8

$MODEL 
  COMP=(DEPOT)
  COMP=(CENT)

$PK
  ; Typical values of PK parameters
  TVCL   = THETA(1)
  TVV    = THETA(2)
  TVKA   = THETA(3)
  TVD1   = THETA(4)
  
  ; PK covariates
  CL_AGE = (AGE/35.0)**THETA(5)
  CL_WT  = (WT/70)**THETA(6)
  V_WT   = (WT/70)**THETA(7)
  
  CLCOV = CL_AGE*CL_WT
  VCOV  = V_WT
  
  ; PK parameters
  CL = TVCL*CLCOV*EXP(ETA(1));
  V  = TVV*VCOV*EXP(ETA(2)); 
  KA = TVKA; 
  D1 = TVD1*EXP(ETA(3));
  
  S2 = V

$DES 
  DADT(1) = -KA*A(1)
  DADT(2) = KA*A(1)-(CL/V)*A(2)

$ERROR
  IPRED = A(2)/S2
  Y=IPRED*(1+EPS(1))

$THETA  ; log values
  (0,0.5)   ;  1 TVCL (L/hr) 
  (0,2.5)   ;  2 TVV  (L) 
  (0,0.2)   ;  3 TVKA (1/hr) 
  (0,0.5)   ;  4 TVD1 (hr) 
  (-0.5)    ;  5 CL_AGE
  (0.8)     ;  6 CL_WT
  (1)       ;  7 V_WT

$OMEGA BLOCK(2)
  0.2       ;ETA(CL)
  0.01 0.1  ;ETA(V)

$OMEGA BLOCK(1)
  0.1       ;ETA(KA)

$SIGMA
  0.05     ; 1 pro error

$EST MAXEVAL=9999 METHOD=1 INTER SIGL=6 NSIG=3 PRINT=1 RANMETHOD=P MSFO=./hwwk6.msf 
$COV PRINT=E RANMETHOD=P
$TABLE NUM IPRED NPDE CWRES NOPRINT ONEHEADER RANMETHOD=P FILE=hwwk6.tab
$TABLE NUM CL V KA D1 ETAS(1:LAST) NOAPPEND NOPRINT ONEHEADER FILE=hwwk6par.tab
