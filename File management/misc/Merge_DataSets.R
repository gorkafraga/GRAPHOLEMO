
library(openxlsx)

dat1 <- read.xlsx("O:\studies\grapholemo\LEMO_Master.xlsx", sheet  = "Cognitive")
dat2 <- read.xlsx("O:\studies\grapholemo\analysis\LEMO_GFG\beh\LEMO_Master.xlsx", sheet  = "Sheet2")
dirout <- 'N:/studies/AllRead/Organizational/Kontakt mit Probanden/Data_report'

dat2save <- merge(dat1,dat2,by = c("vp"),all.x = TRUE, all.y = TRUE)


 write.xlsx(dat2save,paste(dirout,'/merged.xlsx',sep = ''),sheet = "merged",append=TRUE,row.names = FALSE,showNA=FALSE)
 