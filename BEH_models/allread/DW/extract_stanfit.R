# Patrick Haller, January 2020

center_colmeans <- function(x) {
  xcenter = colMeans(x)
  x - rep(xcenter, rep.int(nrow(x), ncol(x)))
}

extract_stanfit <- function(stanfit,meancenter){
  # this function extracts the RLDDM parameters from the 
  # stanfit model, yielded by the function "run_rlddm"
  # and returns 2 objects: 
  # 1) a list of mean-centered(!) trial-by-trial parameters (assoc. strength, prediction error, ...)
  # 2) a list of mean-centered(!)subject-level parametrs (learning rate, decision boundary, ...)
  cat("loading performance data during fmri...\n")
  source <- paste0(dirinput, "/data/preprocessed_task_performance/")
  
  file <- dir(path = source,pattern="raw_data.Rda")
  load(paste0(source,file))
  
  file <- dir(path = source,pattern="performance_data.Rda")
  load(paste0(source,file))
  
  DT_trials <- raw_data[, .N, by = subjID]
  subjs <- DT_trials$subjID

  
  fit <- stanfit
  ###############################
  ## TRIAL-BY-TRIAL PARAMETERS ##
  ###############################
  
  v_hat <- rep("NA",input_data$T)
  for (i in 1:input_data$T){
    index <- paste0("v_hat[",i,"]")
    v_hat[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  v_hat <- as.double(v_hat)
  
  # association strength of active (i.e. correct) stimulus pair
  as_active <- rep("NA",input_data$T)
  for (i in 1:input_data$T){
    index <- paste0("as_active[",i,"]")
    as_active[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  as_active <- as.double(as_active)
  
  # association strength of inactive (i.e. incorrect) stimulus pair
  as_inactive <- rep("NA",input_data$T)
  for (i in 1:input_data$T){
    index <- paste0("as_inactive[",i,"]")
    as_inactive[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  as_inactive <- as.double(as_inactive)
  
  as_chosen <- rep("NA",input_data$T)
  for (i in 1:input_data$T){
    index <- paste0("as_chosen[",i,"]")
    as_chosen[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  as_chosen <- as.double(as_chosen)
  
  # prediction errors
  pe_tot_hat <- rep("NA",input_data$T)
  for (i in 1:input_data$T){
    index <- paste0("pe_tot_hat[",i,"]")
    pe_tot_hat[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  pe_tot_hat <- as.double(pe_tot_hat)
  
  # prediction errors
  pe_pos_hat <- rep("NA",input_data$T)
  for (i in 1:input_data$T){
    index <- paste0("pe_pos_hat[",i,"]")
    pe_pos_hat[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  pe_pos_hat <- as.double(pe_pos_hat)
  
  # prediction errors
  pe_neg_hat <- rep("NA",input_data$T)
  for (i in 1:input_data$T){
    index <- paste0("pe_neg_hat[",i,"]")
    pe_neg_hat[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  pe_neg_hat <- abs(as.double(pe_neg_hat))
  
  
  # mean-center params
  # add the trial-by-trial regressors to the original dataset
  tbtparameters <- cbind(raw_data[,1:9],raw_data[,18],raw_data[,14:16],
                   pe_pos=as.array(pe_pos_hat),pe_neg=as.array(pe_neg_hat), pe_tot=as.array(pe_tot_hat),
                   as_active=as.array(as_active),as_inactive=as.array(as_inactive), as_chosen =as.array(as_chosen),
                   drift=as.array(v_hat))
  

  # mean-center parameters
  if (meancenter == 1){
    for(i in 1:input_data$N){
      subj = as.character(subjs[i])
      tbtparameters_by_subj <- as.matrix(tbtparameters[which(tbtparameters$subjID==subj),14:20])
      tbtparameters_by_subj <- center_colmeans(tbtparameters_by_subj)
      tbtparameters[which(tbtparameters$subjID==subj),14:20] <- data.frame(tbtparameters_by_subj)
    }
  }
  
  # write trial-by-trial parameters as file for each subject individually
  for(i in 1:input_data$N){
    subj = as.character(subjs[i])
    write.table(tbtparameters[which(tbtparameters$subjID==subj),], paste0("outputs/",subj,"_rlddm_parameters",".csv"),
                quote=FALSE, sep=",", row.names=FALSE, col.names=TRUE)
  }
  
  dir.create("outputs",showWarnings = FALSE)
  write.table(tbtparameters, paste0("outputs/","Parameters_perTrial.csv"), sep=",", row.names=FALSE, col.names=TRUE,quote = FALSE) 
  
  cat("wrote trial-by-trial parameters\n")
  
  ########################
  ## SUBJECT PARAMETERS ##
  ########################
  
  eta_pos <- rep("NA",input_data$N)
  for (i in 1:input_data$N){
    index <- paste0("eta_pos[",i,"]")
    eta_pos[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  eta_pos <- as.double(eta_pos)
  
  eta_neg <- rep("NA",input_data$N)
  for (i in 1:input_data$N){
    index <- paste0("eta_neg[",i,"]")
    eta_neg[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  eta_neg <- as.double(eta_neg)
  
  a <- rep("NA",input_data$N)
  for (i in 1:input_data$N){
    index <- paste0("a[",i,"]")
    a[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  a <- as.double(a)
  
  v_mod <- rep("NA",input_data$N)
  for (i in 1:input_data$N){
    index <- paste0("v_mod[",i,"]")
    v_mod[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  v_mod <- as.double(v_mod)
  
  tau <- rep("NA",input_data$N)
  for (i in 1:input_data$N){
    index <- paste0("tau[",i,"]")
    tau[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  tau <- as.double(tau)

  subject_parameters <- cbind(v_mod=as.array(v_mod),a=as.array(a),tau=as.array(tau),eta_pos=as.array(eta_pos),eta_neg=as.array(eta_neg))
 
  if(meancenter == 1){
    sp_matrix <- as.matrix(subject_parameters)
    sp_matrix_centered <- center_colmeans(sp_matrix)
    subject_parameters <- data.frame(sp_matrix_centered)
  }
  subject_parameters <- cbind(subjID=unique(tbtparameters$subjID),subject_parameters)
  
  # write out subject parameters
  
  
  write.table(subject_parameters, paste0("outputs/","Parameters_perSubject.csv"), sep=",", row.names=FALSE, col.names=TRUE,quote = FALSE) 
  
  cat("wrote subject parameters\n")
  cat("returning parameters\n")
  out <- list("tria-by-trial_parameters" = tbtparameters, "subject_parameters" = subject_parameters)
  return(out)
  }