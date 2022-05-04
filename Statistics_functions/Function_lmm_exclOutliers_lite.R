Function_lmm_exclOutliers_lite <- function(formula_fixed,formula_random,Data,resThreshold) {
    
  Packages <- c("nlme","emmeans","tibble","plyr") #Load libraries 
  lapply(Packages, library, character.only = TRUE)#
  
  
  # RUN MODEL FIT and repeats model if there are outlier residuals... until no more outliers are found
  #---------------------------------------------------------------------------------------
  iter <- 0 
  Data <- as.data.frame(Data)
  modeldata <<- Data
  excludedRows <<- c()
  print('Starting....')
  
  repeat{
    iter <- iter + 1
    fit  <<- nlme::lme(fixed = formula_fixed,
                       random = formula_random,
                       data = modeldata, 
                       na.action = na.omit,
                       method="REML") 
    
    # Gather residuals, find row index of outliers
    allresiduals <- unlist(residuals(fit,type="normalized",asList = TRUE))
    lastOutliers <- as.numeric(sapply(strsplit(names(which(abs(allresiduals) > resThreshold)),".",fixed=TRUE),"[[",2))
    
    # If lastOutliers exclude those rows from dataset.
    if (length(lastOutliers)!=0){
      excludedRows <<- c(excludedRows,lastOutliers) 
      modeldata <<- Data[-excludedRows,] 
      print(iter) 
    }
    
    # When there are no more outliers break the repeat loop 
    if (length(lastOutliers)==0) {  
      print(paste0('Done at ',iter,' iteration'))
      break   
    } 
  }
  allresiduals <<-allresiduals
  # save the data rows that were excluded and summarize exclusion
  summaryOut <<- Data[excludedRows,] 
  excludedRows_id <<- as.character(paste0(rownames(plyr::match_df(Data, summaryOut)),collapse=','))
  excludedRows_n <<- length(excludedRows)
  excludedRows_percent <<- round((length(excludedRows)*100)/nrow(Data),2)
  excludedRows_table <<- as.data.frame(cbind(excludedRows_id,excludedRows_n,excludedRows_percent))
  niterations <<- iter
  print('Linear mixed model finished. Output variables: fit, excludedRows_*,allresiduals, summaryOut,modeldata,niterations')
}

