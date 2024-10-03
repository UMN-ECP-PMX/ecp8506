source(here::here("src/global.R"))
library(dplyr)
library(mrgsolve)

#' There is a model _in this directory_ called `two-compartment.mod`. 
#' 
#' It's supposed to be a two-compartment model, but it looks like it 
#' is actually coded as a one-compartment model
#' 
#' 
#' Modify this file to make it a two-compartment model. You'll 
#' have to add some parameters, a compartment, and update the 
#' differential equations. 
#' 
#' The answer model is also given in this directory. 
#' 

mod <- mread("two-compartment.mod", project = here("exercises"))

param(mod)
init(mod)

# mread("two-compartment-answer.mod", project = here("exercises"))
