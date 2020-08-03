rm(list=ls(all=TRUE)) # 
Packages <- c("readr","tidyr","dplyr","viridis","data.table","BH")
lapply(Packages, require, character.only = TRUE)

#=====================================================================================
# GATHER DATA  + FORMAT FOR CHOICE RT  MODEL  
#=====================================================================================
# https://rdrr.io/cran/hBayesDM/man/choiceRT_ddm.html
# Data should be assigned a character value specifying the full path and name (including extension information, e.g. ".txt") of the file that contains the behavioral data-set of all subjects of interest for the current analysis. The file should be a tab-delimited text file, whose rows represent trial-by-trial observations and columns represent variables.
#For the Choice Reaction Time Task, there should be 3 columns of data with the labels "subjID", "choice", "RT". It is not necessary for the columns to be in this particular order, however it is necessary that they be labeled correctly and contain the information below:
# -  subjID (A unique identifier for each subject in the data-set.)
# - choice (Choice made for the current trial, coded as 1/2 to indicate lower/upper boundary or left/right choices (e.g., 1 1 1 2 1 2))
# - RT (Choice reaction time for the current trial, in **seconds** (e.g., 0.435 0.383 0.314 0.309, etc.).
# *Note: The file may contain other columns of data (e.g. "ReactionTime", "trial_number", etc.), but only the data within the column names listed above will be used during the modeling. As long as the necessary columns mentioned above are present and labeled correctly, there is no need to remove other miscellaneous data columns.
#--------------------------------------------------------------------------------------------
#set dirs
dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/logs/2blocks"
diroutput <- "O:/studies/allread/mri/analysis_GFG/stats/task/modelling/model_choiceRT"
masterfile  <- "O:/studies/allread/mri/analysis_GFG/Allread_MasterFile_GFG.xlsx" # use this to find your subjects
setwd(dirinput)
#Some starting info
nblocks <- 2              
ntrials <- 40             # trials per block
stims_per_block <- 4      # number of stimuli to be learned per block
RTbound <- 0.100           # set a limit for implausibly fast responses  (previously 150 ms)
taskpattern<- "FeedLearn_MRI"

# READ SUBJECTS LIST
T <- xlsx::read.xlsx(file = masterfile,sheetName= "Lists_subsamples")
selection <- menu(colnames(T),graphics=TRUE,title="Choose list")
subjects  <- T[selection]
subjects <- subjects[!is.na(subjects)]

# select log/txt files from selected subjects
files <- dir(pattern=paste("*.4stim_.*",".txt",sep=""), recursive=TRUE)
files <- files[which(substr(files,1,6) %in% subjects)]  # take log files of those subjects


# print number of blocks for checking
for (i in 1:length(subjects)){
  if  (length(grep(subjects[i],files))>nblocks) {  cat(subjects[i]," has more than",nblocks," blocks!\n") }
  else { cat(subjects[i],"is OK. n blocks =",length(grep(subjects[i],files)),"\n")         
  }
}
#---------------------------------------------------------------------
# Gather all data before preprocessing
# ------------------------------------

setwd(dirinput)
datalist <- list()
for (f in 1:length(files)){
  raw <- read_delim(files[f],"\t", escape_double = FALSE, locale = locale(), trim_ws = TRUE)
  # minor fix for some files with inconsistent headers
  if (length(which(colnames(raw)=="vSymbols"))!=0) {
      raw$vSymbol1 <- substr(raw$vSymbols,1,1)
      raw$vSymbol2 <- substr(raw$vSymbols,2,2)
      tmpIdx <- which(colnames(raw)=="vSymbols")
      raw$vSymbolCorrect <- 0
      for (ii in 1:length(raw$vStim1)) {
        jnk <- cbind(raw$vStim1[ii],raw$vStim2[ii])
        raw$vSymbolCorrect[ii] <-	 jnk[which(jnk==raw$aStim[ii])] 
      }
      raw <- select(raw,c(1:(tmpIdx-1)),length(raw)-2,length(raw)-1,length(raw),c(1+tmpIdx:c(length(raw)-2)))
  }
  # Stop if it can't find 40 trials in a file
  if (dim(raw)[1] != ntrials) {cat(files[f]," does not have ",ntrials, "!! script STOPS.\n")
    break  }
  
  # Add to list 
  ssInf<- rep(sapply(strsplit(files[f],'/'),'[',1),dim(raw)[1]) #repeat subject name each row
  #ssInf <- rep(substr(files[f],1,(regexpr(taskpattern,files[f])[[1]]-2)),dim(raw)[1])
  datalist[[f]] <- cbind(ssInf,raw)
}
rawG <- data.table::rbindlist(datalist) # combine all data frames in on



# Format gathered data for Stan
# ----------------------------------------------------
colnames(rawG)[1] <- "subjID"
rawG$rt <- rawG$rt/1000 # RTs in seconds
names(rawG)[names(rawG)=="rt"] <- "RT"

# Remove response trials with too quick responses
datTable <- filter(rawG,fb!=2)
datTable <- filter(datTable,RT>RTbound)
datTable <- data.table(datTable)
datTable$choice <- datTable$fb
datTable$trial<-as.integer(datTable$trial)
#Count of trials per subject 
DT_trials <- datTable[,.N,by = subjID]
subjs <- DT_trials$subjID
n_subj    <- length(subjs)

# Reasign trial index (we excluded observations)
for (ss in subjs){ 
  subidx <- which(datTable$subjID==ss)
  datTable[subidx,]$trial <- seq.int(nrow(datTable[subidx,]))
}
 
### recode blocks (so in all subjects they are recoded to 1 and 2,or 1)
DT_trials_per_block <- datTable[, .N, by = list(subjID,block)]
datTable$block <- as.factor(datTable$block)
for (ss in subjs){
  subidx <- which(datTable$subjID==ss)
  n1 <- DT_trials_per_block[which(DT_trials_per_block==ss),]$N[1]
  b1 <-rep("1",n1)
  
  n2 <- DT_trials_per_block[which(DT_trials_per_block==ss),]$N[2]
  if (is.na(n2)) {
    cat(ss, " has only one block\n")
    datTable[subidx]$block <- c(b1)
  } else {
    b2 <- rep("2",n2)
    datTable[subidx]$block <- c(b1,b2)
  }
}
datTable$block <- as.integer(datTable$block)

# Some nr formatting adjusts
datTable$choice <- datTable$fb+1 # Responses 0 becomes 1 (incorrect) and 1 becomes 2 (correct)
datTable$aStim <- as.double(datTable$aStim)
datTable$vStim1 <- as.double(datTable$vStim1)
datTable$vStim2 <- as.double(datTable$vStim2)

# Because stimuli change in each block, give unique numbers for stimuli for each block
datTable[which(datTable$block==2),]$aStim = datTable[which(datTable$block==2),]$aStim + (stims_per_block) #sums the number of stimuli perblock
datTable[which(datTable$block==2),]$vStim1 = datTable[which(datTable$block==2),]$vStim1 + (stims_per_block)
datTable[which(datTable$block==2),]$vStim2 = datTable[which(datTable$block==2),]$vStim2 + (stims_per_block)

#Log in each trial which v-stimuli is correctly mapped to audio and which not
datTable$vStimNassoc <- ifelse(datTable$aStim==datTable$vStim1,datTable$vStim2,datTable$vStim1)
datTable$vStimAssoc <- datTable$aStim
# get minRT per subject
minRT <- with(datTable, aggregate(RT, by = list(y = subjID), FUN = min)[["x"]])
ifelse(is.null(dim(minRT)),minRT<-as.array(minRT))

# Get index of first and last trial per subject 
first <- as.double(which(datTable$trial==1))
# if N=1 transform int to 1-d array
first<-as.array(first)
# last is a Sx1 matrix identifying all last trials of a subject for each choice
last <- (first + DT_trials$N - 1)
# if N=1 transform int to 1-d array
last<-as.array(last)
# define the values for the rewards: if upper resp, value = 1
value <- ifelse(datTable$choice==2, 1, 0)
n_trials <- nrow(datTable)

#Count number of blocks
blocks <- aggregate(datTable$block ~ datTable$subjID, FUN = max )[2]
blocks <- blocks$`datTable$block`
ifelse(is.null(dim(blocks)),blocks<-as.array(blocks))


# save for choice RT ##### 
T2save <- datTable[,c('subjID','RT','choice')]
destinationDir <- paste(diroutput,"/Preproc_ChoiceRTddm_",colnames(T)[selection],'_',n_subj,'ss',sep="")
dir.create(destinationDir)
setwd(destinationDir)
write.table(T2save,"datTable.txt",sep = "\t",row.names = FALSE)
write.table(aggregate(datTable$block ~ datTable$subjID, FUN = max ),"subjects_blocks.txt",sep = "\t",row.names = FALSE)

#######################

# Final list for STAN
# ----------------------------------------------------
# datList <- list("T"=n_trials,
#                 "Nu_max" = max(datTable[which(choice==2), .N, by = list(subjID,choice)]$N),
#                 "Nl_max" = max(datTable[which(choice==1), .N, by = list(subjID,choice)]$N),
#                 "Nu" = datTable[which(choice==2), .N, by = list(subjID,choice)]$N,
#                  "Nl" = datTable[which(choice==1), .N, by = list(subjID,choice)]$N,
#                 "RTu" =  
#                 "RTl" = 
#                 "minRT" = minRT,   
#                 "RTbound" = RTbound)
#                  

# Vaiable description: 
#---------------------
#T  (1 number: total count of trials)
#RTbound 	(minimum RT allowed)
#minRT 	(minimum RT per subject)
#iter 	(trial indexes per subject, across blocks)
#response	 (response incorrect 1, correct 2)
#stim_assoc  	(auditory stimuli,  or correct vstim)
#stim_nassoc 	(incorrect visual stimuli in a trial)
#RT 	( reaction time in sec)
#First	(first trial in each subject, across blocks)
#last 	(last trial in each subject, across blocks)
#value	('reward' 0 or 1)
#n_stims	 (number blocks x 4 stim per block )
#Trials	(total number of trials each subject has)

# #Save 
# #####################################
# # Create folder with timeand date stamp
# #destinationDir <- paste("Preproc_",n_subj,'ss',format(Sys.time(),'_%Y%m%d_%H%M'),sep="")
# destinationDir <- paste(diroutput,"/Preproc_ChoiceRTddm_",n_subj,'ss',sep="")
# dir.create(destinationDir)
# setwd(destinationDir)
# #R vars
# save(datList,file="Preproc_list")
# save(datTable,file="Preproc_data")
# #csv file
# write.csv(datTable,file="Preproc_data.csv",row.names = FALSE)
# write(subjects,file="Preproc_subjects.txt")
# 
# 


 