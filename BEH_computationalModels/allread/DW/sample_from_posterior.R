# Patrick Haller, January 2020

library(rstan, rstanarm, rstudioapi)

## define paths
dirinput <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))

saved_model_path <- paste0(dirinput,"/fitted_models/")
setwd(saved_model_path)
fit <- readRDS("fit_final.rds")

samples <- matrix(data=NA, nrow = 500, ncol = 5)
colnames(samples) <- c("a","eta_pos","eta_neg","tau","v_mod")

# matrices have dimensions 6000x4x17 -> 6000 iterations, 4 chains, 17 subjects
# Extract all samples from chains
posterior_mu_a <- rstan::extract(fit, pars=c("mu_a"),permuted=FALSE)
#posterior_mu_a_mod <- rstan::extract(fit, pars=c("mu_a_mod"),permuted=FALSE)
posterior_mu_eta_pos <- rstan::extract(fit, pars=c("mu_eta_pos"),permuted=FALSE)
posterior_mu_eta_neg <- rstan::extract(fit, pars=c("mu_eta_neg"),permuted=FALSE)
posterior_mu_tau <- rstan::extract(fit, pars=c("mu_tau"),permuted=FALSE)
posterior_mu_v_mod <- rstan::extract(fit, pars=c("mu_v_mod"),permuted=FALSE)

# Sample 500 parameter sets
set.seed(66)

for (i in 1:500){
  iteration <- sample(1:6000, 1)
  chain <- sample(1:4, 1)
  samples[i,1] <- posterior_mu_a[iteration,chain,1]
  samples[i,2] <- posterior_mu_eta_pos[iteration,chain,1]
  samples[i,3] <- posterior_mu_eta_neg[iteration,chain,1]
  samples[i,4] <- posterior_mu_tau[iteration,chain,1]
  samples[i,5] <- posterior_mu_v_mod[iteration,chain,1]
}

# write out sampled parameters as csv files to use for generating data for parameter recovery
write.table(samples, file="data/extracted_posterior_samples/posterior_samples_final_fit.csv", quote=FALSE, sep = ",", col.names = TRUE)