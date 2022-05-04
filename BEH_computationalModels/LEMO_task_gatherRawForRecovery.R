#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","BH")
lapply(Packages, require, character.only = TRUE)
#=====================================================================================
# GATHER DATA  + FORMAT FOR MODEL (in STAN)
#=====================================================================================
# - Read task logs used in MRI analysis
# - Concatenate all text files (given they have 40 trials)
# - Trim trials with no response ("too slow trials")
# - Select columns and code new ones needed for model in Stan
# - Save formatted and gathered data as txt file
# REFS: e.g. From Pederson et al.,2017 https://github.com/gbiele/RLDDM/blob/master/RLDDM.jags.txt 
#--------------------------------------------------------------------------------------------
#set dirs
task <- 'fbl_B'
logfolder <-  paste0('O:/studies/grapholemo/analysis/LEMO_GFG/mri/preprocessing/',task,'/')
firstlevelfolder <- paste0('O:/studies/grapholemo/analysis/LEMO_GFG/mri/1stLevel/FeedbackLearning/',task,'/')
diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/beh/modeling/'
masterfile  <- "O:/studies/grapholemo/LEMO_Master.xlsx" # use this to find your subjects
#Some initial info
nblocks <- 2              
ntrials <- 48             # trials per block
stims_per_block <- 6      # number of stimuli to be learned per block
 
# Find log files
files <- dir(logfolder,'*.txt$',all.files=T,recursive=TRUE) %>% .[grep("*logs*",.)]
# find subject IDs, assuming the 2nd subfolder level firstlevelfolder are the subject IDs
subjects <- dir(firstlevelfolder,pattern='*spmT.*.nii',recursive=T) %>% strsplit(.,split = "/") %>% sapply(.,'[',2) %>% unique(.) %>% .[grep('^gpl*',.)]
selectedfiles <- files[which(sapply(strsplit(files,'/'),'[',1) %in% subjects )] 

if (length(selectedfiles)==0){ 
  stop('no files were selected.Check again.EXECUTION STOPS')
  
}else{ 
  
  for (ss in 1:length(subjects)){
    if (length(grep(subjects[ss], selectedfiles))){ 
      print(paste0(subjects[ss],' has 2 blocks '))}
    else {
      print(paste0(subjects[ss],' has ', length(grep(subjects[ss], selectedfiles)),  'blocks '))
    }
    
  }
  
  # Gather all data before preprocessing
  # ------------------------------------
  datalist <- list()
  for (f in 1:length(files)){
    raw <- read_delim(paste0(logfolder,'/',files[f]),"\t", escape_double = FALSE, locale = locale(), trim_ws = TRUE)
    # Exclude unnecessary columns inconsistent between files : "Fbtype "in first 5 files  and 'leftismatch' in the rest
    if (any(grepl('FBtype',colnames(raw)))){ 
      raw <- raw[,-which(names(raw)=='FBtype')]
      #correct shifted column names
      colnames(raw)[which(colnames(raw)=='vSymbol')] <- 'aFile'
      colnames(raw)[grep('aFile',colnames(raw))[2]] <- 'vSymbol'
    }
    if (any(grepl('LeftIsMatch',colnames(raw)))){ raw <- raw[,-which(names(raw)=='LeftIsMatch')]}
    
    # Check trials
    if (dim(raw)[1] > ntrials) {
      raw <-  raw[7:dim(raw)[1],] # in task B the first 6 rows are junk from practice trials
    }
    if (dim(raw)[1] != ntrials) {cat(files[f]," does not have ",ntrials, "!! script STOPS.\n")
      break  }
    
    # Add subject info to table 
    raw$subjID <- sapply(strsplit(files[f],'/'),'[',1)
    raw <- relocate(raw, 'subjID') # 
    
    datalist[[f]] <- raw
  }
  # quick check for table size consistency 
  if (length(which(diff(sapply(datalist,function(x) nrow(x)))!=0))==0){print('OK. Tables n rows consistent')} else { print('table n rows differ!')}
  if (length(which(diff(sapply(datalist,function(x) ncol(x)))!=0))==0){print('OK. Tables n cols consistent')} else { print('table n cols differ!')}
  
  # combine all data frames in on
  rawG <- data.table::rbindlist(datalist) 
  
  # Format gathered data for Stan
  # ----------------------------------------------------
  colnames(rawG)[1] <- "subjID"
  rawG$rt <- rawG$rt/1000
  names(rawG)[names(rawG)=="rt"] <- "RT"
  
  # Remove response trials with too quick responses

  datTable <- data.table(rawG)
  datTable$response <- datTable$fb
  datTable$trial<-as.integer(datTable$trial)
  
  #Count of trials per subject 
  DT_trials <- datTable[,.N,by = subjID]
  subjs <- DT_trials$subjID
  n_subj    <- length(subjs) 
  
  
  # recode blocks (so for all subjects they are 1 and 2,or 1)
  DT_trials_per_block <- datTable[, .N, by = list(subjID,block)]
  datTable$sourceBlock <- as.factor(datTable$block)
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
  
  
  #correction by Patrick ######################
  # add trials per block to data frame
  iter <- vector()
  DT_trials_per_block <- datTable[, .N, by = list(subjID,block)]
  for(i in 1:length(DT_trials_per_block$N)){
    iter <- append(iter,(seq.int(1,DT_trials_per_block[i,]$N)))
  }
  datTable$iter <- iter
  
  trials_block <- vector()
  for(i in 1:length(DT_trials_per_block$N)){
    trials_block <- append(trials_block,(rep(DT_trials_per_block[i,]$N,DT_trials_per_block[i,]$N)))
  }
  #####################################
  
  
  # Some nr formatting adjusts
  datTable$response <- datTable$fb+1 # Responses 0 becomes 1 (incorrect) and 1 becomes 2 (correct)
  datTable$aStim <- as.double(datTable$aStim)
  datTable$vStim <- as.double(datTable$vStim)
  
  
  # Because stimuli change in each block, give unique numbers for stimuli for each block
  datTable[which(datTable$block==2),]$aStim = datTable[which(datTable$block==2),]$aStim + (stims_per_block)
  datTable[which(datTable$block==2),]$vStim = datTable[which(datTable$block==2),]$vStim + (stims_per_block)
  
  
  #Log in each trial which v-stimuli is correctly mapped to audio and which not
  datTable$vStimNassoc <- ifelse(datTable$aStim==datTable$vStim, datTable$aStim,datTable$vStim)
  datTable$vStimAssoc <- datTable$aStim
  
  # get minRT per subject
  minRT <- with(datTable, aggregate(RT, by = list(y = subjID), FUN = min)[["x"]])
  ifelse(is.null(dim(minRT)),minRT<-as.array(minRT))
  
  # Get index of first and last trial per subject 
  first <- as.double(which(datTable$trial==1))
  first<-as.array(first)  # if N=1 transform int to 1-d array
  last <- (first + DT_trials$N - 1)   # Sx1 matrix identifying all last trials of a subject for each choice
  last <-as.array(last)  # if N=1 transform int to 1-d array
  
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
                  "T"=n_trials, #T  (1 number: total count of trials)
                  "RTbound" = 0,   #RTbound 	(minimum RT allowed)
                  "minRT" = minRT,   #minRT 	(minimum RT per subject)
                  "iter" = datTable$iter, #iter 	(trial indexes per subject, across blocks)
                  "response" = datTable$response,    #response	 (response incorrect 1, correct 2)
                  "stim_assoc" = datTable$aStim,  #stim_assoc  	(auditory stimuli,  or correct vstim)
                  "stim_nassoc" = datTable$vStimNassoc,   #stim_nassoc 	(incorrect visual stimuli in a trial)
                  "RT" = datTable$RT,   #RT 	( reaction time in sec)
                  "first" = first,   #First	(first trial in each subject, across blocks)
                  "last" = last,  #last 	(last trial in each subject, across blocks)
                  "value"=value,   #value	('reward' 0 or 1)
                  "n_stims"=stims_per_block*blocks,  #n_stims	 (number blocks x 4 stim per block )
                  "trials" = trials_block) 
  
  
}
#Save 
#####################################
# Create folder with time and date stamp
destinationDir <- paste0(diroutput,task,"_rawForParamRecovery_n",length(subjects))
dir.create(destinationDir)
setwd(destinationDir) # go destination
#R vars
save(datList,file="raw_list.rda")
save(datTable,file="raw_data.rda")
#csv files for additional checks
write.csv(datTable,file="raw_data.csv",row.names = FALSE)
write(subjects,file="Preproc_subjects.txt")
write(paste0(logfolder,'/',files),file="Names_source_files.txt")

#make a copy of the source files in destination
newdir <- paste0(destinationDir,"/Copy_source_files/")
dir.create(newdir)
file.copy(paste0(logfolder,'/',files), newdir)

