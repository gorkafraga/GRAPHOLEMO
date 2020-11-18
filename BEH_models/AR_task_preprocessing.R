#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","BH")
lapply(Packages, require, character.only = TRUE)
#=====================================================================================
# GATHER DATA  + FORMAT FOR MODEL (in STAN)
#=====================================================================================
# - Concatenate all text files (given they have 40 trials)
# - Trim trials with no response ("too slow trials")
# - Select columns and code new ones needed for model in Stan
# - Save formatted and gathered data as txt file
#--------------------------------------------------------------------------------------------
# REFS: e.g. From Pederson et al.,2017 https://github.com/gbiele/RLDDM/blob/master/RLDDM.jags.txt 

#set dirs
dirinput <- "O:/studies/allread/mri/analysis_GFG/stats/task/logs/GFG"
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

# READ SUBJECTS LIST
#--------------------------------------------------------------------
T <- xlsx::read.xlsx(file = masterfile,sheetName= "Lists_subsamples")
selection <- menu(colnames(T),graphics=TRUE,title="Choose list")

subjects  <- T[selection]
subjects <- subjects[!is.na(subjects)]

# select log/txt files from selected subjects
#--------------------------------------------------------------------
files <- dir(pattern=paste("*.4stim_.*",".txt",sep=""), recursive=TRUE)
files <- files[which(substr(files,1,6) %in% subjects)]  # take log files of those subjects

# print number of blocks for checking
for (i in 1:length(subjects)){
  if  (length(grep(subjects[i],files))>nblocks) {  cat(subjects[i]," has more than",nblocks," blocks!\n") }
  else { cat(subjects[i],"is OK. n blocks =",length(grep(subjects[i],files)),"\n")         
  }
}


#`%nin%` = Negate(`%in%`) 
#assign(targetGroup,T[which(T %nin% "")]) # remove empty cells and assign the value to a variable with the name contained in 'targetgroup' variable... 
#`%!in%` = Negate(`%in%`) 
#subjects <- subjects[which(subjects %!in% c("AR1025","AR1063"))] # use this to exclude subjects




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
rawG$rt <- rawG$rt/1000
names(rawG)[names(rawG)=="rt"] <- "RT"

# Remove response trials with too quick responses
datTable <- filter(rawG,fb!=2)
datTable <- filter(datTable,RT>RTbound)
datTable <- data.table(datTable)
datTable$response <- datTable$fb
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

# recode blocks (so for all subjects they are 1 and 2,or 1)
DT_trials_per_block <- datTable[, .N, by = list(subjID,block)]
# seq.int(DT_trials_per_block[1]$N)                                                                      !!!!!!!!!!! 
datTable$block <- as.factor(datTable$block)
for (ss in subjs){
  subidx <- which(datTable$subjID==ss)
  n1 <- DT_trials_per_block[which(DT_trials_per_block==ss),]$N[1]
  b1 <-rep("1",n1)
  
  n2 <- DT_trials_per_block[which(DT_trials_per_block==ss),]$N[2]
  if (is.na(n2)) {
    cat(ss, " has only one block!\n")
    datTable[subidx]$block <- c(b1)
  } else {
    b2 <- rep("2",n2)
    datTable[subidx]$block <- c(b1,b2)
  }
}
datTable$block <- as.integer(datTable$block)

# Some nr formatting adjusts
datTable$response <- datTable$fb+1 # Responses 0 becomes 1 (incorrect) and 1 becomes 2 (correct)
datTable$aStim <- as.double(datTable$aStim)
datTable$vStim1 <- as.double(datTable$vStim1)
datTable$vStim2 <- as.double(datTable$vStim2)

# Because stimuli change in each block, give unique numbers for stimuli for each block
datTable[which(datTable$block==2),]$aStim = datTable[which(datTable$block==2),]$aStim + (stims_per_block)
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
value <- ifelse(datTable$response==2, 1, 0)
n_trials <- nrow(datTable)

#Count number of blocks
blocks <- aggregate(datTable$block ~ datTable$subjID, FUN = max )[2]
blocks <- blocks$`datTable$block`
ifelse(is.null(dim(blocks)),blocks<-as.array(blocks))

# Final list for STAN
# ----------------------------------------------------
datList <- list("N" = n_subj,
                "T"=n_trials,
                "RTbound" = RTbound,
                "minRT" = minRT, 
                "trial" = datTable$trial,
                "response" = datTable$response, 
                "stim_assoc" = datTable$aStim,
                "stim_nassoc" = datTable$vStimNassoc, 
                "RT" = datTable$RT, 
                "first" = first, 
                "last" = last,
                "value"=value, 
                "n_stims"=stims_per_block*blocks,
                "ntrials" = DT_trials$N) 

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

#Save 
#####################################
# Create folder with timeand date stamp
#destinationDir <- paste("Preproc_",n_subj,'ss',format(Sys.time(),'_%Y%m%d_%H%M'),sep="")

destinationDir <- paste(diroutput,"/Preproc_",n_subj,'ss',sep="")
dir.create(destinationDir)
setwd(destinationDir)
#R vars
save(datList,file="Preproc_list")
save(datTable,file="Preproc_data")
#csv file
write.csv(datTable,file="Preproc_data.csv",row.names = FALSE)
write(subjects,file="Preproc_subjects.txt")




 