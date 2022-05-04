rm(list=ls(all=TRUE)) # remove all variables (!)
group1dir <- choose.dir('O:/studies/allread/mri/analyses_NF/rlddm_analyses_NF/RLDDModel_gfg_versions/output_verygoodperf_20/Preproc_20ss/output_testv31noiter')
output1<- readRDS(paste(group1dir,"/fit_rlddm.rds",sep=""))

group2dir <- choose.dir('O:/studies/allread/mri/analysis_GFG/stats/task/modelling/model_choiceRT')
output2<- readRDS(paste(group2dir,"/ddm_fit.rds",sep=""))

diff_alpha <- group1$parVals$mu_alpha - group2$parVals$mu_alpha
diff_delta<- group1$parVals$mu_delta - group2$parVals$mu_delta
diff_beta <- group1$parVals$mu_beta - group2$parVals$mu_beta
diff_tau <- group1$parVals$mu_tau - group2$parVals$mu_tau

printFit(output1, output2, ic = "both")


HDIofMCMC(diff_alpha)
plotHDI(diff_alpha)