[PROB]
  ECP8506 homework assignment simulation

[SET] delta=0.01, end=24

[CMT] DEPOT CENT  

[INPUT] @annotated
WT   : 70 : Weight (kg)
AGE  : 35 : Age (years)

[THETA] @annotated
0.5  : Typical value of clearance (L/h)
2.5  : Typical value of volume (L)
0.2  : Typical value of First-order absorption rate constant (/h)
0.5  : Typical value of Zero-order absorption duration (h)
-0.5 : AGE on CL
0.8  : WT on CL
1    : WT on V1

[OMEGA] @correlation 
0.2 
0.33 0.1

[OMEGA] @block
0.1

[SIGMA]
0.05

[MAIN]
double TVCL     = THETA1;
double TVV      = THETA2;
double TVKA     = THETA3;
double TVD1     = THETA4;
double CL_AGE   = THETA5;
double CL_WT    = THETA6;
double V_WT     = THETA7;

double CL = TVCL*pow((WT/70.0),CL_WT)*pow((AGE/35.0),CL_AGE)*exp(ETA(1));
double V  = TVV*pow((WT/70.0),V_WT)*exp(ETA(2)); 
double KA = TVKA; 
double D1 = TVD1*exp(ETA(3));

D_DEPOT = D1; 

[ODE]
dxdt_DEPOT = -KA*DEPOT; 
dxdt_CENT = KA*DEPOT-(CL/V)*CENT; 

[TABLE] 
capture CP = CENT/V;
capture Y = CP*(1+EPS(1));
