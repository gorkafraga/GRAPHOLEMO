rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("grid","gridExtra","readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","rstantools","hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr","tibble","cmdstanr")
lapply(Packages, require, character.only = TRUE)
#==============================================================================================================
# COMBINE CHAINS OF MODELS (from cmdStan)
#============================================================================================================
# - find chains stored as .csv files
# - Only chains from the same run should be in input folder (problems if .csv from different model runs are found )
# - creates large rds cmdstan object and log likelihood for model comparison
# - time consuming (chains are very large files)
#----------------------------------------------------------------------------------------------------------------
# Set dirs
#model_list <- c('LEMO_rlddm_v21','LEMO_rlddm_v22','LEMO_rlddm_v31','LEMO_rlddm_v32')  
model  <- c('LEMO_rlddm_v32')   
set_cmdstan_path('G:/cmdstan/cmdstan-2.25.0')
#dirinput <- paste0("G:/GRAPHOLEMO/MODELS/fbl_a/",model)
#diroutput <- paste0("G:/GRAPHOLEMO/MODELS/fbl_a/",model,"")
dirinput <- paste0("C:/Users/gfraga-adm/run_chains_fbl_a/", model)
diroutput <- dirinput

dir.create(diroutput,recursive=TRUE)
setwd(diroutput)

# Sampling settings ----------------------------------------------------
mychains <- 4 # numebr of mcmc chains
 
 
# memory options (required?)
options(buildtools.check = NULL)
options(mc.cores = parallel::detectCores()) 
rstan_options(auto_write = TRUE)
memory.limit(1024*1024*1024*1024)
memory.size(max = TRUE)  
# Gather the samples to create a stan fit object -------------------------------------------------------
samples_list <- c()
for (ii in 1:mychains){
  samplefile <- dir(path=dirinput,pattern=paste0('/*.-',ii,'-.*.csv'))
  print(paste0(' Reading chain ', ii , ' (', samplefile,')'))
  
  samples_list <- c(samples_list,rstan::read_stan_csv(paste0(diroutput,'/',samplefile)))
  print(paste0(' Chain ', ii , ' read'))
}
cmdstanfit <- rstan::sflist2stanfit(samples_list)
saveRDS(cmdstanfit,paste0(diroutput,'/',model,'_fit.rds'))

# Save some values for model comparisons
loglik1 <- loo::extract_log_lik(cmdstanfit, merge_chains = FALSE)
saveRDS(loglik1,paste0(diroutput,'/',model,'_logLik.rds')) 

 
