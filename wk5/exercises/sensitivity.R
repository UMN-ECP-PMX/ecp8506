
source(here::here("src/global.R"))
library(dplyr)
library(mrgsolve)
library(here)

#' Load the model called "pk2" (2-cmt pk) from the internal library
#' (`?modlib`)
#' 
#' Construct a simulation that shows how time to steady state depends
#' on volume of distribution (V2); look at 10, 50 and 100 L
#' while dosing 100 mg every day for a month
#' 

