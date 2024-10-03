$PARAM CL = 1, V = 20, KA = 1.2

$CMT DEPOT CENT

$DES
dxdt_DEPOT = -KA * DEPOT;
dxdt_CENT  =  KA * DEPOT - (CL/V)*CENT;

$TABLE
capture CP = CENT/V;
