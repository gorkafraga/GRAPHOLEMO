rm(list=ls(all=TRUE))  #clears all! 
Packages <- c("nlme","emmeans","haven","ggplotify","dplyr","readxl") #Load libraries (you mast install packages before)
lapply(Packages, library, character.only = TRUE) 
source('N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/STATISTICAL_ANALYSIS/R_templates/Func_LMM_outliers.R') # read function
#--------------------------------------------------------------------------------------------------------------
#  TEMPLATE TO RUN LINEAR MIXED MODELS
# =============================================================================================================
# - Main input options: residuals threshold for outlier exclusion, formulas
# - Filters and data format must be edited depending on your data
# - Runs a linear mixed model using the function "Func_LMM_outliers"
# - If more than 2 fixed factors the function does contrasts with all possible combinations 
# - saves fit, tables with effects, contrasts tables and plots (optional)
#--------------------------------------------------------------------------------------------------------------

# Edit Input options
resThreshold    <- 3 # set your threshold for outlier removal (based on normalized residual)
givemeplots     <- 1 #set to 1 if you want additional model and contrast plots (0 to cancel)
savethecode     <- 0 # set to 0 if you don't want a text copy of this script saved with date and time 

# Edit Paths
dirinput        <- 'N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats'
diroutput       <- 'N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats/output_lmm'
fileinput       <- 'FPVS_gathered_longOK.sav'

# Edit Model formulas [Syntax for fixed factors: DV ~ Factor1*Factor2+Covariate. Syntax for a random intercept: ~1|subjectID] 
formula_fixed   <- as.formula('value ~ group*grade*hemisphere*cond')
formula_random  <- as.formula('~1|subject')

# READ AND PREPARE DATA-------------------------------------------------------------
    #Read  (use haven::read_sav,haven::read_sas or readxl::read_excel).  
    raw <- haven::read_sav(paste0(dirinput,'/',fileinput))
    raw <- as.data.frame(raw) # make sure it was read as dataframe! and NOT a 'tibble'. Else using the indexing of outlier rows in this is script will be WRONG 
     
    #Prepare dataset for analysis 
    dat <- raw # work on a copy, keep original dataset 
    
    #Filter data (use dplyr::filteruse):
    mybase="FF"
    mytype="BCamp"
    dat <- dplyr::filter(dat , (base == mybase) & (type== mytype) & (group!= 'Gap')) 
              
    # Ensure format of  your variables (as.factor or as.numeric)
     dat$group <- as.factor(dat$group)
     dat$grade <- as.factor(dat$grade)
     dat$hemisphere <- as.factor(dat$hemisphere)
     dat$cond <- as.factor(dat$cond)
     dat$subject <- as.factor(dat$subject)
     
 
  
 # RUN MODEL (do NOT edit)  ---------------------------------------------------------------------------- m_d[^_^]b_m calls external function !
 Func_LMM_outliers(formula_fixed,formula_random,dat,resThreshold,givemeplots)
      
  # SAVE (edit output filenames)---------------------------------------------------- 
 
 outputnamebase <- paste0('Model1_',mytype,'_',mybase)
 
 saveRDS(fit,paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_fit.rds"))
 # save excluded rows summary
 writexl::write_xlsx(summaryOut,paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_excludedData.xlsx")) #save in file
 writexl::write_xlsx(excludedRows_table,paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_excludedRows.xlsx")) #save in file
 # save effects and contrasts
 writexl::write_xlsx(Teffects,paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_effects.xlsx")) #save in file
 writexl::write_xlsx(as.data.frame(allresi),paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_residuals.xlsx")) #save in file
 writexl::write_xlsx(dfcons,paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_contrast.xlsx")) #save in file
 writexl::write_xlsx(as.data.frame(mymmeans),paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_emmeans.xlsx")) #save in file
 
 
 # save additional contrasts (check if they were created by the function first)
 if(exists('additionalContrasts')){ 
    for (ii in 1:length(additionalContrasts)){
     writexl::write_xlsx(as.data.frame(additionalContrasts[[ii]]$emmeans),paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_emmeans_",ii,".xlsx")) #save in file
     writexl::write_xlsx(as.data.frame(additionalContrasts[[ii]]$contrasts),paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_contrast_",ii,".xlsx")) #save in file
    }
  }
 # save plots
 # if (givemeplots==1){
 #     sjPlot::plot_model(fit,type="int")
 #     save_plot(paste0(diroutput,"/",outputnamebase,"_r","_effects.jpg"),fig=last_plot())
 #     ggplot2::ggsave(filename = paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_residuals.jpg"),plot = plot_fit, width = 220, height = 220, dpi=100, units = "mm")
 #     ggplot2::ggsave(filename = paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_contrast.jpg"),plot = combiplot, width = 220, height = 220, dpi=100, units = "mm")
 #     if(exists('additionalContrasts')){
 #        ggplot2::ggsave(filename = paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_contrastsLong.jpg"),plot = combiplotsLong,width = 220, height = 220, dpi=100, units = "mm")
 #     }
 # } 
 # 

# Additional plots for the contrasts ###################################################################

if (givemeplots==1){
  ggplot2::ggsave(filename = paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_residuals.jpg"),plot = as.grob(plot(fit)),width = 220, height = 220, dpi=100, units = "mm")
  
    if(exists('additionalContrasts')){
      for (ii in 1:length(additionalContrasts)){
          #read contrast  
          table2plot <- as.data.frame(additionalContrasts[[ii]]$contrasts)
          #plot settings
          pd <- position_dodge(0.75) 
          xvar <- names(table2plot)[2]
          zvar <-names(table2plot)[3]
          #plot
          fig<- ggplot(data = table2plot, aes_string(x=xvar, y = "estimate", fill=xvar)) +
          geom_errorbar(aes(x=get(xvar), ymin=estimate-SE, ymax=estimate+SE,color=get(xvar)),width=.05, size= 1, position=pd)+ 
          geom_point(shape=23,size=4)+
          labs(title =paste0(paste0(outputnamebase,"_r",resThreshold), ' contrast ', as.matrix(unique(table2plot[1]))," (error bars show SE!)"))+
          facet_wrap(zvar)+
          theme_bw()
          #save
          ggplot2::ggsave(filename = paste0(diroutput,"/",outputnamebase,"_r",resThreshold,"_contrast_",ii,".jpg"),plot = fig,width = 220, height = 220, dpi=100, units = "mm")
          
      }
    }
} 

 
 #save script 
 if (savethecode==1){    
     scriptfile <- rstudioapi::getActiveDocumentContext()$path
     scriptfilepattern <- gsub(":","",sub(":","",gsub("-","",sub(" ","",Sys.time()))))
     file.copy(scriptfile,gsub('//','/',paste0(diroutput,paste0('/code_',scriptfilepattern,'_',gsub(".R$",".txt",basename(scriptfile))))))
 }
 