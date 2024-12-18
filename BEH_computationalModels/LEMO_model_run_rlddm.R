rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("grid","gridExtra","readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","rstantools","hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr","tibble","cmdstanr")
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
#model_list <- c('LEMO_rlddm_v21','LEMO_rlddm_v22','LEMO_rlddm_v31','LEMO_rlddm_v32')  
model  <- c('LEMO_rlddm_v32')   

set_cmdstan_path('C:/Users/gfraga-adm/Documents/.cmdstanr/cmdstan-2.29.1')

dirinput <- paste0("C:/Users/gfraga-adm/run_chains_fbl_b/data_preprocessed")
diroutput <- paste0("C:/Users/gfraga-adm/run_chains_fbl_b/",model,"/")
modelpath <- "C:/Users/gfraga-adm/"
load(paste0(dirinput,'/Preproc_data.rda'))
load(paste0(dirinput,'/Preproc_list.rda'))


dir.create(diroutput,recursive=TRUE)
setwd(diroutput)
  
  # Sampling settings ----------------------------------------------------
   mychains <- 4 # number of mcmc chains
   myiter <-  10000#10000
   mywarmup <- 4000# 4000 # in cmd stan these are not part of the iterations This is also called 'burn-in' 
   switch(model,
               LEMO_rlddm_v12={
                 #init_list <- function() { list(mu_pr=c(1, -0.5,  0.5, -1),sigma=c(1,0.5,1,0.5)) }
                  #init_list <- NULL
                  init_list <- function() { list(mu_pr=c( 0.598, -4.358, -0.287, 1.36),sigma=c(0.043,0.216,0.482,0.021)) }#
                },
               LEMO_rlddm_v11={
                 #init_list <-function() { list(mu_pr=c(1.5,1,3),sigma_pr=c(0.1,0.1,3)) } 
                 init_list <- function() { list(mu_pr=c( 0.584187, -3.43305, 0.0876689, 1.25882),sigma=c(0.06,0.6,0.36,0.37)) }#
                 #init_list <-  NULL
               },
                LEMO_rlddm_v11_mupr={
                  init_list <-function() { list(mu_pr=c(1,0.5,0.5),sigma_pr=c(0.1,0.1,0.1)) }
                  #init_list <- NULL
                },
                rlddm4={
                 #init_list <-  function() { list(mu_pr=c(0.86, -0.68, -0.96, -0.1),sigma=c(0.5, 0.6, 1.2, 0.8)) }
                  init_list <-  NULL
                },
               LEMO_rlddm_v22={
                 #init_list <- function() { list(mu_pr=c(1,0.5,0.5,0.5),sigma_pr=c(0.1,0.1,0.1,0.1)) }
                 init_list <- function() { list(mu_pr=c(1,0.5,0.5),sigma_pr=c(0.1,0.1,0.1)) }
                 
                 #init_list <- NULL
               },
               LEMO_rlddm_v21={
                 init_list <- function() { list(mu_pr=c(1,0.5,0.5,0.5),sigma_pr=c(0.1,0.1,0.1,0.1)) }
                 #init_list <- NULL
               },
               LEMO_rlddm_v32={
                # init_list <- function() { list(mu_pr=c(1,0.5,0.5),sigma_pr=c(0.1,0.1,0.1)) }
                 init_list <- NULL
               },
               LEMO_rlddm_v31={
                # init_list <-function() { list(mu_pr=c(1,0.5,0.5),sigma_pr=c(0.1,0.1,0.1)) }
                 init_list <- NULL
            
              })
  
 # FIT THE MODEL - draw samples.  \_m_d('_')b_m_/  (time consuming)
 #-------------------------------------------------------------------------------------
  options(buildtools.check = NULL)
  #options(mc.cores = 8)
  options(mc.cores = parallel::detectCores()) 
  rstan_options(auto_write = TRUE)
  memory.limit(1024*1024*1024*1024)
  memory.size(max = TRUE) 
  # Sys.setenv(LOCAL_CPPFLAGS = '-mtune=native') # Comment this if you get errors.But else, this could improve execution times
  #Sys.setenv(LOCAL_CPPFLAGS = '-march=znver2 -mtune=znver2') # Comment this if you get errors.But else, this could improve execution times
  
  # compile  model 
  cmdstanmodel <- cmdstanr::cmdstan_model(paste0(modelpath,'/',model,'.stan'), compile = TRUE)
  #begin sampling
  cmdstanfit <- cmdstanmodel$sample (data    = datList,
                              chains  = mychains,
                              parallel_chains = getOption("mc.cores", mychains),
                              iter_sampling = myiter,
                              iter_warmup  = mywarmup,  #note in cmdstan warmups are ADDED to iterations
                              thin    = 1,
                               init = init_list,
                              save_warmup = FALSE,
                              output_dir = diroutput,
                              adapt_delta   = 0.999,#0.999/0.995  # Default 0.8 
                              refresh = 10,
                              validate_csv = FALSE, 
                              show_messages = TRUE)
  
  #cmdstanfit$save_object(file = paste0(diroutput,'/cmdstanObj_',model,'.rds'))
  
  # Gather the samples to create a stan fit object -------------------------------------------------------
    samples_list <- c()
    for (ii in 1:mychains){
      samplefile <- dir(path=diroutput,pattern=paste0('/*.-',ii,'-.*.csv'))
        print(paste0(' Reading chain ', ii , ' (', samplefile,')'))
      
      samples_list <- c(samples_list,rstan::read_stan_csv(paste0(diroutput,'/',samplefile)))
        print(paste0(' Chain ', ii , ' has been read'))
    }
    cmdstanfit <- rstan::sflist2stanfit(samples_list)
    saveRDS(cmdstanfit,paste0(diroutput,'/',model,'_fit.rds'))
    
 # Save some values for model comparisons
     loglik1 <- loo::extract_log_lik(cmdstanfit, merge_chains = FALSE)
    saveRDS(loglik1,paste0(diroutput,'/',model,'_logLik.rds')) 
    
    #save script
   scriptfile <- rstudioapi::getActiveDocumentContext()$path
   scriptfilepattern <- gsub(":","",sub(":","",gsub("-","",sub(" ","",Sys.time()))))
   file.copy(scriptfile,gsub('//','/',paste0(diroutput,paste0('/code_',scriptfilepattern,'_',gsub(".R$",".txt",basename(scriptfile))))))
    
    