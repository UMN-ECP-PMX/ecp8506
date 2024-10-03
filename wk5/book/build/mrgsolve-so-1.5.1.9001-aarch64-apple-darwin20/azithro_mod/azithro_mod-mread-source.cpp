// Source MD5: 139dbacc4b59fad0ca371071f5b685ad

#include "azithro_mod-mread-header.h"

// PREAMBLE CODE BLOCK:
__BEGIN_config__
__END_config__

// MAIN CODE BLOCK:
__BEGIN_main__
CL = TVCL*pow(WT/70.0,0.75)*exp(ETACL);
V1 = TVV1*(WT/70)*exp(ETAV1);
Q2 = TVQ2*pow(WT/70.0,0.75);
V2 = TVV2*(WT/70.0);
__END_main__

// DIFFERENTIAL EQUATIONS:
__BEGIN_ode__
dxdt_GUT  = -KA*GUT;
dxdt_CENT =  KA*GUT - (CL+Q2+Q3)*CENT/V1 + Q2*PER2/V2 + Q3*PER3/V3;
dxdt_PER2 =  Q2*(CENT/V1 - PER2/V2);
dxdt_PER3 =  Q3*(CENT/V1 - PER3/V3);
__END_ode__

// MODELED EVENTS:
__BEGIN_event__
__END_event__

// TABLE CODE BLOCK:
__BEGIN_table__
CP = CENT/(V1/1000.0)*exp(RUV);
_capture_[0] = CP;
__END_table__

