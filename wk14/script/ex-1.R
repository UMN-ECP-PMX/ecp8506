library(mrgsolve)
library(mrgsim.sa)

#' Load the `irm1` model from the internal model library
#' Look at the code to see what is happening with this model
mod <- # INSERT YOUR CODE
see(mod)

#' Update the model object
#' - simulation end time = 120
#' - simulation output delta = 0.1
#' - only need RESP in the simulated output

# INSERT YOUR CODE
# INSERT YOUR CODE

#' Update parameters in the model
#' - KIN = 1, KOUT = 0.2
param(mod)
# INSERT YOUR CODE

#' Dose is 100 mg x1
dose <- ev()

#' Sensitivity analysis using parseq_cv on 
#' - KIN, KOUT, V2, CL
mod %>% 
  ev(dose) %>% 
  # INSERT YOUR CODE
  sens_each() %>% 
  sens_plot(layout = "facet_grid")


#' Now, update CL to 0.001 (essentially zero)
#' Turn on the non-linear clearance by setting VMAX to 1 and 
#' KM to 1

# INSERT YOUR CODE

#' Sensitivity analysis on CL, VMAX, V2 and plot using `dose` event object
mod %>% 
  # INSERT YOUR CODE
  # INSERT YOUR CODE
  # INSERT YOUR CODE
  sens_plot(layout = "facet_grid")
