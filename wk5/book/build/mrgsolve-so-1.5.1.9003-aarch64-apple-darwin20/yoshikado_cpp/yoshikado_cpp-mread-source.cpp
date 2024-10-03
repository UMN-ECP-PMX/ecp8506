// Source MD5: f638b530e79a4f6da398d1c97b5f62cb

#include "yoshikado_cpp-mread-header.h"

// PREAMBLE CODE BLOCK:
__BEGIN_config__
__END_config__

// MAIN CODE BLOCK:
__BEGIN_main__
if(NEWIND <=1) {
  CLintall = fbCLintall/fb;
  PSact = 1.0/(1.0+Rdiff)*CLintall/beta;
  PSdiffi = Rdiff/(1.0+Rdiff)*CLintall/beta;
  PSdiffe = Rdiff/(1.0+Rdiff)/gamma*CLintall/beta;
  CLint = CLintall/(1.0-beta)*Rdiff/(1.0+Rdiff)/gamma;
  Vme = Vmus*exFmus;
  Vae = Vadi*exFadi;
  Vse = Vski*exFski;
  Vmc = Vmus-Vme;
  Vac = Vadi-Vae;
  Vsc = Vski-Vse;
  dVliv = Vliv/5.0;
  ikitot = imw*ikiu/ifb;
}
__END_main__

// DIFFERENTIAL EQUATIONS:
__BEGIN_ode__
Ccent = cent/Vcent;
Cmus  = mus/Vmus;
Cski  = ski/Vski;
Cadi  = adi/Vadi;
Vhe = dVliv*exFliv;
Vhc = dVliv*(1-exFliv);
Chc1 = hc1/Vhc;
Chc2 = hc2/Vhc;
Chc3 = hc3/Vhc;
Chc4 = hc4/Vhc;
Chc5 = hc5/Vhc;
Che1 = he1/Vhe;
Che2 = he2/Vhe;
Che3 = he3/Vhe;
Che4 = he4/Vhe;
Che5 = he5/Vhe;
iCcent = icent/Vcent;
Cme = me/Vme;
Cse = se/Vse;
Cae = ae/Vae;
Cmc = mc/Vmc;
Csc = sc/Vsc;
Cac = ac/Vac;
iCliv1 = iliv1/dVliv;
iCliv2 = iliv2/dVliv;
iCliv3 = iliv3/dVliv;
iCliv4 = iliv4/dVliv;
iCliv5 = iliv5/dVliv;
dxdt_igut = -ika/ifafg*igut;
dxdt_icent = 
  Qh*iCliv5/iKp_liv 
  - Qh*iCcent 
  - iClr*iCcent 
  - Qmus*(iCcent-Cme) 
  - Qski*(iCcent-Cse) 
  - Qadi*(iCcent-Cae);
dxdt_me = Qmus*(iCcent-Cme) - PSmus*ifb*(Cme-Cmc/iKp_mus);
dxdt_se = Qski*(iCcent-Cse) - PSski*ifb*(Cse-Csc/iKp_ski);
dxdt_ae = Qadi*(iCcent-Cae) - PSadi*ifb*(Cae-Cac/iKp_adi);
dxdt_mc = PSmus*ifb*(Cme-Cmc/iKp_mus);
dxdt_sc = PSski*ifb*(Cse-Csc/iKp_ski);
dxdt_ac = PSadi*ifb*(Cae-Cac/iKp_adi);
dxdt_iliv1 = Qh*(iCcent-iCliv1/iKp_liv) - (ifhCLint/5.0)*iCliv1 + ika*igut;
dxdt_iliv2 = Qh*(iCliv1-iCliv2)/iKp_liv - (ifhCLint/5.0)*iCliv2;
dxdt_iliv3 = Qh*(iCliv2-iCliv3)/iKp_liv - (ifhCLint/5.0)*iCliv3;
dxdt_iliv4 = Qh*(iCliv3-iCliv4)/iKp_liv - (ifhCLint/5.0)*iCliv4;
dxdt_iliv5 = Qh*(iCliv4-iCliv5)/iKp_liv - (ifhCLint/5.0)*iCliv5;
csai1 = 1.0+(iCliv1/iKp_liv)/ikitot;
csai2 = 1.0+(iCliv2/iKp_liv)/ikitot;
csai3 = 1.0+(iCliv3/iKp_liv)/ikitot;
csai4 = 1.0+(iCliv4/iKp_liv)/ikitot;
csai5 = 1.0+(iCliv5/iKp_liv)/ikitot;
hex2 = fh*(PSdiffe/5.0);
dxdt_he1 = Qh*(Ccent-Che1)-(fb*(PSact/csai1+PSdiffi)/5.0)*Che1+hex2*Chc1 + ka*gut;
dxdt_he2 = Qh*(Che1 -Che2)-(fb*(PSact/csai2+PSdiffi)/5.0)*Che2+hex2*Chc2;
dxdt_he3 = Qh*(Che2 -Che3)-(fb*(PSact/csai3+PSdiffi)/5.0)*Che3+hex2*Chc3;
dxdt_he4 = Qh*(Che3 -Che4)-(fb*(PSact/csai4+PSdiffi)/5.0)*Che4+hex2*Chc4;
dxdt_he5 = Qh*(Che4 -Che5)-(fb*(PSact/csai5+PSdiffi)/5.0)*Che5+hex2*Chc5;
hcx2 = fh*((PSdiffe+CLint)/5.0);
dxdt_hc1 = fb*((PSact/csai1+PSdiffi)/5.0)*Che1 - hcx2*Chc1;
dxdt_hc2 = fb*((PSact/csai2+PSdiffi)/5.0)*Che2 - hcx2*Chc2;
dxdt_hc3 = fb*((PSact/csai3+PSdiffi)/5.0)*Che3 - hcx2*Chc3;
dxdt_hc4 = fb*((PSact/csai4+PSdiffi)/5.0)*Che4 - hcx2*Chc4;
dxdt_hc5 = fb*((PSact/csai5+PSdiffi)/5.0)*Che5 - hcx2*Chc5;
dxdt_cent = 
  Qh*Che5 
  - Qh*Ccent 
  - CLr*Ccent 
  - Qmus*(Ccent-Cmus/Kp_mus) 
  - Qski*(Ccent-Cski/Kp_ski) 
  - Qadi*(Ccent-Cadi/Kp_adi);
dxdt_mus = Qmus*(Ccent-Cmus/Kp_mus);
dxdt_ski = Qski*(Ccent-Cski/Kp_ski);
dxdt_adi = Qadi*(Ccent-Cadi/Kp_adi);
dxdt_gut  = ktr*ehc3 - ka/fafg*gut;
dxdt_ehc1 = fbile*fh*(CLint/5.0)*(Chc1+Chc2+Chc3+Chc4+Chc5)-ktr*ehc1;
dxdt_ehc2 = ktr*(ehc1-ehc2);
dxdt_ehc3 = ktr*(ehc2-ehc3);
__END_ode__

// MODELED EVENTS:
__BEGIN_event__
__END_event__

// TABLE CODE BLOCK:
__BEGIN_table__
CP =  cent/Vcent;
CSA = icent/Vcent;
CSAliv = iliv1/dVliv;
_capture_[0] = CP;
_capture_[1] = CSA;
_capture_[2] = CSAliv;
__END_table__

