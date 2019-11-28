.libPaths()
assign(".lib.loc", "C:/Program Files/R/R-3.6.1/library", envir = environment(.libPaths))

#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan",
              "hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot")
#install.packages("rstan", dependencies = TRUE, type = "source", lib = "C:/Program Files/R/R-3.6.1/library")
#"rstanarm",
#lapply(Packages, install.packages, character.only = TRUE)
lapply(Packages, require, character.only = TRUE)
#=====================================================================================
# RUN MODEL (with Stan)
#=====================================================================================
# - Load preprocessed  data list (formatted and with variables needed for Stan)
# - Load model 
# - Extract output with some processing
# 
#--------------------------------------------------------------------------------------------
# REFS: e.g. From Pederson et al.,2017 https://github.com/gbiele/RLDDM/blob/master/RLDDM.jags.txt 
#set dirs
dirinput <- "O:/studies/grapholemo/Analysis/models"
diroutput <- "N:/studies/Grapholemo/Scripts/grapholemo"
model_path <- "N:/studies/Grapholemo/Scripts/grapholemo/RLDDM_v01_GFG.stan"

setwd(dirinput)
load("Gathered_list")

# LOAD MODEL  #
###############
# rstan_options(auto_write = TRUE)
# options(mc.cores = parallel::detectCores())
# Sys.setenv(LOCAL_CPPFLAGS = '-march=native')

stanmodel <- rstan::stan_model(model_path)


fit <- rstan::sampling(object  = stanmodel,
                       data    = dat,
                       pars    = c("alpha","v_mod","tau","assoc_active_pair",
                                   "assoc_inactive_pair","delta_hat","pe_hat",
                                   "mu_alpha","mu_v_mod","mu_tau","log_lik"),
                       #init    = "random",
                       chains  = 1,
                       iter    = 9000,
                       warmup  = 3000, # warmup should be no more than 1/2 iterations (iter values include the warmups)
                       thin    = 1,
                       init_r =  0.5,
                       save_warmup = FALSE,
                       control = list(adapt_delta   = 0.995,
                                      stepsize      = 0.005,
                                      max_treedepth = 20),
                       verbose =TRUE)


# save model

saveRDS(fit, "fit_rlddm_gfg.rds")
fit <- readRDS(paste(dirinput,"/fit_rlddm_gfg.rds",sep=""))
# fit <- readRDS("fit1.rds") 

##############
# check data #
###############

parVals <- rstan::extract(fit, permuted = TRUE)
fit_summary <- rstan::summary(fit)
print(fit_summary)


traceplot(fit, pars = c("mu_alpha", "mu_v_mod","mu_tau", "lp__"))
stan_hist(fit, pars = c("mu_alpha","mu_v_mod","mu_tau"))
stan_dens(fit, pars = c("mu_alpha","mu_v_mod","mu_tau"))

#####################################
# EXTRACT AND WRITE OUT PARAMETERS  #
#####################################
alpha <- rep("NA",dat$N)
for (i in 1:dat$N){
  index <- paste0("alpha[",i,"]")
  alpha[i] <- fit_summary$summary[index,1]
}
alpha <- as.double(alpha)


drift_mod <- rep("NA",dat$N)
for (i in 1:dat$N){
  index <- paste0("v_mod[",i,"]")
  drift_mod[i] <- fit_summary$summary[index,1]
}
drift_mod <- as.double(drift_mod)

tau <- rep("NA",dat$N)
for (i in 1:dat$N){
  index <- paste0("tau[",i,"]")
  tau[i] <- fit_summary$summary[index,1]
}
tau <- as.double(tau)

# delta = average of upper and lower response boundary
deltas <- rep("NA",dat$T)
for (i in 1:dat$T){
  index <- paste0("delta_hat[",i,"]")
  deltas[i] <- fit_summary$summary[index,1]
}
deltas <- as.double(deltas)

# association strength of active (i.e. correct) stimulus pair
assoc_active_pair <- rep("NA",dat$T)
for (i in 1:dat$T){
  index <- paste0("assoc_active_pair[",i,"]")
  assoc_active_pair[i] <- fit_summary$summary[index,1]
}
assoc_active_pair <- as.double(assoc_active_pair)

# association strength of inactive (i.e. incorrect) stimulus pair
assoc_inactive_pair <- rep("NA",dat$T)
for (i in 1:dat$T){
  index <- paste0("assoc_inactive_pair[",i,"]")
  assoc_inactive_pair[i] <- fit_summary$summary[index,1]
}
assoc_inactive_pair <- as.double(assoc_inactive_pair)

# prediction errors
pe_hat <- rep("NA",dat$T)
for (i in 1:dat$T){
  index <- paste0("pe_hat[",i,"]")
  pe_hat[i] <- fit_summary$summary[index,1]
}
pe_hat <- as.double(pe_hat)

# add the trial-by-trial regressors to the dataset
tbtregs <- cbind(pe=as.array(pe_hat),delta=as.array(deltas),drift=rep(0,dat$T),assoc_active=as.array(assoc_active_pair),assoc_inactive=as.array(assoc_inactive_pair))
#tbtregs <- cbind(raw_data[,1:9],raw_data[,18],raw_data[,14:16],pe=as.array(pe_hat),delta=as.array(deltas),drift=rep(0,dat$T),assoc_active=as.array(assoc_active_pair),assoc_inactive=as.array(assoc_inactive_pair))
for(i in 1:dat$N){
  subj = as.character(subjs[i])
  tbtregs[which(tbtregs$subjID==subj),]$drift = tbtregs[which(tbtregs$subjID==subj),]$delta * drift_mod[i]
}

# write out parameters for each subject separately
for(i in 1:n_subj){
  subj = as.character(subjs[i])
  write.table(tbtregs[which(tbtregs$subjID==subj),], paste0(subj,"_params",".csv"),
              quote=FALSE, sep=",", row.names=FALSE, col.names=TRUE)
}

# compute mean drift for each subject
mean_drift <-  rep("NA",dat$N)
mean_drift <- aggregate(list(drift=tbtregs$drift),list(subjID=tbtregs$subjID), mean)
subj_params <- cbind(mean_drift,alpha,tau,drift_mod)
# write out subject parameters
write.table(subj_params, "subj_params.csv", sep=",", row.names=FALSE, col.names=TRUE,quote = FALSE)

