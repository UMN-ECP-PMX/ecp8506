// Source MD5: f638b530e79a4f6da398d1c97b5f62cb

// PLUGINS:

// FIXED:
// No fixed parameters.

// NAMESPACES:

// MODEL HEADER FILES:
#include "mrgsolv.h"
#include "modelheader.h"

// INCLUDE databox functions:
#include "databox_cpp.h"

// USING plugins:

// INCLUDES:


// GLOBAL CODE BLOCK:
// GLOBAL VARS FROM BLOCKS & TYPEDEFS:
// DECLARED BY USER
typedef double capture;
namespace {
  double CLintall;
  double PSact;
  double PSdiffi;
  double PSdiffe;
  double CLint;
  double Vme;
  double Vae;
  double Vse;
  double Vmc;
  double Vac;
  double Vsc;
  double dVliv;
  double ikitot;
  double Ccent;
  double Cmus;
  double Cski;
  double Cadi;
  double Vhe;
  double Vhc;
  double Chc1;
  double Chc2;
  double Chc3;
  double Chc4;
  double Chc5;
  double Che1;
  double Che2;
  double Che3;
  double Che4;
  double Che5;
  double iCcent;
  double Cme;
  double Cse;
  double Cae;
  double Cmc;
  double Csc;
  double Cac;
  double iCliv1;
  double iCliv2;
  double iCliv3;
  double iCliv4;
  double iCliv5;
  double csai1;
  double csai2;
  double csai3;
  double csai4;
  double csai5;
  double hex2;
  double hcx2;
  capture CP;
  capture CSA;
  capture CSAliv;
}
// DECLARED VIA AUTODEC

// GLOBAL START USER CODE:

// DEFS:
#define __INITFUN___ _model_yoshikado__cpp_main__
#define __ODEFUN___ _model_yoshikado__cpp_ode__
#define __TABLECODE___ _model_yoshikado__cpp_table__
#define __EVENTFUN___ _model_yoshikado__cpp_event__
#define __CONFIGFUN___ _model_yoshikado__cpp_config__
#define __REGISTERFUN___ R_init_yoshikado_cpp
#define _nEQ 31
#define _nPAR 43
#define gut_0 _A_0_[0]
#define igut_0 _A_0_[1]
#define cent_0 _A_0_[2]
#define mus_0 _A_0_[3]
#define adi_0 _A_0_[4]
#define ski_0 _A_0_[5]
#define ehc1_0 _A_0_[6]
#define ehc2_0 _A_0_[7]
#define ehc3_0 _A_0_[8]
#define he1_0 _A_0_[9]
#define he2_0 _A_0_[10]
#define he3_0 _A_0_[11]
#define he4_0 _A_0_[12]
#define he5_0 _A_0_[13]
#define hc1_0 _A_0_[14]
#define hc2_0 _A_0_[15]
#define hc3_0 _A_0_[16]
#define hc4_0 _A_0_[17]
#define hc5_0 _A_0_[18]
#define icent_0 _A_0_[19]
#define me_0 _A_0_[20]
#define se_0 _A_0_[21]
#define ae_0 _A_0_[22]
#define mc_0 _A_0_[23]
#define sc_0 _A_0_[24]
#define ac_0 _A_0_[25]
#define iliv1_0 _A_0_[26]
#define iliv2_0 _A_0_[27]
#define iliv3_0 _A_0_[28]
#define iliv4_0 _A_0_[29]
#define iliv5_0 _A_0_[30]
#define gut _A_[0]
#define igut _A_[1]
#define cent _A_[2]
#define mus _A_[3]
#define adi _A_[4]
#define ski _A_[5]
#define ehc1 _A_[6]
#define ehc2 _A_[7]
#define ehc3 _A_[8]
#define he1 _A_[9]
#define he2 _A_[10]
#define he3 _A_[11]
#define he4 _A_[12]
#define he5 _A_[13]
#define hc1 _A_[14]
#define hc2 _A_[15]
#define hc3 _A_[16]
#define hc4 _A_[17]
#define hc5 _A_[18]
#define icent _A_[19]
#define me _A_[20]
#define se _A_[21]
#define ae _A_[22]
#define mc _A_[23]
#define sc _A_[24]
#define ac _A_[25]
#define iliv1 _A_[26]
#define iliv2 _A_[27]
#define iliv3 _A_[28]
#define iliv4 _A_[29]
#define iliv5 _A_[30]
#define dxdt_gut _DADT_[0]
#define dxdt_igut _DADT_[1]
#define dxdt_cent _DADT_[2]
#define dxdt_mus _DADT_[3]
#define dxdt_adi _DADT_[4]
#define dxdt_ski _DADT_[5]
#define dxdt_ehc1 _DADT_[6]
#define dxdt_ehc2 _DADT_[7]
#define dxdt_ehc3 _DADT_[8]
#define dxdt_he1 _DADT_[9]
#define dxdt_he2 _DADT_[10]
#define dxdt_he3 _DADT_[11]
#define dxdt_he4 _DADT_[12]
#define dxdt_he5 _DADT_[13]
#define dxdt_hc1 _DADT_[14]
#define dxdt_hc2 _DADT_[15]
#define dxdt_hc3 _DADT_[16]
#define dxdt_hc4 _DADT_[17]
#define dxdt_hc5 _DADT_[18]
#define dxdt_icent _DADT_[19]
#define dxdt_me _DADT_[20]
#define dxdt_se _DADT_[21]
#define dxdt_ae _DADT_[22]
#define dxdt_mc _DADT_[23]
#define dxdt_sc _DADT_[24]
#define dxdt_ac _DADT_[25]
#define dxdt_iliv1 _DADT_[26]
#define dxdt_iliv2 _DADT_[27]
#define dxdt_iliv3 _DADT_[28]
#define dxdt_iliv4 _DADT_[29]
#define dxdt_iliv5 _DADT_[30]
#define iKp_mus _THETA_[0]
#define iKp_adi _THETA_[1]
#define iKp_ski _THETA_[2]
#define iKp_liv _THETA_[3]
#define ifb _THETA_[4]
#define ikiu _THETA_[5]
#define imw _THETA_[6]
#define PSmus _THETA_[7]
#define PSski _THETA_[8]
#define PSadi _THETA_[9]
#define ifhCLint _THETA_[10]
#define ifafg _THETA_[11]
#define iClr _THETA_[12]
#define ika _THETA_[13]
#define itlag _THETA_[14]
#define Kp_ski _THETA_[15]
#define Kp_mus _THETA_[16]
#define Kp_adi _THETA_[17]
#define CLr _THETA_[18]
#define Vcent _THETA_[19]
#define fafg _THETA_[20]
#define ktr _THETA_[21]
#define ka _THETA_[22]
#define fb _THETA_[23]
#define fh _THETA_[24]
#define fbCLintall _THETA_[25]
#define fbile _THETA_[26]
#define gamma _THETA_[27]
#define beta _THETA_[28]
#define Rdiff _THETA_[29]
#define tlag _THETA_[30]
#define Qh _THETA_[31]
#define Qmus _THETA_[32]
#define Qski _THETA_[33]
#define Qadi _THETA_[34]
#define Vliv _THETA_[35]
#define Vmus _THETA_[36]
#define Vski _THETA_[37]
#define Vadi _THETA_[38]
#define exFliv _THETA_[39]
#define exFmus _THETA_[40]
#define exFski _THETA_[41]
#define exFadi _THETA_[42]

