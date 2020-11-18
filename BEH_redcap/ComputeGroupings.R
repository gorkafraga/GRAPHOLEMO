rm(list=ls(all=TRUE)) # remove all variables (!)
#install.packages('openxlsx')
library(openxlsx)
library(readr)
library(dplyr)
library(pracma)
################################################################################################################################

#  READ MASTER FILE COMPUTE GROUPING VARIABLE 

################################################################################################################################
# - Score:  mean word and pseudoword percentile from closest time point to MR recording
# - Threshold: poor < 16 good > 25  ('gap' those in between)
# ----------------------------------------------------------------------------------------------------------------------------
masterfile = 'O:/studies/allread/mri/analysis_GFG/Allread_MasterFile_GFG.xlsx'
dirinput <-'O:/studies/allread/mri/analysis_GFG/stats/cognitive_tests'
diroutput <-'O:/studies/allread/mri/analysis_GFG/stats/cognitive_tests'
outputfilename <- 'grouping_computed.xls'

setwd(dirinput)

#-------------------------
# Get  dates 
demoDat <- read.xlsx(masterfile,sheet = "IDs_Demographics",detectDates = TRUE)
demoDatTrimmed <- demoDat[,c("subjID","Date_MR")]

cogniDat <- read.xlsx(masterfile,sheet = "Cognitive_tests",detectDates = TRUE)
cogniDatTrimmed<-cogniDat[,c("subjID","Date_beh_T1","Date_beh_T2","Date_beh_T3")]

# Calculate difference between dates (behavioral tests vs MR testing)
Dates <- merge.data.frame(demoDatTrimmed,cogniDatTrimmed, by = "subjID", all.x = TRUE, all.y = TRUE, sort = TRUE)
diff1 <- as.numeric(difftime(as.Date(Dates$Date_MR), as.Date(Dates$Date_beh_T1), units = "days"))
diff2 <- as.numeric(difftime(as.Date(Dates$Date_MR), as.Date(Dates$Date_beh_T2), units = "days"))
diff3 <- as.numeric(difftime(as.Date(Dates$Date_MR), as.Date(Dates$Date_beh_T3), units = "days"))

diffs <- cbind(diff1,diff2,diff3)
#-------------------------
# Loop thru rows 
demoDat$groupBySLRT <- matrix("",nrow=dim(demoDat)[1])
demoDat$scoreToGroup <- matrix("",nrow=dim(demoDat)[1])
demoDat$tpToGroup <- matrix("",nrow=dim(demoDat)[1]) 
for (i in 1:dim(diffs)[1]) {
     tp <-  which(abs(diffs[i,]) == min(abs(diffs[i,]),na.rm = TRUE))
     
     if (!isempty(tp)){
       demoDat$tpToGroup[i] <- tp       
       
       # SCORE
         if (tp == 1){        
           score <- mean(c(cogniDat$SLRT_words_corr_pr_T1[i], cogniDat$SLRT_pseudo_corr_pr_T1[i])) 
           demoDat$score[i] <- score
         } else if  (tp==2) {
           score <- mean(c(cogniDat$SLRT_words_corr_pr_T2[i], cogniDat$SLRT_pseudo_corr_pr_T2[i]))
           demoDat$score[i] <- score
         } else if   (tp==3){
           score <- mean(c(cogniDat$SLRT_words_corr_pr_T3[i], cogniDat$SLRT_pseudo_corr_pr_T3[i]))
           demoDat$score[i] <- score
         }
         
         # GROUP
         if (score < 16){        
           demoDat$groupBySLRT[i] <- "poor" 
           
         } else if  (score >  25) {
           demoDat$groupBySLRT[i] <- "typical" 
         } else{
           demoDat$groupBySLRT[i] <- "gap" 
        }
       
     } else {
       #demoDat$groupBySLRT[i] <- "x" 
       demoDat$score[i] <- "x"
       demoDat$tpToGroup[i] <- "x"
     }
    
}
      
 
#  Export  
write.xlsx(demoDat[,c("subjID","groupBySLRT","score","tpToGroup")],paste(diroutput,'/',outputfilename,sep=""))









 