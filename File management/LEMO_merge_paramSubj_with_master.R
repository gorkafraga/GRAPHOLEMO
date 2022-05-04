rm(list=ls())
library(openxlsx)
library(dplyr)
master <-  openxlsx::read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Cognitive",detectDates = TRUE)

# Read model data 1
dat1 <-read.csv('O:/studies/grapholemo/analysis/LEMO_GFG/beh/modeling/analysis_n39/fbl_a/LEMO_rlddm_v32/Parameters_perSubject.csv')
colnames(dat1)[-1] <- paste0('LEMO_rlddm_v32','_FBLA_',colnames(dat1)[-1])
colnames(dat1)[1] <- 'Subj_ID'

# Read model data 2
dat2 <-read.csv('O:/studies/grapholemo/analysis/LEMO_GFG/beh/modeling/analysis_n39/fbl_b/LEMO_rlddm_v32/Parameters_perSubject.csv')
colnames(dat2)[-1] <- paste0('LEMO_rlddm_v32','_FBLB_',colnames(dat2)[-1])
colnames(dat2)[1] <- 'Subj_ID'

# merge 1
mdatamerged <- merge(dat1,dat2,by='Subj_ID')

# MERGE
alldatamerged <- merge(dplyr::select(master,'Subj_ID'),mdatamerged,by='Subj_ID',all = TRUE)

# Save
openxlsx::write.xlsx(alldatamerged,'O:/studies/grapholemo/TMP_gather_parameters_perSubject.csv')

 

  