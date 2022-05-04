rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","rstantools","hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr","tibble","cmdstanr")
lapply(Packages, require, character.only = TRUE)
#==============================================================================================================
#   R  U N    S T A N M O D E L with CMD STAN  R
#============================================================================================================
# - Load preprocessed  data list (formatted and with variables needed for Stan)
# - Load model 
# - Extract output with some processing
# # REFS: e.g. From Pederson et al.,2017 https://github.com/gbiele/RLDDM/blob/master/RLDDM.jags.txt 
#------------------------------------------------------------------------------------------------
# Set dirs
set_cmdstan_path('G:/cmdstan/cmdstan-2.25.0')
dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RL_delta/GoodPerf_72"
modelpath <- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan"
load(paste0(dirinput,'/Preproc_data.rda'))
load(paste0(dirinput,'/Preproc_list.rda'))

setwd('O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RL_delta/GoodPerf_72/out_bandit2arm_delta')
# Select data format for hBayesDM names
datList$Tsubj <- datTable$iter
datList$choice <- datTable$response
datList$outcome <- datTable$fb
datList$outcome[which(datList$outcome==0)] <- -1


#model_list <- c('AR_rlddm_v21','AR_rlddm_v22','AR_rlddm_v31','AR_rlddm_v32')  
model  <- c('bandit2arm_delta')   
 
  #diroutput <- paste(dirinput,"/outputs/out_",model,sep='')
  diroutput <- paste0(dirinput,'/out_',model)
  dir.create(diroutput,recursive=TRUE)
  setwd(diroutput)
  
  # Sampling settings ----------------------------------------------------
   mychains <- 4 # numer of mcmc chains
   myiter <-  10000
   mywarmup <-  4000 # in cmd stan these are not part of the iterations This is also called 'burn-in' 
   init_list <- NULL
  
 # FIT THE MODEL - draw samples.  /_m_d('_')b_m_/  (time consuming)
 #-------------------------------------------------------------------------------------
  options(buildtools.check = NULL)
  #options(mc.cores = 8)
  options(mc.cores = parallel::detectCores()) 
  rstan_options(auto_write = TRUE)
  memory.limit(9999999999)
  memory.size(max = TRUE) 
  #options(mc.cores = parallel::detectCores()) # for faster execution on local, multicore CPU with excess RAM%
  #Sys.setenv(LOCAL_CPPFLAGS = '-mtune=native') # Comment this if you get errors.But else, this could improve execution times
  #Sys.setenv(LOCAL_CPPFLAGS = '-march=znver2 -mtune=znver2') # Comment this if you get errors.But else, this could improve execution times
  
  # compile  model 
  cmdstanmodel <- cmdstanr::cmdstan_model(paste0(modelpath,'/',model,'.stan'), compile = TRUE)
  #begin sampling
  cmdstanfit <- cmdstanmodel$sample (data    = datList,
                              chains  = mychains,
                              parallel_chains  = mychains, 
                              iter_sampling = myiter,
                              iter_warmup  = mywarmup,  #note in cmdstan warmups are ADDED to iterations
                              thin    = 2,
                              init = init_list,
                              save_warmup = FALSE,
                              output_dir = diroutput,
                              #adapt_delta   = 0.999,#0.999/0.995  # Default 0.8 
                              refresh = 10,
                              show_messages = TRUE)
  
  # Gather the samples to create a stan fit object -------------------------------------------------------
    samples_list <- c()
    for (ii in 1:mychains){
      samplefile <- dir(path=diroutput,pattern=paste0('/*.-',ii,'-.*.csv'))
      samples_list <- c(samples_list,rstan::read_stan_csv(paste0(diroutput,'/',samplefile)))
    }
    cmdstanfit <- rstan::sflist2stanfit(samples_list)
    saveRDS(cmdstanfit,paste0(diroutput,'/',model,'.rds'))
 

    
    #save script
    scriptfile <- rstudioapi::getActiveDocumentContext()$path
    scriptfilepattern <- gsub(":","",sub(":","",gsub("-","",sub(" ","",Sys.time()))))
    file.copy(scriptfile,gsub('//','/',paste0(diroutput,paste0('/code_',scriptfilepattern,'_',gsub(".R$",".txt",basename(scriptfile))))))
    
    