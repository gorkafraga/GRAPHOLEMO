rm(list=ls(all=TRUE))#clear all
Packages <- c("haven","dplyr","tidyr","plotly")
lapply(Packages, library, character.only = TRUE)
# function to compute correlations
source('N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Study_specific/LEXI_GFG_2019/BEHAVE and regressions/func_gather_corrs.R')
#------------------------------------------------------------------------------------------------------------------------------------------
#  RUN CORRELATIONS
# - calls function
# - reads outliers from neural variables
#------------------------------------------------------------------------------------------------------------------------------------------
#inputs
fileinput <- "FPVS_Master_behNeuro.sav" 
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats" 
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats/lmm_GFG/correlations" 
subjectIdentifier <- 'subject'
typevars <- 'behavioral' # TYPE 'neuro' or 'behavioral' 
mymeasure="bcAmps"
oddBase = "Odd" # "Base" or "Odd" 
selectgroup= 'Poor' #'Poor' ,'Gap' or 'All' 
# Read data  
setwd(dirinput)
raw <-  haven::read_sav(fileinput)


# Filter 
if (selectgroup=='All'){
  dat <- dplyr::filter(raw , (group== 'Typ' | group == 'Poor'| group == 'Gap'))
} else {
  print(paste0('Selecting group: ',selectgroup))
  dat <- dplyr::filter(raw , (group== selectgroup))
}

xvars <- colnames(dat)[grep( paste0(mymeasure,'.*.',oddBase,'.*_sep$'),colnames(dat))]
yvars <- c("months_since_schoolstart_at_vt1", "slrt_w_richtig_T1", "slrt_pw_richtig_T1", "elfe_gesamt_T1")
 


# OUTLIER DETECTION  ############################################################################################################################
# Go thru the variables search for outliers
selectedVariables <- c(xvars,yvars)
outliers <- list()
for (i in 1:length(selectedVariables)){
  
  var <- selectedVariables[i]
  values <- as.matrix(select(dat,all_of(var)))
  
  # Get the values of the data that are outliers
  outlier_values <- boxplot.stats(values,coef=1.5)$out 
  print('finding outliers in xvar with boxplot.stats using the coefficient 1.5 ....')
  
  # Get the subject ids and put them together separated by comma as a string 
  outlier_subjects <- paste0(dat$subject[which(values %in% outlier_values)],collapse=",")
  outliers[[i]] <- as.data.frame(outlier_subjects)
  colnames(  outliers[[i]] ) <- var
  
}


# put together in a dataset
df <- sapply(outliers,as.data.frame,simplify = TRUE,)
df <- as.data.frame(cbind(names(df),df),row.names = FALSE)
colnames(df) <- c('variable','outliers')
# save as xls
outputbasename <- paste0('Outliers_boxplotStats_',mymeasure,'_',oddBase)
openxlsx::write.xlsx(df,file=paste0(diroutput,'/', outputbasename,'_',selectgroup,'.xlsx'))

#--------plotly! 
dat2plot <- select(dat,all_of(c(subjectIdentifier,selectedVariables)))
dat2plot_long <- pivot_longer(dat2plot,all_of(selectedVariables))
fig <- plotly::plot_ly(dat2plot_long,x =~name,y =~value,type='box',color=~name,boxpoints="suspectedOutliers")
htmlwidgets::saveWidget(fig, paste0(diroutput,"/",outputbasename,'_',selectgroup,'.html'), selfcontained = F, libdir = "lib")

#############################################################################################################################


# CORRELATIONS
 
#loop thru neural variables and run a correlation with all behavioral
corrs <- list()
counter <- 0
varnames <- unlist(df$variable)
outliersIDs <- unlist(df$outliers)

for (xs in 1:length(xvars)) {
    currXvar <- varnames[which(varnames==xvars[xs])]
   
   # exclude outliers  
    currOutliersIdx_x <-outliersIDs[which(varnames==xvars[xs])]
     `%nin%` = Negate(`%in%`)
    dat2use <- dat[which(dat$subject %nin% unlist(strsplit(currOutliersIdx_x,split=','))),]
    
    
   for (ys in 1:length(yvars)){
     counter <- counter + 1
     currYvar <- varnames[which(varnames==yvars[ys])]
     
     # exclude outliers  
     currOutliersIdx_y <-outliersIDs[which(varnames==yvars[ys])]
     `%nin%` = Negate(`%in%`)
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
writexl::write_xlsx(as.data.frame(regTable),paste0(diroutput,'/Corrs_exclOut_',selectgroup,'.xlsx'))

# plot correlations for exploration
corrs2plot <- regTable[which(regTable$`p-value` < 0.1),]
 
fig2 <- plotly::plot_ly(corrs2plot,x =~predictor,y =~pearson_r,color=~predicted,type='scatter',mode='markers',size=3) 
fig2 <- fig2 %>% layout (title= "Correlations with p < 0.1 after excluding outliers only from neural variables")
htmlwidgets::saveWidget(fig2, paste0(diroutput,"/Correlation_summary_",typevars,'_',selectgroup,".html"), selfcontained = F, libdir = "lib")
