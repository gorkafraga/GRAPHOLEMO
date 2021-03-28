
library(openxlsx)
dirout <- 'O:/studies/allread/mri/analysis_GFG'
# READ data
dat1 <- read.xlsx("O:/studies/allread/mri/analysis_GFG/Allread_MasterFile_GFG.xlsx", sheet  = "IDs_Demographics")
dat2 <- read.csv("O:/studies/allread/mri/analyses_NF/rlddm_analyses_NF/RLDDM/modeling/normPerf72_no0/outputs/out_AR_rlddm_v12/Parameters_perSubject.csv",sep=";")

#rename some variables
preffix <- "normPerf72_no0_RLDDM12_"
colnames(dat2)[-1] <- paste0(preffix,colnames(dat2)[-1])

#merge by subject variable
dat2save <- merge(dat1[1],dat2,by = c("subjID"),all.x = TRUE, all.y = TRUE)

#save
 write.xlsx(dat2save,paste(dirout,'/',preffix,'_merged.xlsx',sep = ''),sheet = "merged",append=TRUE,row.names = FALSE,showNA=FALSE)
 