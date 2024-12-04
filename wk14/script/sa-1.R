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

setwd(here("wk14")) # Don't set my computer on fire

data <- nm_join("model/pk/106")

mod <- mread("model/pk/simmod/106.cpp", capture = "CL")
mod <- zero_re(mod)
outvars(mod)
mod <- update(mod, delta = 0.1, outvars = "IPRED")
outvars(mod)

out <- 
  mod %>% 
  ev(amt = 100, ii = 24, addl = 1, ss = 1) %>% 
  parseq_manual(
    WT = seq(50,90,10), 
    ALB = c(4.5, seq(3,6,1)), 
    EGFR = seq(60,110,10)
  ) %>% 
  sens_each(recsort = 3)

out

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
  


set.seed(12345)
post <- fread("data/boot/boot-106.csv")
post <- select(post, contains("THETA"))
post <- mutate(post, iter = row_number())


sim <- function(i) {
  out <- 
    mod %>% 
    param(slice(post, i)) %>%
    ev(amt = 100, ii = 24, addl = 1, ss = 1) %>% 
    parseq_manual(
      WT = seq(50,90,10), 
      ALB = seq(3,6,1), 
      EGFR = seq(50,110,10)
    ) %>% 
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
  .by = c(ID)
)
rf <- rename(reff, irep = ID)

out <- lapply(1:300, sim) %>% rbindlist()

out <- left_join(out, rf)

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

