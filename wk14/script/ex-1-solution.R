library(mrgsolve)
library(mrgsim.sa)

#' Load the `irm1` model from the internal model library
#' Look at the code to see what is happening with this model
mod <- modlib("irm1")
see(mod)

#' Update the model object
#' - simulation end time = 120
#' - simulation output delta = 0.1
#' - only need RESP in the simulated output
mod <- update(mod, end = 120, delta = 0.1)
mod <- update(mod, outvars = "RESP")

#' Update parameters in the model
#' - KIN = 1, KOUT = 0.2

param(mod)
mod <- param(mod, KIN = 1, KOUT = 0.20)

#' Dose is 100 mg x1
dose <- ev(amt = 100)

#' Sensitivity analysis using parseq_cv on 
#' - KIN, KOUT, V2, CL
mod %>% 
  ev(dose) %>% 
  parseq_cv(KIN, KOUT, V2, CL) %>% 
  sens_each() %>% 
  sens_plot(layout = "facet_grid")


#' Now, update CL to some very small number (but larger than 0)
#' Turn on the non-linear clearance by setting VMAX to 1 and 
#' KM to 1
mod <- param(mod, CL = 0.001, VMAX = 1, KM = 1)

#' Sensitivity analysis on CL, VMAX, V2 and plot
mod %>% 
  ev(dose) %>% 
  parseq_cv(CL, VMAX, V2) %>% 
  sens_each() %>% 
  sens_plot(layout = "facet_grid")

