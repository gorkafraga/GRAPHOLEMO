# Patrick Haller, January 2020

wiener_generator <- function(raw_data, posterior_samples,
                             n_psets, n_subj, n_trials, n_blocks, n_pairs){
  
  raw_data$vStimNassoc <- ifelse(raw_data$aStim==raw_data$vStim1,raw_data$vStim2,raw_data$vStim1)
  #get the presented stimuli for all trials from a participant (same for all participants, only assignment between sounds and symbols were randomised)
  vstim_assoc <- raw_data[which(raw_data$subjID=="biokurs19-05"),]$aStim
  vstim_assoc <- rep(vstim_assoc, n_subj*n_psets)
  vstim_nassoc <- raw_data[which(raw_data$subjID=="biokurs19-05"),]$vStimNassoc
  vstim_nassoc <- rep(vstim_nassoc, n_subj*n_psets)
  
  seeds = c(22,33,44,55,66)
  
  subjID <- vector()
  RT <- vector(mode = "double")
  fb <- vector()
  p_assoc <- vector()
  p_nassoc <- vector()
  block <- vector()
  trial <- vector()
  response <- vector()
  # fix starting point at 0.5
  posterior_samples$z <- 0.5
  
  ev <- matrix(data=0, nrow=n_blocks*n_trials*n_subj*n_psets,ncol=24)
  v <- list()
  v <- rep(0,n_trials*n_blocks*n_subj*n_psets)
  
  for (i in 1:n_psets){
    # for each of this set, create 5 synthetic subjects
    for (s in 1:n_subj){
      is = ((i-1)*n_trials*n_blocks*n_subj) + ((s-1)*n_trials*n_blocks)
      set.seed(seeds[s])
      # is indicates the index shift to store the generated values in the according row number
      a <- posterior_samples$a[i]
      eta_pos <- posterior_samples$eta_pos[i]
      eta_neg <- posterior_samples$eta_neg[i]
      tau <- posterior_samples$tau[i]
      v_mod <- posterior_samples$v_mod[i]
      z <- posterior_samples$z[i]
      for(b in 0:(n_blocks-1)){
        # now, create 3x40 trials
        # first, update index shift for each block
        is = ((i-1)*n_trials*n_blocks*n_subj) + ((s-1)*n_trials*n_blocks) + (b*40)
        for(p in 1:n_pairs){
          # initialize lower(=1) and upper(=2) bound values for all pairs
          ev[1+is,p] <- 0.5
        }
        for(t in 1:(n_trials-1)){
          for(p in 1:n_pairs){
            ev[t+1+is,p] = ev[t+is,p]
          }
          v[t+is] <- ((ev[t+is,vstim_assoc[t+is]]+ev[t+is,vstim_nassoc[t+is]])/2) * v_mod
          choiceRT <- rwiener(1, a, tau, z, v[t+is])
          while(choiceRT$q >2 | choiceRT$q < 0.5){
            choiceRT <- rwiener(1, a, tau, z, v[t+is])
          }
          block[t+is] <- b+1
          trial[t+is] <- t
          RT[t+is] <-  choiceRT$q
          fb[t+is] <-  choiceRT$resp
          p_assoc[t+is] <- vstim_assoc[t+is]
          p_nassoc[t+is] <- vstim_nassoc[t+is]
          if(choiceRT$resp == 'lower'){
            response[t+is] <- 'error'
            ev[t+1+is,vstim_nassoc[t+is]] = ev[t+is,vstim_nassoc[t+is]] + eta_neg*(abs(0-(1-ev[t+is,vstim_nassoc[t+is]])))
            ev[t+1+is,vstim_assoc[t+is]] = ev[t+is,vstim_assoc[t+is]] + eta_neg*(abs(0-ev[t+is,vstim_assoc[t+is]]))
          }
          else{
            response[t+is] <- 'hit'
            ev[t+1+is,vstim_assoc[t+is]] = ev[t+is,vstim_assoc[t+is]] + eta_pos*(abs(1-ev[t+is,vstim_assoc[t+is]]))
            ev[t+1+is,vstim_nassoc[t+is]] = ev[t+is,vstim_nassoc[t+is]] + eta_pos*(abs(1-(1-ev[t+is,vstim_nassoc[t+is]])))
          }
        }
        v[n_trials+is] <- ((ev[(n_trials-1+is),vstim_assoc[(n_trials-1+is)]]+ev[vstim_nassoc[(n_trials-1+is)],2])/2) * v_mod
        choiceRT <- rwiener(1, a, tau, z, v[n_trials+is])
        while(choiceRT$q >2 | choiceRT$q < 0.5){
          choiceRT <- rwiener(1, a, tau, z, v[t+is])
        }
        if(choiceRT$resp == 'lower'){
          response[n_trials+is] <- 'error'
        }
        else{
          response[n_trials+is] <- 'hit'
        }
        RT[n_trials+is] <-  choiceRT$q
        fb[n_trials+is] <-  choiceRT$resp
        p_assoc[n_trials+is] <- vstim_assoc[n_trials+is]
        p_nassoc[n_trials+is] <- vstim_nassoc[n_trials+is]
        block[n_trials+is] <- b+1
        trial[n_trials+is] <- n_trials
      }
    }
  }
  # In Rwiener 1 is upper response -> switch them such that it matches the RLDDM implementation
  fbswitched <- ifelse(fb==1,2,1)
  
  subjs <- rep(1:(n_subj*n_psets),each=n_blocks*n_trials)
  subjs <- paste0('syntheticsubject_',subjs)
  generated_data <- data.frame(subjID=subjs, block=block, trial=trial, RT=as.double(RT), fb=fbswitched, response = response, p_assoc, p_nassoc, drift=v)
  cat("returning generated data\n")
  return(generated_data)
}