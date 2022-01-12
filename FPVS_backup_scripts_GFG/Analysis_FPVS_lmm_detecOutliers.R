rm(list=ls(all=TRUE))#clear all
Packages <- c("haven","dplyr","tidyr")
lapply(Packages, library, character.only = TRUE)
#source("N:/Developmental_Neuroimaging/Scripts/Scripts_R/R-plots and stats/Geom_flat_violin.R")

#inputs
fileinput <- "FPVS_gathered_long.sav" 
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats" 
diroutput <-  "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats"
outlierCoeff <- 3 # or 1.5 


measurelist <- c('snr','bcAmps','zscores')
condition <- c("CSinFF","PWinFF","WinFF","FFinW","CSinW")
subjectIdentifier <- 'subject'

# Read data  
setwd(dirinput)
raw <-  haven::read_sav(fileinput)
for (mm in 1:length(measurelist)){
    measure=measurelist[mm]
    #Add any Initial filter 
    dat <- raw
    dat$rowID <- 1:nrow(raw)
    dat <- dat[which(dat$group=='Typ' | dat$group== 'Poor'),]
    # add new variable with outliers
    tmp <- as.vector(matrix(0,nrow = nrow(dat)))
    dat <- cbind(dat,tmp)
    colnames(dat)[which(colnames(dat)=='tmp')] <- paste('Outliers',measure,'withinCond',sep="_")
    
    
    # Go thru the variables search for outliers
    outliers <- list()
    for (i in 1:length(condition)){
        #Select current data
        currcond <- condition[i]
        values <- dat$value[which(dat$cond==currcond & dat$type==measure)]
        rowIDs <- dat$rowID[which(dat$cond==currcond & dat$type==measure)]
        
        # Get the values of the data that are outliers
        outlier_values <- boxplot.stats(values,coef=outlierCoeff)$out 
        outlier_idx <- rowIDs[which(values %in% outlier_values)]
        
        # Get the cases ids and put them together separated by comma as a string
        outlier_cases <- paste0(paste(dat$subject[outlier_idx],dat$group[outlier_idx],dat$cond[outlier_idx],dat$hemisphere[outlier_idx],sep="_"),collapse=",")
        outliers[[i]]<- as.data.frame(cbind(paste('outliers', measure,currcond,sep='_'),
                                            as.data.frame(outlier_cases),
                                            length(outlier_idx),
                                            outlierCoeff,
                                            paste(round(dat$value[outlier_idx],2),collapse=';')))
        colnames(outliers[[i]]) <- c('variable','outlier_cases','outlier_count','boxstats_coefficient','outlier_values')
        
        # Mark corresponding rows in the outliers variable
        dat[outlier_idx,
            which(colnames(dat)==paste0('Outliers_',measure,'_withinCond'))] <- 1
        print(which( dat$rowID == dat$rowID[outlier_idx]))
        print(outlier_cases)
        
        
}

# put together in a dataset
df <-  data.table::rbindlist(outliers,use.names = FALSE)
# save as xls
openxlsx::write.xlsx(df,file=paste0(diroutput,'/Outliers_boxplotStats_',measure,'.xlsx'))
haven::write_sav(dat, paste0(diroutput,'/FPVS_gathered_long_',measure,'_outliers.sav'))

}
 
