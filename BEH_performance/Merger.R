rm(list=ls())
library(openxlsx)

master <- read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Cognitive")
dat1 <- read.csv("O:/studies/grapholemo/analysis/LEMO_GFG/beh/FBL_A_Performance_wide.csv")
dat2 <- read.csv("O:/studies/grapholemo/analysis/LEMO_GFG/beh/FBL_B_Performance_wide.csv")
dirout <-   'O:/studies/grapholemo' 

colnames(dat1)[1] <- 'Subj_ID'
colnames(dat1)[1] <- 'Subj_ID'
alldat <- cbind(dat1,dat2)

dat2save <- merge(alldat,select(master,1),by = c("Subj_ID"),all = TRUE)

# Save 
write.xlsx(dat2save,paste(dirout,'/tmp_merged.xlsx',sep = ''),sheet = "perfomerged",append=TRUE,row.names = FALSE,showNA=FALSE)


#  SAVE WITH STYLE  
wb <-createWorkbook()
addWorksheet(wb, "tmpMerged")
writeData(wb, 1, dat2save, startRow = 1, startCol = 1)
hs1_light <- createStyle(fgFill ='khaki', halign = "CENTER", border = "Bottom", fontColour = "black")
hs1_dark <- createStyle(fgFill = 'yellow2', halign = "CENTER",  border = "Bottom", fontColour = "black")
hs2_light <- createStyle(fgFill = 'lightgreen', halign = "CENTER", border = "Bottom", fontColour = "black")
hs2_dark <- createStyle(fgFill =  'chartreuse3', halign = "CENTER",  border = "Bottom", fontColour = "black")

idx1 <- grep("FBLA*.meanRT.*", colnames(dat2save))
idx2 <- grep("FBLA*.count.*", colnames(dat2save))

idx3 <- grep("FBLB*.meanRT.*", colnames(dat2save))
idx4 <- grep("FBLB*.count.*", colnames(dat2save))

addStyle(wb, sheet = 1, hs1_light, rows = 1, cols = idx1, gridExpand = TRUE)
addStyle(wb, sheet = 1, hs2_light, rows = 1, cols = idx2, gridExpand = TRUE)
addStyle(wb, sheet = 1, hs1_dark, rows = 1, cols = idx3, gridExpand = TRUE)
addStyle(wb, sheet = 1, hs2_dark, rows = 1, cols = idx4, gridExpand = TRUE)

saveWorkbook(wb,paste0(dirout,'/tmp_merged_color.xlsx'), overwrite = TRUE)


# -----------------------------------------------------------------------------------
# longitudinal files. combine by rows
longdat1 <- read.csv("O:/studies/grapholemo/analysis/LEMO_GFG/beh/FBL_A_Performance_long.csv")
longdat2 <- read.csv("O:/studies/grapholemo/analysis/LEMO_GFG/beh/FBL_B_Performance_long.csv")
longdat2save <- rbind(longdat1,longdat2)

haven::write_sav(longdat2save,"O:/studies/grapholemo/analysis/LEMO_GFG/beh/FBL_performance_long.sav")


  