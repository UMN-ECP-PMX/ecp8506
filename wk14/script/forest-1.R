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

#' Load data specification object and modify
spec <- ys_load("data/derived/pk.yml")
spec <- ys_extend(spec)
spec <- ys_namespace(spec, "abbreviated")

#' Set up an object to store all the labels
all_labels <- ys_get_short(spec)
all_labels$CL <- ys_get_short_unit(spec)$CL
all_labels$FORM <- "Formulation"
all_labels$CI_label <- "Median [95% CI]"
all_labels$x_lab <- "Fraction and 95% CI \nRelative to Reference"
plot_labels <- as_labeller(unlist(all_labels))

unit <- ys_get_unit(spec)
unit$FORM <- ""
unit <- unit %>% 
  as_tibble() %>% 
  pivot_longer(everything(), values_to = "unit")

setwd(here("wk14"))

set.seed(12345)
post <- fread("data/boot/boot-106.csv")
post <- select(post, contains("THETA"))
post <- slice_sample(post, n = 100) 
post <- mutate(post, iter = row_number())

#' Get observed covariates
data <- nm_join("model/pk/106")
covs <- distinct(data, ID, EGFR, ALB, AGE, WT) 

getPercentile <- function(.x, .p = c(0.1, 0.9)){
  signif(unname(quantile(.x, .p)), digits = 3)
}

x <- list(
  WT = getPercentile(covs$WT),
  EGFR = getPercentile(covs$EGFR), 
  ALB = getPercentile(covs$ALB),
  AGE = getPercentile(covs$AGE), 
  FORM = c(Capsule = 2, "Oral solution" = 3)
)

x

mod <- mread("model/pk/simmod/106.cpp", capture = "CL")
mod <- zero_re(mod)

mod <- update(mod, end = -1)
mod

out <- mrgsim(mod, idata = post) 
ref <- select(out, iter = ID, ref = CL)

simulate_for_forest <- function(values, col, dose = NULL) {
  #' @param values the covariate values to simulate
  #' @param col name of the covariate in the model (e.g. `WT`)
  #' @param dose event object; use `NULL` for no event
  #' Make an idata set

  idata <- tibble(!!sym(col) := values, LVL = seq_along(values))
  idata <- crossing(post, idata)
  idata <- mutate(idata, ID = row_number())
  
  #' Simulate
  out <-
    mrgsim_df(
      mod, 
      events = dose, 
      idata = idata, 
      carry_out = c(col, "LVL", "iter"), 
      recsort = 3
    ) 
  #' Groom the output
  out <- 
    out %>% 
    mutate(name = col, value = !!sym(col)) %>% 
    select(-!!sym(col)) %>%
    arrange(ID, time, LVL)
  
  #' Process renames
  if(is_named(values)) {
    out <- mutate(
      out, 
      value = factor(value, labels = names(values), levels = values)
    )
  } else {
    out <- mutate(out, value = fct_inorder(as.character(value)))  
  }
  
  out
}

out <- imap(x, simulate_for_forest) %>% list_rbind()

x
count(out, name)

#' Get ready to plot
sims <- left_join(out, ref, by = "iter")
sims <- left_join(sims, unit, by = "name")
sims <- mutate(sims, cov_level = paste(value, unit))
sims <- mutate(sims, across(c(value, cov_level), fct_inorder))
sims <- mutate(sims, name = factor(name, levels = rev(names(x))))


#' We want to plot the clearance relative to reference
sims <- mutate(sims, relcl = CL/ref)

#' Summarize the simulated clearances
sum_data <- pmforest::summarize_data(
  data = sims , 
  value = "relcl",
  group = "name",
  group_level = "cov_level",
  probs = c(0.025, 0.975),
  statistic = "median"
)

#' Plot
clp <- pmforest::plot_forest(
  data = sum_data,
  summary_label = plot_labels,
  text_size = 3.5,
  shape_size = 2.5,
  shapes = "circle",
  vline_intercept = 1,
  x_lab = all_labels$x_lab,
  CI_label = all_labels$CI_label,
  plot_width = 8, 
  x_breaks = c(0.4, 0.6, 0.8, 1, 1.2, 1.4, 1.6), 
  x_limit = c(0.4, 1.45),
  annotate_CI = TRUE,
  nrow = 1
) 

clp

# Cmax ------------------------------------------------
mod <- update(mod, delta = 0.1, end = 24)
mod

#' Define an intervention
regimen <- ev(amt = 15, evid = 1, ii = 24, ss = 1)

ref <- mod %>% 
  mrgsim(
    events = regimen, 
    idata = post, 
    recover = "iter", 
    recsort = 3
  ) %>%
  group_by(iter) %>%
  summarise(CMAX = max(IPRED), .groups = "drop") %>%
  select(iter, refCMAX = CMAX)

#' Simulate the scenarios (set in Covariate Value Selection section above)
out <- imap(x, simulate_for_forest, dose = regimen) %>% list_rbind()

#' Summarise
sims <- 
  out %>% 
  group_by(name, value, LVL, iter) %>% 
  summarise(CMAX = max(IPRED), .groups = "drop") 

#' Get ready to plot
sims <- left_join(sims, ref, by = "iter")
sims <- left_join(sims, unit, by = "name")
sims <- mutate(sims, cov_level = paste(value, unit))
sims <- mutate(sims, across(c(value, cov_level), fct_inorder))
sims <- mutate(sims, name = factor(name, levels = rev(names(x))))

#' We want to plot the Cmax relative to reference
sims <- mutate(sims, relCMAX = CMAX/refCMAX)

#' Summarize the simulated cmaxs
sum_data_cmax <- pmforest::summarize_data(
  data = sims , 
  value = "relCMAX",
  group = "name",
  group_level = "cov_level",
  probs = c(0.025, 0.975),
  statistic = "median"
)

#' Plot
cmaxp <- pmforest::plot_forest(
  data = sum_data_cmax,
  summary_label = plot_labels,
  text_size = 3.5,
  shape_size = 2.5,
  shapes = "circle",
  vline_intercept = 1,
  x_lab = all_labels$x_lab,
  CI_label = all_labels$CI_label,
  plot_width = 8, 
  x_breaks = c(0.4, 0.6, 0.8, 1, 1.2, 1.4, 1.6), 
  x_limit = c(0.4, 1.75),
  annotate_CI = TRUE,
  nrow = 1
) 

cmaxp
