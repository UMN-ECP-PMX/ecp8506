source(here::here("src/global.R"))
library(dplyr)
library(mrgsolve)
library(here)

#' - Load the `meropenem-pk` model from the `model` directory
#' 
#' - Simulate the following scenarios:
#'   - 500 mg IV bolus q8h x 3
#'   - 1000 mg IV over 3 hours q8h x3

#' Look at the `CP` output

