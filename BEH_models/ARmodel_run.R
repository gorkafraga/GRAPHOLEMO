#bPaths()
#assign(".lib.loc", "C:/Program Files/R/R-3.6.1/library", envir = environment(.libPaths)) 
#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","rstantools",
              "hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr", "data.table","tibble")

lapply(Packages, require, character.only = TRUE)
#source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")
#==============================================================================================================
#_____                _____ _______       _   _                       _      _ 
#|  __ \              / ____|__   __|/\   | \ | |                     | |    | |
#| |__) |   _ _ __   | (___    | |  /  \  |  \| |  _ __ ___   ___   __| | ___| |
#|  _  / | | | '_ \   \___ \   | | / /\ \ | . ` | | '_ ` _ \ / _ \ / _` |/ _ \ |
#| | \ \ |_| | | | |  ____) |  | |/ ____ \| |\  | | | | | | | (_) | (_| |  __/ |
#|_|  \_\__,_|_| |_| |_____/   |_/_/    \_\_| \_| |_| |_| |_|\___/ \__,_|\___|_|
#
#============================================================================================================
# - Load preprocessed  data list (formatted and with variables needed for Stan)
# - Load model 
# - Extract output with some processing
# 
# REFS: e.g. From Pederson et al.,2017 https://github.com/gbiele/RLDDM/blob/master/RLDDM.jags.txt 
#------------------------------------------------------------------------------------------------
# Set inputs 
dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/model_rtb300/Preproc_18ss"
diroutput <- "O:/studies/allread/mri/analysis_GFG/stats/task/model_rtb300/Preproc_18ss"
modelpath <- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan"
choiceModel <- 'rlddm_v31'

# Get preprocessed input data and list of variables and settings for the  model
setwd(dirinput)
load("Preproc_data") 
load("Preproc_list") 


# Create STANMODEL object with our model ( this may take a couple of minutes)
#------------------------------------------------------------------------------------------------
if (!exists("stanmodel")){
  stanmodel <- rstan::stan_model(paste0('N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan/',choiceModel,'.stan')) 
} else { cat("It seems you already created a model??\n")
}

# Model sampling inputs 
#myparameters <- c("a","v_mod","tau","eta_pos","eta_neg","mu_a","mu_v_mod","mu_tau","mu_eta_pos","mu_eta_neg","sigma_pr","sigma_eta_pr","v_hat", "pe_tot_hat", "pe_pos_hat", "pe_neg_hat","as_active","as_inactive", "as_chosen","lp_","log_lik")

#myparameters <- c("a","v_mod","tau","eta_pos","eta_neg","mu_a","mu_v_mod","mu_tau","mu_eta_pos","mu_eta_neg","sigma_pr","sigma_eta_pr",
#                  "v_hat", "pe_tot_hat", "pe_pos_hat", "pe_neg_hat","as_active","as_inactive", "as_chosen","lp_","log_lik")
#myparameters <- c("lp_","log_lik")

mychains <- 4 # numer of mcmc chains
myiter <- 700#10000
mywarmup <- 200#4000 # from iterations, how many will be warm ups

# FIT THE MODEL - draw samples.  _m_d('_')b_m_  (time consuming)
#-------------------------------------------------------------------------------------
#options(mc.cores = parallel::detectCores()) # for faster execution on local, multicore CPU with excess RAM
options(mc.cores = 8)
rstan_options(auto_write = TRUE) #avoid recompilation of unchanged Stan programs
Sys.setenv(LOCAL_CPPFLAGS = '-march=corei7 -mtune=corei7') # Comment this if you get errors.But else, this could improve execution times
cat("Fitting model",basename(choiceModel),"...\n")
stanfit <- rstan::sampling(object  = stanmodel,
                           data    = datList,
                          # pars    = myparameters, # if using the default all parameters are stored in model fit, use option include =TRUE only those included in pars=() are stored in fitted   
                          # include = TRUE,
                           chains  = mychains,
                           iter    = myiter,
                           warmup  = mywarmup,
                           thin    = 1,
                           init_r =  1,
                           save_warmup = FALSE,
                        #   control = list(adapt_delta = 0.999, stepsize = 0.01, max_treedepth = 12),
                           verbose =FALSE)

# save model
#------------------------------------------------------------------------------------- 
destinationFolder <- paste(diroutput,'/output_',choiceModel,sep='')
dir.create(destinationFolder)
setwd(destinationFolder)
saveRDS(stanfit, "fit_rlddm.rds")
