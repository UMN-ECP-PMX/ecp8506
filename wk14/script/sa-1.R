#' 
#' Use mrgsim.sa to do sensitivity analysis and create forest plots
#' 

library(dplyr)
library(forcats)
library(mrgsolve)
library(here)
library(ggplot2)
library(mrgsim.sa)

theme_set(theme_bw() + theme(legend.position = "top"))

options(ggplot2.discrete.colour = RColorBrewer::brewer.pal(name = "Dark2", n = 8))
options(ggplot2.discrete.fill = RColorBrewer::brewer.pal(name = "Dark2", n = 8))

setwd(here("wk14")) # Don't set my computer on fire

#' Sensitivity analysis on a simple PK model 


#' Now, open up our 106 PopPK example and set up 
mod <- mread("model/pk/simmod/106.cpp", capture = "CL")
outvars(mod)

mod <- zero_re(mod)
mod <- update(mod, delta = 0.1, outvars = "IPRED")
outvars(mod)

#' Dose: 100 mg qday at steady state
sensi <- 
  mod %>% 
  ev(amt = 100, ii = 24, addl = 1, ss = 1) %>% 
  parseq_manual(
    WT = seq(50,110,10), 
    ALB = seq(2,7,1), 
    EGFR = seq(50,110,10)
  )

out <- sens_each(sensi, recsort = 3)

sens_plot(out)

summ <- summarise(
  out, 
  Cmax = max(dv_value),
  ref = max(ref_value),
  .by = c(case, p_name, p_value)
)

summ

summ <- mutate(summ, rel = Cmax / ref)
summ <- mutate(summ, y = paste(p_name, "=", p_value))
summ <- mutate(summ, yf = fct_inorder(y))

summ

ggplot(data = summ, aes(x = rel, y = yf, color = p_name)) + 
  geom_point(size = 3) + 
  geom_vline(xintercept = 1, lty = 2) + 
  scale_x_continuous(breaks = seq(0.5, 2, 0.1), limits = c(0.5,2))

summarise(
  summ, 
  Min = min(rel), 
  Max = max(rel), 
  .by = p_name
) %>% mutate(range = Max - Min)


#' Load bootstrap parameter estimates; no IIV in 
#' these simulations, so we only need THETA
post <- fread("data/boot/boot-106.csv")
post <- select(post, contains("THETA"))
post <- mutate(post, irep = row_number())
post <- mutate(post, THETA6 = runif(n(), 0.2, 1.2))
range(post$THETA8)

#' Create a function 
sim <- function(i) {
  
  draw <- slice(post,i)
  
  dose <- ev(amt = 100, ii = 24, addl = 1, ss = 1)
  
  mod <- parseq_manual(
    mod, 
    WT = seq(50,90,10), 
    ALB = seq(3,6,1), 
    EGFR = seq(50,110,10)
  )
  
  out <- 
    mod %>% 
    param(draw) %>%
    ev(dose) %>% 
    sens_each() %>% 
    mutate(irep = i)
  
  out
}

ref <- 
  mod %>% 
  ev(amt = 100, ii = 24, addl = 1, ss = 1) %>% 
  idata_set(post) %>% 
  mrgsim_df()

reff <- summarise(
  ref, 
  ref = max(IPRED), 
  .by = ID
)
rf <- rename(reff, irep = ID)

out <- lapply(1:300, sim) %>% rbindlist()

#' Join on reference simulation
out <- left_join(out, rf, by = "irep")

#' Summarize
summ <- summarise(
  out, 
  Cmax = max(dv_value),
  ref = max(ref),
  .by = c(case, p_name, p_value, irep)
)

summ <- mutate(summ, rel = Cmax / ref)

summ2 <- summarise(
  summ, 
  median = median(rel), 
  lower = quantile(rel, 0.025), 
  upper = quantile(rel, 0.975),
  .by = c(p_name, p_value)
)

summ2 <- mutate(summ2, y = paste(p_name, "=", p_value))
summ2 <- mutate(summ2, yf = fct_inorder(y))
summ2

ggplot(data = summ2, aes(x = median, y = yf, color = p_name)) + 
  geom_pointrange(aes(xmin = lower, xmax = upper)) + 
  geom_vline(xintercept = 1, lty = 2) + 
  scale_x_continuous(breaks = seq(0.6, 1.4, 0.1), limits = c(0.7,1.6))

