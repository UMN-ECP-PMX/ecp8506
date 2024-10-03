// Source MD5: 227a7897844e72a95f7e950b23dc134d

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
// DECLARED VIA AUTODEC

// GLOBAL START USER CODE:
#define CP (CENT/V)

// DEFS:
#define __INITFUN___ _model_pk1_main__
#define __ODEFUN___ _model_pk1_ode__
#define __TABLECODE___ _model_pk1_table__
#define __EVENTFUN___ _model_pk1_event__
#define __CONFIGFUN___ _model_pk1_config__
#define __REGISTERFUN___ R_init_pk1
#define _nEQ 2
#define _nPAR 3
#define EV_0 _A_0_[0]
#define CENT_0 _A_0_[1]
#define EV _A_[0]
#define CENT _A_[1]
#define dxdt_EV _DADT_[0]
#define dxdt_CENT _DADT_[1]
#define CL _THETA_[0]
#define V _THETA_[1]
#define KA _THETA_[2]

