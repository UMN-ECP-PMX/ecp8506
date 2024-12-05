library(dplyr)
library(tidyr)
library(purrr)
library(forcats)
library(mrgsolve)
library(here)
library(data.table)
library(yspec)
library(rlang)
library(bbr)
library(glue)
library(ggplot2)

setwd(here("wk14"))

options(pillar.width = Inf)

#' Load data specification object and modify
spec <- ys_load("data/derived/pk.yml")

set.seed(12345)
post <- fread("data/boot/boot-106.csv")
post <- slice_sample(post, n = 100) 
post <- mutate(post, iter = row_number())


#' Get observed covariates
data <- nm_join("model/pk/106")
data <- ys_factors(data, spec, RF) %>% mutate(RF = as.integer(RF))
covs <- distinct(data, ID, EGFR, ALB, AGE, WT, RF, SEX, CP) 
covs <- mutate(covs, WTG = ntile(WT, 4), ALBG = ntile(ALB,4))

set.seed(12345)
renal <- slice_sample(covs, n = 1000, by = RF, replace = TRUE)
renal <- mutate(renal, name = "RF", level = RF)
count(renal, RF)

set.seed(12345)
weight <- slice_sample(covs, n = 1000, by = WTG, replace = TRUE)
weight <- mutate(weight, name = "WTG", level = WTG)
count(weight, WTG)

set.seed(12345)
alb <- slice_sample(covs, n = 1000, by = ALBG, replace = TRUE)
alb <- mutate(alb, name = "ALBG", level = ALBG)
count(alb, ALBG)

set.seed(12345)
sex <- slice_sample(covs, n = 1000, by = SEX, replace = TRUE)
sex <- mutate(sex, name = "SEX", level = SEX)
count(sex, SEX)

set.seed(12345)
cp <- slice_sample(covs, n = 1000, by = CP, replace = TRUE)
cp <- mutate(cp, name = "CP", level = CP)
count(cp, CP)

data <- bind_rows(renal, weight, alb, sex, cp)

data <- mutate(data, ID = row_number())

count(data, name, level)

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

out <- mrgsim(mod, data, obsonly = TRUE, recover = "name,level" ) 

sims <- filter(out, near(time,24))

sims %>% 
  summarise(Median = median(IPRED), .by = c(name, level)) %>% 
  arrange(name, level)


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

cmin <- lapply(1:10, sim, mod, data) %>% rbindlist()

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

summ2 <- summarise(
  summ1, 
  lb = quantile(Median, 0.025),
  Med = median(Median), 
  ub = quantile(Median, 0.975), 
  .by = c(name, level)
) %>% arrange(name, level)

