rm(list=ls(all=TRUE))  #clears all! 
Packages <- c("nlme","emmeans","haven","ggplotify","dplyr","readxl") #Load libraries (you mast install packages before)
lapply(Packages, library, character.only = TRUE) 
source('N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_computationalModels_compareTasks/LEMO_Func_LMM_outliers.R') # read function
#--------------------------------------------------------------------------------------------------------------
#  TEMPLATE TO RUN LINEAR MIXED MODELS
# =============================================================================================================
# - Main input options: residuals threshold for outlier exclusion, formulas
# - Filters and data format must be edited depending on your data
# - Runs a linear mixed model using the function "Func_LMM_outliers"
# - If more than 2 fixed factors the function does contrasts with all possible combinations 
# - saves fit, tables with effects, contrasts tables and plots (optional)
#--------------------------------------------------------------------------------------------------------------

# Edit Input options???
resThreshold    <- 3 # set your threshold for outlier removal (based on normalized residual)
givemeplots     <- 1 #set to 1 if you want additional model and contrast plots (0 to cancel)
savethecode     <- 0 # set to 0 if you don't want a text copy of this script saved with date and time 
dependentvariable <- 'value'


# Edit Paths
dirinput <- "O:/studies/grapholemo/analysis/LEMO_GFG/beh/" 
diroutput <-  "O:/studies/grapholemo/analysis/LEMO_GFG/beh/stats_model_taskCompare" 
setwd(diroutput)
dir.create(diroutput)

# function to mean center 
center_apply <- function(x) {
  apply(x, 2, function(y) y - mean(y))
}


# Create File to read

param_a <- read.csv('O:/studies/grapholemo/analysis/LEMO_GFG/beh/modeling/analysis_n39/fbl_b/LEMO_rlddm_v32/Parameters_perSubject.csv')
param_b <- read.csv('O:/studies/grapholemo/analysis/LEMO_GFG/beh/modeling/analysis_n39/fbl_b/LEMO_rlddm_v32/Parameters_perSubject.csv')
    
    param_a$task <- 'A'
    mc_a <- center_apply(param_a[,2:6])
    colnames(mc_a) <- paste0('meanCen_',colnames(param_a))[2:6]
    param_a <- relocate(param_a,task,before=param_a$SubjID)
    
    param_b$task <- 'B'
    mc_b <- center_apply(param_b[,2:6])
    colnames(mc_b) <- paste0('meanCen_',colnames(param_b))[2:6]
    param_b <- relocate(param_b,task,before=param_b$SubjID)
    
    param_a <- cbind(param_a,mc_a)
    param_b <- cbind(param_b,mc_b)
    
dat <- rbind(pivot_longer(param_a,cols=colnames(param_a)[3:ncol(param_a)],names_to = 'parameter'),
             pivot_longer(param_b,cols=colnames(param_b)[3:ncol(param_b)],names_to = 'parameter'))

# save in spss just in case
haven::write_sav(data=dat,path = paste0(dirinput,'/LEMO_parameters_long.sav'))

# In wide format also just in case 
cbind(param_a,param_b)


# Edit Model formulas [Syntax for fixed factors: DV ~ Factor1*Factor2+Covariate. Syntax for a random intercept: ~1|subjIDID] 

formula_random  <- as.formula('~1|subjID')
formula_fixed <- as.formula(paste0(dependentvariable,'~ task') )

#Ensure format of your variables (as.factor or as.numeric)

dat$task   <- as.factor(dat$task)
dat$parameter   <- as.factor(dat$parameter)
raw <- dat # this used later to know what was excluded

### LOOP THRU PARAMETERS 
parameters <- c('a','tau','v_mod','eta_pos','eta_neg')
parameters <- paste0('meanCen_',parameters)
    
for (p in 1:length(parameters)){
  dat2use <- as.data.frame(filter(dat,parameter==parameters[p]))
    # RUN MODEL (do NOT edit)  ---------------------------------------------------------------------------- m_d[^_^]b_m calls external function !
    LEMO_Func_LMM_outliers(formula_fixed,formula_random,dat2use,resThreshold,givemeplots)
    
    # SAVE (edit output filenames)---------------------------------------------------- 
    
    outputnamebase <- paste0('LMM_',parameters[p])
    
    saveRDS(fit,paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_fit.rds"))
    
    # save excluded rows summary
    writexl::write_xlsx(summaryOut,paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_excludedData.xlsx")) #save in file
    writexl::write_xlsx(excludedRows_table,paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_excludedRows.xlsx")) #save in file
    # save effects and contrasts
    writexl::write_xlsx(Teffects,paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_effects.xlsx")) #save in file
    writexl::write_xlsx(as.data.frame(allresi),paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_residuals.xlsx")) #save in file
    writexl::write_xlsx(dfcons,paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_contrast.xlsx")) #save in file
    writexl::write_xlsx(as.data.frame(mymmeans),paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_emmeans.xlsx")) #save in file
    
    #Save outlier filter in a vector of length = original data set
    outcol <- as.data.frame(matrix(0,nrow(raw),1))
    colnames(outcol) <- paste0('Out_',outputnamebase,'_r',resThreshold)
    outcol[as.numeric(unlist(strsplit(excludedRows_id,','))),1] <- 1 # CORRECTED from previous: outcol[as.numeric(excludedRows_id),1] <- 1 
    
    rawOut <- cbind(raw,outcol)
    
    write_sav(rawOut,paste0(diroutput,"/Data_",outputnamebase,"_r",resThreshold,".sav")) #save in file
    
    
    
    # save additional contrasts (check if they were created by the function first)
    if(exists('additionalContrasts')){ 
        # ADD MORE contrasts , customized: 
        newcon <- emmeans(fit,as.formula('pairwise ~ third'),adjust="Tukey") 
        additionalContrasts[[length(additionalContrasts)+1]]  <- newcon
        for (ii in 1:length(additionalContrasts)){
            writexl::write_xlsx(as.data.frame(additionalContrasts[[ii]]$emmeans),paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_emmeans_",ii,".xlsx")) #save in file
            writexl::write_xlsx(as.data.frame(additionalContrasts[[ii]]$contrasts),paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_contrast_",ii,".xlsx")) #save in file
        }
    }
    
    
# PLOTS 
    
    if (givemeplots==1){
        ggplot2::ggsave(filename = paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_residuals.jpg"),plot = as.grob(plot(fit)),width = 220, height = 220, dpi=100, units = "mm")
        
      
      ## Plot effects 
        ds <- Rmisc::summarySE(dat2use,measurevar="value",groupvars = c("task")) 
     
        colormap <- c('darkorange','darkorange3')
        fig <- 
          ggplot(dat2use,aes(x=task,y=value)) +
          geom_point(aes(fill=task),shape=21, size = 1,alpha=.2,position= position_jitter(width = 0.03, height = NULL)) + 
          geom_boxplot(aes(fill=task,color=task),width=.2,alpha=.3,outlier.alpha=.9,fatten=NULL, notch=TRUE,lwd=.1) +
          #
          geom_errorbar(data=ds, aes(x= task,ymin=value-ci,ymax=value+ci,color = task),lwd=1,width=.1)+
          geom_point(data=ds,aes(x=task,y=value,fill=task),shape=21,size = 2) + 
          scale_color_manual(values=colormap)+
          scale_fill_manual(values=colormap)+
          theme_bw() +
          theme(axis.title.x =element_blank(),
                axis.title=element_text(size=14),
                axis.text = element_text(size=12),
                axis.text.x = element_text(angle=0),
                panel.grid.major = element_blank())+
          scale_y_continuous(name=paste0(parameters[p]))
        #save 
        ggsave(paste0(diroutput,"/PLOT_",outputnamebase,"_r",resThreshold,".jpg"),plot=fig, units = 'mm', height = 120, width = 100,dpi = 300)
        
      
  }
 
    
    
    #save script 
    if (savethecode==1){    
        scriptfile <- rstudioapi::getActiveDocumentContext()$path
        scriptfilepattern <- gsub(":","",sub(":","",gsub("-","",sub(" ","",Sys.time()))))
        file.copy(scriptfile,gsub('//','/',paste0(diroutput,paste0('/code_',scriptfilepattern,'_',gsub(".R$",".txt",basename(scriptfile))))))
    }
}
