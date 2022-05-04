rm(list=ls())
# RUN t-test over each column of the wide formatted dataset(e.g., roi values)
#----------------------------------------------------------------------------
# -  Two tailed t-tests against 0 

# define inputs
dirinput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/mri/stats_ROI/GLM0_thirds/'#end with /
diroutput <- dirinput
fileinput <- 'ROI_vals_2LvGLM0thirdsexMiss.sav'
setwd(dirinput)

#read file 
df <- haven:::read_spss(paste0(dirinput,fileinput))


#
tbl <- list()
for (c in 2:ncol(df)){
    
    currdat <- dplyr::select(df,colnames(df)[c])
    myt <- t.test(currdat,mu=0 , alternative ="two.sided")
    # make table with info 
    myt_summary <- as.data.frame(
        cbind(round(myt$statistic,2),
              myt$parameter,
              as.numeric(round(myt$p.value,5)),
              round(myt$estimate,2),
              round(myt$stderr,2),
              paste(sapply(myt$conf.int, function(x) round(x,2)),collapse=','),
              #summary in text 
              paste0('t(',myt$parameter,')=',round(myt$statistic,2),', p=', round(myt$p.value,4))
              
        )
    )
    myt_summary <- cbind(colnames(currdat),myt_summary)
    colnames(myt_summary)<- c('variable','t','df','p','estimate','stderr','CI','summary')
    
    # add to list
    tbl[[c]] <- myt_summary
}    
tbl2save <- do.call(rbind,tbl)
tbl2save$t <- as.numeric(tbl2save$t)
tbl2save$df <- as.numeric(tbl2save$df)
tbl2save$p <- as.numeric(tbl2save$p)
tbl2save$estimate <- as.numeric(tbl2save$estimate)
tbl2save$stderr <- as.numeric(tbl2save$stderr)
# save 
writexl::write_xlsx(tbl2save,paste0(diroutput,'T-tests_',gsub('.sav','.xlsx',fileinput)))


#  Make a clean version for report 
# ---------------------------------
sortedRois <- c('LFusi','RFusi','LPrecentral','RPrecentral','LSTG','RSTG','LPutamen','RPutamen','LHippocampus','RHippocampus',
                'LCaudate','RCaudate','LInsula','RInsula','LmidCingulum','RmidCingulum','LSupramarginal','RSupramarginal')

onsets <- c('s1','s3','f1','f3','s13','s31','f13','f31')
tidyT <- list()
tasks <- c('FBLA','FBLB')
counter <- 1
for (tt in 1:length(onsets)) {
    curOnset <- onsets[tt]
    for (t in 1:length(tasks)){
        curTask <- tasks[t]
        for (i in 1:length(sortedRois)){
            
            tidyT[[counter]] <- tbl2save[grep(paste0('eigen_',curTask,'_.*._',sortedRois[i],'_',curOnset,'$'),tbl2save$variable,perl = TRUE),]
            counter <- counter + 1
        }
    }
}

tidyT <- as.data.frame(do.call(rbind,tidyT))
tidyT$t <- round(tidyT$t,2)
tidyT$p <- round(tidyT$p,3)
#tidyT$summary <- paste0('F(',tidyT$numDF,',',tidyT$denDF,')=',round(tidyT$`F-value`,2),', p=',round(tidyT$`p-value`,3))
rownames(tidyT) <- gsub('contrast','',rownames(tidyT))
#save 
writexl::write_xlsx(tidyT,paste0('T-test_',gsub('.sav','_tidy.xlsx',fileinput)))
