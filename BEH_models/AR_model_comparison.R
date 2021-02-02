# Based on Patrick Haller, January 2020
# Model comparison between 6 RLDDM variants. 
#library(rethinking, rstanarm, rstudioapi)
rm(list=ls(all=TRUE)) 
Packages <- c('rstanarm','rstudioapi',"grid","gridExtra")
lapply(Packages, require, character.only = TRUE)
dirinput <- "G:/RLDDM_fromNF/42kids"
diroutput <- "G:/RLDDM_fromNF/42kids"

readfit <- 0 
setwd(diroutput)
#options(mc.cores = parallel::detectCores())
memory.limit(9999999999)
memory.size(max = TRUE) 


logLik <- list()
rEff <- list()
waic <- list()
loo <- list ()
if (readfit == 0) {
  # EXtract  COMPARE MODELS WITH LOG LIK AVERAGED OVER SUBJ 
  #==========================================================
  listModels <- c("AR_rlddm_v11","AR_rlddm_v12","AR_rlddm_v21","AR_rlddm_v22","AR_rlddm_v31","AR_rlddm_v32")
  for (i in 1:length(listModels)){
    logLik[[i]]<- readRDS(paste0(dirinput,'/',listModels[i],'_logLik.rds'))
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
  
  # Plots with PSIS k diagnostic
  plots <- list()
  plots[[j]] <-  local ({
      for (i in 1:length(listModels)){
        plots[[i]] <- plot(loo[[i]],main = paste0( "PSIS diagnostic - ",listModels[i]))
        print( print(plots[[i]] ))
      }
   })
  allplots <- do.call(grid.arrange,plots)
  
  
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
}
 