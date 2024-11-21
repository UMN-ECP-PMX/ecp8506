## Setup the engine 


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

## Question 0: What is the typical concentration-time profile after oral dose of 
## 100, 150 and 250 mg including the 95%CI (or 5th-95th of the typical value)?

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


## Question 1: What is the typical (median) Cmax (with 95%CI) after 100, 
## 150 and 250 mg from Drug X? 




## Question 2: what is the probability that an individual patient will have a 
## concentration equal or above the 500 mg/L threshold at 12hr  post dose
## Test: 100 mg, 150 mg and 250 mg?

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


## Question 3: what is the probability that an individual patient will have a 
## concentration equal or above 500 mg/L 24 hr post dose after taking 100 mg, 150 mg and 250 mg?




## Question 4: What is the probability to measure
## concentration above 500 mg/L at 24 hours for 100, 150 and 250 mg?




