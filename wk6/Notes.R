

# First stop --------------------------------------------------------------

# Load a model and check

library(here)
library(tidyverse)
library(mrgsolve)
library(microbenchmark)

mod <- mread("106.cpp", project = here("wk6/mrg-model"))

mod
see(mod)
param(mod)
omat(mod)
smat(mod)

# Second stop -------------------------------------------------------------

# Modify the [ param ] of a model

mod2 <- mread("106-2.cpp", project = here("wk6/mrg-model"))

param(mod)
param(mod2)

# Third stop --------------------------------------------------------------

# Update model parameters prior to the simulations

## param
mod$WT
mrgsim(mod) %>% plot("WT")

mod <- param(mod, WT=80)
mod$WT
mrgsim(mod) %>% plot("WT")

## update
mod <- update(mod, param=list(WT=60))
mod$WT

## Update using a list object
p <- list(WT=100, FOO=2)

mod <- param(mod, p)
mod$WT

mod <- update(mod, param=p)
mod$WT

## Update using a data.frame object

df <- data.frame(WT=65, FOO=1)
mod <- param(mod, df)
mod <- update(mod, param=df)
mod$WT

df <- data.frame(WT=c(65, 100), FOO=1)
mod <- param(mod, df[2, ])
mod <- update(mod, param=df[2,])
mod$WT

# Fourth stop -------------------------------------------------------------

withr::with_seed(12131, 
                 data <- data.frame(
                   ID=1:3, TIME=0, AMT=100, CMT=1, EVID=1, 
                   WT = rnorm(3, 70, 10), # Simulate 3 random WT 
                   EGFR = rnorm(3, 90, 10), # Simulate 3 random EGFR
                   ALB = rnorm(3, 4.5, 2),  # Simulate 3 random ALB
                   AGE = 50)) # AGE=50 for everyone
data

out <- mod %>% zero_re() %>% data_set(data) %>% mrgsim()

plot(out, "WT,EGFR,ALB,AGE,IPRED,Y")


# Fifth stop --------------------------------------------------------------

inventory(mod2, data)

param_tags(mod2)
check_data_names(data, mod2)
data2 <- data %>% rename(WT2=WT)
check_data_names(data2, mod2)

# Sixth stop --------------------------------------------------------------

# nmext and nmxml

mod <- mread("106.cpp", project=here("wk6/mrg-model"))
mod2 <- mread("106-2.cpp", project=here("wk6/mrg-model"))
param(mod)
param(mod2)

as.list(mod)$nm_import

# microbenchmark::microbenchmark(
#   mod <- mread("106.cpp", project=here("wk6/mrg-model")),
#   mod2 <- mread("106-2.cpp", project=here("wk6/mrg-model")), 
#   times = 5L
# )

# Seventh stop ------------------------------------------------------------

# [ set ]

# Eighth stop ------------------------------------------------------------

self.mtime



