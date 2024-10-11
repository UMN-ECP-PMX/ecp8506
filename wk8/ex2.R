
# Library -----------------------------------------------------------------

library(mrgsolve)
library(tidyverse)
library(here)

# Load mrgsolve model -----------------------------------------------------

mod <- mread("hwwk6.cpp", project=here("wk8/model"))

mod          # Check model configuration
see(mod)     # Check model code
mod@code     # Check model code again
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

# Load cov_eta ------------------------------------------------------------

cov_eta <- read.csv(here("wk8/data/cov_eta.csv"), header=TRUE)
head(cov_eta)

# Simulation with cov_eta -------------------------------------------------

out1 <- mod %>% 
  data_set(cov_eta) %>%              # Simulate using `cov_eta` as data set 
  mrgsim(obsonly=TRUE,               # Keep observation records only
         etasrc="data.all",          # Search for ETAs in input data (`cov_eta`)
         output="df",                # Output simulation results as data frame
         Req="IPRED,AUC,CL,V,KA,D1", # Output variables
         recover="WT,AGE,DOSE")      # Variables copied from input data (`cov_eta`)

# Simulation graphical checks ---------------------------------------------

out1 %>% mutate(Dose = paste0(DOSE/1000, " mg")) %>% 
  mutate(Dose = fct_reorder(Dose, DOSE)) %>% 
  ggplot(aes(x=TIME, y=IPRED, group=ID))+
  facet_wrap(~Dose, ncol=1, scales="free")+
  geom_line()+xlab("Time (hours)")+ylab("Concentration (ug/L)")+
  theme_bw()+theme(legend.position = "bottom")

# Calculate Cmax and AUC0-48 ----------------------------------------------

# Generate a table that has all the individual exposures
tab1 <- out1 %>% group_by(ID, DOSE) %>% 
  summarise(`Cmax`=max(IPRED), 
            `AUC0-48`=max(AUC)) %>% 
  ungroup()
tab1

# Graphical check tab1 ----------------------------------------------------

sim_check <- function(tab, exposure, ylab){
  
  p <- tab %>% mutate(Dose = paste0(DOSE/1000, " mg")) %>% 
    mutate(Dose = fct_reorder(Dose, DOSE)) %>% 
    ggplot(aes(x=Dose, y={{exposure}}))+
    geom_point()+xlab("")+ylab(ylab)+
    theme_bw()+theme(legend.position = "bottom")
  
  return(p)
}

p1 <- sim_check(tab1, `Cmax`   , 
          expression(C[max] (ug/L)))         # Plot Cmax vs dose
p2 <- sim_check(tab1, `AUC0-48`, 
          expression(AUC[0-48] (ug*hour/L))) # Plot AUC vs dose

pmplots::pm_grid(list(p1,p2), ncol=1)

# Simulation using iparam -------------------------------------------------

# Load model for direct EBE simulation
mod_ebe <- mread("hwwk6_ebe.cpp", project=here("wk8/model"))
mod_ebe <- mod_ebe %>% zero_re()
mod_ebe <- update(mod_ebe, end=48, delta=0.1)

#' Check model random effects again to see what has been changed?  
revar(mod)

# Load iparam
iparam <- read.csv(here("wk8/data/iparam.csv"), header=TRUE)
head(iparam)
head(cov_eta)

# Simulate
out2 <- mod_ebe %>% 
  data_set(iparam) %>%                # Simulate using `iparam` as data set 
  mrgsim(obsonly=TRUE,                # Keep observation records only
         output="df",                 # Output simulation results as data frame
         Req="IPRED,AUC,CL,V,KA,D1",  # Output variables
         recover="WT,AGE,DOSE")       # Variables copied from input data (`iparam`)

# Check identity between `out1` and `out2` --------------------------------

# Check individual parameters `out1` and `out2`

check_ind_param <- function(param){
  p <- ggplot()+
    geom_point(aes(x=out1[[param]], y=out2[[param]]))+
    xlab(paste0(param, " Method 1"))+
    ylab(paste0(param, " Method 2"))+
    geom_abline(aes(slope=1, intercept=0), linetype=2, color="red")+
    theme_bw()
  return(p)
}

pList <- map(c("CL","V","KA","D1"), check_ind_param)
pmplots::pm_grid(pList)

# Check IPRED
xx1 <- dplyr::select(out1, ID, TIME, IPRED_mod1=IPRED)
xx2 <- dplyr::select(out2, ID, TIME, IPRED_mod2=IPRED)
xx <- left_join(xx1, xx2)

id <- sample(1:max(xx$ID), 9)

ggplot(xx[xx$ID %in% id & xx$TIME %% 1 == 0, ], 
       aes(x=IPRED_mod1, y=IPRED_mod2))+
  geom_point()+
  geom_abline(aes(slope=1, intercept=0), linetype=2, color="red")+
  facet_wrap(~ID, ncol = 3, scales = "free")+
  xlab(paste0("IPRED Method 1"))+
  ylab(paste0("IPRED Method 2"))+
  theme_bw()



