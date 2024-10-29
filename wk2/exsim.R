
library(mrgsolve)
library(dplyr)
library(ggplot2)

mod <- mread("pk1", modlib())
mod <- update(mod, end=240, delta=0.5)
mod
param(mod)

sims <- mod %>% 
  ev(amt=100, ii=12, addl=10) %>% 
  mrgsim(obsonly=TRUE) %>% 
  as.data.frame()

sims %>% ggplot(aes(x=time))+
  geom_ribbon(aes(ymin = 7, ymax = 9), alpha=0.2)+
  ylab("Cp")+xlab("Time")+
  geom_line(aes(y=CP))+theme_bw()