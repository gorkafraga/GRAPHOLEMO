

# MODEL COMPARISON 
#----------------------------------------------------
# - Saves tables with different fit estimates and ranks models
# - Saves plot with pareto shape k estimates (PSISdiagnostic)
# - Reads *_logLik.rds files containing loglik extracted from the fit 
# - If  "readfit <- 1 " it will NOT compare models but it will read fit files (e.g., modelxxx.rds) and extract first loglik and saving them as .rds(e.g., modelxxx_loglik.rds)
# - Reading large fit objects may lead to crash. You can do readfit <- 1 choosing only 2 or 3 models at a time. 

rm(list=ls(all=TRUE)) 
Packages <- c('rstanarm','rstudioapi',"grid","gridExtra","ggplot2","ggplotify")
lapply(Packages, require, character.only = TRUE)
# Edit inputs
dirinput <- "C:/Users/gfraga/chains_fbl_b"
diroutput <- dirinput
readfit <- 0 
listModels <- c("LEMO_rlddm_v31","LEMO_rlddm_v32")
setwd(diroutput)

# Memory options
options(mc.cores = parallel::detectCores())
memory.limit(1024*1024*1024*1024)
memory.size(max = TRUE) 

# Initialize output lists
logLik <- list()
rEff <- list()
waic <- list()
loo <- list ()
 
if (readfit==1) {
  for (i in 1:length(listModels)){
    fit <- readRDS(paste0(dirinput,'/',listModels[i],'/',listModels[i],'_fit.rds'))
    loglik1 <- loo::extract_log_lik(fit, merge_chains = FALSE)
    saveRDS(loglik1,paste0(dirinput,'/',listModels[i],'/',listModels[i],'_logLik.rds'))
  }

} else if (readfit == 0) {
  # EXtract  COMPARE MODELS WITH LOG LIK AVERAGED OVER SUBJ 
  #==========================================================
  for (i in 1:length(listModels)){
    logLik[[i]]<- readRDS(paste0(dirinput,'/',listModels[i],'/',listModels[i],'_logLik.rds'))
    rEff[[i]] <-loo::relative_eff(exp(logLik[[i]]))
    waic[[i]] <- waic(logLik[[i]])
    loo[[i]] <- loo(logLik[[i]], r_eff=rEff[[i]] , cores=2, save_psis = TRUE) 
  }
  print("done computing rEFF, WAIC and LOO")
  
  
  #Table with estimates
  summaryTable<- list()
  for (i in 1:length(listModels)){
    summaryTable[[i]] <- as.data.frame(t(c(listModels[i],round(waic[[i]]$estimate[,1],3),round( loo[[i]]$estimates[,1],3)))) # take the estimate means of each model
  }
  summaryTable <- data.table::rbindlist(summaryTable)  # gather in a table with a reference to model names (1st column)
  colnames(summaryTable)[1] <- "model"
  #add ranks to the table (rank the models based on each estimate )
  ranks <- apply(summaryTable, 2, rank, ties.method='min')
  colnames(ranks)<- paste0("rank_",colnames(ranks))
  tableWithRanks<- cbind(summaryTable,ranks)
  writexl::write_xlsx(tableWithRanks,paste0(diroutput,'/Model_fit_estimates.xlsx'))
  print("done gathering estimates")
  
  if (length(listModels)==6){
    # Comparisons (only if six models. Modify accordingly )
    compareTable_loo <- as.data.frame(rstanarm::loo_compare(loo[[1]], loo[[2]], loo[[3]], loo[[4]], loo[[5]], loo[[6]]))
    models_sorted<- listModels[order=as.numeric(gsub("model","",rownames(compareTable_loo)))] # rename rows according to your list of models 
    compareTable_loo <- cbind(models_sorted,compareTable_loo)
    writexl::write_xlsx(compareTable_loo,paste0(diroutput,'/Model_compare_loo.xlsx'))
    print("done loo comparisons")
    
    compareTable_waic <- as.data.frame(rstanarm::loo_compare(waic[[1]], waic[[2]], waic[[3]], waic[[4]], waic[[5]], waic[[6]]))
    models_sorted<- listModels[order=as.numeric(gsub("model","",rownames(compareTable_waic)))] # rename rows according to your list of models 
    compareTable_waic <- cbind(models_sorted,compareTable_waic)
    writexl::write_xlsx(compareTable_waic,paste0(diroutput,'/Model_compare_waic.xlsx'))
    print("done waic comparisons")
  }
  
  if (length(listModels)==4){
    # Comparisons 
    compareTable_loo <- as.data.frame(rstanarm::loo_compare(loo[[1]], loo[[2]], loo[[3]], loo[[4]]))
    models_sorted<- listModels[order=as.numeric(gsub("model","",rownames(compareTable_loo)))] # rename rows according to your list of models 
    compareTable_loo <- cbind(models_sorted,compareTable_loo)
    writexl::write_xlsx(compareTable_loo,paste0(diroutput,'/Model_compare_loo.xlsx'))
    print("done loo comparisons")
    
    compareTable_waic <- as.data.frame(rstanarm::loo_compare(waic[[1]], waic[[2]], waic[[3]], waic[[4]]))
    models_sorted<- listModels[order=as.numeric(gsub("model","",rownames(compareTable_waic)))] # rename rows according to your list of models 
    compareTable_waic <- cbind(models_sorted,compareTable_waic)
    writexl::write_xlsx(compareTable_waic,paste0(diroutput,'/Model_compare_waic.xlsx'))
    print("done waic comparisons")
  }
  
  
  if (length(listModels)==2){
    # Comparisons (only if six models. Modify accordingly )
    compareTable_loo <- as.data.frame(rstanarm::loo_compare(loo[[1]], loo[[2]]))
    models_sorted<- listModels[order=as.numeric(gsub("model","",rownames(compareTable_loo)))] # rename rows according to your list of models 
    compareTable_loo <- cbind(models_sorted,compareTable_loo)
    writexl::write_xlsx(compareTable_loo,paste0(diroutput,'/Model_compare_loo.xlsx'))
    print("done loo comparisons")
    
    compareTable_waic <- as.data.frame(rstanarm::loo_compare(waic[[1]], waic[[2]]))
    models_sorted<- listModels[order=as.numeric(gsub("model","",rownames(compareTable_waic)))] # rename rows according to your list of models 
    compareTable_waic <- cbind(models_sorted,compareTable_waic)
    writexl::write_xlsx(compareTable_waic,paste0(diroutput,'/Model_compare_waic.xlsx'))
    print("done waic comparisons")
  }
  
  # PLOTS with PSIS k diagnostic
  plots <- list()
  for (i in 1:length(listModels)){
    plots[[i]] <-   local ({
      myplot <- as.grob(function() plot(loo[[i]],main = paste0( "PSIS diagnostic - ",listModels[i])))
      print (myplot) 
    })
  }
  allplots <- do.call(grid.arrange,plots,)
  # Save 
  ggplot2::ggsave("PSIS_kplots.jpg",allplots,width = 350, height = 310, dpi=150, units = "mm")
  

}

