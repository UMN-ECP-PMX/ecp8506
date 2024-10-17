
# Library -----------------------------------------------------------------
library(tidyverse)
library(here)
library(truncnorm)
library(GGally)
library(MASS)

source(here("wk9", "functions", "helper.R"))

# Functions from references: https://github.com/vanhasseltlab/copula_vps
source(here("wk9", "functions", "estimate_vinecopula_from_data.R"))
source(here("wk9", "functions", "plot_distributions.R"))

# Load population data ----------------------------------------------------

# Load data for analysis 
dataDir <- here("wk9/data")
pop <- read.csv(file.path(dataDir, "pop.csv"))

# Separate the dataset based on SEX
pop_male <- pop %>% filter(SEX == "male")
pop_female <- pop %>% filter(SEX == "female")

nsub <- nrow(pop) # Count number of subjects

# Check population
summ(pop) %>% knitr::kable()

cont_cov <- c("AGE", "WT", "HT", "EGFR", "ALB", "BMI")
cat_cov <- c("SEX")

png(here("wk9", "pics", "pop.png"), height = 720, width = 720)
p <- ggpairs(pop, columns=cont_cov, 
              aes(color=SEX, alpha=0.5))
print(p)
dev.off()

# Marginal distributions --------------------------------------------------

# Function to simulate from truncated normal distribution
sim_from_md <- function(x){
  rtruncnorm(nsub, a=0, b=Inf, mean=mean(pop[[x]]), sd=sd(pop[[x]]))
}

withr::with_seed(
  seed=12315,
  vp1 <- data.frame(
    AGE  = sim_from_md("AGE"),
    WT   = sim_from_md("WT"), 
    HT   = sim_from_md("HT"),
    EGFR = sim_from_md("EGFR") ,
    ALB  = sim_from_md("ALB"),
    BMI  = sim_from_md("BMI"),
    SEX  = sample(c("male","female"), size=nsub, replace=TRUE)
    ))

# Check summary statistics
left_join(summ(pop), summ(vp1)) %>% knitr::kable()

pop %>% count(SEX)
vp1 %>% count(SEX)

# Check actual distribution
png(here("wk9", "pics", "md1.png"), height = 720, width = 720)
p1a <- ggpairs(vp1, columns=cont_cov, 
               aes(color=SEX, alpha=0.5))
print(p1a)
dev.off()

# Contour plot
png(here("wk9", "pics", "md2.png"), height = 720, width = 720)
p1b <- plot_comparison_distribution_sim_obs_generic(
  sim_data = vp1 %>% dplyr::select(-SEX), 
  obs_data = pop %>% dplyr::select(-SEX), 
  plot_type = "density")
print(p1b)
dev.off()

# Multivariate normal distributions ---------------------------------------

means_male <- pop_male %>% 
  summarise(across(all_of(cont_cov), mean)) %>% 
  pivot_longer(cols = everything()) %>% pull(value)

means_female <- pop_female %>% 
  summarise(across(all_of(cont_cov), mean)) %>% 
  pivot_longer(cols = everything()) %>% pull(value)

cov_male <- pop_male %>% 
  dplyr::select(all_of(cont_cov)) %>% cov()

cov_female <- pop_female %>% 
  dplyr::select(all_of(cont_cov)) %>% cov()

withr::with_seed(
  seed=12315, 
  vp2_male   <- mvrnorm(n=100, mu=means_male, Sigma=cov_male) %>% 
    as.data.frame() %>% mutate(SEX="male")
)

withr::with_seed(
  seed=35671, 
  vp2_female <- mvrnorm(n=100, mu=means_female, Sigma=cov_female) %>% 
    as.data.frame() %>% mutate(SEX="female")
)

vp2 <- bind_rows(vp2_male, vp2_female)

# Check summary statistics
left_join(summ(pop), summ(vp2)) %>% knitr::kable()

pop %>% count(SEX)
vp2 %>% count(SEX)

# Check actual distribution
png(here("wk9", "pics", "mvnd1.png"), height = 720, width = 720)
p2a <- ggpairs(vp2, columns=cont_cov, 
              aes(color=SEX, alpha=0.5))
print(p2a)
dev.off()

# Contour plot
png(here("wk9", "pics", "mvnd2.png"), height = 720, width = 720)
p2b <- plot_comparison_distribution_sim_obs_generic(
  sim_data = vp2 %>% dplyr::select(-SEX), 
  obs_data = pop %>% dplyr::select(-SEX), 
  plot_type = "density")
print(p2b)
dev.off()

# Copula ------------------------------------------------------------------

copula_male <- estimate_vinecopula_from_data(
  pop_male, variables_of_interest = cont_cov, 
  family_set = "parametric")

copula_female <- estimate_vinecopula_from_data(
  pop_female, variables_of_interest = cont_cov, 
  family_set = "parametric")

# save(copula_male, file=here(dataDir, "copula_male.Rdata"))
# save(copula_female, file=here(dataDir, "copula_female.Rdata"))
# 
# load(here(dataDir, "copula_male.Rdata"))
# load(here(dataDir, "copula_female.Rdata"))

withr::with_seed(
  seed = 4321, 
  vp3_male   <- simulate(copula_male  , n=100, value_only=FALSE) %>% 
    mutate(SEX="male")
  )

withr::with_seed(
  seed=4312,
  vp3_female <- simulate(copula_female, n=100, value_only=FALSE) %>% 
    mutate(SEX="female")
  )

vp3 <- bind_rows(vp3_male, vp3_female)

# Check actual distribution
png(here("wk9", "pics", "copula1.png"), height = 720, width = 720)
p3a <- ggpairs(vp3, columns=cont_cov, 
               aes(color=SEX, alpha=0.5))
print(p3a)
dev.off()

# Contour plot
png(here("wk9", "pics", "copula2.png"), height = 720, width = 720)
p3b <- plot_comparison_distribution_sim_obs_generic(
  sim_data = vp3 %>% dplyr::select(-SEX), 
  obs_data = pop %>% dplyr::select(-SEX), 
  plot_type = "density")
print(p3b)
dev.off()
