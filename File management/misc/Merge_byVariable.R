

# Merge excel table by a given variable 
diroutput <- 'O:/studies/allread/mri/analysis_GFG/stats/task/performance/learn_12_allFromNada/'
outputfilename <- 'Perform_summary_merged.xlsx'
masterfile= 'O:/studies/allread/mri/analysis_GFG/Allread_MasterFile_GFG.xlsx'
file2merge = 'O:/studies/allread/mri/analysis_GFG/stats/task/performance/learn_12_allFromNada/Perform_summary.xlsx'

# read master file and performance data
masterData <- xlsx::read.xlsx(masterfile,sheetName = 'IDs_Demographics',detectDates = TRUE)
data2merge <-   xlsx::read.xlsx(file2merge,sheetIndex = 1,detectDates = TRUE)
#
Dmerged <- merge.data.frame(masterData[,1:2],data2merge, by = "subjID", all.x = TRUE, all.y = TRUE, sort = TRUE)
write.xlsx(Dmerged,paste(diroutput,'/',outputfilename,sep=""),row.names = FALSE,showNA = FALSE)
