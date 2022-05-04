#remotes:::install_github("yunshiuan/label4MRI")
rm(list =ls())
library(label4MRI)

#  # Optional merger of result tables from different contrasts and task
#-----------------------------------------------------------------
basedirinput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/mri/2ndLevel/FeedbackLearning/'
diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/mri/2ndLevel/FeedbackLearning/'
glmversion <- '2Lv_GLM0_mopa_vpe'
#glmversion <- '2Lv_GLM0'
model <- 'LEMO_rlddm_v32'
summaryFoldername <- 'summary_withFWE'
tasks <- c('FBL_A','FBL_B')
#tasks <- c('')
#filepattern <- 'postPre'
filepattern <- ''

#tasks <- c('FBL_AB')
tbl <- list()
for (t in 1:length(tasks)){
  
  dirinput  <- paste0(basedirinput,tasks[t],'/',glmversion,'/',summaryFoldername,'/') 
  if (grepl('*pairedTs',basedirinput)){
    dirinput <- paste0(basedirinput,glmversion,'/',summaryFoldername,'/')
  }
  if (grepl('mopa',glmversion)){
    dirinput  <- paste0(basedirinput,tasks[t],'/',model,'/',glmversion,'/',summaryFoldername,'/')
    
  }
  
  setwd(dirinput)
  files <- dir(dirinput,paste0('^Results.*.',filepattern,'.*.xlsx'))
  
  tmptbl <- list()
  for (f in 1:length(files)){
    tmp <- readxl::read_xlsx(paste0(dirinput,files[f]))
    tmp$file <- gsub('Results_Table',paste0(tasks[t],'_',glmversion),tmp$file)
    tmptbl[[f]]   <- tmp
  }
  tmptbl <- do.call(rbind,tmptbl)
  
  tbl[[t]] <- tmptbl
}
tbl <- do.call(rbind,tbl)

#  SEARCH ANATOMICAL LABELS AND MERGE WITH TABLE 
#-------------------------------------------------------
#
#dat <- readxl::read_xlsx('O:/studies/grapholemo/analysis/LEMO_GFG/mri/Summaries_manualCombi.xlsx')

dat <- tbl
dat$xcoord <- as.numeric(dat$xcoord)
dat$ycoord <- as.numeric(dat$ycoord)
dat$zcoord <- as.numeric(dat$zcoord)

label <- list()
distances <- list()
for (i in 1:nrow(dat)){
  info <- label4MRI::mni_to_region_name(x = dat$xcoord[i],
                                        y= dat$ycoord[i],
                                        z = dat$zcoord[i],
                                        template = "aal")
  
  label[[i]] <- info$aal.label
  distances[[i]] <- round(info$aal.distance,2)
}

myregions <- cbind(do.call(rbind,label),
                   do.call(rbind,distances))


colnames(myregions) <- c('aal','dist')
tab2save <- cbind(tbl,myregions)
#some formatting
tab2save$cluster_pFWE <- as.numeric(tab2save$cluster_pFWE)
tab2save$peak_T <- as.numeric(tab2save$peak_T)
tab2save$peak_Z <- as.numeric(tab2save$peak_Z)
tab2save$peak_pFWE <- as.numeric(tab2save$peak_pFWE)

#save
if (grepl('withFWE',summaryFoldername)){
  writexl::write_xlsx(tab2save,paste0(diroutput,'Result_regions_',glmversion,'_withFWE',filepattern,'.xlsx'))  
} else {
  writexl::write_xlsx(tab2save,paste0(diroutput,'Result_regions_',glmversion,filepattern,'.xlsx'))  
}

