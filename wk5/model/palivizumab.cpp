[ global ] 

double wt(double page, double sex, double zscore) {
  double log_wt = 2.591277 - 0.01155*pow(page,0.5) - 
    2201.705*pow(page,-2.0) + 0.0911639*sex;
  double sd = 0.1470258 + 505.92394*pow(page,-2.0) - 
    140.0576*pow(page,-2.0)*log(page); 
  return(exp(log_wt + zscore*sd));
}

[ pkmodel ] 
cmt = "MUS,CENT,PERIPH"
depot = TRUE

[ param ] 
RACE = 0
TITER = 0
WT_ZSCORE = 0
GA = 28
BL_PAGE = 12
SEX = 1
WT_BASED = 1
CLD = 0

[ theta ] 
198   // 1  CL, ml/day
4090  // 2  V2, ml
2230  // 3  V3, ml
879   // 4  Q, ml/day
1.01  // 5  KA, 1/day
0.694 // 6  F1
0.411 // 7  Beta
62.3  // 8  TCL, mo
1.06  // 9  RACE, black
1.05  // 10 RACE, Hispanic
1.12  // 11 RACE, Asian
1.10  // 12 RACE, other
1.20  // 13 CLD
1.15  // 14 TITER 10
1.06  // 15 TITER 20
1.08  // 16 TITER 40
1.21  // 17 TITER >= 80
1.06  // 18 V2~RACE

[ omega ] @block
0.2372
0.0548 0.3807

[ sigma ] 
0.0639

[ main ] 

double PAGE = BL_PAGE + TIME/7.0; 
double WT = wt(PAGE,SEX,WT_ZSCORE);
double WTVX = WT/70.0;
double WTCL = pow(WTVX,0.75);  
double RACE_HISP = RACE==2 ? 1 : 0;  
double Beta = THETA7;
double TCL = THETA8;
double AGECL = 1.0 - (1.0 - Beta) * exp(-((PAGE-40)/4.35) * (log(2.0)/TCL));
double CLDCL = 1; 
if(CLD==1) CLDCL = THETA13;
double TITERCL = 1;
if(TITER==10) TITERCL=THETA14;
if(TITER==20) TITERCL=THETA15;
if(TITER==40) TITERCL=THETA16;
if(TITER>=80) TITERCL=THETA17;

double RACECL = 1;
switch(int(RACE)) {
case 0: 
  RACECL = 1;
  break;
case 1: 
  RACECL = THETA9;
  break;
case 2: 
  RACECL = THETA10;
  break;
case 3: 
  RACECL = THETA11;
  break;
case 4: 
  RACECL = THETA12;
  break;
default:
  RACECL = 1;
  break;
}

double CL = THETA1 * WTCL * AGECL * RACECL * CLDCL * TITERCL * exp(ETA(1));
double V2 = THETA2 * WTVX * pow(THETA18,RACE_HISP) * exp(ETA(2)); 
double V3 = THETA3 * WTVX; 
double Q  = THETA4 * WTCL;
double KA = THETA5;
double F1 = THETA6; 
if(WT_BASED) F1 = F1*WT;
F_MUS = F1;

[ table ] 
capture IPRED = CENT/(V2/1000);
capture DV = IPRED*(1+EPS(1));

[ capture ] PAGE CL CP = IPRED WT EVID
  
