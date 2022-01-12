#run_rlddm <- function(model, data, pars, chains, iter, warmup){
run_rlddm <- function(model, data, chains, iter, warmup){
  
  if (FALSE) {
    switch(model@model_name,
           rlddm1={
             init_list <- function() { list(mu_pr=c(1, -0.5,  0.5, -1),sigma=c(1,0.5,1,0.5)) } 
           },
           rlddm4={
             init_list <- "random" #function() { list(mu_pr=c(0.86, -0.68, -0.96, -0.1),sigma=c(0.5, 0.6, 1.2, 0.8)) }
           },
           rlddm2={
             init_list <- function() { list(mu_pr=c(1,0.5,0.5,0.5),sigma=c(0.1,0.1,0.1,0.1)) }
           },
           rlddm5={
             init_list <- function() { list(mu_pr=c(1,0.5,0.5,0.5),sigma=c(0.1,0.1,0.1,0.1)) }
           },
           rlddm3={
             init_list <- function() { list(mu_pr=c(1,0.5,0.5),sigma=c(0.1,0.1,0.1)) }
           },
           rlddm6={
             init_list <-function() { list(mu_pr=c(1,0.5,0.5),sigma=c(0.1,0.1,0.1)) }
           },
           {
             print('Error: Model not known.')
             return(-1)
           }
    )
    
    
    stanfit <- rstan::sampling(object  = model,
                               data    = data,
                               chains  = chains,
                               iter    = iter,
                               warmup  = warmup,
                               thin    = 1,
                               init_r  = 1,
                               init = init_list,
                               # init = 0.5,
                               pars    = "",
                               save_warmup = FALSE,
                               sample_file = paste0(stanmodel@model_name,'_samples.csv'),
                               #  control = list(adapt_delta   = 0.99,#0.999/0.995
                               # stepsize      = 0.05,#0.05
                               #control = list(max_treedepth = 12),
                               verbose =FALSE)
  }
  
  switch(tools::file_path_sans_ext(basename(mod$stan_file())),
         rlddm1={
           init_list <- function() { list(mu_pr=c(1, -0.5,  0.5, -1),sigma=c(1,0.5,1,0.5)) } 
         },
         rlddm4={
           init_list <-  NULL #function() { list(mu_pr=c(0.86, -0.68, -0.96, -0.1),sigma=c(0.5, 0.6, 1.2, 0.8)) }function() { list(mu_pr=c(0.86, -0.68, -0.96, -0.1),sigma=c(0.5, 0.6, 1.2, 0.8)) }
         },
         rlddm2={
           init_list <- function() { list(mu_pr=c(1,0.5,0.5,0.5),sigma=c(0.1,0.1,0.1,0.1)) }
         },
         rlddm5={
           init_list <- function() { list(mu_pr=c(1,0.5,0.5,0.5),sigma=c(0.1,0.1,0.1,0.1)) }
         },
         rlddm3={
           init_list <- function() { list(mu_pr=c(1,0.5,0.5),sigma=c(0.1,0.1,0.1)) }
         },
         rlddm6={
           init_list <-function() { list(mu_pr=c(1,0.5,0.5),sigma=c(0.1,0.1,0.1)) }
         },
         {
           print('Error: Model not known.')
           return(-1)
         }
  )
  
  stanfit <- model$sample   (data    = data,
                             chains  = chains,
                             parallel_chains  = chains,
                             iter_sampling = iter,
                             iter_warmup  = warmup,
                             thin    = 1,
                             init = init_list,
                             save_warmup = FALSE,
                             output_dir = 'D:/ARmodel_ph/tmp/',
                             refresh = 10,
                             show_messages = TRUE)
  return(stanfit)
}