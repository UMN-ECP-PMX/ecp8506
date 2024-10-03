
library(mrgsolve)

code <- '
$PARAM KA = 1.2, CL = 1.3, TVVC = 30

$MAIN
k = cl/VC;

VC = TVVC*WT;

$ODE

dxdt_GUT = -KA*GUT

dxdt_CENT = KA*GUT - k*CENT

'

mod <- try(mcode("wrong",code))

