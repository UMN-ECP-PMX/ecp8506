
# Library -----------------------------------------------------------------

library(mrgsolve)
library(tidyverse)
library(here)

# Load mrgsolve model -----------------------------------------------------

mod <- mread("hwwk6.cpp", project=here("wk8/model"))

mod          # Check model configuration
see(mod)     # Check model code
param(mod)   # Check model parameters
omat(mod)    # Check omega matrix
smat(mod)    # Check sigma matrix
revar(mod)   # Check model random effects 
outvars(mod) # Check model output variables

# Adjust model configurations ---------------------------------------------

#' Set `OMEGA` and `SIGMA` matrices to zero to remove IIV and RUV
mod <- mod %>% zero_re()

#' Check model random effects again to see what has been changed?  
revar(mod)

#' You can also do this separately by
omat(mod)
smat(mod)

#' Configure the model to simulate up to 48-hour
#' for the calculation of AUC0-48
mod <- update(mod, end=48, delta=0.1)

# Simulation example ------------------------------------------------------

#' Perform simulation
#' `obsonly=TRUE` requests observation records only in the output
#' `output="df"` makes the output as a data frame
#' `Req="IPRED,AUC"` request the output of IPRED and AUC

out_example <- mod %>% 
  ev(amt=0.1*10, # Calculate total dose "0.1 mg/kg * 10 kg"
     rate=-2, # Enable the use of `D1`
     time=0, cmt=1) %>% 
  mrgsim(param=list(WT=10, AGE=2), # 10 kg & 2 years old
         obsonly=TRUE, 
         output="df", 
         Req="IPRED,AUC")

#' Check simulation output
head(out_example)

#' Graphical check simulation output
out_example %>% ggplot(aes(x=time, y=IPRED))+
  geom_line()+ # line plot
  xlab("Time (hours)")+ylab("Concentration (ug/L)") # Changes X and Y axis labels

#' Calculate `Cmax` and `AUC0-48`
out_example %>% summarise(Cmax=max(IPRED), `AUC0-48`=max(AUC))

# It's your turn! ---------------------------------------------------------

#' 1. Perform simulation for a typical subject with
#'  (1). 2  years old AGE, 10 kg WT
#'  (2). 10 years old AGE, 40 kg WT
#'  (3). 18 years old AGE, 70 kg WT
#' 2. Graphical check the output
#' 3. Calculate `Cmax` and `AUC0-48` for each typical subject





