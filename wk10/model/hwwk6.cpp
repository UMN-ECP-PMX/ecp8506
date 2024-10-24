[ PROB ]
  Drug X PK Model
  
[ CMT ] @annotated
  DEPOT : Depot oral dosing compartment 
  CENT  : Central compartment 
  AUC   : Accumulation compartment 

[ PARAM ]  
  WT   = 70  // Body weight in Kg
  AGE  = 35  // Age in years

[ THETA ] @annotated
  0.287054  : TVCL
  2.545190  : TVV
  0.202388  : TVKA
  0.464711  : TVD1
  -1.248800 : CLAGE 
  1.075160  : CLWT
  1.176740  : VWT

[ OMEGA ] @block 
  0.1568400
  0.0335622 0.1178330
  
[ OMEGA ] @block
  0.0556292

[ SIGMA ] @block
  0.0527144

[ PK ] 
  double TVCL   = THETA(1);
  double TVV    = THETA(2);
  double TVKA   = THETA(3);
  double TVD1   = THETA(4);
  
  double CL_AGE = pow(AGE/35.0, THETA(5));
  double CL_WT  = pow(WT/70, THETA(6));
  double V_WT   = pow(WT/70, THETA(7));
    
  double CLCOV = CL_AGE*CL_WT;
  double VCOV  = V_WT;
  
  double CL  = TVCL*CLCOV*exp(ETA(1));
  double V   = TVV*VCOV*exp(ETA(2)); 
  double KA  = TVKA; 
  double D1  = TVD1*exp(ETA(3));
  
  D_DEPOT = D1; 
  
  double S2 = V;

[ DES ]
  double CP = CENT/V; 
    
  dxdt_DEPOT = -KA*DEPOT;
  dxdt_CENT  =  KA*DEPOT-CL*CP;
  dxdt_AUC   =  CP;

[ ERROR ] 
  double IPRED = CP;
  double Y = IPRED * (1+EPS(1));

[ CAPTURE ] CL V KA D1 IPRED Y WT AGE
