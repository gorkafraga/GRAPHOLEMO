rm(list=ls())
libraries <- c("Rcpp","boot","readr","tidyr","dplyr","bayesplot","rstanarm","RWiener","gridExtra","ggplot2","lme4","MASS")
lapply(libraries, require, character.only = TRUE)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")
source("N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_computationalModels/data_generation/LEMO_func_wiener_generator.R")
memory.limit(1024*1024*1024*1024)
memory.size(max = TRUE) 
#----------------------------------------------------------------------
# PARAMETER RECOVERY FROM RLDDM with two learning rates


# - by P.Haller (2021) adapted by G.Fraga-Gonzalez
#--------------------------------------------------------------------
# INPUTS 
task <- 'fbl_a'
model <- 'LEMO_rlddm_v32'
dirinput <-paste0("O:/studies/grapholemo/analysis/LEMO_GFG/beh/modeling/analysis_n39/",task,"/") #dir to stan fit object 
diroutput <- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_computationalModels/data_generation"

## Read data 
# read model fit 
fit <- readRDS(paste0(dirinput,model,'/',model,'_fit.rds'))

# this loads the raw data before trials were removed due to too low RT or missing
#load("data/feedback-all/raw_data_all_trials.rda")
load(paste0('O:/studies/grapholemo/analysis/LEMO_GFG/beh/modeling/',task,'_rawForParamRecovery_n39/raw_data.rda'))
raw_data <- datTable
#args = commandArgs(trailingOnly=TRUE)  
#setwd(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))

raw_data$vStimAssoc <- raw_data$aStim
stimuli <- raw_data %>% dplyr::select(subjID, vStimAssoc, vStimNassoc)

## define paths
#  path to fited stanmodel 
#fit <- readRDS(args[1])
n_draws = fit@stan_args[[4]]$iter-fit@stan_args[[4]]$warmup


# define number of subjects
n_subj = 10
# define number of trials per block
n_trials= 48
# define number of blocks
n_blocks = 2
# define number of pairs
n_pairs = 6*n_blocks
# define number of parameter sets
n_psets = 15

## First, sample from posterior
posterior_mu_a <- rstan::extract(fit, pars=c("mu_a"),permuted=FALSE)
posterior_mu_eta_pos <- rstan::extract(fit, pars=c("mu_eta_pos"),permuted=FALSE)
posterior_mu_eta_neg <- rstan::extract(fit, pars=c("mu_eta_neg"),permuted=FALSE)
posterior_mu_tau <- rstan::extract(fit, pars=c("mu_tau"),permuted=FALSE)
posterior_mu_v_mod <- rstan::extract(fit, pars=c("mu_v_mod"),permuted=FALSE)
posterior_mu_z <- rstan::extract(fit, pars=c("z"),permuted=FALSE)

samples <- matrix(data=NA, nrow = n_psets, ncol = 6)
colnames(samples) <- c("a","eta_pos","eta_neg","tau","v_mod", "z")

set.seed(42)
for (i in 1:n_psets){
  iteration <- sample(1:n_draws, 1)
  chain <- sample(1:4, 1)
  samples[i,1] <- posterior_mu_a[iteration,chain,1]
  samples[i,2] <- posterior_mu_eta_pos[iteration,chain,1]
  samples[i,3] <- posterior_mu_eta_neg[iteration,chain,1]
  samples[i,4] <- posterior_mu_tau[iteration,chain,1]
  samples[i,5] <- posterior_mu_v_mod[iteration,chain,1]
  samples[i,6] <- posterior_mu_z[iteration,chain,1]
}
## Generate synthetic data
generated_data <- LEMO_func_wiener_generator(samples = data.frame(samples),
                                   n_subj = n_subj, 
                                   n_trials = n_trials, 
                                   n_pairs = n_pairs, 
                                   n_psets = n_psets, 
                                   n_blocks = n_blocks)


save(generated_data,file=paste0(diroutput,"/generated_data.rda"))

# preprocessing for rlddm input
n_subj = nlevels(as.factor(generated_data$subjID))
trials = nrow(generated_data)
minRT= as.array(with(generated_data, aggregate(RT, by = list(y = subjID), FUN = min)[["x"]]))
iter = rep(seq.int(1, 120),nlevels(as.factor(generated_data$subjID)))
response = generated_data$fb
stim_assoc = generated_data$p_assoc
stim_nassoc = generated_data$p_nassoc
RT = generated_data$RT
first = as.array(which(iter==1))
last = as.array(which(iter==120))
value <- ifelse(generated_data$fb==2, 1, 0)
n_stims <- rep(24, n_subj)


dat <- list("N" = n_subj, 
            "T"=trials,
            "RTbound" = 0.15,
            "minRT" = minRT, 
            "iter" = iter, 
            "response" = response, 
            "stim_assoc" = stim_assoc, 
            "stim_nassoc" = stim_nassoc,
            "RT" = RT,
            "first" = first,
            "last" = last,
            "value"=value,
            "n_stims"=n_stims) 

###############
# LOAD MODEL  #
###############

# define which model you used here
stanmodel <- rstan::stan_model(args[2])

fit <- rstan::sampling(object  = stanmodel,
                       data    = dat,
                       pars    = c("mu_a","mu_v_mod","mu_tau","mu_eta_pos","mu_eta_neg", "mu_z"),
                       chains  = 4,
                       iter    = 2000,
                       warmup  = 1000,
                       thin    = 1,
                       init_r =  1,
                       seed = 42,
                       save_warmup = FALSE,
                       control = list(adapt_delta   = 0.9,
                                      #stepsize      = 0.01,
                                      max_treedepth = 11),
                       verbose =FALSE)

# save model
saveRDS(fit,paste0("fit_synthetic_short__",Sys.Date(),".rds"))

list_of_draws <- rstan::extract(fit)

sink(paste0("posteriors_fit_synthetic_", args[1], ".txt"))

cat("=============================\n")
cat("Posteriors\n")
cat("=============================\n")

print(names(list_of_draws))
params <- summary(fit, pars = c("mu_a","mu_v_mod", "mu_tau", "mu_eta_pos", "mu_eta_neg", "mu_z"), probs = c(0.1, 0.9))$summary
print(params)
sink()

