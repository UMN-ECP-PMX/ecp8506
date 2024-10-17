#Wrapper function around rvinecopulib (spline-based)
library(kde1d)
library(rvinecopulib)
#object for estimation and methods contour(), plot() and simulate()

estimate_vinecopula_from_data <- function(dat, variables_of_interest = NULL, 
                                          polynomial = FALSE, ID_name = NULL, 
                                          time_name = NULL, keep_data = FALSE, ...) {
  estimate_spline_marginal <- function(covariate, xmin = NaN) {
    covariate <- covariate[!is.na(covariate)]
    param <- kde1d(covariate, xmin = xmin)
    param$x <- NULL
    marg <- list(pdf = function(u) qkde1d(u, param),
                 pit = function(x) pkde1d(x, param),
                 rdist = function(n) rkde1d(n, param),
                 density = function(x) dkde1d(x, param),
                 dist = param)
    return(marg)
  }
  
  
  if(is.null(variables_of_interest)) {
    #create set of variables between which the copula is made
    variables_of_interest <- setdiff(colnames(dat), c(ID_name, time_name))
  }
  
  if (polynomial) {
    #throw error if ID_name and/or time_name is not specified, these are needed for polynomial random effect model
    if (is.null(ID_name) | is.null(time_name)) {
      stop("ID_name and time_name should be specified when polynomial = TRUE")
    }
    
    time_range <- range(dat[, time_name])
    
    #estimate individual coefficients from polynomial random effect model
    dat_out <- as.data.frame(matrix(NA, nrow = length(unique(dat[, ID_name])), 
                                    ncol = 3*length(variables_of_interest)))
    names(dat_out) <- paste0("b", 0:2, "_", rep(variables_of_interest, each = 3))
    for (variable in variables_of_interest) {
      formula_v <- as.formula(paste(variable, "~ poly(", time_name, ", 2, raw = TRUE) +", 
                                    "(1 + poly(", time_name,",2, raw = TRUE)|", ID_name,")"))
      re_lm <- lmer(data = dat, formula_v, REML = TRUE)
      #extract individual coefficients
      dat_out[grep(paste0("_", variable), names(dat_out))] <-  coef(re_lm)[[ID_name]]
    }
  } else {
    dat_out <- dat[, variables_of_interest]
    time_range <- NULL
  }
  
  #estimate the marginal splines for each variable and create uniform data set
  marginals <- list()
  dat_unif <- dat_out
  for (variable in names(dat_unif)) {
    marginals[[variable]] <- estimate_spline_marginal(dat_out[, variable])
    ind_na <- is.na(dat_unif[, variable])
    dat_unif[!ind_na, variable] <- marginals[[variable]]$pit(dat_unif[!ind_na, variable])
  }

  #Account for discrete variables
  if (hasArg(var_types)) {
    arg_list <- list(...)
    var_types <- arg_list[["var_types"]]
    rm(arg_list)
    if (any("d" %in% var_types)) {
      discrete_vars <- names(dat_out[var_types == "d"])
      discrete_data <- dat_out[, discrete_vars, drop = F]
      for (variable in discrete_vars) {
        ind_na <- is.na(dat_out[, variable])
        discrete_data[!ind_na, variable] <- marginals[[variable]]$pit(dat_out[!ind_na, variable] - 1)
      }
      names(discrete_data) <- paste0(names(discrete_data), "_d")
      dat_unif <- cbind.data.frame(dat_unif, discrete_data)
    }
  }
  
  
  #estimate copula
  vine_coefs <- vinecop(dat_unif, ...)
  
  #create output object
  vine_output <- list(vine_copula = vine_coefs, marginals = marginals, 
                      polynomial = polynomial, 
                      names = c(ID_name = ID_name, time_name = time_name), 
                      time_range = time_range, 
                      variables_of_interest = variables_of_interest)
  if (keep_data) {
    vine_output <- append(vine_output, list(original_data = dat_out, uniform_data = dat_unif), after = 3)
  }
  
  class(vine_output) <- "estVineCopula"
  
  return(vine_output)
}

plot.estVineCopula <- function(vine_output, ...) {
  plot(vine_output$vine_copula, ...)
}

contour.estVineCopula <- function(vine_output, ...) {
  contour(vine_output$vine_copula, ...)
}

#simulation from estimated vine copula
#value_only = TRUE for longitudinal predictions, or FALSE for list with 
#   parameters and longitudinal predictions
simulate.estVineCopula <- function(vine_output, n, value_only = TRUE) {
  
  #Simulation
  if (any(vine_output$vine_copula$var_types == "d")) {
    vine_distribution <- vinecop_dist(vine_output$vine_copula$pair_copulas, vine_output$vine_copula$structure, var_types = vine_output$vine_copula$var_types)
    dat_sim <- as.data.frame(rvinecop(n, vine_distribution))
    names(dat_sim) <- vine_output$variables_of_interest[1:ncol(dat_sim)]
  } else {
    dat_sim <- as.data.frame(rvinecop(n, vine_output$vine_copula))
  }
  
  for (variable in names(dat_sim)) {
    ind_na <- is.na(dat_sim[, variable])
    dat_sim[!ind_na, variable] <- vine_output$marginals[[variable]]$pdf(dat_sim[!ind_na, variable])
  }
  if (any(vine_output$vine_copula$var_types == "d")) {
    dat_sim[, vine_output$vine_copula$var_types == "d"] <- round(dat_sim[, vine_output$vine_copula$var_types == "d"])
  }
  
  #polynomials
  if (vine_output$polynomial) {
    gest_times <- seq(vine_output$time_range[1], vine_output$time_range[2], length.out = 100)
    time_data <- as.data.frame(expand_grid(rownames(dat_sim), gest_times))
    names(time_data) <- vine_output$names
    suppressMessages(df_sim <- dat_sim %>% 
      rownames_to_column(vine_output$names["ID_name"]) %>%
      right_join(time_data))
    
    for (variable in vine_output$variables_of_interest) {
      col_ind <- grep(paste0("_", variable), names(df_sim))
      df_sim[, variable] <- df_sim[, col_ind[1]] + df_sim[, col_ind[2]]*df_sim[, vine_output$names["time_name"]] + 
        df_sim[, col_ind[3]]*df_sim[, vine_output$names["time_name"]]^2
    }
    output <- df_sim %>% dplyr::select(all_of(c(as.character(vine_output$names), vine_output$variables_of_interest)))
    if (value_only) {
      return(output)
    } else {
      return(list(values = output, parameters = dat_sim))
    }
  }
  
  return(dat_sim)
}

