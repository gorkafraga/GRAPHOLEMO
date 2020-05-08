.libPaths()
assign(".lib.loc", "C:/Program Files/R/R-3.6.1/library", envir = environment(.libPaths))

#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan",
              "hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr")
lapply(Packages, require, character.only = TRUE)

source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")
#=====================================================================================
# RUN MODEL (with Stan)
#=====================================================================================
# - Load preprocessed  data list (formatted and with variables needed for Stan)
# - Load model 
# - Extract output with some processing
# 
#--------------------------------------------------------------------------------------------
# REFS: e.g. From Pederson et al.,2017 https://github.com/gbiele/RLDDM/blob/master/RLDDM.jags.txt 
#------------------------------------------------------------------------------------------------
# Set inputs 
source('N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/run_rlddm.R')
dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/preprocessed"
diroutput <- dirinput
modelpath <- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan"
choiceModel <- 'rlddm1'

#------------------------------------------------------------------------------------------------
# Get preprocessed input data and list of variables and settings for the  model
setwd(dirinput)
load("Gathered_data") 
load("Gathered_list_for_Stan") 

# Execution settings for faster processing 
#options(mc.cores = parallel::detectCores()) # for execution on local, multicore CPU with excess RAM
#options(mc.cores = 4)
rstan_options(auto_write = TRUE) #avoid recompilation of unchanged Stan programs
#Sys.setenv(LOCAL_CPPFLAGS = '-march=corei7 -mtune=corei7') # Comment this if you get errors.But else, this could improve execution times

# Create STANMODEL object with our model 
if (!exists("stanmodel")){
  stanmodel <- rstan::stan_model(paste0('N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan/',choiceModel,'.stan'))
} else { cat("It seems you already created a model??\n")
}

## Model sampling inputs 
myparameters <- c("a","v_mod","tau","eta_pos","eta_neg","mu_a","mu_v_mod","mu_tau","mu_eta_pos","mu_eta_neg","sigma","sigma_eta",
                  "v_hat", "pe_tot_hat", "pe_pos_hat", "pe_neg_hat",  "log_lik")
mychains <- 4 # numer of mcmc chains
myiter <- 10000
mywarmup <- 4000 # from iterations, how many will be warm ups

###### Fit model ##    _m_d('_')b_m_  (draws samples, takes time)
#-------------------------------------------------------------------------------------
cat("Fitting model",basename(choiceModel),"...\n")
stanfit <- rstan::sampling(object  = stanmodel,
                           data    = dat,
                           pars    = myparameters,
                           chains  = mychains,
                           iter    = myiter,
                           warmup  = mywarmup,
                           thin    = 1,
                           init_r =  1,
                           save_warmup = FALSE,
                           control = list(adapt_delta   = 0.99,stepsize = 0.01,max_treedepth = 12),
                           verbose =FALSE)
#-------------------------------------------------------------------------------------

fit <- rstan::sampling(object  = model,
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
