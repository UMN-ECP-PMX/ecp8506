
source(here::here("src/global.R"))
library(dplyr)
library(mrgsolve)


#' Choose a `PKPD` model from the internal model library 
#' (`?modlib` scroll down to "Examples") to explore

#' - Check the parameter values (`param`)
#' - Check the compartments and initial values (`init`)
#' - Review the model code (`see`)

mod <- modlib()


