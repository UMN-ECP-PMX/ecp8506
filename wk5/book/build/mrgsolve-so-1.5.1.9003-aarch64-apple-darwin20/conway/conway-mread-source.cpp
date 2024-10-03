// Source MD5: 87fcc3c5f0062b4694297712eea17e0a

#include "conway-mread-header.h"

// PREAMBLE CODE BLOCK:
__BEGIN_config__
__END_config__

// MAIN CODE BLOCK:
__BEGIN_main__
p = N*delta;
__END_main__

// DIFFERENTIAL EQUATIONS:
__BEGIN_ode__
dxdt_art = 0;
eps = art*epsilon;
dxdt_T = lambda - d*T - (1.0-eps)*beta*V*T;
dxdt_L = (alpha_L)*(1.0-eps)*beta*V*T + (rho - a - d_L)*L;
dxdt_I = (1.0-alpha_L)*(1.0-eps)*beta*V*T - delta*I + a*L - m*E*I;
dxdt_V = p*I  - c*V;
dxdt_E = lambda_e + (b_e)*(I/(k_b+I))*E - d_e*(I/(k_d+I))*E - mu*E;
__END_ode__

// MODELED EVENTS:
__BEGIN_event__
__END_event__

// TABLE CODE BLOCK:
__BEGIN_table__
logV = log10(V);
logT = log10(T);
logI = log10(I);
logE = log10(E);
logL = log10(L);
year = TIME/365;
_capture_[0] = logV;
_capture_[1] = logT;
_capture_[2] = logI;
_capture_[3] = logE;
_capture_[4] = logL;
_capture_[5] = year;
__END_table__

