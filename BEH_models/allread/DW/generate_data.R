# Patrick Haller, January 2020

Packages <- c("RWiener", "readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr","cowplot","tidyr","psych","ggpubr","gridExtra")
lapply(Packages, require, character.only = TRUE)

dirinput <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd(dirinput)

source("scripts/wiener_generator.R")
source("scripts/get_summary_and_plots.R")

posterior_samples <- read.csv(file = "data/extracted_posterior_samples/posterior_samples_final_fit.csv")
load(file ="data/preprocessed_task_performance/pilots_performance_data.Rda" )

# define number of subjects
n_subj = 5
# define number of trials per block
n_trials= 40
# define number of blocks
n_blocks = 3
# define number of pairs
n_pairs = 8*n_blocks
# define number of parameter sets
n_psets = 100

generated_data <- wiener_generator(raw_data, posterior_samples,
                                   n_subj = n_subj, n_trials = n_trials, n_pairs = n_pairs, n_psets = n_psets, n_blocks = n_blocks)

save(generated_data,file="generated_data_final.Rda")

summary_plots <- get_summary_and_plots(generated_data) 

ggsave("cumulative_lines_generated.eps", plot = summary_plots$cumulative_lines, device=cairo_ps)
ggsave("average_accuracy_generated_fake.eps",plot = summary_plots$accuracy, device=cairo_ps)