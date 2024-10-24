
# Library -----------------------------------------------------------------

library(mrgsolve)
library(tidyverse)
library(here)

# Load mrgsolve model -----------------------------------------------------

mod <- mread("hwwk6.cpp", project=here("wk10/model"))

mod          # Check model configuration
see(mod)     # Check model code
param(mod)   # Check model parameters
omat(mod)    # Check omega matrix
smat(mod)    # Check sigma matrix
revar(mod)   # Check model random effects 
outvars(mod) # Check model output variables

# Adjust model configurations ---------------------------------------------

#' Set `SIGMA` matrices to zero to remove RUV
mod <- mod %>% zero_re(sigma)

#' Check model random effects again to see what has been changed?  
revar(mod)

#' Configure the model to simulate up to 96 hour
mod <- update(mod, end=96, delta=1)

# Create dataset for simulation -------------------------------------------

#' Load demographics
pop <- read.csv(here("wk10/data/pop.csv"))

#' Put together doses

data <- map(seq(0.1,1.2,0.1), # Test dose 0.1-1.2 mg/kg
            function(dose){
              xx <- pop %>% 
                mutate(DOSE=dose) %>% 
                mutate(AMT=DOSE*WT, TIME=0, RATE=-2, 
                       EVID=1, CMT=1, ADDL=7, II=12) %>%
                dplyr::select(ID, TIME, AMT, CMT, 
                              RATE, EVID, ADDL, II, everything())
              return(xx)}
            ) %>% bind_rows() %>% mutate(ID = 1:n())
  
# Simulation --------------------------------------------------------------

withr::with_seed(
  seed=123, 
  out <- mrgsim(mod, data, 
                obsonly=TRUE, 
                output="df", 
                Req="IPRED,AUC", 
                recover="DOSE,AGE,WT"))

# Visualize simulation ----------------------------------------------------

summ <- out %>% 
  group_by(DOSE, TIME) %>% 
  summarise(
    Q10 = quantile(IPRED, prob=0.1), 
    Q50 = quantile(IPRED, prob=0.5), 
    Q90 = quantile(IPRED, prob=0.9)) %>% 
  mutate(DOSE=paste0(DOSE, " mg/kg"))
  
summ %>% ggplot(aes(x=TIME))+
  geom_line(aes(y=Q50))+
  geom_ribbon(aes(ymin=Q10, ymax=Q90), alpha=0.25)+
  geom_hline(yintercept=1,linetype="dashed") +
  geom_hline(yintercept=15,linetype="dashed") +
  xlab("Time (hours)")+ylab("Drug X concentration (ug/L)")+
  facet_wrap(~DOSE)+
  theme_bw()

# Calculate fraction with Cmin > 1 ug/L -----------------------------------

#' calculate what fraction of trough concentrations are above 1 ug/L at 96 hours
fraction_above <- function(x,boundary) { length(x[x>boundary])/length(x) }

#' Summrise Cmin by individual
cmin <- out %>% group_by(ID, DOSE) %>% 
  summarise(Cmin=IPRED[TIME==96], .groups = "drop") %>% 
  mutate(Dose=paste0(DOSE, " mg/kg"))

#' Check Cmin distributions by dose
ggplot(cmin)+geom_histogram(aes(x=Cmin))+
  geom_vline(xintercept=1,linetype="dashed",color="red") + # Cmin threshold
  facet_wrap(~Dose)+
  theme_bw()

#' Calculate and plot fraction with Cmin > 1 ug/L
above <- cmin %>% group_by(DOSE) %>% 
  summarize(FRAC=fraction_above(Cmin,1))
knitr::kable(above)

ggplot(data=above) + 
  geom_line(aes(x=DOSE,y=FRAC),color='red') + 
  geom_hline(yintercept=0.8,linetype="dashed") +
  xlab("Dose (mg/kg)") + ylab("Fraction Cmin > 1 ug/L")+
  theme_bw()

# It's your turn! ---------------------------------------------------------

#' Perform stochastic simulation to see
#' at what dose level > 90% of patients can 
#' have steady-state Cmax < 15 ug/L

