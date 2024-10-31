library(tidyverse)
theme_set(theme_bw())
library(mrgsolve)
library(data.table)
library(haven)
library(PKPDmisc)
library(pmplots)
library(mrggsave)
library(nhanesA)
library(here)
library(future)
library(furrr)
library(bbr)
library(pmforest)

setwd(here("script"))
out_data_dir <- here("data", "sim")

# Set to TRUE to re-run all simulations
# If FALSE, will load data from previous simulations
# NOTE: if running sims, use a large head node (ideally 16 vCPU's)
RUN_SIMS <- FALSE

options(
  mrgsolve.project = "model", 
  mrggsave.dir = "../deliv/figure/106", 
  mrg.script = "pk-sim-renal.R",
  dplyr.summarise.inform = FALSE,
  tibble.width = Inf
)

plan(multisession)
set.seed(20205432)
opt <- furrr_options(seed = TRUE)

#Read in bootstrap (or posterior or simpar and covariance matrix)
boot <- fread(here("data", "boot", "boot-106.csv"))
boot <- boot %>% 
  mutate(boot, ID = seq(n())) %>%
  mutate(ITERATION = 1:n())

#Read in NHANES datasets
letters <- c('',paste("_",LETTERS[2:10],sep=''))

dem <- map_df(letters,.f = function(x){
  nhanes(paste('DEMO',x,sep='')) %>% 
    select(ID = SEQN, AGE = RIDAGEYR, 
           SEX = RIAGENDR, RACE = RIDRETH1) %>%
    mutate_all(.funs = as.numeric)})

demo_labels <- tibble(
  col = names(dem),
  label = sapply(dem, attr, "label")
)

wt <- map_df(letters,.f = function(x){
  nhanes(paste('BMX',x,sep='')) %>% 
    select(ID = SEQN, WT = BMXWT) %>%
    mutate_all(.funs = as.numeric)})

bmx_labels <- tibble(
  col = names(wt),
  label = sapply(wt, attr, "label")
)

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
anyNA(covar)
# TRUE
covar <- filter(covar, !is.na(WT) & !is.na(ALB) & !is.na(SCR))
anyNA(covar)
# FALSE

# https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DEMO_J.htm#RIDRETH1 BLACK
# https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DEMO_J.htm#RIAGENDR FEMALE
covar <- mutate(
  covar %>% filter(AGE>=18), 
  EGFR = 175 * (SCR)^(-1.154) * AGE^(-0.203) * 0.742^(SEX==2) * 1.212^(RACE==4), 
  USUBJID = ID, 
  ID = seq(n())
) %>%
  #Make renal function groups
  mutate(RFGroup = case_when(EGFR >= 90 ~ '1: Normal',
                             EGFR <90 & EGFR>=60 ~ '2: Mild',
                             EGFR <60 & EGFR>=45 ~ '3: Mild-Mod',
                             EGFR <45 & EGFR>=30 ~ '4: Mod-Sev',
                             EGFR <30 & EGFR>=15 ~ '5: Sev',
                             EGFR <15 ~'6: ESRD',
                             TRUE ~ 'ERROR'))

fparam <- nm_join(here("model", "pk", "106")) %>% 
  #Generate AUCSS
  mutate(AUCSS = DOSE/CL,
         RFGroup = case_when(EGFR >= 90 ~ '1: Normal',
                             EGFR <90 & EGFR>=60 ~ '2: Mild',
                             EGFR <60 & EGFR>=45 ~ '3: Mild-Mod',
                             EGFR <45 & EGFR>=30 ~ '4: Mod-Sev',
                             EGFR <30 & EGFR>=15 ~ '5: Sev',
                             EGFR <15 ~'6: ESRD',
                             TRUE ~ 'ERROR'))

#Normal, Mild, Mild-mod, Mod-sev, Severe
#Generate AUC distribution for populations with characteristics of interest
#At doses of 25 mg

#Function to create datasets
dcreatefunc <- function(rfgroup, Name) {
  #browser()
  out = covar %>%
    dplyr::filter(RFGroup == rfgroup)  %>%
    sample_n(size = 1000,replace = T) %>%
    mutate(GRP = Name)
  
  return(out)
}


if (isTRUE(RUN_SIMS)) {
  #Read in mrgsolve model
  mod <- mread("106.mod") %>% zero_re('sigma')
  param(mod)
  omat(mod)
  
  #Simulate for doses of 25 mg BID with iterative resampling of 
  #populations and simulation with uncertainty. 
  withr::with_seed(01242022, {
    map(c(25), function(xamt){
      simresIIV <- future_map_dfr(
        PKPDmisc::chunk_df(boot, ITERATION, 
                           .nchunks = 16),.options = opt,
        function(.chunk){
          map_dfr(
            .chunk$ITERATION, 
            function(iter, params = .chunk, simmod = mod, Xamt = xamt) {
              
              uc <- filter(params, ITERATION==iter) %>% select(-ID)
              
              #Generate AUC distribution for populations with characteristics of interest
              
              simdats <- pmap_df(
                list(rfgroup = list("1: Normal","2: Mild","3: Mild-Mod",
                                    "4: Mod-Sev","5: Sev", "6: ESRD"),
                     Name = list("Adult Normal",
                                 "Adult Mild", "Adult Mild-Mod",
                                 "Adult Mod-Sev","Adult Sev",
                                 "Adult ESRD")),
                .f = dcreatefunc)
              
              #Make a new ID variable
              simdat_tot <- simdats %>%
                mutate(ID = seq(n())) %>%
                mutate(DOSE = Xamt)
              
              #Set up tgrid
              simt <- tgrid(start=0,
                            end = 1,
                            delta = 1)
              
              
              ddat <- simdat_tot %>% mutate(time=0,
                                            amt=DOSE, evid=1,cmt=1,ss=1,ii=12)
              
              out <- mod %>%
                data_set(ddat) %>%
                param(uc %>% select(starts_with('THETA'))) %>%
                omat(uc %>% as_bmat('OMEGA')) %>%
                carry_out(DOSE) %>% 
                mrgsim_df(obsonly=TRUE, tgrid=simt, 
                          recover = 'GRP') %>%
                distinct(ID, GRP, AUC, DOSE) %>% 
                mutate(run = iter)
              
              
              return(out)
              
            }
          )
        }
      )
      
      saveRDS(simresIIV, file = here(out_data_dir, 
                                     paste('simresIIVPop',xamt,'.RDS', 
                                           sep = '')))
    }
    )
  }
  )
  
} else { 
  
  
  simresIIV25mg <- readRDS(file = file.path(out_data_dir, 
                                            'simresIIVPop25.RDS'))
}


#Make 10 mg dosed subjects for ESRD
esrd10 <- filter(simresIIV25mg, GRP == 'Adult ESRD') %>%
  mutate(CL = DOSE/AUC) %>%
  #recalculate AUC
  mutate(DOSE = 10,
         AUC = DOSE/CL) %>%
  select(-CL)

simresIIV25mg2 <- bind_rows(simresIIV25mg,esrd10) 

#Create Normalized variables
simresIIV2 <- simresIIV25mg2 %>%
  mutate(med = simresIIV25mg2 %>% 
           filter(GRP == 'Adult Normal') %>% 
           group_by(run) %>%
           summarize(med=median(AUC)) %>%
           ungroup() %>% 
           summarize(medm = median(med)) %>%
           pull(medm))%>% 
  mutate(GRP = factor(GRP,
                      levels = c('Adult Normal',
                                 'Adult Mild','Adult Mild-Mod',
                                 'Adult Mod-Sev','Adult Sev',
                                 'Adult ESRD'))) %>%
  mutate(GRP2 = factor(paste(DOSE, 'mg', sep = ' '))) %>%
  arrange(GRP) %>%
  mutate(N_AUC = AUC/med)

sumData1 <- simresIIV2 %>%
  summarize_data(
    value = N_AUC,
    replicate = run,
    group = GRP,
    group_level = GRP2
  )


shaded_interval <- quantile(simresIIV2$N_AUC[simresIIV2$GRP=="Adult Normal"], c(0.05,0.95))

plt1 <- plot_forest(data = sumData1,
                    shaded_interval = shaded_interval,
                    #summary_label = plot_labels,
                    text_size = 3.5,
                    digits = 3,
                    vline_intercept = 1,
                    x_lab = expression(paste("Normalized ", AUC[SS])),
                    CI_label = "Median [95% CI]",
                    caption = paste0("Lower line represents the median of the summary statistics (Median, 5th and 95th quantiles).
              Upper lines represent the 95% CI of the individual statistics.
              Shaded interval corresponds to ",round(shaded_interval[1],2),
              ", ",round(shaded_interval[2],2)),
              plot_width = 8,
              #x_breaks = c(0.4,0.6, 0.8, 1, 1.2, 1.4,1.6),
              #x_limit = c(0.4,1.45),
              ggplot_theme = theme_classic(),
              shape_size = 2,
              annotate_CI=T)

plt1

mrggsave_last(stem = "106-pk-sim-renal-normalized-auc-norm-range", height = 6.5, width = 6.5)

shaded_interval <- quantile(simresIIV2$AUC[simresIIV2$GRP=="Adult Normal"], c(0.05,0.95))

sumData2 <- simresIIV2 %>%
  summarize_data(
    value = AUC,
    replicate = run,
    group = GRP,
    group_level = GRP2
  )

plt2 <- plot_forest(data = sumData2,
                    shaded_interval = shaded_interval,
                    #summary_label = plot_labels,
                    text_size = 3.5,
                    digits = 3,
                    vline_intercept = NULL,
                    x_lab = expression(paste(AUC[SS], "  (mg*h/L)")),
                    CI_label = "Median [95% CI]",
                    caption = paste0("Lower line represents the median of the summary statistics (Median, 5th and 95th quantiles).
              Upper lines represent the 95% CI of the individual statistics.
              Shaded interval corresponds to ",round(shaded_interval[1],2),
              ", ",round(shaded_interval[2],2)),
              plot_width = 8,
              #x_breaks = c(0.4,0.6, 0.8, 1, 1.2, 1.4,1.6),
              #x_limit = c(0.4,1.45),
              ggplot_theme = theme_classic(),
              shape_size = 2,
              annotate_CI=T)

plt2  

mrggsave_last(stem = "106-pk-sim-renal-auc-raw-range", height = 6.5, width = 6.5)
