rm(list=ls(all=TRUE)) # remove all variables (!)
#install.packages('openxlsx')
library(openxlsx)
library(readr)
library(dplyr)
library(pracma)
#-----------------------------------------------------------------------------------------------------------------------------
# _____                       _     ____          _                       _       _        
# | ______  ___ __   ___  _ __| |_  |  _ \ ___  __| | ___ __ _ _ __     __| | __ _| |_ __ _ 
# |  _| \ \/ | '_ \ / _ \| '__| __| | |_) / _ \/ _` |/ __/ _` | '_ \   / _` |/ _` | __/ _` |
# | |___ >  <| |_) | (_) | |  | |_  |  _ |  __| (_| | (_| (_| | |_) | | (_| | (_| | || (_| |
# |_____/_/\_| .__/ \___/|_|   \__| |_| \_\___|\__,_|\___\__,_| .__/   \__,_|\__,_|\__\__,_|
#            |_|                                              |_|                           
#
# - REQUIRES SUBJECT IDENTIFIER TO BE THE FIRST VARIABLE! ! ! 
##-----------------------------------------------------------------------------------------------------------------------------
# EXPORT OPTIONS 
############################################################################################################################
mergeCases = 1 # if = 1 it will read cases from your master file
masterfile = 'O:/studies/allread/mri/analysis_GFG/Allread_MasterFile_GFG.xlsx'
#Set directories and output name 
#############################################################################################################################
dirinput <-'O:/studies/allread/mri/analysis_GFG/'
diroutput <-'O:/studies/allread/mri/analysis_GFG/'
setwd(dirinput)

# read data sets
masterData <- read.xlsx(masterfile,sheet = 4,detectDates = TRUE)

T <-masterData
#take only those with T3 available 
myvars3 <- colnames(masterData)[grep("*_T3",colnames(masterData))]
myvars1 <- gsub("_T3","_T1",myvars3)
myvars2 <- gsub("_T3","_T2",myvars3)

mynewvarspre <- gsub("_T1","_PRE",myvars1)
mynewvarspost <- gsub("_T1","_POST",myvars1)
mynewvarswait <-  gsub("_T1","_WAIT",myvars1)

TG1subjIDX <-which(T$Group=="1")
TG2subjIDX <- which(T$Group=="2")

# PRE
for (i in 1:length(myvars1)){
  tmp <- as.data.frame(T[,myvars1[i]])
  colnames(tmp)<-mynewvarspre[i]
  tmp[TG2subjIDX,1] <- T[TG2subjIDX,myvars2[i]] # for TG2 is T2
  T<-cbind(T,tmp)
  rm(tmp)
}
#POST
for (i in 1:length(myvars1)){
  tmp <- as.data.frame(T[,myvars2[i]])
  colnames(tmp)<-mynewvarspost[i]
  tmp[TG2subjIDX,1] <- T[TG2subjIDX,myvars3[i]] # for TG2 is T3
  #tmp[TG2subjIDX,1] <- T[TG2subjIDX,myvars2[i]]
  T<-cbind(T,tmp)
  rm(tmp)
}
# WAIT
for (i in 1:length(myvars1)){
  tmp <- as.data.frame(T[,myvars3[i]])  # for TG2 this is T1
  colnames(tmp)<-mynewvarswait[i]
  tmp[TG2subjIDX,1] <- T[TG2subjIDX,myvars1[i]]  # for TG1 is T3
  #tmp[TG2subjIDX,1] <- T[TG2subjIDX,myvars2[i]]
  T<-cbind(T,tmp)
}


setwd(diroutput)
write.xlsx(T,"TP_recoded.xlsx")

 







