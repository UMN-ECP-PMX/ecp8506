
[ prob ]
  This is my homework assignment for week 6

[ cmt ] depot cent
  
[ param ] 
  WT=70  // weight in kg
  AGE=35 // age in years

[ nmext ]
  path = "../nm-model/106/106.ext"
  root = "cppfile"
  
[ pk ]
  // Typical values of PK parameters
  double TVCL   = THETA(1);
  double TVV    = THETA(2);
  double TVKA   = THETA(3);
  double TVD1   = THETA(4);
    
  // PK covariates
  double CL_AGE = pow((AGE/35.0), THETA(5));
  double CL_WT  = pow((WT/70), THETA(6));
  double V_WT   = pow((WT/70), THETA(7));
      
  double CLCOV = CL_AGE*CL_WT;
  double VCOV  = V_WT;
    
  // PK parameters
  double CL = TVCL*CLCOV*exp(ETA(1));
  double V  = TVV*VCOV*exp(ETA(2)); 
  double KA = TVKA; 
  double D1 = TVD1*exp(ETA(3));
    
  double S2 = V;
  
  D_depot = D1; 
  
[ ode ]
  dxdt_depot = -KA*depot;
  dxdt_cent = KA*depot - (CL/V)*cent; 
  
[ error ]
  double IPRED = cent/S2;
  double Y = IPRED * (1+EPS(1));

[ capture ] CL V KA D1 IPRED Y WT AGE
  
  
