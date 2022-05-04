# Patrick Haller, January 2020
# model adjusted for Gorka

LEMO_func_wiener_generator <- function(samples,
                             n_psets, n_subj, n_trials, n_blocks, n_pairs){

  samples <- samples[rep(1:nrow(samples), times = n_subj), ]

  ev <- array(data=0.5, dim=c(dim(samples)[1], # number of synthetic subjects
                            n_trials,
                            n_blocks, 
                            24))
  v <- array(data=0, dim=c(dim(samples)[1], # number of synthetic subjects
                           n_trials,
                           n_blocks))
  
  synthetic_data = data.frame(subjID=character(), 
                                block=integer(), 
                                trial=integer(),
                                RT=double(),
                                fb=integer(),
                                p_assoc=integer(), 
                                p_nassoc=integer(), 
                                drift=double())
    
  # for each p_set - subj_combination
  for (i in 1:dim(samples)[1]){
    # get params
    a <- samples[i,1]
    eta_pos <- samples[i,2]
    eta_neg <- samples[i,3]
    tau <- samples[i,4]
    v_mod <- samples[i,5]
    z <- samples[i,6]
    # select random stimulus sequence
    ssubj <- sample(unique(stimuli$subjID),1)
    vstims <- stimuli %>% filter(subjID==ssubj) %>% 
      dplyr::select(vStimAssoc, vStimNassoc)
    vstim_assoc <- vstims$vStimAssoc
    vstim_assoc <- Matrix(vstim_assoc, nrow = n_trials, ncol=3)
    vstim_nassoc <- vstims$vStimNassoc
    vstim_nassoc <- Matrix(vstim_nassoc, nrow = n_trials, ncol=3)
    for(b in 1:n_blocks){
      for(t in 1:(n_trials-1)){
        for(p in 1:n_pairs){
          ev[i,t+1,b,p] = ev[i,t,b,p]
        }
        v[i,t,b] <- ((ev[i,t,b,vstim_assoc[t,b]]+ev[i,t,b,vstim_nassoc[t,b]])/2) * v_mod
        choiceRT <- rwiener(1, a, tau, z, v[i,t,b])
        # only allow RT between 0.2 and 2s (according to exclusion criteria)
        #if(choiceRT$q > 2){
        #  choiceRT$q = 2
        #}
        #else if (choiceRT$q < 0.2){
        #  choiceRT$q = 0.2
        #}
        # trial information to write in synthetic data set
        ###
        if(choiceRT$resp == 'lower'){
          response <- 'error'
          ev[i,t+1,b,vstim_assoc[t,b]] = ((ev[i,t,b,vstim_assoc[t,b]]) + eta_neg*(abs(0-ev[i,t,b,vstim_assoc[t,b]])))
          ev[i,t+1,b,vstim_nassoc[t,b]] = ((ev[i,t,b,vstim_nassoc[t,b]]) + eta_neg*(abs(0-(1-ev[i,t,b,vstim_nassoc[t,b]]))))
        }
        else{
          response <- 'hit'
          ev[i,t+1,b,vstim_assoc[t,b]] = ((ev[i,t,b,vstim_assoc[t,b]]) + eta_pos*(abs(1-ev[i,t,b,vstim_assoc[t,b]])))
          ev[i,t+1,b,vstim_nassoc[t,b]] = ((ev[i,t,b,vstim_nassoc[t,b]]) + eta_neg*(abs(1-(1-ev[i,t,b,vstim_nassoc[t,b]]))))
        }
        synthetic_data <- rbind(synthetic_data,
                                list(subjID=paste0('syntheticsubject_',i),
                                     block=b,
                                     trial=t,
                                     RT=choiceRT$q,
                                     fb=choiceRT$resp,
                                     response=response,
                                     p_assoc=vstim_assoc[t,b],
                                     p_nassoc=vstim_nassoc[t,b],
                                     drift=v[i,t,b]))
      
        }
      # for last trial
      v[i,n_trials,b] <- ((ev[i,n_trials-1,b,vstim_assoc[(n_trials-1),b]]+ev[i,n_trials-1,b,vstim_nassoc[(n_trials-1),b]])/2) * v_mod
      choiceRT <- rwiener(1, a, tau, z, v[i,n_trials,b])
      #if(choiceRT$q > 2){
      #  choiceRT$q = 2
      #}
      #else if (choiceRT$q < 0.2){
      #  choiceRT$q = 0.2
      #}
      if(choiceRT$resp == 'lower'){
        response <- 'error'
      }
      else{
        response <- 'hit'
      }
      synthetic_data <- rbind(synthetic_data,
                              list(subjID=paste0('syntheticsubject_',i),
                                   block=b,
                                   trial=n_trials,
                                   RT=choiceRT$q,
                                   fb=choiceRT$resp,
                                   response=response,
                                   p_assoc=vstim_assoc[n_trials,b],
                                   p_nassoc=vstim_nassoc[n_trials,b],
                                   drift=v[i,n_trials,b]))
    }
  }
  synthetic_data$fb <-  ifelse(synthetic_data$fb=="upper",2,1)
  return(data.frame(synthetic_data))
}