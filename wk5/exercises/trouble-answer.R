
library(mrgsolve)

code <- '
$PARAM KA = 1.2, CL = 1.3, TVVC = 30, WT = 70

$CMT GUT CENT

$MAIN
double k = CL/VC;

double VC = TVVC*WT;

$ODE

dxdt_GUT = -KA*GUT;

dxdt_CENT = KA*GUT - k*CENT;

'

mod <- mcode("right", code)
