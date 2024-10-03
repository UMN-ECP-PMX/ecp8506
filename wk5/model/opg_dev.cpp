$PROB
# Zierhut et al. (2008)
  - Population PK-PD model for Fc-osteoprotegerin in healthy 
    postmenopausal women
  - J Pharmacokinet Pharmacodyn 35(4): 379-99 

  
// Structure:    
//   SubQ dosing
//   3-cmt model / Linear / MM elimination
//   Urinary N-telopeptide


// Parameters
//   IV dose indicator
//   Clearance 168 ml/h
//   Central volume 2800 ml
//   Peripheral volume 443 ml
//   Peripheral volume 269 ml
//   Inter-comp. clearance 15.5 ml/h
//   Inter-comp. clearance 3.02 ml/h
//   Absorption rate constant 0.0131 /hr

//   Max. velocity 13300 ng/h
//   Michaelis constant 6.74 ng/ml
//   Bioavailability fraction, 0.0719
//   NTX synthesis rate constant 0.864
//   NTX degredation rate constant 0.0204 /hr
//   IC50 5.38 ng/ml


// CP (ng/mL) is 1000*1000*CENT/VC
// use c++ pre-processor directive

// Random effects on 
//   - CL, VC, VP1, VP2, Q1, KA, FSC, KSYN, KDEG, IC50
// Initial Urinary NTX is KSYN / KDEG


// Inter-individual variability
// Clearance 0.0391
// Central volume 0.0102
// Peripheral volume 0.0144
// Peripheral volume 0.0333
// Inter.comp clearance 0.0379
// Absorption rate constant 0.0457
// F-sc 0.263
$OMEGA

$OMEGA @block

$OMEGA

// Inter-individual variability
//   Synthesis rate constant 0.281
//   Degredation rate constant 0.0325
//   Covariance: 0.0867
//   IC-50 1.18
// 


$CAPTURE PKDV PDDV


// Residual error
//   Additive log-scale, IV dose 0.0193
//   Additive log-scale, SC dose 0.7330
//   Proportional NTX, 0.0407
//   Additive NTX, 20.7


// Differential equations
// CLNL, SC, CENT, P1, P2, NTX



// Error model
// IV dose indicator picks add ruv
// Only take proportional error for PD
// Need PKDV and PDDV

    
    
