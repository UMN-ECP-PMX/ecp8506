
library(here)
library(tidyverse)
library(mrgsolve)

mod <- modlib("popex")

sigma <- as_bmat(0.1)

mod <- smat(mod, sigma)

set.seed(1234)
out <- mod %>% ev(amt=1000) %>% 
  mrgsim(end=100, delta=15, nid=10, obsonly=TRUE) %>% 
  as.data.frame() %>% 
  filter(time != 0)

p1 <- out %>% ggplot(aes(x=time, y=DV))+
  geom_point(size=2.5)+geom_smooth()+
  xlab("Time")+ylab("Concentration")+
  theme_classic()+
  theme(axis.title = element_text(size=20), 
        axis.text = element_blank())

p1



