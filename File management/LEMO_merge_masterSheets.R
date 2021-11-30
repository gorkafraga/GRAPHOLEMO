rm(list=ls())
library(openxlsx)
library(dplyr)
dat1 <-  read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Demographics",detectDates = TRUE)
dat2 <-  read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Cognitive",detectDates = TRUE)
dat3 <-  read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Task_FBL",detectDates = TRUE)
dirout <-   'O:/studies/grapholemo/analysis/LEMO_GFG' 

dat1$Subj_ID <- tolower(dat1$Subj_ID)

# Start merging
dat12 <- merge(dat1,dat2,by="Subj_ID")
alldat <- merge(dat12,dat3,by="Subj_ID")


# Compute additional performance variables 
alldat$FBLA_meanRT_b1_t123 <- rowMeans(dplyr::select(alldat,c('FBLA_meanRT_b1_t1','FBLA_meanRT_b1_t2','FBLA_meanRT_b1_t3')),na.rm = TRUE,dims= 1)
alldat$FBLA_meanRT_b2_t123 <- rowMeans(dplyr::select(alldat,c('FBLA_meanRT_b2_t1','FBLA_meanRT_b2_t2','FBLA_meanRT_b2_t3')),na.rm = TRUE,dims= 1)
alldat$FBLA_meanRT_t123 <- rowMeans(dplyr::select(alldat,c('FBLA_meanRT_b1_t123','FBLA_meanRT_b2_t123')),na.rm = TRUE,dims= 1)

alldat$FBLA_meanRT_b1_q1234 <- rowMeans(dplyr::select(alldat,c('FBLA_meanRT_b1_q1','FBLA_meanRT_b1_q2','FBLA_meanRT_b1_q3','FBLA_meanRT_b1_q4')),na.rm = TRUE,dims= 1)
alldat$FBLA_meanRT_b2_q1234 <- rowMeans(dplyr::select(alldat,c('FBLA_meanRT_b2_q1','FBLA_meanRT_b2_q2','FBLA_meanRT_b2_q3','FBLA_meanRT_b2_q4')),na.rm = TRUE,dims= 1)
alldat$FBLA_meanRT_q1234 <- rowMeans(dplyr::select(alldat,c('FBLA_meanRT_b1_q1234','FBLA_meanRT_b2_q1234')),na.rm = TRUE,dims= 1)
#
alldat$FBLB_meanRT_b1_t123 <- rowMeans(dplyr::select(alldat,c('FBLB_meanRT_b1_t1','FBLB_meanRT_b1_t2','FBLB_meanRT_b1_t3')),na.rm = TRUE,dims= 1)
alldat$FBLB_meanRT_b2_t123 <- rowMeans(dplyr::select(alldat,c('FBLB_meanRT_b2_t1','FBLB_meanRT_b2_t2','FBLB_meanRT_b2_t3')),na.rm = TRUE,dims= 1)
alldat$FBLB_meanRT_t123 <- rowMeans(dplyr::select(alldat,c('FBLB_meanRT_b1_t123','FBLB_meanRT_b2_t123')),na.rm = TRUE,dims= 1)

alldat$FBLB_meanRT_b1_q1234 <- rowMeans(dplyr::select(alldat,c('FBLB_meanRT_b1_q1','FBLB_meanRT_b1_q2','FBLB_meanRT_b1_q3','FBLB_meanRT_b1_q4')),na.rm = TRUE,dims= 1)
alldat$FBLB_meanRT_b2_q1234 <- rowMeans(dplyr::select(alldat,c('FBLB_meanRT_b2_q1','FBLB_meanRT_b2_q2','FBLB_meanRT_b2_q3','FBLB_meanRT_b2_q4')),na.rm = TRUE,dims= 1)
alldat$FBLB_meanRT_q1234 <- rowMeans(dplyr::select(alldat,c('FBLB_meanRT_b1_q1234','FBLB_meanRT_b2_q1234')),na.rm = TRUE,dims= 1)

####

alldat$FBLA_proportionPerThird_b1_t123 <- rowMeans(dplyr::select(alldat,c('FBLA_proportionPerThird_b1_t1','FBLA_proportionPerThird_b1_t2','FBLA_proportionPerThird_b1_t3')),na.rm = TRUE,dims= 1)
alldat$FBLA_proportionPerThird_b2_t123 <- rowMeans(dplyr::select(alldat,c('FBLA_proportionPerThird_b2_t1','FBLA_proportionPerThird_b2_t2','FBLA_proportionPerThird_b2_t3')),na.rm = TRUE,dims= 1)
alldat$FBLA_proportionPerThird_t123 <- rowMeans(dplyr::select(alldat,c('FBLA_proportionPerThird_b1_t123','FBLA_proportionPerThird_b2_t123')),na.rm = TRUE,dims= 1)

alldat$FBLB_proportionPerThird_b1_t123 <- rowMeans(dplyr::select(alldat,c('FBLB_proportionPerThird_b1_t1','FBLB_proportionPerThird_b1_t2','FBLB_proportionPerThird_b1_t3')),na.rm = TRUE,dims= 1)
alldat$FBLB_proportionPerThird_b2_t123 <- rowMeans(dplyr::select(alldat,c('FBLB_proportionPerThird_b2_t1','FBLB_proportionPerThird_b2_t2','FBLB_proportionPerThird_b2_t3')),na.rm = TRUE,dims= 1)
alldat$FBLB_proportionPerThird_t123 <- rowMeans(dplyr::select(alldat,c('FBLB_proportionPerThird_b1_t123','FBLB_proportionPerThird_b2_t123')),na.rm = TRUE,dims= 1)

#
alldat$FBLA_proportionPerQuartile_b1_q1234 <- rowMeans(dplyr::select(alldat,c('FBLA_proportionPerQuartile_b1_q1','FBLA_proportionPerQuartile_b1_q2','FBLA_proportionPerQuartile_b1_q3','FBLA_proportionPerQuartile_b1_q4')),na.rm = TRUE,dims= 1)
alldat$FBLA_proportionPerQuartile_b2_q1234 <- rowMeans(dplyr::select(alldat,c('FBLA_proportionPerQuartile_b2_q1','FBLA_proportionPerQuartile_b2_q2','FBLA_proportionPerQuartile_b2_q3','FBLA_proportionPerQuartile_b2_q4')),na.rm = TRUE,dims= 1)
alldat$FBLA_proportionPerQuartile_q1234 <- rowMeans(dplyr::select(alldat,c('FBLA_proportionPerQuartile_b1_q1234','FBLA_proportionPerQuartile_b2_q1234')),na.rm = TRUE,dims= 1)

alldat$FBLB_proportionPerQuartile_b1_q1234 <- rowMeans(dplyr::select(alldat,c('FBLB_proportionPerQuartile_b1_q1','FBLB_proportionPerQuartile_b1_q2','FBLB_proportionPerQuartile_b1_q3','FBLB_proportionPerQuartile_b1_q4')),na.rm = TRUE,dims= 1)
alldat$FBLB_proportionPerQuartile_b2_q1234 <- rowMeans(dplyr::select(alldat,c('FBLB_proportionPerQuartile_b2_q1','FBLB_proportionPerQuartile_b2_q2','FBLB_proportionPerQuartile_b2_q3','FBLB_proportionPerQuartile_b2_q4')),na.rm = TRUE,dims= 1)
alldat$FBLB_proportionPerQuartile_q1234 <- rowMeans(dplyr::select(alldat,c('FBLB_proportionPerQuartile_b1_q1234','FBLB_proportionPerQuartile_b2_q1234')),na.rm = TRUE,dims= 1)

##
#save in SPSS
haven::write_sav(alldat,"O:/studies/grapholemo/analysis/LEMO_GFG/LEMO_beh_fbl.sav")


  