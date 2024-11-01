
# Library -----------------------------------------------------------------

library(here) 
library(tidyverse)
library(nhanesA)

# Dir ---------------------------------------------------------------------

outDir <- here("wk9", "data")

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

# Random sample 300 female subjects ---------------------------------------

withr::with_seed(seed=12369, 
                 data <- covar %>% 
                   filter(SEX == 2) %>% 
                   slice_sample(n=300) %>% 
                   dplyr::select(-ID, -SEX, -RACE))

pmplots::pairs_plot(data, names(data))


# Output ------------------------------------------------------------------

write.csv(data, 
          file.path(outDir, "hwpop.csv"), 
          row.names = FALSE, quote = FALSE)

