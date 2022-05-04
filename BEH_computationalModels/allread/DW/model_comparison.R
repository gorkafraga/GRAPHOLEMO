# Patrick Haller, January 2020
# Model comparison between 6 RLDDM variants. 

# library(rethinking, rstanarm, rstudioapi)
library(rstanarm, rstudioapi)


# dirinput <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
saved_model_path <- paste0(datainput)
setwd(saved_model_path)

######################################################
### COMPARE MODELS WITH LOG LIK AVERAGED OVER SUBJ ###
######################################################

rlddm1 <- readRDS("rlddm1")
rlddm2 <- readRDS("rlddm2")
rlddm3 <- readRDS("rlddm3")
rlddm4 <- readRDS("rlddm4")
rlddm5 <- readRDS("rlddm5")
rlddm6 <- readRDS("rlddm6")

rlddm1_72 <- readRDS("O:/studies/allread/mri/analyses_NF/rlddm_analyses_NF/RLDDModel_ph_versions/data/normPerf_72/raw_task_performance/rlddm1")

loglik1 <- loo::extract_log_lik(rlddm1, merge_chains = FALSE)
r_eff1 <- loo::relative_eff(exp(loglik1))
loo1 <- loo(loglik1, r_eff=r_eff1, cores=2, save_psis = TRUE)
waic1 <- waic(loglik1)

loglik1 <- loo::extract_log_lik(rlddm1_72, merge_chains = FALSE)
r_eff1 <- loo::relative_eff(exp(loglik1))
loo1 <- loo(loglik1, r_eff=r_eff1, cores=2, save_psis = TRUE)
waic1 <- waic(loglik1)

loglik2 <- loo::extract_log_lik(rlddm2, merge_chains = FALSE)
r_eff2 <- loo::relative_eff(exp(loglik2))
loo2 <- loo(loglik2, r_eff=r_eff2, cores=2, save_psis = TRUE)
waic2 <- waic(loglik2)

loglik3 <- loo::extract_log_lik(rlddm3, merge_chains = FALSE)
r_eff3 <- loo::relative_eff(exp(loglik3))
loo3 <- loo(loglik3, r_eff=r_eff3, cores=2, save_psis = TRUE)
waic3 <- waic(loglik3)

loglik4 <- loo::extract_log_lik(rlddm4, merge_chains = FALSE)
r_eff4 <- loo::relative_eff(exp(loglik4))
loo4 <- loo(loglik4, r_eff=r_eff4, cores=1, save_psis = TRUE)
waic4 <- waic(loglik4)

loglik5 <- loo::extract_log_lik(rlddm5, merge_chains = FALSE)
r_eff5 <- loo::relative_eff(exp(loglik5))
loo5 <- loo(loglik5, r_eff=r_eff5, cores=2, save_psis = TRUE)
waic5 <- waic(loglik5)

loglik6 <- loo::extract_log_lik(rlddm6, merge_chains = FALSE)
r_eff6 <- loo::relative_eff(exp(loglik6))
loo6 <- loo(loglik6, r_eff=r_eff6, cores=2, save_psis = TRUE)
waic6 <- waic(loglik6)



print(rstanarm::loo_compare(loo1, loo2, loo3, loo4, loo6), digits=4)
print(rstanarm::loo_compare(waic1, waic2, waic3, waic4, waic6), digits=4)
print(rstanarm::loo_compare(loo1, loo2, loo3, loo4, loo5, loo6), digits=4)
print(rstanarm::loo_compare(waic1, waic2, waic3, waic4, waic5, waic6), digits=4)
# print(rethinking::compare(rlddm1,rlddm2,rlddm3,rlddm4,rlddm5,rlddm6),digits=4)