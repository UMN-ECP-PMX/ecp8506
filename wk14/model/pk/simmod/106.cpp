[ PLUGIN ] autodec nm-vars

[ PKMODEL ] cmt = "GUT CENT PERIPH", depot = TRUE

[ PARAM ]  
WT = 70, AGE = 35, EGFR = 90, ALB = 4.5

[ NMEXT ] 
project = ".."
root = "cppfile"
run = 106

[ PK ]
V2WT   = LOG(WT/70.0);
CLWT   = LOG(WT/70.0)*0.75;
CLEGFR = LOG(EGFR/90.0)*THETA(6);
CLAGE  = LOG(AGE/35.0)*THETA(7);
V3WT   = LOG(WT/70.0);
QWT    = LOG(WT/70.0)*0.75;
CLALB  = LOG(ALB/4.5)*THETA(8);

KA   = EXP(THETA(1) + ETA(1));
V2   = EXP(THETA(2) + V2WT + ETA(2));
CL   = EXP(THETA(3) + CLWT + CLEGFR + CLAGE + CLALB + ETA(3));
V3   = EXP(THETA(4) + V3WT);
Q    = EXP(THETA(5) + QWT);  

S2 = V2/1000.0; //; dose in mcg, conc in mcg/mL

[ ERROR ] 
F = CENT/S2;
Y = F*(1+EPS(1)); 
IPRED = F; 

[ CAPTURE ]
CL Q V2 V3 KA ETA(1) ETA(2) ETA(3) IPRED
