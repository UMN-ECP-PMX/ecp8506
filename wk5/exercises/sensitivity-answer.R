
source(here::here("src/global.R"))
library(dplyr)
library(mrgsolve)
library(here)
library(ggplot2)
theme_set(theme_bw() + theme(legend.position = "top"))

#' Load the model called "pk2" (2-cmt pk) from the internal library
#' (`?modlib`)
#' 
#' Construct a simulation that shows how time to steady state depends
#' on volume of distribution (V2); look at 10, 50 and 100 L
#' while dosing 100 mg every day for a month
#' 

mod <- modlib("pk2")

idata <- data.frame(V2 = c(10, 50, 100))

doses <- ev(amt = 100, ii = 24, total = 28)

out <- mrgsim_ei(
  mod, 
  doses, 
  idata,
  end = 168*4, 
  delta = 0.1, 
  recover = "V2", 
  output = "df"
)

ggplot(out, aes(time, CP, color = factor(V2))) + 
  geom_line()
