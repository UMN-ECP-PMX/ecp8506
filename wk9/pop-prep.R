
# pop prep ----------------------------------------------------------------

library(tidyverse)
library(here)

data <- read.csv(here("wk9/data/VirtualPopulation-2024-10-16.csv"))

out <- data %>% 
  dplyr::select(SEX=Sex, 
                AGE=Age, 
                WT=Weight,
                HT=Height, 
                ALB=Albumin, 
                BMI, 
                EGFR=eGFR)

write.csv(out, here("wk9/data/pop.csv"), 
          row.names = FALSE, quote = FALSE)
