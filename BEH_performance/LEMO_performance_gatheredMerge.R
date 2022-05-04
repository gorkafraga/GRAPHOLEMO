rm(list=ls())
library(openxlsx)
library(dplyr)

master <- openxlsx::read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Cognitive")
dirinput <- "O:/studies/grapholemo/analysis/LEMO_GFG/beh/gathered_performance_tables/"
dat1 <- read.csv(paste0(dirinput,"FBL_A_Performance_wide.csv"))
dat2 <-  read.csv(paste0(dirinput,"FBL_B_Performance_wide.csv"))
dirout <-   'O:/studies/grapholemo' 
dirout_sav <- 'O:/studies/grapholemo/analysis/LEMO_GFG/beh/'
colnames(dat1)[1] <- 'Subj_ID'
#colnames(dat2)[1] <- 'Subj_ID'
alldat <- cbind(dat1,dat2)
colnames(master)[1] <- "Subj_ID"
dat2save <- merge(alldat,select(master,1),by = c("Subj_ID"),all = TRUE)

# Save 
write.xlsx(dat2save,paste(dirout,'/tmp_merged.xlsx',sep = ''),sheet = "perfomerged",append=TRUE,row.names = FALSE,showNA=FALSE)


#  SAVE WITH STYLE  
wb <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, "tmpMerged")
openxlsx::writeData(wb, 1, dat2save, startRow = 1, startCol = 1)
hs1_light <- createStyle(fgFill ='khaki', halign = "CENTER", border = "Bottom", fontColour = "black")
hs1_dark <- createStyle(fgFill = 'yellow2', halign = "CENTER",  border = "Bottom", fontColour = "black")
hs2_light <- createStyle(fgFill = 'lightgreen', halign = "CENTER", border = "Bottom", fontColour = "black")
hs2_dark <- createStyle(fgFill =  'chartreuse3', halign = "CENTER",  border = "Bottom", fontColour = "black")

idx1 <- grep("FBLA*.meanRT.*", colnames(dat2save))
idx2 <- grep("FBLA*.count.*", colnames(dat2save))

idx3 <- grep("FBLB*.meanRT.*", colnames(dat2save))
idx4 <- grep("FBLB*.count.*", colnames(dat2save))

openxlsx::addStyle(wb, sheet = 1, hs1_light, rows = 1, cols = idx1, gridExpand = TRUE)
openxlsx::addStyle(wb, sheet = 1, hs2_light, rows = 1, cols = idx2, gridExpand = TRUE)
openxlsx::addStyle(wb, sheet = 1, hs1_dark, rows = 1, cols = idx3, gridExpand = TRUE)
openxlsx::addStyle(wb, sheet = 1, hs2_dark, rows = 1, cols = idx4, gridExpand = TRUE)

openxlsx::saveWorkbook(wb,paste0(dirout,'/tmp_merged_color.xlsx'), overwrite = TRUE)


# -----------------------------------------------------------------------------------
# longitudinal files. bind rows
longdat1 <- read.csv(paste0(dirinput,"FBL_A_Performance_long.csv"))
longdat2 <-  read.csv(paste0(dirinput,"FBL_B_Performance_long.csv"))
longdat2save <- rbind(longdat1,longdat2)

haven::write_sav(longdat2save, paste0(dirout_sav, "LEMO_fbl_long.sav"))


# cumulative probabilities
longcum1 <- read.csv(paste0(dirinput, "FBL_A_cumulative_probabilities.csv"))
  longcum1$task <- 'FBL_A'
longcum2 <- read.csv(paste0(dirinput, "FBL_B_cumulative_probabilities.csv"))
  longcum2$task <- 'FBL_B'
longcum2save <- rbind(longcum1,longcum2)

haven::write_sav(longcum2save, paste0(dirout_sav,"LEMO_fbl_probabilities.sav"))

