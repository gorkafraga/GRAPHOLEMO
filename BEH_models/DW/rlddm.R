# Master script to run rlddm-analysis on feedback learning task
# Patrick Haller, January 2020

#load required packages
Packages <- c("StanHeaders", "rstan", "Rcpp", "bayesplot", "boot", 
              "readr", "data.table", "ggplot2","tibble", "rstanarm",
              "dplyr","tidyr","xlsx")
lapply(Packages, require, character.only = TRUE)
options(mc.cores = 8)

# set directories
dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/logs"  # should be the top folder

#datainput <- paste0(dirinput,"/data/data_verygoodperf_20a")
datainput <- paste0(dirinput,"/normperf_72")
masterfile <- 'O:/studies/allread/mri/analysis_GFG/Allread_MasterFile_GFG.xlsx'
# load required scripts
source('N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/DW/load_data.R') 

meancenter = 1 # if 1 -> meancenter all rlddm parameters (needed in fMRI analyses) 0 = do not meancenter

options(buildtools.check = NULL)
# rm(input_data)
input_data <- data_preprocess(datainput, masterfile) #load or preprocess input data
