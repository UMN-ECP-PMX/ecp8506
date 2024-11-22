## Setup the engine 

# Drug X is a novel small molecule being developed for Disease Y. Phase 1a/1b studies
# have been completed with single doses of 100, 150, and 250 mg in healthy volunteers 
# and a small cohort of patients (Phase 1b). The drug showed a promising safety 
# profile and preliminary efficacy signals. The target concentration for efficacy
# has been established as 500 mg/L based on preclinical studies.
# 
# The development team needs to select an optimal dose for Phase 2 studies.
# You have been provided with a population PK model (106.mod, 106.cpp) developed 
# from Phase 1 data, including parameter estimates and their uncertainty.

library(tidyverse)
library(simpar)
library(mrgsolve)
library(here)
library(bbr)


setwd(here("wk12"))

model_dir <- "model/"
sim_model <- 106

mrg_mod <- mread(file.path(model_dir, sim_model))


nm_model <- read_model(file.path(model_dir, sim_model)) 
param <- model_summary(nm_model)


THETA <- get_theta(param)
OMEGA <- get_omega(param)
SIGMA <- get_sigma(param)
COV <- cov_cor(param)
thCOV <- COV$cov_theta


param_mat<- simpar(
  nsim = 1000, 
  theta = THETA, 
  covar = thCOV, 
  omega = OMEGA, 
  sigma = SIGMA, 
  odf = 200, 
  sdf = 3500
) |>
  as_tibble()

names(param_mat) <- gsub("[[:punct:]]", "", names(param_mat))

patterns <- c(
  "^OM" = "OMEGA",
  "^TH" = "THETA",
  "^SG" = "SIGMA"
)

param_data <- param_mat |>
  rename_with(~ str_replace_all(.x, patterns)) 

## Simulation function

sim_engine <- function(i, model, param_data, events){
  
  .model <- zero_re(model)
  
  mod <- param(.model, slice(param_data, i)) 
  
  mrgsim(mod, 
         data = events, 
         end=24) |>
    mutate(irep=i) 
}

# Q1. 
#. A. Given the uncertainty in model parameters, characterize the typical
# concentration-time profiles for each dose level (100, 150, 250 mg). 
# What is the 90% confidence interval around these profiles?  
#  B. Calculate typical AUC0-24 and Cmax with 5th and 95th around
# the typical value. 

typical_events <- expand.ev(amt = c(100, 150, 250), 
                            ii = 0, 
                            addl = 0)


sim_uc <- map_dfr(
  1:nrow(param_data), 
  sim_engine, 
  model = mrg_mod, 
  param_data = param_data, 
  events = typical_events
)



out_plot <- sim_uc |>
  mutate(DOSE = case_when(
    ID == 1 ~ "100",
    ID == 2 ~ "150",
    ID == 3 ~ "250"
  )) |> 
  group_by(DOSE, time) |>
  summarize(med_conc = median(Y), 
            lo = quantile(Y, 0.025), 
            up = quantile(Y, 0.975))
  

out_plot |>
  ggplot(aes(time, med_conc, group=DOSE)) + 
  geom_line(aes(color=DOSE)) + 
  geom_ribbon(aes(ymin = lo, ymax = up), alpha = 0.5)




# Q2. What is the probability that individual patients will maintain concentrations 
# above the target threshold of 500 mg/L at 12 hours post-dose for each dose level? 
# Consider both parameter uncertainty and between-subject variability in your 
# analysis. How does this impact dose selection?
# Can you look at the probability on 24 hrs? 

pop_value <- expand.ev(amt = c(100, 150, 250), 
                       ID = 1:10, 
                       WT = rnorm(10, mean = 70, sd = 5)) |>
  mutate(DOSE = amt)


sim_engine_bsv <- function(i, model, param_data, events){
  
    .model <- zero_re(model, sigma)
    .omega <- as_bmat(slice(param_data, i), "OMEGA")
  #  .sigma <- as_bmat(slice(param_data, i), "SIGMA")
   
   
  mod <- param(.model, slice(param_data, i)) |>
    omat(.omega)
  
  mrgsim(mod, 
         data = events, 
         recover = "DOSE", 
         end=24) |>
    mutate(irep=i) 
}


sim_pop <- map_dfr(
  1:nrow(param_data), 
  sim_engine_bsv, 
  model = mrg_mod, 
  param_data = param_data, 
  events = pop_value
)

plot_pop <- sim_pop |>
  group_by(DOSE, time) |>
  summarize(med = median(Y), 
            lo  = quantile(Y, 0.05), 
            up  = quantile(Y, 0.95)) |>
  ggplot(aes(time, med, group=as.factor(DOSE))) +
  geom_line(aes(color = as.factor(DOSE))) + 
  geom_ribbon(aes(ymin = lo, ymax = up, fill=as.factor(DOSE)), alpha =0.5) + 
  geom_hline(yintercept = 500) + 
  geom_vline(xintercept = 12)

fsim_pop <- filter(sim_pop, time == 12)

fsim_pop |>
  group_by(DOSE) |>
  summarize(prop = mean(Y >= 500 ))


## Q3. What is the probability that patients will have an observed 
# concentrations above the target threshold of 500 mg/L at 24 hours 
# post-dose for each dose level? Consider both parameter uncertainty,
# between-subject variability and residual unexplained variability in your analysis. 
# How does this impact dose selection?




