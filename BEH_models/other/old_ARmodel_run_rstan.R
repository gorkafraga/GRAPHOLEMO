#bPaths()
#assign(".lib.loc", "C:/Program Files/R/R-3.6.1/library", envir = environment(.libPaths)) 
#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","rstantools",
              "hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr","tibble")

lapply(Packages, require, character.only = TRUE)
#source("//kjpd-nas01.d.uzh.ch/BrainMap$/studies/allread/mri/analyses_NF/rlddm_analyses_NF/RLDDModel_gfg_versions")
#==============================================================================================================
#   R  U N    S T A N M O D E L
#============================================================================================================
# - Load preprocessed  data list (formatted and with variables needed for Stan)
# - Load model 
# - Extract output with some processing
# 
# REFS: e.g. From Pederson et al.,2017 https://github.com/gbiele/RLDDM/blob/master/RLDDM.jags.txt 
#------------------------------------------------------------------------------------------------
# Set inputs 
dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM/GoodPerf_42"
diroutput <- "O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM/GoodPerf_42"
modelpath <- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan"
choiceModel <- 'AR_rlddm_v11'

setwd(dirinput)
load('Preproc_data')
load('Preproc_list')




# Create STANMODEL object with our model ( this may take a couple of minutes)
#------------------------------------------------------------------------------------------------
if (!exists("stanmodel")){
  stanmodel <- rstan::stan_model(paste0(modelpath,'/',choiceModel,'.stan')) 
  # stanmodel <- rstan::stan_model(paste0('N:/Users/dwillinger/scripts/ARmodel/Stan/',choiceModel,'.stan')) 
  cat("Compiled model\n")
} else { cat("It seems you already compiled a model??\n")
}

# Model sampling inputs 
#myparameters <- c("a","v_mod","tau","eta_pos","eta_neg","mu_a","mu_v_mod","mu_tau","mu_eta_pos","mu_eta_neg","sigma_pr","sigma_eta_pr","v_hat", "pe_tot_hat", "pe_pos_hat", "pe_neg_hat","as_active","as_inactive", "as_chosen","lp_","log_lik")

#myparameters <- c("a","v_mod","tau","eta_pos","eta_neg","mu_a","mu_v_mod","mu_tau","mu_eta_pos","mu_eta_neg","sigma_pr","sigma_eta_pr",
#                  "v_hat", "pe_tot_hat", "pe_pos_hat", "pe_neg_hat","as_active","as_inactive", "as_chosen","lp_","log_lik")
#myparameters <- c("lp_","log_lik")

mychains <- 4 # numer of mcmc chains
myiter <- 1000 #10000
mywarmup <- 100 #4000 # from iterations, how many will be warm ups

# some memory and processor settings
#options(mc.cores = 16)        
    memory.limit(9999999999)
    memory.size(max = TRUE)
    options(mc.cores = 8)
    # options(mc.cores = parallel::detectCores()) # for faster execution on local, multicore CPU with excess RAM%
    rstan_options(auto_write = TRUE) #avoid recompilation of unchanged Stan programs
    Sys.setenv(LOCAL_CPPFLAGS = '-mtune=native') # Comment this if you get errors.But else, this could improve execution times
    Sys.setenv(LOCAL_CPPFLAGS = '-march=znver2 -mtune=znver2') # Comment this if you get errors.But else, this could improve execution times
    memory.limit (size=4e+6)

# FIT THE MODEL - draw samples.  _m_d('_')b_m_  (time consuming)
#-------------------------------------------------------------------------------------
cat("Proceding to fit model",basename(choiceModel),"...\n")
# Begin sampling
stanfit <- rstan::sampling(object  = stanmodel,
                           data    = datList,
                           # pars    = myparameters, # if using the default all parameters are stored in model fit, use option include =TRUE only those included in pars=() are stored in fitted   
                           # include = TRUE,
                           chains  = mychains,
                           iter    = myiter, 
                           warmup  = mywarmup,
                           sample_file = paste0(choiceModel,'_samples.csv'),
                           thin    = 1,
                           init_r =  1,
                           init =  "random",
                           #init = list(mu_pr=c(0.86, -0.68, -0.96, -0.1),sigma_pr=c(0.5, 0.6, 1.2, 0.8)),
                           save_warmup = FALSE,
                           #control = list(adapt_delta = 0.999, stepsize = 0.01, max_treedepth = 12),
                           verbose =FALSE)

# save model
#------------------------------------------------------------------------------------- 
destinationFolder <- paste(diroutput,'/output_',choiceModel,sep='')
dir.create(destinationFolder)
setwd(destinationFolder)
saveRDS(stanfit, "fit_rlddm.rds")
