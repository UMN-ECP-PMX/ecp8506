
source(here::here("src/global.R"))
library(dplyr)
library(mrgsolve)
library(here)

#' - Model: `model/gcsf.mod`
#' 
#' - Simulate 2.5, 5, and 10 mcg/kg assuming 50, 70, 90 kg individual
#' - Simulate 2.5, 5, and 10 mcg/kg assuming log(WT) ~ N(mean=log(80),sd=0.1)
#' 
#' - Do daily SC dosing x 7d; put the dose into the `ABS` compartment
#' 

mod <- mread_cache("model/gcsf.mod")






