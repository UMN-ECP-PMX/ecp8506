// Source MD5: 87fcc3c5f0062b4694297712eea17e0a

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
  double p;
  double eps;
  capture logV;
  capture logT;
  capture logI;
  capture logE;
  capture logL;
  capture year;
}
// DECLARED VIA AUTODEC

// GLOBAL START USER CODE:

// DEFS:
#define __INITFUN___ _model_conway_main__
#define __ODEFUN___ _model_conway_ode__
#define __TABLECODE___ _model_conway_table__
#define __EVENTFUN___ _model_conway_event__
#define __CONFIGFUN___ _model_conway_config__
#define __REGISTERFUN___ R_init_conway
#define _nEQ 6
#define _nPAR 21
#define art_0 _A_0_[0]
#define T_0 _A_0_[1]
#define L_0 _A_0_[2]
#define I_0 _A_0_[3]
#define V_0 _A_0_[4]
#define E_0 _A_0_[5]
#define art _A_[0]
#define T _A_[1]
#define L _A_[2]
#define I _A_[3]
#define V _A_[4]
#define E _A_[5]
#define dxdt_art _DADT_[0]
#define dxdt_T _DADT_[1]
#define dxdt_L _DADT_[2]
#define dxdt_I _DADT_[3]
#define dxdt_V _DADT_[4]
#define dxdt_E _DADT_[5]
#define epsilon _THETA_[0]
#define pv2 _THETA_[1]
#define kdlta _THETA_[2]
#define n _THETA_[3]
#define c _THETA_[4]
#define delta _THETA_[5]
#define N _THETA_[6]
#define alpha_L _THETA_[7]
#define rho _THETA_[8]
#define d_L _THETA_[9]
#define a _THETA_[10]
#define lambda _THETA_[11]
#define d _THETA_[12]
#define beta _THETA_[13]
#define lambda_e _THETA_[14]
#define b_e _THETA_[15]
#define k_b _THETA_[16]
#define d_e _THETA_[17]
#define k_d _THETA_[18]
#define mu _THETA_[19]
#define m _THETA_[20]

