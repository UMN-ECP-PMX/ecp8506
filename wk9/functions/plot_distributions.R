#plot function for comparing simulation with observed data

plot_comparison_distribution_sim_obs_generic <- function(sim_data, obs_data, variables = NULL, 
                                                         sim_nr = 1, title = NULL, plot_type = "points", 
                                                         pick_color = c("#F46E32", "#5063B9"), full_plot = TRUE,
                                                         caption = NULL, grob = FALSE) {
  #Combine truth and simulation results
  total_data <- obs_data %>% mutate(type = "observed") %>%
    bind_rows(sim_data %>% mutate(type = "simulated"))
  
  total_data$type <- factor(total_data$type, levels = c("simulated", "observed"))
  names(pick_color) <- NULL
  if ("simulation_nr" %in% colnames(sim_data)) {
    # Use only 1 simulation for plotting
    total_data <- total_data %>%
      filter(simulation_nr %in% sim_nr | is.na(simulation_nr))
  }
  
  if (is.null(variables)) {
    variables <- setdiff(colnames(sim_data), "simulation_nr")
  }
  variables_str <- paste0("`", variables, "`")

  point_plots <- density_plots <- list()
  combination_variables <- cbind(t(combn(variables_str, 2)), t(combn(variables, 2)))
  for (i in 1:nrow(combination_variables)) {
    combination <- paste(combination_variables[i, 3:4], collapse = "_")
    part_data <- total_data[, c(combination_variables[i, 3:4], "type")] %>% 
      filter(rowSums(is.na(total_data[, combination_variables[i, 3:4]])) == 0)
    
    if (plot_type != "density") {
      point_plots[[combination]] <- ggplot(mapping = aes_string(x = combination_variables[i, 1], y = combination_variables[i, 2])) +
        geom_point(data = part_data[part_data$type == "simulated", ], alpha = 0.3, shape = 16, color = pick_color[1]) +
        geom_point(data = part_data[part_data$type == "observed", ], alpha = 0.8, shape = 16, color = pick_color[2]) +
        theme_bw() + 
        theme(legend.position = "none")
    }
    if (plot_type != "points") {
      density_plots[[combination]] <- ggplot(mapping = aes_string(x = combination_variables[i, 1], y = combination_variables[i, 2])) +
        geom_density2d(data = part_data[part_data$type == "simulated", ], color = pick_color[1], bins = 20) +
        geom_density2d(data = part_data[part_data$type == "observed", ],  alpha = 1, color = pick_color[2], linetype = 2, bins = 20) +
        scale_y_continuous(expand = expansion(mult = c(0, 0))) +
        scale_x_continuous(expand = expansion(mult = c(0, 0))) +
        theme_bw() +
        theme(legend.position = "none")
    }
  }
  
  if(!full_plot) {
    if (plot_type == "density") {
      return(density_plots)
    }
    if (plot_type == "points") {
      return(point_plots)
    }
    else if (plot_type == "both") {
      names(density_plots) <- paste0("density_",names(density_plots))
      names(point_plots) <- paste0("point_", names(point_plots))
      return(c(density_plots, point_plots))
    }
  }
  
  
  univariate_plots <- list()
  for (i in variables_str) {
    univariate_plots[[i]] <- total_data %>% 
      ggplot(aes_string(y = i, x = "type", fill = "type")) +
      geom_boxplot() +
      scale_fill_manual(values = c(pick_color[1], pick_color[2])) +
      theme_bw() +
      theme(legend.position = "none")
  }
  nr_cross_plots <- choose(length(variables), 2)
  layout_mat <- matrix(NA, nrow = length(variables), ncol = length(variables))
  layout_mat[lower.tri(layout_mat)] <- 1:nr_cross_plots
  diag(layout_mat) <- nr_cross_plots + (1:length(variables))
 
  
  
  if (plot_type == "points") {
    list_plots <- c(point_plots, univariate_plots)
  } else if (plot_type == "density") {
    list_plots <- c(density_plots, univariate_plots)
  } else if (plot_type == "both") {
    t_layout_mat <- t(layout_mat)
    t_layout_mat[lower.tri(t_layout_mat)] <- nr_cross_plots + length(variables) + (1:nr_cross_plots)
    layout_mat <- t(t_layout_mat)
    list_plots <- c(density_plots, univariate_plots, point_plots)
  }
  
  if (grob) {
    return(gridExtra::arrangeGrob(grobs = list_plots, layout_matrix = layout_mat, 
                                  top = title, bottom = grid::textGrob(caption, gp = grid::gpar(fontsize = 70), x = 0, hjust = 0)))
  }
  
  gridExtra::grid.arrange(grobs = list_plots, layout_matrix = layout_mat, top = title, bottom = caption)
}
