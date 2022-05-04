rm(list=ls())
library(openxlsx)

# Gather  Beta values for the different contrasts in a dataset for analysis 
#-------------------------------------------------------------------------------------
tasklist <- c('FBL_A','FBL_B')
typelist <- c('eigen','median','mean') # which summary value wase used 'eigen','mean' or 'median' 
glmversion <- '2Lv_GLM0_thirds_exMiss' 
diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/mri/stats_ROI/GLM0_thirds/'
rlddm <- 'LEMO_rlddm_v32'

allgathered <- list()
for (ty in 1:length(typelist)) { 
    type <- typelist[ty]
    gathered <- list()
    for (t in 1:length(tasklist)){
      task <- tasklist[t] 
      # Gather  files 
      if (grepl('mopa',glmversion)) {
        dirinput <-paste0('O:/studies/grapholemo/analysis/LEMO_GFG/mri/2ndLevel/FeedbackLearning/',task,'/',rlddm,'/',glmversion,'/ROI_',type)
      }else{
        dirinput <-paste0('O:/studies/grapholemo/analysis/LEMO_GFG/mri/2ndLevel/FeedbackLearning/',task,'/',glmversion,'/ROI_',type)
      }
            files <- dir(path = dirinput, pattern = '*con0*.*.csv')
      tbl <- list()
          for (f in 1:length(files)){
            tbl [[f]] <-  read.csv(paste0(dirinput,'/',files[[f]]))
          }
          tbl <- do.call(cbind,tbl)
     
          # rename variables
          if(grepl('mopa',glmversion)){
              colnames(tbl)[-1] <- paste(glmversion,colnames(tbl)[-1],sep='_')
              colnames(tbl) <- gsub(glmversion,gsub('_','',glmversion),colnames(tbl))
              colnames(tbl) <- gsub('2Lv','',colnames(tbl))
              colnames(tbl) <- gsub('con0002',replacement = 'st',colnames(tbl))
              colnames(tbl) <- gsub('con0003',replacement = 'fb',colnames(tbl))
              colnames(tbl) <- gsub('con0004',replacement = 'stfb',colnames(tbl))
              colnames(tbl) <- gsub('con0005',replacement = 'fbst',colnames(tbl))
              colnames(tbl) <- gsub('con0006',replacement = 'asPos',colnames(tbl))
              colnames(tbl) <- gsub('con0007',replacement = 'asNeg',colnames(tbl))
              colnames(tbl) <- gsub('con0008',replacement = 'pePos',colnames(tbl))
              colnames(tbl) <- gsub('con0009',replacement = 'peNeg',colnames(tbl))
              colnames(tbl) <- paste(type,gsub('_','',task),colnames(tbl),sep="_")
          }else{
            colnames(tbl)[-1] <- paste(glmversion,colnames(tbl)[-1],sep='_')
            colnames(tbl) <- gsub(glmversion,gsub('_','',glmversion),colnames(tbl))
            colnames(tbl) <- gsub('2Lv','',colnames(tbl))
            colnames(tbl) <- gsub('con0002',replacement = 's13',colnames(tbl))
            colnames(tbl) <- gsub('con0003',replacement = 's31',colnames(tbl))
            colnames(tbl) <- gsub('con0004',replacement = 'f13',colnames(tbl))
            colnames(tbl) <- gsub('con0005',replacement = 'f31',colnames(tbl))
            colnames(tbl) <- gsub('con0006',replacement = 's1',colnames(tbl))
            colnames(tbl) <- gsub('con0007',replacement = 's3',colnames(tbl))
            colnames(tbl) <- gsub('con0008',replacement = 'f1',colnames(tbl))
            colnames(tbl) <- gsub('con0009',replacement = 'f3',colnames(tbl))
            colnames(tbl) <- gsub('thirdsexMiss','3rdsExM',colnames(tbl))
            colnames(tbl) <- paste(type,gsub('_','',task),colnames(tbl),sep="_")
          }
          
          
          colnames(tbl)[1] <- 'subject'
          # 
          gathered[[t]] <- tbl
    }
    
    gathered <- do.call(cbind,gathered)
    allgathered[[ty]] <- gathered 
    
}
allgathered <- do.call(cbind,allgathered)

#remove duplicate subject variables 
colnames(allgathered)[1] <- 'subjID'
allgathered <- allgathered[,-grep(pattern = 'subject',colnames(allgathered))]

# save in Wide SPSS format
haven:::write_sav(allgathered, paste0(diroutput,'ROI_vals_',gsub('_','',glmversion),'.sav'))

# save in long SPSS format
allgathered_long <- tidyr:::pivot_longer(allgathered,colnames(allgathered)[-1])
allgathered_long <- tidyr:::separate(allgathered_long,col=name,into = c('type','task','glm','region','contrast'),sep = '_')
haven:::write_sav(allgathered_long, paste0(diroutput,'ROI_vals_',gsub('_','',glmversion),'_long.sav'))
