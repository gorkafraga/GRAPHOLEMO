rm(list=ls(all=TRUE))#clear all
Packages <- c("haven","dplyr","tidyr")
lapply(Packages, library, character.only = TRUE)
#source("N:/Developmental_Neuroimaging/Scripts/Scripts_R/R-plots and stats/Geom_flat_violin.R")

#inputs
fileinput <- "Master_LEXI_behavSelect_N1.sav" 
dirinput <- "O:/studies/lexi/eeg/analyses/Visual Longitudinal Analysis_GFG/" 
diroutput <- "O:/studies/lexi/eeg/analyses/Visual Longitudinal Analysis_GFG/Letters_vs_Digits_vs_New/correlations"
vars2read <- c('T1_mAmp3_LPOT9_N1diffDN', 'T1_mAmp3_RPOT9_N1diffDN',
               'T2_mAmp3_LPOT9_N1diffDN', 'T2_mAmp3_RPOT9_N1diffDN',
               'T3_mAmp3_LPOT9_N1diffDN', 'T3_mAmp3_RPOT9_N1diffDN',
               'T5_mAmp3_LPOT9_N1diffDN', 'T5_mAmp3_RPOT9_N1diffDN',
               'T6_mAmp3_LPOT9_N1diffDN', 'T6_mAmp3_RPOT9_N1diffDN') # list of variables (as column names in data)
subjectIdentifier <- 'subject'
# Read data  
setwd(dirinput)
raw <-  haven::read_sav(fileinput)

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
    outlier_subjects <- paste0(dat$subject[which(values %in% outlier_values)],collapse=",")
    outliers[[i]] <- as.data.frame(outlier_subjects)
    colnames(  outliers[[i]] ) <- var
    
}
# put together in a dataset
df <- sapply(outliers,as.data.frame,simplify = TRUE,)
df <- as.data.frame(cbind(names(df),df),row.names = FALSE)
colnames(df) <- c('variable','outliers')
# save as xls
openxlsx::write.xlsx(df,file=paste0(diroutput,'/Outliers_boxplotStats.xlsx'))

#--------plotly! 
dat2plot <- select(dat,all_of(c(subjectIdentifier,vars2read)))
dat2plot_long <- pivot_longer(dat2plot,vars2read,)
fig <- plotly::plot_ly(dat2plot_long,x =~name,y =~value,type='box',color=~name,boxpoints="suspectedOutliers")
htmlwidgets::saveWidget(fig, paste0(diroutput,"/Outliers_boxplotStats.html"), selfcontained = F, libdir = "lib")

