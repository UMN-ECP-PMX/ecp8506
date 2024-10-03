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

mod <- mread(here("model/meropenem-pk.mod"))

ev1 <- ev(amt = 500, ii = 8, addl = 2, rate = 0)
ev2 <- ev(amt = 1000, ii = 8, addl = 2, rate = amt / 3)

data <- as_data_set(ev1, ev2)

mrgsim(mod, data) %>% plot("CC")
