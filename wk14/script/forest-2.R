library(dplyr)
library(tidyr)
library(purrr)
library(forcats)
library(mrgsolve)
library(here)
library(data.table)
library(yspec)
library(bbr)
library(ggplot2)

theme_set(theme_bw() + theme(legend.position = "top"))
options(
  ggplot2.discrete.colour = RColorBrewer::brewer.pal(name = "Dark2", n = 8), 
  ggplot2.discrete.fill = RColorBrewer::brewer.pal(name = "Dark2", n = 8),
  pillar.width = Inf, 
  mrgsolve.project = here("wk14/model/pk/simmod")
)

setwd(here("wk14"))

#' Load data specification object and modify
spec <- ys_load("data/derived/pk.yml")

#' Simulation model
mod <- mread("106.cpp")

set.seed(12345)
post <- fread("data/boot/boot-106.csv")
post <- slice_sample(post, n = 100) 
post <- mutate(post, iter = row_number())

#' Get observed covariates
data <- nm_join("model/pk/106")
data <- ys_factors(data, spec, RF) %>% mutate(RF = as.integer(RF))
count(data,RF)
covs <- distinct(data, ID, EGFR, ALB, AGE, WT, RF, SEX) 

#' Group continuous covariates into quartile bins
covs <- mutate(covs, WTG = ntile(WT, 4), ALBG = ntile(ALB,4))
count(covs, WTG)

set.seed(12345)
renal <- slice_sample(covs, n = 1000, by = RF, replace = TRUE)
renal <- mutate(renal, name = "RF", level = RF)
renal <- mutate(renal, label = c("None", "Mild", "Moderate", "Severe")[RF])

count(renal, RF, label)
count(covs, RF)

set.seed(12345)
weight <- slice_sample(covs, n = 1000, by = WTG, replace = TRUE)
weight <- arrange(weight, WTG)
weight <- mutate(weight, name = "WTG", level = WTG, label = paste0("WT Q", WTG))
distinct(weight, WTG, label)

set.seed(12345)
alb <- slice_sample(covs, n = 1000, by = ALBG, replace = TRUE)
alb <- arrange(alb, ALBG)
alb <- mutate(alb, name = "ALBG", level = ALBG, label = paste0("ALB Q", ALBG))
count(alb, ALBG, label)

set.seed(12345)
sex <- slice_sample(covs, n = 1000, by = SEX, replace = TRUE)
sex <- arrange(sex, SEX)
sex <- mutate(sex, name = "SEX", level = SEX, label = c("Male", "Female")[SEX+1])
count(sex, SEX, label)

data <- bind_rows(renal, weight, alb, sex)

data <- mutate(data, ID = row_number())

count(data, name, level, label)

data <- mutate(
  data, 
  amt = 100, 
  ii = 24, 
  addl = 1, 
  ss = 1, 
  evid = 1, 
  time = 0, 
  cmt = 1
)

out <- mrgsim(mod, data, obsonly = TRUE, recover = "name,level,label" ) 

# Important: get these in order right away!
out <- mutate(out, label = fct_inorder(label))
out <- select(out, label, everything())

cmin <- filter(out, near(time,24))

cmin %>% 
  summarise(Cmin = median(IPRED), .by = label) %>% 
  arrange(label)

sim <- function(i, mod, data) {
  draw <- post[i,]
  mod <- param(mod, draw)
  mod <- omat(mod, as_bmat(draw, "OMEGA"))
  out <- mrgsim(
    mod, data, obsonly = TRUE, recover = "name,level", 
    output = "df", 
    ss_rtol = 1e-3
  )
  out <- filter(out, time==24)
  out$irep <- i
  out
}

library(future.apply)
library(future.callr)
plan(callr, workers = 5)
set.seed(12345)
cmin <- future_lapply(1:100, sim, mod, data, future.seed = TRUE) %>% rbindlist()

summ1 <- summarise(
  cmin, 
  p5 = quantile(IPRED, 0.05),
  Median = median(IPRED), 
  p95 = quantile(IPRED, 0.95), 
  .by = c(name, level, irep)
)

long <- pivot_longer(
  summ1, 
  cols = c(p5, Median, p95), 
  names_to = "metric"
)

long

summ3 <- summarise(
  long, 
  lb = quantile(value, 0.025), 
  Median = median(value), 
  ub = quantile(value, 0.975), 
  .by = c(name, level, metric)
) %>% arrange(name, level)

summ3 <- mutate(
  summ3, 
  label = fct_inorder(paste(name,"=",level))
)

med <- filter(summ3, metric == "Median")

#' Median plus/minus 95% 
ggplot(data = med, aes(x = Median, y = label, group = metric, color = name)) + 
  geom_pointrange(aes(xmin = lb, xmax = ub))
