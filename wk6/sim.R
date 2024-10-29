
# Library -----------------------------------------------------------------

library(here) 
library(tidyverse)
library(mrgsolve)
library(nhanesA)

# Dir ---------------------------------------------------------------------

outDir <- here("wk6", "data")
modDir <- here("wk6", "mrg-model")

# Model -------------------------------------------------------------------

# Load model
mod <- mread("sim.cpp", project = modDir)
mod
param(mod)
omat(mod)
smat(mod)
see(mod)

# Load NHANES data --------------------------------------------------------

# nhanesA::browseNHANES()

#' `nhanesA` reference: 
#' https://ehsanx.github.io/SPPH504007SurveyData/docs/importing-nhanes-to-r.html
#' `pk-sim-renal.R` in MRG example proj 

letters <- c('',paste("_",LETTERS[2:10],sep=''))

# Extract demographics information
dem <- map_df(letters,.f = function(x){
  nhanes(paste('DEMO',x,sep='')) %>% 
    dplyr::select(ID = SEQN, AGE = RIDAGEYR, 
                  SEX = RIAGENDR, RACE = RIDRETH1) %>%
    mutate_all(.funs = as.numeric)})

demo_labels <- tibble(
  col = names(dem),
  label = sapply(dem, attr, "label")
)

# Extract body measure information
wt <- map_df(letters,.f = function(x){
  nhanes(paste('BMX',x,sep='')) %>% 
    select(ID = SEQN, WT = BMXWT, HT = BMXHT) %>%
    mutate_all(.funs = as.numeric)})

bmx_labels <- tibble(
  col = names(wt),
  label = sapply(wt, attr, "label")
)

# Extract laboratory information
lab <- map_df(letters,.f = function(x){
  return(x %>% purrr::when(. =='' ~ nhanes(paste('LAB18',sep='')) %>% 
                             select(ID = SEQN, ALB = LBXSAL, SCR = LBXSCR) %>%
                             mutate_all(.funs = as.numeric),
                           . == '_B' ~ nhanes(paste('L40',.,sep='')) %>% 
                             select(ID = SEQN, ALB = LBXSAL, SCR = LBDSCR) %>%
                             mutate_all(.funs = as.numeric),
                           . == '_C' ~ nhanes(paste('L40',.,sep='')) %>% 
                             select(ID = SEQN, ALB = LBXSAL, SCR = LBXSCR) %>%
                             mutate_all(.funs = as.numeric),
                           . %in% letters[4:10] ~ nhanes(paste('BIOPRO',.,sep='')) %>% 
                             select(ID = SEQN, ALB = LBXSAL, SCR = LBXSCR) %>%
                             mutate_all(.funs = as.numeric),
                           ~ stop("No matches found: check data name")))})

lab_labels <- tibble(
  col = names(lab), 
  label = sapply(lab, attr, "label")
)

#Join into 1 dataset and generate EGFR
covar <- left_join(dem, lab) %>% left_join(wt)
mrgmisc::nasum(covar)
# # A tibble: 4 × 2
#    name   n_NA
#   <chr> <int>
#   1 ALB   37342
#   2 SCR   37346
#   3 WT     6134
#   4 HT    13077
covar <- filter(covar, !is.na(WT) & !is.na(HT) & !is.na(ALB) & !is.na(SCR))
mrgmisc::nasum(covar)
# no NAs

# Create a dataset for simulations ----------------------------------------

covar2 <- mutate(
  covar %>% filter(AGE>3, AGE<=18), # 3-18 ped only
  USUBJID = ID, ID = seq(n())
) %>% dplyr::select(ID, USUBJID, everything())

# Randomly sample 50 subjects
withr::with_seed(seed=720, index <- sample(covar2$ID, 50, replace = FALSE))

cont_cov <- c("WT", "AGE")
cat_cov <- c()

pop <- covar2 %>% dplyr::select(ID, all_of(cont_cov)) %>% 
  filter(ID %in% index) %>% mutate(ID = 1:n()) %>% 
  mutate(across(all_of(cont_cov), ~round(.x, digits = 2))) 

dose <- pop %>% mutate(AMT=c(rep(1000,10),
                             rep(2000,10), 
                             rep(5000,10),
                             rep(10000,10),
                             rep(20000,10)), 
                       EVID=1, TIME=0, CMT=1, RATE=-2) %>% 
  mutate(DOSE=AMT)

head(dose)

# Make a figure for lecture illustration ----------------------------------

withr::with_seed(1234,
                 test1 <- slice_sample(covar2, n=1000))

mean_WT  <- mean(test1$WT)
sd_WT    <- sd(test1$WT)
mean_HT <- mean(test1$HT)
sd_HT   <- sd(test1$HT)

withr::with_seed(1234,
                 test2 <- data.frame(ID=1:1000, 
                                     WT=rnorm(1000,mean=mean_WT,sd=sd_WT), 
                                     HT=rnorm(1000,mean=mean_HT,sd=sd_HT)
                                     )
                 ) 

p_cov1 <- pmplots::pairs_plot(test1, c("WT//Weight (kg)", "HT//Height (cm)"))
p_cov2 <- pmplots::pairs_plot(test2, c("WT//Weight (kg)", "HT//Height (cm)"))

# p_cov1
# p_cov2

# Simulate PK profiles ----------------------------------------------------

check_data_names(data=dose,mod)

obs <- withr::with_seed(seed=1234, 
                        mrgsim(mod, data=dose, obsonly=TRUE, end=48,
                               output="df", recover="DOSE"))

p1 <- obs %>% ggplot(aes(x=TIME, y=CP, group=ID))+
  geom_line()+facet_wrap(~DOSE, ncol=5)+
  scale_y_log10()+theme_bw()
p1

# Taking random samples

planned_sample_time <- c(0.1,0.2,0.5,1,2,4,8,12,24)

take_random_sample <- function(i){
  sample_noise <- rnorm(9,mean=0,sd=0.1)
  actual_sample_time <- planned_sample_time*(1+sample_noise)
  actual_sample_time <- round(actual_sample_time, digits=2)
  
  pk_temp <- obs %>% filter(ID==i) %>% 
    filter(TIME %in% actual_sample_time)
  
  return(pk_temp)
}

pk <- withr::with_seed(seed=12135, 
                       map(1:50, take_random_sample) %>% 
                         bind_rows()) %>% 
  dplyr::select(ID, TIME, DV=Y, DOSE) %>% 
  arrange(ID, TIME) %>% 
  mutate(DV=round(DV, digits = 2))

p2 <- pk %>% ggplot(aes(x=TIME, y=DV, group=ID))+
  geom_line()+facet_wrap(~DOSE, ncol=5)+
  scale_y_log10()+theme_bw()
p2

# Combine dose and pk

data <- bind_rows(dose, pk) %>% 
  arrange(ID,TIME) %>% 
  mutate(AMT=ifelse(is.na(AMT),0,AMT), 
         EVID=ifelse(is.na(EVID),0,EVID), 
         CMT=ifelse(is.na(CMT),2,1),
         RATE=ifelse(is.na(RATE),0,RATE)) %>% 
  mutate(DV=ifelse(EVID==1,0,DV)) %>% 
  mutate(MDV=ifelse(EVID==1,1,0)) %>% 
  mutate(BLQ=ifelse(EVID==1,2,ifelse(DV<0.5,1,0))) %>% 
  mutate(DV=ifelse(BLQ==1,0.25,DV)) %>% 
  mutate(C=".") %>% 
  group_by(ID) %>% 
  fill(WT, .direction = "down") %>% 
  fill(AGE, .direction = "down") %>% 
  ungroup() %>% 
  mutate(NUM=1:n()) %>% 
  arrange(ID,TIME) %>% 
  dplyr::select(C,NUM,ID,TIME,AMT,RATE,EVID,MDV,CMT,DV,BLQ,WT,AGE,DOSE)

anyNA(data)

# Make sure reproducible
data %>% count(EVID, BLQ)
# # A tibble: 3 × 3
# EVID   BLQ     n
# <dbl> <dbl> <int>
# 1     0     0   415
# 2     0     1     2
# 3     1     2    50

data %>% filter(BLQ==1)
# # A tibble: 2 × 14
# C       NUM    ID  TIME   AMT  RATE  EVID   MDV   CMT    DV   BLQ    WT   AGE  DOSE
# <chr> <int> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
# 1 .         2     1  0.1      0     0     0     0     2  0.25     1 116      15  1000
# 2 .        77     9  0.07     0     0     0     0     2  0.25     1  97.8    18  1000

# Output
write.csv(data, 
          file.path(outDir, "nmdat1.csv"), 
          row.names = FALSE, quote = FALSE)

