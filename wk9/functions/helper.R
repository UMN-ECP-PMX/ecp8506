

summ <- function(dat){
  
  dat_name <- deparse(substitute(dat))
  
  dat <- dat %>% dplyr::select(-SEX)
  
  means <- dat %>% 
    summarise(across(everything(), mean)) %>% 
    mutate(across(everything(), ~round(.x, digits=2))) %>% 
    pivot_longer(cols=everything(), names_to="name", values_to="mean")
  
  sds <- dat %>% 
    summarise(across(everything(), sd)) %>% 
    mutate(across(everything(), ~round(.x, digits=2))) %>% 
    pivot_longer(cols=everything(), names_to="name", values_to="sd")
  
  sum <- left_join(means, sds) %>% 
    mutate(value=paste0(mean, " (", sd, ")")) %>% 
    dplyr::select(-mean, -sd) %>% 
    rename("{dat_name}":=value)
    
  return(sum)
  
}