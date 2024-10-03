
source(here::here("src/global.R"))
library(dplyr)
library(mrgsolve)

#' You've been sick for the last two weeks and can't take it any more. 
#' Finally, you decide to go to the doctor, who gives you a diagnosis of 
#' pneumonia. When you get home with your azithromycin 
#' prescription, you start wondering about the directions: take 
#' 500 mg as a single dose on Day 1, followed by 250 mg once daily 
#' on Days 2 through 5.

#' Explore this regimen using the following model:
#' 
#' - Model name: `azithro-fixed.mod`
#' - Model location: `model`
#' 
#' 

#' Simulate out to at least day 14 to see what is happening.

mod <- mread("model/azithro-fixed.mod") 

day1 <- ev(amt = 500)
day25 <- ev(amt = 250, ii = 24, total = 4)

doses <- seq(day1, wait = 24, day25)

out <- mrgsim(mod, doses, end = 168*2)

plot(out)
