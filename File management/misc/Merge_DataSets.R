
library(openxlsx)

dat1 <- read.xlsx("N:/studies/AllRead/Organizational/Kontakt mit Probanden/Data_report/Data_3TPs_selected_merged.xlsx", sheet  = "Sheet1")
dat2 <- read.xlsx("N:/studies/AllRead/Organizational/Kontakt mit Probanden/Data_report/Data_3TPs_selected_merged.xlsx", sheet  = "Sheet2")
dirout <- 'N:/studies/AllRead/Organizational/Kontakt mit Probanden/Data_report'

dat2save <- merge(dat1,dat2,by = c("vp"),all.x = TRUE, all.y = TRUE)


 write.xlsx(dat2save,paste(dirout,'/merged.xlsx',sep = ''),sheet = "merged",append=TRUE,row.names = FALSE,showNA=FALSE)
 