// Source MD5: 35d347b8b646c8d7a12933ff8eb53a35

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
  double V;
  double KA;
  capture IPRED;
  capture DV;
}
// DECLARED VIA AUTODEC

// GLOBAL START USER CODE:

// DEFS:
#define __INITFUN___ _model_popex_main__
#define __ODEFUN___ _model_popex_ode__
#define __TABLECODE___ _model_popex_table__
#define __EVENTFUN___ _model_popex_event__
#define __CONFIGFUN___ _model_popex_config__
#define __REGISTERFUN___ R_init_popex
#define _nEQ 2
#define _nPAR 4
#define GUT_0 _A_0_[0]
#define CENT_0 _A_0_[1]
#define GUT _A_[0]
#define CENT _A_[1]
#define dxdt_GUT _DADT_[0]
#define dxdt_CENT _DADT_[1]
#define TVKA _THETA_[0]
#define TVCL _THETA_[1]
#define TVV _THETA_[2]
#define WT _THETA_[3]
#define ECL _xETA(1)
#define EV _xETA(2)
#define EKA _xETA(3)

