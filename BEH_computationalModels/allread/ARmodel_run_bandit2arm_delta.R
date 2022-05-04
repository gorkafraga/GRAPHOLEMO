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
dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RL_delta/GoodPerf_72"
diroutput <- "O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RL_delta/GoodPerf_72"
modelpath <- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan"
choiceModel <- 'bandit2arm_delta'
setwd(dirinput)
load('Preproc_data.rda')
load('Preproc_list.rda')

# Select data format for hBayesDM names
datTable <- dplyr::select(datTable, c('subjID','response','fb'))
colnames(datTable) <- c('subjID','choice','outcome')
datTable$outcome[which(datTable$outcome==0)] <- -1

datList$Tsubj <- datList$trials
datList$choice <- datTable$choice
datList$outcome <- datTable$outcome
 


# settings 
  mychains <- 4 # numer of mcmc chains
  myiter <- 2000 #10000
  mywarmup <- 1000 #4000 # from iterations, how many will be warm ups
    #Sys.setenv(LOCAL_CPPFLAGS = '-mtune=native') # Comment this if you get errors.But else, this could improve execution times
  #Sys.setenv(LOCAL_CPPFLAGS = '-march=znver2 -mtune=znver2') # Comment this if you get errors.But else, this could improve execution times
  memory.limit (9999999999)

#Run hBayesDM model 
  
fit <-
  bandit2arm_delta(data = datTable,
                  niter = myiter,
                  nwarmup = mywarmup,
                  nchain = mychains,
                  ncore = parallel::detectCores(),
                  nthin = 2,
                  inits = "vb",
                  indPars = "mean",
                  modelRegressor = FALSE,
                  vb = FALSE,
                  inc_postpred = FALSE,
                  adapt_delta = 0.95,
                  stepsize = 1,
                  max_treedepth = 10
  )


 
 # save model
#------------------------------------------------------------------------------------- 
destinationFolder <- paste(diroutput,'/output_',choiceModel,sep='')
dir.create(destinationFolder)
setwd(destinationFolder)
saveRDS(fit, "fit.rds")
