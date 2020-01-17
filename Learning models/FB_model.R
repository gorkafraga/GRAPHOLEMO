.libPaths()
assign(".lib.loc", "C:/Program Files/R/R-3.6.1/library", envir = environment(.libPaths))

#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan",
              "hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr")
lapply(Packages, require, character.only = TRUE)
source("N:/Developmental_Neuroimaging/Scripts/Misc R/R-plots and stats/Geom_flat_violin.R")
#=====================================================================================
# RUN MODEL (with Stan)
#=====================================================================================
# - Load preprocessed  data list (formatted and with variables needed for Stan)
# - Load model 
# - Extract output with some processing
# 
#--------------------------------------------------------------------------------------------
# REFS: e.g. From Pederson et al.,2017 https://github.com/gbiele/RLDDM/blob/master/RLDDM.jags.txt 
#set dirs
dirinput <- "O:/studies/grapholemo/Analysis/models"
diroutput <- dirinput
model_path <- "N:/studies/Grapholemo/Scripts/grapholemo/RLDDM_v01_GFG.stan"


setwd(dirinput)
load("Gathered_data") #read gathered data (that will be combined with model parameters later)
load("Gathered_list_for_Stan") #read list with gather data input for model

# LOAD MODEL  #
###############
# rstan_options(auto_write = TRUE)
# options(mc.cores = parallel::detectCores())
# Sys.setenv(LOCAL_CPPFLAGS = '-march=native')

stanmodel <- rstan::stan_model(model_path)


fit <- rstan::sampling(object  = stanmodel,
                       data    = dat,
                       pars    = c("alpha","v_mod","tau","assoc_active_pair",
                                   "assoc_inactive_pair","delta_hat","pe_hat",
                                   "mu_alpha","mu_v_mod","mu_tau","log_lik"),
                       #init    = "random",
                       chains  = 1,
                       iter    = 9000,
                       warmup  = 3000, # warmup should be no more than 1/2 iterations (iter values include the warmups)
                       thin    = 1,
                       init_r =  0.5,
                       save_warmup = FALSE,
                       control = list(adapt_delta   = 0.995,
                                      stepsize      = 0.005,
                                      max_treedepth = 20),
                       verbose =TRUE)


# save model

saveRDS(fit, "fit_rlddm_gfg.rds")
