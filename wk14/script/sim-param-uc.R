
# Library
library(dplyr)
library(simpar)
library(here)
library(bbr)

# Load model
modDir <- here("wk6", "nm-model")
mod <- read_model(.path=file.path(modDir, "106"))

# Load model summaries
sum <- mod %>% model_summary()
th    <- bbr::get_theta(sum) # Get THETA estimates
om    <- bbr::get_omega(sum) # Get OMEGA estimates
sg    <- bbr::get_sigma(sum) # Get SIGMA estimates
covar <- bbr::cov_cor(sum)$cov_theta # Get THETA covariance matrix

nmdata <- bbr::nm_data(mod) %>% filter(is.na(C), BLQ==0)

nsub <- length(unique(nmdata$ID))
nobs <- nmdata %>% filter(EVID==0) %>% nrow()

# Simulate parameter uncertainty
set.seed(12345)
uc <- simpar(
  nsim=1000, 
  theta=th, 
  covar=covar, 
  omega=om, 
  odf=160, # >= nid 
  sigma=sg, 
  sdf=3142 # >= nobs
) %>% as.data.frame()

# View(uc)

write.csv(uc, here("wk14", "data", "uc.csv"), row.names=FALSE, quote=FALSE)
