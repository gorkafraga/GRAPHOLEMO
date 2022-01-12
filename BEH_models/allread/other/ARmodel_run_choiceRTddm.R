#.libPaths()
#assign(".lib.loc",  envir = environment(.libPaths)) 
#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","rstantools","hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr","tibble")

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
dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/modelling/DDM_hBayesDM/Preproc_ChoiceRTddm_Group0_31ss"
diroutput <- "O:/studies/allread/mri/analysis_GFG/stats/task/modelling/DDM_hBayesDM/Preproc_ChoiceRTddm_Group0_31ss"

# Get preprocessed input data and list of variables and settings for the  model
setwd(diroutput)
mychains <- 4 # numer of mcmc chains
myiter <-  10000
mywarmup <- 1000#4000 # from iterations, how many will be warm ups

# FIT THE MODEL - draw samples.  _m_d('_')b_m_  (time consuming)
#-------------------------------------------------------------------------------------
options(mc.cores = parallel::detectCores())
ddmfit <- choiceRT_ddm(data = "choose", niter = myiter, nwarmup = mywarmup, nchain = mychains,
                       ncore = 4, nthin = 1, inits = "vb", indPars = "mean",
                       modelRegressor = FALSE, vb = FALSE, inc_postpred = FALSE,
                       adapt_delta = 0.95, stepsize = 1, max_treedepth = 10)

# save model
#------------------------------------------------------------------------------------- 
setwd(diroutput)
saveRDS(ddmfit, "ddm_fit.rds")
