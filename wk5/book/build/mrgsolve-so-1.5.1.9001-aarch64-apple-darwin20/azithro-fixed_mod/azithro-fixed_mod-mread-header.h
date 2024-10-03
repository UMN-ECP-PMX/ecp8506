// Source MD5: 189c6ca289a9d23c507269fc1d587198

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
  double V1;
  double Q2;
  double V2;
  capture CP;
}
// DECLARED VIA AUTODEC

// GLOBAL START USER CODE:

// DEFS:
#define __INITFUN___ _model_azithro__fixed__mod_main__
#define __ODEFUN___ _model_azithro__fixed__mod_ode__
#define __TABLECODE___ _model_azithro__fixed__mod_table__
#define __EVENTFUN___ _model_azithro__fixed__mod_event__
#define __CONFIGFUN___ _model_azithro__fixed__mod_config__
#define __REGISTERFUN___ R_init_azithro-fixed_mod
#define _nEQ 4
#define _nPAR 8
#define GUT_0 _A_0_[0]
#define CENT_0 _A_0_[1]
#define PER2_0 _A_0_[2]
#define PER3_0 _A_0_[3]
#define GUT _A_[0]
#define CENT _A_[1]
#define PER2 _A_[2]
#define PER3 _A_[3]
#define dxdt_GUT _DADT_[0]
#define dxdt_CENT _DADT_[1]
#define dxdt_PER2 _DADT_[2]
#define dxdt_PER3 _DADT_[3]
#define TVCL _THETA_[0]
#define TVV1 _THETA_[1]
#define TVQ2 _THETA_[2]
#define TVV2 _THETA_[3]
#define Q3 _THETA_[4]
#define V3 _THETA_[5]
#define KA _THETA_[6]
#define WT _THETA_[7]
#define ETACL _xETA(1)
#define ETAV1 _xETA(2)
#define RUV _xEPS(1)

