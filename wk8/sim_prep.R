
library(tidyverse)
library(here)

data <- read.csv(here("wk6/data/nmdat1.csv"), header = TRUE)
tab <- read.table(here("wk6/nm-model/hwwk6/hwwk6par.tab"), 
                   skip=1, header = TRUE)

df <-left_join(tab, data) %>% filter(EVID==1)

cov_eta <- df %>% 
  dplyr::select(ID, TIME, AMT, RATE, EVID, CMT, DOSE, 
                WT, AGE, starts_with("ETA")) %>% 
  distinct()

iparam <- df %>% distinct(ID, TIME, AMT, RATE, EVID, CMT, DOSE, 
                          CL, V, KA, D1) %>% 
  rename(CLI=CL, VI=V, KAI=KA, D1I=D1)

write.csv(cov_eta, here("wk8/data/cov_eta.csv"), 
          quote = FALSE, row.names = FALSE)

write.csv(iparam, here("wk8/data/iparam.csv"), 
          quote = FALSE, row.names = FALSE)
