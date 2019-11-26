#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan",
              "hBayesDM","Rcpp")
#"rstanarm",
lapply(Packages, require, character.only = TRUE)
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
diroutput <- "N:/studies/Grapholemo/Scripts/grapholemo"
model_path <- "N:/studies/Grapholemo/Scripts/grapholemo/RLDDM_v01_GFG.stan"

setwd(dirinput)
load("Gathered_list")

# LOAD MODEL  #
###############

stanmodel <- rstan::stan_model(model_path)

fit <- rstan::sampling(object  = stanmodel,
                       data    = dat,
                       pars    = c("alpha","v_mod","tau","assoc_active_pair",
                                   "assoc_inactive_pair","delta_hat","pe_hat",
                                   "mu_alpha","mu_v_mod","mu_tau","log_lik"),
                       #init    = "random",
                       chains  = 4,
                       iter    = 9000,
                       warmup  = 3000,
                       thin    = 1,
                       init_r =  0.5,
                       save_warmup = FALSE,
                       control = list(adapt_delta   = 0.995,
                                      stepsize      = 0.005,
                                      max_treedepth = 20),
                       verbose =FALSE)
