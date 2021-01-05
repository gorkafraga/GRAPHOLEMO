# Patrick Haller, January 2020
# Model comparison between 6 RLDDM variants. 

#library(rethinking, rstanarm, rstudioapi)
library(rstanarm, rstudioapi)

saved_model_path <- "O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM_fromLocal/GoodPerf_72/outputs"
setwd(saved_model_path)

######################################################
### COMPARE MODELS WITH LOG LIK AVERAGED OVER SUBJ ###
######################################################

rlddm11 <- readRDS("O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM_fromLocal/GoodPerf_72/outputs/out_AR_rlddm_v11/AR_rlddm_v11")
rlddm12 <- readRDS("O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM_fromLocal/GoodPerf_72/outputs/out_AR_rlddm_v12/AR_rlddm_v12")
rlddm31 <- readRDS("O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM_fromLocal/GoodPerf_72/outputs/out_AR_rlddm_v31/AR_rlddm_v31")
rlddm32 <- readRDS("O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM_fromLocal/GoodPerf_72/outputs/out_AR_rlddm_v32/AR_rlddm_v32")
#rlddm4 <- readRDS("fit_rlddm4.rds")
#rlddm5 <- readRDS("fit_rlddm5.rds")
#rlddm6 <- readRDS("fit_rlddm6.rds")

loglik1 <- loo::extract_log_lik(rlddm11, merge_chains = FALSE)
r_eff1 <- loo::relative_eff(exp(loglik1))
loo1 <- loo(loglik1, r_eff=r_eff1, cores=2, save_psis = TRUE)
waic1 <- waic(loglik1)

loglik2 <- loo::extract_log_lik(rlddm12, merge_chains = FALSE)
r_eff2 <- loo::relative_eff(exp(loglik2))
loo2 <- loo(loglik2, r_eff=r_eff2, cores=2, save_psis = TRUE)
waic2 <- waic(loglik2)

loglik3 <- loo::extract_log_lik(rlddm31, merge_chains = FALSE)
r_eff3 <- loo::relative_eff(exp(loglik3))
loo3 <- loo(loglik3, r_eff=r_eff3, cores=2, save_psis = TRUE)
waic3 <- waic(loglik3)

loglik4 <- loo::extract_log_lik(rlddm32, merge_chains = FALSE)
r_eff4 <- loo::relative_eff(exp(loglik4))
loo4 <- loo(loglik4, r_eff=r_eff4, cores=2, save_psis = TRUE)
waic4 <- waic(loglik4)
 
print(rstanarm::loo_compare(loo1, loo2, loo3, loo4), digits=4)
print(rstanarm::loo_compare(waic1, waic2, waic3, waic4), digits=4)
#print(rethinking::compare(rlddm1,rlddm2,rlddm3,rlddm4),digits=4)
#-----------------------------------------------------------------------------GFG

#diff_alpha <- model11$parVals$mu_alpha - group2$parVals$mu_alpha
#diff_delta<- group1$parVals$mu_delta - group2$parVals$mu_delta
#diff_beta <- group1$parVals$mu_beta - group2$parVals$mu_beta
#diff_tau <- group1$parVals$mu_tau - group2$parVals$mu_tau

#printFit(output1, output2, ic = "both")


HDIofMCMC(diff_alpha)
plotHDI(diff_alpha)