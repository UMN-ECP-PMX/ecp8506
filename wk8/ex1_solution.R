
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

# Assemble a data frame for simulation ----------------------------------

#' We can use `expand.idata` function in `mrgsolve` package 
#' to assemble the data frame

data <- data.frame(ID=1:3, DOSEMGKG = 0.1, # 0.1 mg/kg dosing
                   WT = c(10,40,70),       # 10, 40 and 70 kg body weight
                   AGE = c(2,10,18)) %>%   # 2, 10, 18 years old
  mutate(AMT = DOSEMGKG*WT,                # Calculate actual dosing
         EVID = 1,                         # Dosing records
         RATE = -2,                        # To enable the use of `D1` in `hwwk6.mod`
         CMT = 1,                          # Dose in `DEPOT` 
         TIME=0)                           # Start dose at time 0

# Simulation --------------------------------------------------------------

#' `obsonly=TRUE` requests observation records only in the output
#' `output="df"` makes the output as a data frame
#' `Req="IPRED,AUC"` request the output of IPRED and AUC
#' `recover="WT,AGE"` recover the WT and AGE in the input `data`

out <- mrgsim(mod, data, obsonly=TRUE, 
              output="df", Req="IPRED,AUC", 
              recover="WT,AGE")

# Simulation graphical checks ---------------------------------------------

out %>% mutate(Group=paste0(WT, " kg and ", AGE, " years")) %>% 
  ggplot(aes(x=TIME, y=IPRED, group=ID, color=Group))+
  geom_line()+xlab("Time (hours)")+ylab("Concentration (ug/L)")+
  theme_bw()+
  theme(legend.position = "bottom")

# Calculate Cmax and AUC0-48 ----------------------------------------------

tab <- out %>% group_by(WT, AGE) %>% 
  summarise(`Cmax`=max(IPRED), 
            `AUC0-48`=max(AUC)) %>% 
  ungroup()

# Format table ------------------------------------------------------------

tab %>% mutate(across(`Cmax`:`AUC0-48`, ~round(.x, digits = 2))) %>% 
  rename(`WT (kg)`=`WT`, 
         `AGE (years)`=`AGE`, 
         `Cmax (ug/L)`=`Cmax`, 
         `AUC0-48 (ug*hour/L)`=`AUC0-48`) %>% 
  knitr::kable()

