# Patrick Haller, January 2020

run_rlddm <- function(model, data, pars, chains, iter, warmup){
  
 stanmodel <- rstan::stan_model('N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan/rlddm1.stan')
  cat("fitting model ", basename(model))
  stanfit <- rstan::sampling(object  = stanmodel,
                          data    = data,
                          pars    = pars,
                          chains  = chains,
                          iter    = iter,
                          warmup  = warmup,
                          thin    = 1,
                         init_r =  1,
                         save_warmup = FALSE,
                          control = list(adapt_delta   = 0.99,
                                         stepsize      = 0.01,
                                         max_treedepth = 12),
                          verbose =FALSE)
  return(stanfit)
}