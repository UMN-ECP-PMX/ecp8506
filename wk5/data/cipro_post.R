library(mrgsolve) 
library(dplyr)

mv <- MASS::mvrnorm

# CLNR (l h−1)	7.17 (25 %)	 2.60   ± 0.14	  13.5
# fsecretion	 0.57 (25 %)	                  0.674 (26 %)
# Kp,lung	     3.3 (25 %)	   1.20   ± 0.25	  3.32
# Kp,brain	   0.771 (25 %)	−0.257  ± 0.25	  0.773
# Kp,heart	   3.67 (25 %)	 1.30   ± 0.25	  3.67
# Kp,skin	     0.718 (25 %)	−0.335  ± 0.24	  0.715
# Kp,muscle	   1.6 (25 %)	  −0.0229 ± 0.16	  0.977
# Kp,adipose	 0.449 (25 %)	−0.885  ± 0.23	  0.413
# Kp,spleen	   1.954 (25 %)	 0.668  ± 0.25	  1.95
# Kp,GIT	     3.39 (25 %)	 1.21   ± 0.23	  3.35
# Kp,liver	   3.67 (25 %)	 1.27   ± 0.23	  3.56
# Kp,kidney 	 8.2 (25 %)	   2.09   ± 0.25	  8.09
# Kp,rest	     2.77 (25 %)	 1.35   ± 0.11	  3.86
# IIV CL (CV %)	–		56 (9.3 %)
# IIV Kp (CV %)	–		55 (15 %)
# Proportional residual error (%)	–		33 (7.1 %)



mu <- c(2.6, log(0.674), 1.2, -0.257, 1.3, -0.335, -0.0229, 
        -0.885, 0.668, 1.21, 1.27, 2.09, 1.35)

se <- c(0.14,0.09, 0.25,0.25,0.25,0.24,0.16,0.23,0.25,0.23,0.23,0.25,0.11)

Sigma <- diag(se)^2

lbl <- c("clh", "resch", "klun", "kbra", "khrt", "kskn",
         "kmus", "kadi", "kspl", "kgio", "khep", "kkid", "kres")

n <- 1000

set.seed(2203022)
pars <- as.data.frame(exp(mv(n, mu, Sigma)))

names(pars) <- lbl


pars <- mutate(pars, irep = seq(n())) %>% 
  select(irep,everything())

saveRDS(file = "cipro_post.RDS", pars)

readr::write_csv(path = "cipro_post.csv", pars)


