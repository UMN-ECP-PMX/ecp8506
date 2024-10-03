// Source MD5: 45bdea2bc25b46a69124969458a61641

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
  double CL;
  double VC;
  double VP1;
  double VP2;
  double Q1;
  double Q2;
  double KA;
  double VMAX;
  double KM;
  double FSC;
  double KSYN;
  double KDEG;
  double IC50;
  double CLNL;
  double IPRED;
  double PKEPS;
  double PKDV;
  double PDDV;
  capture dNTX;
}
// DECLARED VIA AUTODEC

// GLOBAL START USER CODE:
#define CP (CENT/(VC/1000000.0))

// DEFS:
#define __INITFUN___ _model_opg_main__
#define __ODEFUN___ _model_opg_ode__
#define __TABLECODE___ _model_opg_table__
#define __EVENTFUN___ _model_opg_event__
#define __CONFIGFUN___ _model_opg_config__
#define __REGISTERFUN___ R_init_opg
#define _nEQ 5
#define _nPAR 14
#define N_SC 1
#define F_SC _F_[0]
#define ALAG_SC _ALAG_[0]
#define R_SC _R_[0]
#define D_SC _D_[0]
#define SC_0 _A_0_[0]
#define CENT_0 _A_0_[1]
#define P1_0 _A_0_[2]
#define P2_0 _A_0_[3]
#define NTX_0 _A_0_[4]
#define SC _A_[0]
#define CENT _A_[1]
#define P1 _A_[2]
#define P2 _A_[3]
#define NTX _A_[4]
#define dxdt_SC _DADT_[0]
#define dxdt_CENT _DADT_[1]
#define dxdt_P1 _DADT_[2]
#define dxdt_P2 _DADT_[3]
#define dxdt_NTX _DADT_[4]
#define IV _THETA_[0]
#define TVCL _THETA_[1]
#define TVVC _THETA_[2]
#define TVVP1 _THETA_[3]
#define TVVP2 _THETA_[4]
#define TVQ1 _THETA_[5]
#define TVQ2 _THETA_[6]
#define TVKA _THETA_[7]
#define TVVMAX _THETA_[8]
#define TVKM _THETA_[9]
#define TVFSC _THETA_[10]
#define TVKSYN _THETA_[11]
#define TVKDEG _THETA_[12]
#define TVIC50 _THETA_[13]
#define ECL _xETA(1)
#define EVC _xETA(2)
#define EVP1 _xETA(3)
#define EVP2 _xETA(4)
#define EQ1 _xETA(5)
#define EKA _xETA(6)
#define EFSC _xETA(7)
#define EKSYN _xETA(8)
#define EKDEG _xETA(9)
#define EIC50 _xETA(10)
#define ADDIV _xEPS(1)
#define ADDSC _xEPS(2)
#define PDPROP _xEPS(3)
#define PDADD _xEPS(4)

