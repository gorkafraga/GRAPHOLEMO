# Master script to run rlddm-analysis on feedback learning task
# Patrick Haller, January 2020

#load required packages
Packages <- c("StanHeaders", "rstan", "Rcpp", "bayesplot", "boot", 
              "readr", "data.table", "ggplot2","tibble", "rstanarm",
              "dplyr","tidyr")
lapply(Packages, require, character.only = TRUE)
options(mc.cores = 4)

# set directories
dirinput <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd(dirinput)
datainput <- paste0(dirinput, "/data")
modelpath <- paste0(dirinput, "/models")

# load required scripts
source("scripts/load_data.R")
source("scripts/run_rlddm.R")
source("scripts/extract_stanfit.R")

input = "load" # load already preprocessed data, or preprocess new data
model = "rlddm1" # load model you wish to apply (rlddm1, rlddm2,... rlddm6)
meancenter = 1 # if 1 -> meancenter all rlddm parameters (needed in fMRI analyses) 0 = do not meancenter

input_data <- data_preprocess(datainput, input) #load or preprocess input data

stanfit <- run_rlddm(
  model = paste0(modelpath,"/",model,".stan"),
  data    = input_data,
  pars    = c("a","v_mod","tau","eta_pos","eta_neg",
              "mu_a","mu_v_mod","mu_tau","mu_eta_pos","mu_eta_neg","sigma","sigma_eta",
              "v_hat", "pe_tot_hat", "pe_pos_hat", "pe_neg_hat",
              "log_lik"), # parameters to estimate
  chains  = 4, # number of mcmc chains 
  iter    = 10000, # number of iterations
  warmup  = 4000) # number of warmup iterations (included in iter(!))

stanmodel <- rstan::stan_model('N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan/rlddm1.stan')
cat("fitting model ", basename(model))
stanfit <- rstan::sampling(object  = stanmodel,
                           data    = data,
                           pars    = pars,
                           chains  = chains,
                           iter    = iter,
                           warmup  = warmup,
                           thin    = 1,
                           init_r =  1,
                           save_warmup = FALSE,
                           control = list(adapt_delta   = 0.99,
                                          stepsize      = 0.01,
                                          max_treedepth = 12),
                           verbose =FALSE)
saveRDS(stanfit,model)

rlddm_parameters <- extract_stanfit(stanfit, meancenter)
