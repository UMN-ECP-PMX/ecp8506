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

# TOT. NO. OF OBS RECS:     3142
# TOT. NO. OF INDIVIDUALS:      160

test <- simpar(
  nsim = 10, 
  theta = THETA, 
  covar = thCOV, 
  omega = OMEGA, 
  sigma = SIGMA, 
  odf = 200, 
  sdf = 3500
) |>
  as_tibble()

names(test) <- gsub("[[:punct:]]", "", names(test))

patterns <- c(
  "^OM" = "OMEGA",
  "^TH" = "THETA",
  "^SG" = "SIGMA"
)

# Apply all replacements in one go
df <- test |>
  rename_with(~ str_replace_all(.x, patterns)) 


typical <- ev(amt = 100, ii=0, addl=0)

model <- zero_re(mrg_mod)
mod <- param(model, slice(df, 1)) 
param(mod)
mod <- param(model, slice(df, 2)) 
param(mod)
mrg_momodmrg_mod |>
  zero_re() |>
  mrgsim(ev_data, end=24, delta=0.1) |>
  plot()
  

sim_engine <- function(i){
  
  model <- zero_re(mrg_mod)
  mod <- param(model, slice(df, i)) 
  
  mrgsim(mod, data = typical, end=24) |>
    mutate(irep=i) 
}

test2 <- map_dfr(1:10, sim_engine)

mean_plot <- test2 |> filter(!(time == 0 & Y == 0))

mean_plot |>
  group_by(time) |>
  summarize(avg = mean(Y), 
            lo  = quantile(Y, 0.025), 
            up  = quantile(Y, 0.975)) |>
  ggplot(aes(time, avg)) + 
  geom_line() + 
  geom_ribbon(aes(ymin = lo, ymax = up), alpha=0.4)

