rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","BH")
lapply(Packages, require, character.only = TRUE) 
#set dirs
dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/logs/raw"
diroutput <- "O:/studies/allread/mri/analysis_GFG/stats/task/model_rtb300"
masterfile  <- "O:/studies/allread/mri/analysis_GFG/Allread_MasterFile_GFG.xlsx" # use this to find your subjects
setwd(dirinput)
#Some starting info
nblocks <- 2              
ntrials <- 40             # trials per block
stims_per_block <- 4      # number of stimuli to be learned per block
RTbound <- 0.300           # set a limit for implausibly fast responses  (previously 150 ms)
#files <- basename(dir(pattern=paste("*.4stim_.*",".txt",sep=""), recursive=TRUE))
#files <-sapply(strsplit(files,"/"),"[",2) #take just filename without subject's directory
taskpattern<- "FeedLearn_MRI"


# READ SUBJECTS LIST --------------------------------------------------------------------
T <- readxl::read_excel(path = masterfile,sheet= "Lists_subsamples")
selection <- menu(colnames(T),graphics=TRUE,title="Choose list")
subjects  <- T[selection]
subjects <- subjects[!is.na(subjects)]

# Read logfiles--------------------------------------------------------------------
files <- dir(pattern=paste("*.4stim_.*",".txt",sep=""), recursive=TRUE)
files <- files[which(substr(files,1,6) %in% subjects)]  # take log files of those subjects

#Read block indices from those subjects in the list ---------------
master <- readxl::read_excel(path = masterfile,sheet= "MR_Learn_QA")
blockIdx <- cbind(blocks_subjs <- master$subjID[which(!is.na(master$OldBlockSelect))],
                  master$OldBlockSelect[which(!is.na(master$OldBlockSelect))])
blockIdx <- blockIdx[which(blockIdx[,1] %in% subjects)]

#select only log files for selected blocks
selectedFiles <- list()
count <- 1
for (f in 1:dim(blockIdx)[1]) {
  currIdx <-  unlist(strsplit(blockIdx[f,2],",")) # the second column has block numbers separated by comma
   for (ff in 1:length(currIdx) ){
     selectedFiles[[count]] <-  files[grep(paste0(blockIdx[f,1],'.*B',currIdx[ff],'.txt'),files)]
     count <- count + 1
   }
}
selectedFiles <- unlist(selectedFiles)