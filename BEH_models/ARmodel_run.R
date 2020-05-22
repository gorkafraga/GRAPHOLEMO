#bPaths()
#assign(".lib.loc", "C:/Program Files/R/R-3.6.1/library", envir = environment(.libPaths))

#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","rstantools",
              "hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr", "data.table","tibble")

lapply(Packages, require, character.only = TRUE)

#source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")
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

dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/model/Preproc_19ss"
diroutput <- "O:/studies/allread/mri/analysis_GFG/stats/task/model/Preproc_19ss"
modelpath <- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan"
choiceModel <- 'rlddm2'

#------------------------------------------------------------------------------------------------
# Get preprocessed input data and list of variables and settings for the  model
setwd(dirinput)
load("Preproc_data") 
load("Preproc_list") 



# Create STANMODEL object with our model ( this may take a couple of minutes)
if (!exists("stanmodel")){
  stanmodel <- rstan::stan_model(paste0('N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan/',choiceModel,'.stan')) 
} else { cat("It seems you already created a model??\n")
}

## Model sampling inputs 
myparameters <- c("a","v_mod","tau","eta_pos","eta_neg","mu_a","mu_v_mod","mu_tau","mu_eta_pos","mu_eta_neg","sigma","sigma_eta",
                  "v_hat", "pe_tot_hat", "pe_pos_hat", "pe_neg_hat",  "log_lik")
mychains <- 4 # numer of mcmc chains
myiter <- 10000#10000
mywarmup <- 4000#4000 # from iterations, how many will be warm ups

###### Fit model ##    _m_d('_')b_m_  (draws samples, takes time)
#-------------------------------------------------------------------------------------

# Execution settings for faster processing 
options(mc.cores = parallel::detectCores()) # for execution on local, multicore CPU with excess RAM
#options(mc.cores = 4)
rstan_options(auto_write = TRUE) #avoid recompilation of unchanged Stan programs
Sys.setenv(LOCAL_CPPFLAGS = '-march=corei7 -mtune=corei7') # Comment this if you get errors.But else, this could improve execution times
cat("Fitting model",basename(choiceModel),"...\n")
stanfit <- rstan::sampling(object  = stanmodel,
                           data    = datList,
                           pars    = myparameters,
                           chains  = mychains,
                           iter    = myiter,
                           warmup  = mywarmup,
                           thin    = 1,
                           init_r =  1,
                           save_warmup = FALSE,
                           control = list(adapt_delta = 0.999,stepsize = 0.01,max_treedepth = 12),
                           verbose =FALSE)
#------------------------------------------------------------------------------------- 
# save model

destinationFolder <- paste(diroutput,'/output_',choiceModel,sep='')
dir.create(destinationFolder)
setwd(destinationFolder)
saveRDS(stanfit, "fit_rlddm.rds")
