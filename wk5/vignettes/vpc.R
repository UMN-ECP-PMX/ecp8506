#' ---
#' title: Visual Predictive Check
#' ---
#' 
#' # Required packages
library(tidyverse)
library(mrgsolve)
library(vpc)
library(glue)
library(here)

options(mrgsolve.project = here("model/pk"))

mrg_vpc_theme = new_vpc_theme(list(
  sim_pi_fill = "steelblue3", sim_pi_alpha = 0.5,
  sim_median_fill = "grey60", sim_median_alpha = 0.5
))

runno <- 106

#' This should reflect `model/pk/106.ctl`
mod <- mread(glue("{runno}.mrgsolve"))

csv <- read_csv(here("data/derived/analysis3.csv"), na = ".")
tab <- read_table(here(glue("model/pk/{runno}/{runno}.tab")), skip = 1)
csv$DV <- NULL

data <- left_join(csv,tab)

#' # First, validate
#' 
#' We can do this with PRED or IPRED
#' 
#' Checking PRED
#'  
out <- mrgsim(
  zero_re(mod), 
  data = data, 
  obsonly = TRUE, 
  recover = "PRED",
  digits = 5
)

summary(out$PRED - out$Y)

#' Now, check IPRED 
#' 
#' Load in etas
par <- read_table(here(glue("model/pk/{runno}/{runno}par.tab")), skip = 1)
etas <- distinct(par, ETA1, ETA2, ETA3)
etas$ID <- unique(data$ID)
head(etas)

out <- mrgsim(
  zero_re(mod), 
  data = data, 
  idata = etas,
  obsonly = TRUE, 
  recover = "REFERENCE = IPRED",
  Req = "TEST = IPRED",
  etasrc = "idata.all", 
  digits = 5
)

summary(100*(out$TEST - out$REFERENCE)/out$REFERENCE)


#' # Simulate the vpc
#' 
#' ## Take single dose only
sad_mad <- filter(data, STUDYN <= 2) %>% select(-C,-USUBJID)

#' # Set up the simulation
#' 
#' Create a function to simulate out one replicate
sim <- function(rep, data, model) {
  mrgsim(
    model, 
    data = data,
    recover = "RF,STUDY,DOSE,EVID,PRED", 
    Req = "Y", 
    output = "df"  
  ) %>%  mutate(irep = rep)
}

#' Simulate data

#' Just 100 replicates for now
isim <- seq(100)

set.seed(86486)
sims <- lapply(
  isim, sim, 
  data = sad_mad, 
  mod = mod
) %>% bind_rows()


#' Filter both the observed and simulated data
#' For the observed data, we only want actual observations that weren't BLQ
#' For the simulated data, we take simulated observations that were above LQ
fsad_mad <-  filter(sad_mad,  EVID==0, BLQ ==0)
fsims <- filter(sims, EVID==0, Y >= 10)

#' This will dose-normalize the concentrations so we can put them all on 
#' the same plot
fsad_mad <-  mutate(fsad_mad,  DVN = DV/DOSE)
fsims <- mutate(fsims, YN = Y/DOSE)

#' # Create the plot
#' 
#' Pass observed and simulated data into vpc function
p1 <- vpc(
  obs = fsad_mad,
  sim = fsims,
  stratify = "STUDY",
  obs_cols = list(dv = "DVN"),
  sim_cols=list(dv="YN", sim="irep"), 
  log_y = TRUE,
  pi = c(0.05, 0.95),
  ci = c(0.025, 0.975), 
  facet = "columns",
  show = list(obs_dv = TRUE), 
  vpc_theme = mrg_vpc_theme
) 

p1 <- 
  p1 +  
  theme_bw() + 
  ylab("Dose-normalized concentration (ng/mL)")

p1

#' # Stratify on RF
#' 
#' Include multi-dose data
#' 
rf_data <- filter(data, STUDYN==3) 

set.seed(54321)
rf_sims <- lapply(
  isim, sim, 
  data = rf_data, 
  mod = mod
) %>% bind_rows()


#' Filter both the observed and simulated data
f_rf_data <- filter(rf_data, EVID==0, BLQ ==0)
f_rf_sims <- filter(rf_sims, EVID==0, Y >= 10)

f_rf_data <- mutate(f_rf_data, DVN = DV/DOSE)
f_rf_sims <- mutate(f_rf_sims, YN  = Y/DOSE)

p2 <- vpc(
  obs = f_rf_data,
  sim = f_rf_sims,
  stratify = "RF",
  obs_cols = list(dv = "DVN"),
  sim_cols=list(dv="YN", sim="irep"), 
  log_y = TRUE,
  pi = c(0.05, 0.95),
  ci = c(0.025, 0.975), 
  show = list(obs_dv = TRUE), 
  vpc_theme = mrg_vpc_theme
) 

p2 <- 
  p2 +  
  theme_bw() + 
  ylab("Dose-normalized concentration (ng/mL)")

p2

#' # Pred-corrected VPC
#' 
#' 
#' First, generate PRED for all the observations
pred <- mrgsim(zero_re(mod), data = data)

data$PRED <- pred$Y

anyNA(data$PRED)

#' ## Take single dose only
sad_mad <- filter(data, STUDYN <= 2)

set.seed(90807)
sims <- lapply(
  isim, sim, 
  data = sad_mad, 
  mod = mod
) %>% bind_rows()

#' Subset observations and simulated data
fsad_mad <-  filter(sad_mad,  EVID==0, BLQ ==0)
fsims <- filter(sims, EVID==0, Y >= 10)

p3 <- vpc(
  obs = fsad_mad,
  sim = fsims,
  pred_corr = TRUE,
  stratify = "STUDY",
  obs_cols = list(dv = "DV"),
  sim_cols=list(dv = "Y", sim = "irep"), 
  log_y = TRUE,
  pi = c(0.1, 0.9),
  ci = c(0.025, 0.975), 
  facet = "columns",
  show = list(obs_dv = TRUE), 
  vpc_theme = mrg_vpc_theme
) 

p3 <- 
  p3 +  
  theme_bw() + 
  ylab("Pred-corrected concentration (ng/mL)")

p3
