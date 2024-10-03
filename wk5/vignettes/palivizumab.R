library(tidyverse)
library(mrgsolve)

source(here::here("src/global.R"))

mod <- mread("palivizumab.cpp", here("model"))

zs <- qnorm(c(3,97)/100)

nn <- 100000

sampr <- function(...) sample(..., replace = TRUE)

idata <- tibble(
  BL_PAGE  = sampr(seq(26, 78), nn), 
  WT_ZSCORE = sampr(zs, nn),
  SEX = sampr(c(0, 1), nn),
  RACE = sampr(c(0, 1, 2), nn), 
  CLD = sampr(c(0, 1), nn), 
  ID = seq(nn)
)

label <- ev(amt = 15, ii = 30, addl = 4) %>% realize_addl()

out <- 
  mod %>% 
  idata_set(idata) %>% 
  ev(label) %>%
  mrgsim(delta = 1, end = 5*30, Req = "CL,EVID,DV,PAGE,WT") 

summ <- 
  out %>% 
  as_tibble() %>% 
  group_by(time) %>% 
  summarise(
    lo = quantile(DV, 0.05), 
    hi = quantile(DV, 0.95), 
    med = median(DV)
  )

ggplot(summ, aes(x= time)) + 
  geom_ribbon(aes(ymin = lo, ymax = hi), alpha=0.4) + 
  geom_line(aes(y = med), lwd = 1) +
  theme_bw() + geom_hline(yintercept = 40) + 
  ylab("Palivizumab concentration") + xlab("Time (days)")

out %>% 
  filter(time %in% seq(30,150,30)) %>% 
  group_by(time) %>% 
  summarise(pct = mean(DV > 40), wt = median(WT)*2.2)

data <- mutate(
  idata, 
  reg = case_when(
    between(BL_PAGE, 26,39) ~ 1, 
    between(BL_PAGE, 40,65) ~ 2, 
    between(BL_PAGE, 66,78) ~ 3,
    TRUE ~ NA_real_
  )
)

dose <- list(
  c(20,   17,   15,   12.5, 10),
  c(17.5, 15,   12.5, 10,   7.5),
  c(15,   12.5, 10,   7.5,  5)
)

dtime <- c(0, 28, 56, 84, 112)

d <- imap_dfr(dose, function(d, i) {
  tibble(amt = d, time = dtime) %>% 
    mutate(reg = i, evid = 1, cmt = 1)
}) 

df <- nest_join(d, data) %>% 
  unnest(cols = c(data)) %>% 
  arrange(ID, time)

out <- 
  mod %>% 
  data_set(df) %>% 
  mrgsim(delta = 1, end = 5*30, Req = "CL,EVID,DV,PAGE,WT") 

summ <- 
  out %>% 
  as_tibble() %>% 
  group_by(time) %>% 
  summarise(
    lo = quantile(DV, 0.05), 
    hi = quantile(DV, 0.95), 
    med = median(DV)
  )

ggplot(summ, aes(x= time)) + 
  geom_ribbon(aes(ymin = lo, ymax = hi),alpha=0.4) + 
  geom_line(aes(y = med), lwd=1) +
  theme_bw() + geom_hline(yintercept = 40, lty = 2)

out %>% 
  filter(time %in% (dtime+28)) %>% 
  group_by(time) %>% 
  summarise(pct = mean(DV > 40), wt = median(WT)*2.2)
