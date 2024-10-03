
$PKMODEL cmt = "CENT PERIPH"

// POP_CL = THETA(1)
// POP_V1 = THETA(2)
// POP_Q = THETA(3)
// POP_V2 = THETA(4)

$PARAM AGE = 35

$MAIN
double CL = THETA1*pow(AGE/35,THETA5)*exp(ETA(1));
double V1 = THETA2*exp(ETA(2));
double Q  = THETA3*exp(ETA(3));
double V2 = THETA4*exp(ETA(4));

$NMXML 
run = 1001
proj = "model"
omega = TRUE, sigma = TRUE

$TABLE

double RUV_PROP = THETA7;
double RUV_ADD = THETA8;

double IPRED = (CENT/V1);

double W = sqrt((RUV_ADD*RUV_ADD) + 
  (RUV_PROP*RUV_PROP*IPRED*IPRED));

capture Y = IPRED+W*EPS(1);

