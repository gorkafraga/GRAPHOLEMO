rm(list=ls(all=TRUE))#clear all
Packages <- c("haven","dplyr","tidyr","plotly")
lapply(Packages, library, character.only = TRUE)
source('N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Study_specific/LEXI_GFG_2019/BEHAVE and regressions/func_gather_corrs.R')


#inputs
fileinput <- "LEMO_beh_fbl.sav" 
dirinput <- "O:/studies/grapholemo/analysis/LEMO_GFG/" 
diroutput <-  "O:/studies/grapholemo/analysis/LEMO_GFG/beh/plots_cognitiveTests/regressions" 
subjectIdentifier <- 'Subj_ID'
typevarslist  <- c('predictor','predicted') # TYPE 'neuro' or 'behavioral' 
# Read data  
setwd(dirinput)
raw <-  haven::read_sav(fileinput)
raw <- raw[which(raw$Exclusion_MRI==1),]

for (tt in 1:length(typevarslist)){
      
      typevars <- typevarslist[tt]
      
      # select variables
      if (typevars == 'predictor') {
        vars2read <- c('FBLA_meanRT_mean','FBLA_propHitsPerThird_mean', 'FBLA_meanRT_bMean_t1', 'FBLA_meanRT_bMean_t2','FBLA_meanRT_bMean_t3','FBLA_propHitsPerThird_bMean_t1','FBLA_propHitsPerThird_bMean_t2','FBLA_propHitsPerThird_bMean_t3')
        
      } else if (typevars == 'predicted') {
        vars2read <- c(colnames(raw)[c(grep('ran_.*._time_raw',colnames(raw)))],colnames(raw)[c(grep('rst.*corr*',colnames(raw)))],colnames(raw)[c(grep('slrt*.*corr*.',colnames(raw)))],colnames(raw)[c(grep('lgvt*.',colnames(raw)))])
        
      }
      
      #Add any Initial filter 
      #dat <- raw[which(raw$ERP_ND_T1==1),]
      dat <- raw
      
      # Go thru the variables search for outliers
      outliers <- list()
      for (i in 1:length(vars2read)){
        
        var <- vars2read[i]
        values <- as.matrix(select(dat,all_of(var)))
        
        # Get the values of the data that are outliers
        outlier_values <- boxplot.stats(values,coef=1.5)$out 
        # Get the subject ids and put them together separated by comma as a string 
        outlier_subjects <- paste0(dat$subj_ID[which(values %in% outlier_values)],collapse=",")
        outliers[[i]] <- as.data.frame(outlier_subjects)
        colnames(  outliers[[i]] ) <- var
        
      }
      
      # put together in a dataset
      df <- sapply(outliers,as.data.frame,simplify = TRUE,)
      df <- as.data.frame(cbind(names(df),df),row.names = FALSE)
      colnames(df) <- c('variable','outliers')
      # save as xls
      openxlsx::write.xlsx(df,file=paste0(diroutput,'/Outliers_boxplotStats_',typevars,'.xlsx'))
      
      #-------------------------------
      # plotly! 
      dat2plot <- select(dat,all_of(c(subjectIdentifier,vars2read)))
      dat2plot_long <- pivot_longer(dat2plot,vars2read,)
      fig <- plotly::plot_ly(dat2plot_long,x =~name,y =~value,type='box',color=~name,boxpoints="suspectedOutliers")
      htmlwidgets::saveWidget(fig, paste0(diroutput,"/Outliers_boxplotStats_",typevars,".html"), selfcontained = F, libdir = "lib")
      
      
}
      
      
      
      #-------------------------------
      # correlations after excluding outliers
      
      outlier_predictor <- openxlsx::read.xlsx(paste0(diroutput,'/Outliers_boxplotStats_predictor.xlsx'))
      outlier_beh <- openxlsx::read.xlsx(paste0(diroutput,'/Outliers_boxplotStats_predicted.xlsx'))
      
      #loop thru neural variables and run a correlation with all behavioral
      corrs <- list()
      counter <- 0
      
      for (n in 1:nrow(outlier_predictor)) {
          predictorvar <- outlier_predictor$variable[n]
         
         # exclude outliers  
         `%nin%` = Negate(`%in%`)
         # dat2use <- dat[which(dat$subj_ID %nin% unlist(strsplit(outlier_predictor$outliers[n],split=','))),]
             
         for (b in 1:nrow(outlier_beh)){
           counter <- counter + 1
           behavioralvar <- outlier_beh$variable[b]
           # excludeoutliers
           dat2use <- dat[which(dat$subj_ID %nin% unlist(strsplit(outlier_predictor$outliers[n],split=','))),]
           dat2use <- dat2use[which(dat2use$subj_ID %nin% unlist(strsplit(outlier_beh$outliers[b],split=','))),]
           #convert to number format if not formatted for some reason
             if (!is.numeric(dat2use[behavioralvar])){
                  dat2use[behavioralvar] <- as.matrix(dat2use[behavioralvar])
             }
             dat2use <- as.data.frame(dat2use)
             corrs[[counter]] <-  func_gather_corrs(predictorvar,behavioralvar,dat2use)
          
         }
      }
      # save
      regTable <- data.table::rbindlist(corrs)
      writexl::write_xlsx(as.data.frame(regTable),paste0(diroutput,'/Corrs_excludeOutliers.xlsx'))
      
      # plot correlations for exploration
      corrs2plot <- regTable[which(regTable$`p-value` < 0.1),]
       
      fig2 <- plotly::plot_ly(corrs2plot,x =~predictor,y =~pearson_r,color=~predicted,type='scatter',mode='markers')
      fig2 <- fig2 %>% layout (title= "Correlations with p < 0.1 after excluding outliers only from neural variables")
      
      htmlwidgets::saveWidget(fig2, paste0(diroutput,"/Correlation_summary_",typevars,".html"), selfcontained = F, libdir = "lib")
      
      