// Source MD5: 45bdea2bc25b46a69124969458a61641

#include "opg-mread-header.h"

// PREAMBLE CODE BLOCK:
__BEGIN_config__
__END_config__

// MAIN CODE BLOCK:
__BEGIN_main__
CL   = exp(log(TVCL)  + ECL);
VC   = exp(log(TVVC)  + EVC);
VP1  = exp(log(TVVP1) + EVP1);
VP2  = exp(log(TVVP2) + EVP2);
Q1   = exp(log(TVQ1)  + EQ1);
Q2   = TVQ2;
KA   = exp(log(TVKA)  + EKA);
VMAX = TVVMAX;
KM   = TVKM;
FSC  = exp(log(TVFSC) + EFSC);
KSYN = exp(log(TVKSYN) + EKSYN);
KDEG = exp(log(TVKDEG) + EKDEG);
IC50 = exp(log(TVIC50) + EIC50);
NTX_0 = KSYN/KDEG;
F_SC = FSC/(1.0+FSC);
__END_main__

// DIFFERENTIAL EQUATIONS:
__BEGIN_ode__
CLNL = VMAX/(CP+KM);
dxdt_SC     = -KA*SC;
dxdt_CENT   =  KA*SC - (CL+Q1+Q2+CLNL)*CENT/VC + Q1*P1/VP1 + Q2*P2/VP2;
dxdt_P1     =  CENT*Q1/VC - P1*Q1/VP1;
dxdt_P2     =  CENT*Q2/VC - P2*Q2/VP2;
dxdt_NTX    =  KSYN*(1.0 - CP/(IC50+CP)) - KDEG*NTX;
__END_ode__

// MODELED EVENTS:
__BEGIN_event__
__END_event__

// TABLE CODE BLOCK:
__BEGIN_table__
IPRED = CP;
PKEPS = IV==1 ? ADDIV : ADDSC;
PKDV = exp(log(IPRED)+PKEPS);
PDDV = NTX*(1+PDPROP) + PDADD;
dNTX = NTX-NTX_0;
_capture_[0] = PKDV;
_capture_[1] = PDDV;
_capture_[2] = dNTX;
__END_table__

