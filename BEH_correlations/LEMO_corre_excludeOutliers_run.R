rm(list=ls(all=TRUE))#clear all
Packages <- c("haven","plyr","dplyr","tidyr","plotly")
lapply(Packages, library, character.only = TRUE)
# function to compute correlations
source('N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_correlations/LEMO_func_gather_corrs.R')
#------------------------------------------------------------------------------------------------------------------------------------------
#  RUN CORRELATIONS
# - calls function
# - reads outliers from neural variables
#------------------------------------------------------------------------------------------------------------------------------------------
#inputs
fileinput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/beh/LEMO_cogni_fbl.sav'
dirinput <-   'O:/studies/grapholemo/analysis/LEMO_GFG/beh/'
diroutput <-  'O:/studies/grapholemo/analysis/LEMO_GFG/beh/stats_associations_taskcogni'
diroutput <-  'O:/studies/grapholemo/analysis/LEMO_GFG/beh/stats_associations_modelcogni'
subjectIdentifier <- 'Subj_ID'  

# Read data  
setwd(dirinput)
raw <-  haven::read_sav(fileinput)


# Filter 
dat <- raw[which(raw$Exclude_all == 0),]
colnames(dat)[which(colnames(dat)==subjectIdentifier)] <- 'subject'
xvars <- colnames(dat)[c(grep('FBL*.*_t1',colnames(dat)),grep('FBL*.*_t3',colnames(dat)))]
xvars <- colnames(dat)[grep('LEMO_rlddm_v32',colnames(dat))]
yvars <-  c('rias_nix_pr',
            'slrt2b_meanWP_corr_pr','slrt2b_word_corr_pr','slrt2b_pseudo_corr_pr',
            'lgvt_compre_pr','lgvt_speed_pr','lgvt_accu_pr',
            'lgvt_compre_tval','lgvt_speed_tval','lgvt_accu_tval',
            'rst_short1_wsum_corr_pr', 
            'wais4_tot_nitems_raw','wais4_tot_span_raw',
            'ran_color_time_raw','ran_object_time_raw'
            )



# OUTLIER DETECTION  ############################################################################################################################
# Go thru the variables search for outliers
selectedVariables <- c(xvars,yvars)
outliers <- list()
for (i in 1:length(selectedVariables)){
   var <- selectedVariables[i]
  # first exclude based on reasons other than outliers (e.g., invalid test, mic problems) 
  if (grepl('^ran',var)){
    curdat <- dat[which(dat$Exclude_ran!=1),]
  }else if (grepl('^rias',var)){
    curdat <- dat[which(dat$Exclude_rias!=1),]
    
  }else if (grepl('^lgvt',var)){
    curdat <- dat[which(dat$Exclude_lgvt!=1),]
    
  }else if (grepl('^slrt',var)){
    curdat <- dat[which(dat$Exclude_slrt2b!=1),]
    
  }else if (grepl('^wais',var)){
    curdat <- dat[which(dat$Exclude_wais!=1),]
    
  }else if (grepl('^rst',var)){
    curdat <- dat[which(dat$Exclude_rst!=1),]
  } else {
    curdat <- dat
  }
    
    
  
  values <- as.matrix(dplyr::select(curdat,all_of(var)))
  
  # Get the values of the data that are outliers
  outlier_values <- boxplot.stats(values,coef=1.5)$out 
  print(paste0('finding outliers in ', var,'with boxplot.stats using the coefficient 1.5 ....'))
  
  # Get the subject ids and put them together separated by comma as a string 
  outlier_subjects <- paste0(curdat$subject[which(values %in% outlier_values)],collapse=",")
  outliers[[i]] <- as.data.frame(outlier_subjects)
  colnames(  outliers[[i]] ) <- var
  
}


# put together in a dataset
df <- sapply(outliers,as.data.frame,simplify = TRUE,)
df <- as.data.frame(cbind(names(df),df),row.names = FALSE)
colnames(df) <- c('variable','outliers')

# save as xls
outputbasename <- paste0('Outliers_boxplotStats')
openxlsx::write.xlsx(df,file=paste0(diroutput,'/', outputbasename,'.xlsx'))

#--------plotly! 
#dat2plot <- select(curdat,all_of(c(subjectIdentifier,selectedVariables)))
#dat2plot_long <- pivot_longer(dat2plot,all_of(selectedVariables))
#fig <- plotly::plot_ly(dat2plot_long,x =~name,y =~value,type='box',color=~name,boxpoints="suspectedOutliers")
#htmlwidgets::saveWidget(fig,paste0(diroutput,'/', outputbasename,'.html'), selfcontained = F, libdir = "lib")

#############################################################################################################################


# CORRELATIONS
 
#loop thru variables and run a correlation with all behavioral
corrs <- list()
counter <- 0
varnames <- unlist(df$variable)
outliersIDs <- unlist(df$outliers)

for (xs in 1:length(xvars)) {
    currXvar <- varnames[which(varnames==xvars[xs])]
   
   # exclude outliers  
    currOutliersIdx_x <-outliersIDs[which(varnames==xvars[xs])]
     `%nin%` = Negate(`%in%`)
    
    
   for (ys in 1:length(yvars)){
     counter <- counter + 1
     currYvar <- varnames[which(varnames==yvars[ys])]
     # First exclusion based on previous criteria
     if (grepl('^ran',currYvar)){
       curdat <- dat[which(dat$Exclude_ran!=1),]
     }else if (grepl('^rias',currYvar)){
       curdat <- dat[which(dat$Exclude_rias!=1),]
       
     }else if (grepl('^lgvt',currYvar)){
       curdat <- dat[which(dat$Exclude_lgvt!=1),]
       
     }else if (grepl('^slrt',currYvar)){
       curdat <- dat[which(dat$Exclude_slrt2b!=1),]
       
     }else if (grepl('^wais',currYvar)){
       curdat <- dat[which(dat$Exclude_wais!=1),]
       
     }else if (grepl('^rst',currYvar)){
       curdat <- dat[which(dat$Exclude_rst!=1),]
     } else {
       curdat <- dat
     }
     
     # exclude outliers  
     currOutliersIdx_y <-outliersIDs[which(varnames==yvars[ys])]
     `%nin%` = Negate(`%in%`)
     dat2use <- dat[which(curdat$subject %nin% unlist(strsplit(currOutliersIdx_x,split=','))),]
     dat2use <- dat2use[which(dat2use$subject %nin% unlist(strsplit(currOutliersIdx_y,split=','))),]
     #convert to number format if not formatted for some reason
      # if (!is.numeric(dat2use[behavioralvar])){
      #      dat2use[yvars] <- as.matrix(dat2use[yvars])
      # }
       dat2use <- as.data.frame(dat2use)
       corrs[[counter]] <-  func_gather_corrs(currXvar,currYvar,dat2use)
    
       
       #rm(currOutliersIdx_x)
       #rm(currOutliersIdx_y)
   }
}

# save
regTable <- data.table::rbindlist(corrs)
writexl::write_xlsx(as.data.frame(regTable),paste0(diroutput,'/Corrs_exclOut.xlsx'))

# plot correlations for exploration
pthresh <- 0.05
corrs2plot <- regTable[which(regTable$`p-value` < pthresh),]
 
fig2 <- plotly::plot_ly(corrs2plot,x =~predictor,y =~pearson_r,color=~predicted,type='scatter',mode='markers',size=2) 
fig2 <- fig2 %>% layout (title= paste0("Correlations with p < ",pthresh, " after excluding outliers in x and y "))
htmlwidgets::saveWidget(fig2, paste0(diroutput,"/Correlation_summary.html"), selfcontained = F, libdir = "lib")
