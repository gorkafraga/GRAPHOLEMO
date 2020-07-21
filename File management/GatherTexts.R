# GATHER TEXT FILES AND SAVE IN EXCEL
#Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("xlsx")
lapply(Packages, require, character.only = TRUE)

dirinput <- 'O:/studies/allread/mri/analysis_GFG/preprocessing/learn_1'
diroutput <- 'O:/studies/allread/mri/analysis_GFG/preprocessing/learn_1'

files <- dir(dirinput,pattern = '*countBadScans_inBlock_v2.txt',recursive=TRUE)



gathered <- list()
for (f in 1:length(files)) {
  
  currCount <- read.csv(paste(dirinput,'/',files[f],sep=''),sep='\t')
  gathered[[f]] <- cbind(files[f],currCount)
}

G <- data.table::rbindlist(gathered)

setwd(diroutput)
write.xlsx(G,'Gathered_countBadScans.xlsx',row.names = FALSE)
