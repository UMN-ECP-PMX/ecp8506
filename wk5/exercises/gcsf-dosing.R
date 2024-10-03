source(here::here("src/global.R"))
library(dplyr)
library(mrgsolve)
library(here)

#' 
#' G-CSF can be dosed SC or IV at 1 to 10 ug / kg
#' You will practice implementing these simulations
#' with the model called `gcsf-pk.mod` in the model directory
#' 
 
mod <- mread_cache("model/")

#' First, create an event object for 
#' SC administration of 5 mcg/kg (WT = 70 kg)
#' Dose goes in the `ABS` compartment



#' Simulate and plot a single dose
#' Look at GCSF PK and ANC over 120 hours

