rm(list=ls())
library(dplyr)
# RUN  linear mixed models comparing third 1 and 3 for each roi and stim/feedback separately
#----------------------------------------------------------------------------------------------
# -  requires dataset in long format
# -  calls function for linear mixed model with recursive loop to exclude outliers
source('N:/studies/Grapholemo/Methods/Scripts/grapholemo/Statistics_functions/Function_lmm_exclOutliers_lite.R')

# define inputs
dirinput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/mri/stats_ROI/GLM0_thirds/' # end with /
diroutput <- dirinput
fileinput <- 'ROI_vals_2LvGLM0thirdsexMiss_long.sav'
residual_threshold <- 2.5
setwd(dirinput)


#read file, format variables
df <- haven:::read_spss(paste0(dirinput,fileinput))
df$type <- as.factor(df$type)
df$task <- as.factor(df$task)
df$region <- as.factor(df$region)
df$contrast <- as.factor(df$contrast)

## Filter data 
# Do the analysis per task, measure type, and region. Leave only contrasts s1,s3 and f1,f3
types <- unique(df$type) 
tasks <- unique(df$task)
rois <- unique(df$region)
df_stim <- df[which(df$contrast=='s1' | df$contrast=='s3'),]
df_fb <- df[which(df$contrast=='f1' | df$contrast=='f3'),]

tbl <- list()
counter <- 1
for  (ty in 1:length(types)){
    curtype <- types[ty]
    
    for (tk in 1:length(tasks)){
        curtask <- tasks[tk]
        
        for (r in 1:length(rois)){
            curroi <- rois[r]
            
            
            #Filter
            cur_df_stim <- df_stim %>% filter(type == curtype & task == curtask & rois == curroi) %>% droplevels()
            cur_df_fb <- df_fb %>% filter(type == curtype & task == curtask & rois == curroi) %>% droplevels()
            # Linear mixed model------------------------------------------------------
            # call 
            Function_lmm_exclOutliers_lite(formula_fixed = as.formula('value ~ contrast'), 
                                           formula_random = as.formula('~1|subjID'),  
                                           Data = cur_df_stim, 
                                           resThreshold = residual_threshold)
            # Table of effects W
            options(contrasts = c(factor = "contr.helmert", ordered = "contr.poly"))
            Teffects <- nlme::anova.lme(fit,type="marginal")[2,]
            Teffects <- cbind(rownames(Teffects),Teffects)
            colnames(Teffects)[1] <- "Effect"
            Teffects$Effect <- paste(curtype,curtask,curroi,'stim10vs30',sep='_')
            Teffects <- cbind(Teffects,niterations,residual_threshold,excludedRows_table)
            rm(fit)
            # Model with feedback data
            Function_lmm_exclOutliers_lite(formula_fixed = as.formula('value ~ contrast'), 
                                           formula_random = as.formula('~1|subjID'),  
                                           Data = cur_df_fb, 
                                           resThreshold = residual_threshold)
            # Table of effects 
            options(contrasts = c(factor = "contr.helmert", ordered = "contr.poly"))
            Teffects2 <- nlme::anova.lme(fit,type="marginal")[2,]
            Teffects2 <- cbind(rownames(Teffects2),Teffects2)
            colnames(Teffects2)[1] <- "Effect"
            Teffects2$Effect <- paste(curtype,curtask,curroi,'fb10vs30',sep='_')
            Teffects2 <- cbind(Teffects2,niterations,residual_threshold,excludedRows_table)
            rm(fit)
            
            
            # save in large table 
            tbl[[counter]] <- rbind(Teffects,Teffects2)
            rm(Teffects, Teffects2)
            counter <- counter + 1
        }
    }
}

tbl2save <- do.call(rbind,tbl)
#save 
writexl::write_xlsx(tbl2save,paste0('LMM_',gsub('_long.sav','.xlsx',fileinput)))

#  Make a clean version for report 
# ---------------------------------
sortedRois <- c('LFusi','RFusi','LPrecentral','RPrecentral','LSTG','RSTG','LPutamen','RPutamen','LHippocampus','RHippocampus',
                'LCaudate','RCaudate','LInsula','RInsula','LmidCingulum','RmidCingulum','LSupramarginal','RSupramarginal')

onsets <- c('stim','fb')
tidyT <- list()       
counter <- 1
for (tt in 1:length(onsets)) {
    curOnset <- onsets[tt]
    for (t in 1:length(tasks)){
        curTask <- tasks[t]
        for (i in 1:length(sortedRois)){
            
            tidyT[[counter]] <- tbl2save[grep(paste0('eigen_',curTask,'_',sortedRois[i],'_*',curOnset),tbl2save$Effect),]
            counter <- counter + 1
        }
    }
}

tidyT <- do.call(rbind,tidyT)
tidyT$`F-value` <- round(tidyT$`F-value`,2)
tidyT$`p-value` <- round(tidyT$`p-value`,3)
tidyT$summary <- paste0('F(',tidyT$numDF,',',tidyT$denDF,')=',round(tidyT$`F-value`,2),', p=',round(tidyT$`p-value`,3))
rownames(tidyT) <- gsub('contrast','',rownames(tidyT))
#save 
writexl::write_xlsx(tidyT,paste0('LMM_',gsub('_long.sav','_tidy.xlsx',fileinput)))
