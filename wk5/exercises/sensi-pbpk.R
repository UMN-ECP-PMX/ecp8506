
source(here::here("src/global.R"))
library(dplyr)
library(mrgsolve)
library(here)

#' Here is a PBPK model for DDI between a statin and CsA
mod <- mread("yoshikado", here("model"), delta = 0.1, end = 12) 

see(mod)

#' A single CsA dose
csa <- ev(amt = 2000, cmt = 2)

#' A single pitavastatin dose 0.5 hours after CsA
pit <- ev(amt = 30, cmt = 1, time = 0.5)

#' The ddi dosing intervention
ddi <- seq(csa, wait = 0.5, pit)


#' Find the `ikiu` parameter value
#' Generate a sensitivity analysis on this parameter, 
#' varying with uniform distribution between 0.1 and 5 times
#' the nominal value; do this with an idata set
#' 
#' - Make a plot
#' - Summarize the variability in Cmax
#' - Summarize the variability in AUC
#' 

