[ prob ]
  ECP8506 mrgsolve model for illustration
  This model requires mrgsolve >= 1.0.3

[ pkmodel ] cmt = "GUT,CENT,PERIPH", depot = TRUE

[ param ]  
  WT   = 70
  EGFR = 90
  ALB  = 4.5
  AGE  = 35

[ theta ] @annotated
  0.443   : log(TVKA)
  4.12    : log(TVV2)
  1.17    : log(TVCL)
  4.21    : log(TVV3)
  1.28    : log(TVQ)
  0.485   : log(CLEGFR)
  -0.0377 : log(CLAGE)
  0.419   : log(CLALB)

[ omega ] @block 
  0.219
  0.0668 0.0824
  0.121  0.0703 0.114

[ sigma ] @block
  0.0399

[ pk ] 
  double V2WT   = log(WT/70.0);
  double CLWT   = log(WT/70.0)*0.75;
  double CLEGFR = log(EGFR/90.0)*THETA(6);
  double CLAGE  = log(AGE/35.0)*THETA(7);
  double V3WT   = log(WT/70.0);
  double QWT    = log(WT/70.0)*0.75;
  double CLALB  = log(ALB/4.5)*THETA(8);

  double KA  = exp(THETA(1) + ETA(1));
  double V2  = exp(THETA(2) + V2WT + ETA(2));
  double CL  = exp(THETA(3) + CLWT + CLEGFR + CLAGE + CLALB + ETA(3));
  double V3  = exp(THETA(4) + V3WT);
  double Q   = exp(THETA(5) + QWT);

  double S2 = V2/1000.0; //; dose in mcg, conc in mcg/mL

[ error ] 
  double IPRED = CENT/S2;
  double Y = IPRED * (1+EPS(1));

[ capture ] CL V2 IPRED Y WT EGFR ALB AGE
