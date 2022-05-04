# Patrick Haller, January 2020
# read in csv table of slrt scores, extract relevant columns and mean-center

library(readr, reshape2, tidyr)

# helper function to center columns
center_colmeans <- function(x) {
  xcenter = colMeans(x)
  x - rep(xcenter, rep.int(nrow(x), ncol(x)))
}


dirinput <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
datainput <- paste0(dirinput, "/data/reading_fluency")
setwd(datainput)

slrt <- dir(pattern="scores_slrt*", recursive=FALSE)

scores_slrt <- read_delim(
  slrt,";", escape_double = FALSE, locale = locale(), trim_ws = TRUE)

# extract relevant scores
SLRT <- scores_slrt[,c(1,6,7,12,13)]
colnames(SLRT) <- c("testperson","wl_corr","wl_pr","pswl_corr","pswl_pr")
###### WL : EXCLUDE 8, 14 #####

WL <- SLRT[,c(2:5)]
# exclude rows 8 (subj8) and 14 (subj14)
WL <- WL[-c(8,14),]
WL$mean_corr <- rowMeans(WL[c("wl_corr", "pswl_corr")])
WL$mean_pr <- rowMeans(WL[c("wl_pr", "pswl_pr")])
WL_matrix <- as.matrix(WL[,c(1,2,5,6)])
WL_matrix_centered <-  center_colmeans(WL_matrix)
WL <- data.frame(WL_matrix_centered)

write_csv(WL,path = paste0(dirinput, "/data/reading_fluency/SLRT_WL.csv"),col_names = TRUE,quote=FALSE)


##### PSWL : EXCLUDE 10 ######

PSWL <- SLRT
PSWL <- SLRT[,4:5] 
PSWL_matrix <- as.matrix(PSWL)
PSWL_matrix_centered <-  center_colmeans(PSWL_matrix)
PSWL <- data.frame(PSWL_matrix_centered)

write_csv(PSWL,path = paste("SLRT_PSWL.csv",sep=","),col_names = TRUE,quote=FALSE)

#### ALL SCORES

SLRT <- data.frame(SLRT)
write_csv(SLRT,path = paste("SLRT_all.csv",sep=","),col_names = TRUE,quote=FALSE)
