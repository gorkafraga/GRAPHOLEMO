rm(list=ls())
library(openxlsx)
library(dplyr)
dat1 <-  openxlsx::read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Demographics",detectDates = TRUE)
dat2 <-  openxlsx::read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Cognitive",detectDates = TRUE)
dat3 <-  openxlsx::read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Task_FBL",detectDates = TRUE)
dirout <-   'O:/studies/grapholemo/analysis/LEMO_GFG' 

dat1$Subj_ID <- tolower(dat1$Subj_ID)

# Start merging
dat12 <- merge(dat1,dat2,by="Subj_ID")
alldat <- merge(dat12,dat3,by="Subj_ID")

 
##
#save in SPSS
haven::write_sav(alldat,"O:/studies/grapholemo/analysis/LEMO_GFG/LEMO_cogni_fbl.sav")


  