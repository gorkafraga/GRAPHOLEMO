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
dirinput <- "O:/studies/grapholemo/Allread_FBL/Logs"
diroutput <- "O:/studies/grapholemo/Analysis/models"
setwd(dirinput)
#Some starting info
nblocks <- 3 #number of blocks
ntrials <- 40   # number of trials per block
stims_per_block <- 4 # number of stimuli to be learned per block
RTbound <- 0.15 #set a limit to 'too fast' responses
files <- dir(pattern=paste("*.4stim_.*",".txt",sep=""), recursive=TRUE)
taskpattern<- "FeedLearn_MRI"

# Sanity check! Check that subjects have more than nblocks blocks
#--------------------------------------------------------------------
subjects <- files    
for (i in 1:length(files)){
  subjects[i] <-substr(files[i],1,(regexpr(taskpattern,files[i])[[1]]-2)) # find pattern of task and take preceding characters
}
subjects <- unique(subjects)
nsubjects <- length(unique(subjects))
for (j in 1:length(unique(subjects))){
  if  (length(grep(subjects[j],files))>nblocks) {  cat(subjects[j]," has more than",nblocks," blocks!\n") }
  else { cat(subjects[j],"is OK. n blocks =",length(grep(subjects[j],files)),"\n")           }
}
# Gather all data 
# -------------------
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
  ssInf <- rep(substr(files[f],1,(regexpr(taskpattern,files[f])[[1]]-2)),dim(raw)[1])
  datalist[[f]] <- cbind(ssInf,raw)
}
rawG <- data.table::rbindlist(datalist) # combine all data frames in on



# Format gathered data for Stan
# ----------------------------------------------------
colnames(rawG)[1] <- "subjID"
rawG$rt <- rawG$rt/1000
names(rawG)[names(rawG)=="rt"] <- "RT"

# Remove response trials and too quick responses
T <- filter(rawG,fb!=2)
T <- filter(T,RT>RTbound)
T <- data.table(T)
T$response <- T$fb
T$trial<-as.integer(T$trial)
#Count of trials per subject 
DT_trials <- T[,.N,by = subjID]
subjs <- DT_trials$subjID
n_subj    <- length(subjs)
# Reasign trial index (we excluded observations)
for (ss in subjs){
  subidx <- which(T$subjID==ss)
  T[subidx,]$trial <- seq.int(nrow(T[subidx,]))
}

# recode blocks (so for all subjects they are 1 and 2,or 1)
DT_trials_per_block <- T[, .N, by = list(subjID,block)]
T$block <- as.factor(T$block)
for (ss in subjs){
  subidx <- which(T$subjID==ss)
  n1 <- DT_trials_per_block[which(DT_trials_per_block==ss),]$N[1]
  b1 <-rep("1",n1)
  
  n2 <- DT_trials_per_block[which(DT_trials_per_block==ss),]$N[2]
  if (is.na(n2)) {
    cat(ss, " has only one block!\n")
    T[subidx]$block <- c(b1)
  } else {
    b2 <- rep("2",n2)
    T[subidx]$block <- c(b1,b2)
  }
}
T$block <- as.integer(T$block)

# Some nr formatting adjusts
T$response <- T$fb+1 # Responses 0 becomes 1 (incorrect) and 1 becomes 2 (correct)
T$aStim <- as.double(T$aStim)
T$vStim1 <- as.double(T$vStim1)
T$vStim2 <- as.double(T$vStim2)
# Because stimuli change in each block, give unique numbers for stimuli for each block
T[which(T$block==2),]$aStim = T[which(T$block==2),]$aStim + (stims_per_block)
T[which(T$block==2),]$vStim1 = T[which(T$block==2),]$vStim1 + (stims_per_block)
T[which(T$block==2),]$vStim2 = T[which(T$block==2),]$vStim2 + (stims_per_block)

#Log in each trial which v-stimuli is correctly mapped to audio and which not
T$vStimNassoc <- ifelse(T$aStim==T$vStim1,T$vStim2,T$vStim1)
# get minRT per subject
minRT <- with(T, aggregate(RT, by = list(y = subjID), FUN = min)[["x"]])
ifelse(is.null(dim(minRT)),minRT<-as.array(minRT))

# Get index of first and last trial per subject 
first <- as.double(which(T$trial==1))
# if N=1 transform int to 1-d array
first<-as.array(first)
# last is a Sx1 matrix identifying all last trials of a subject for each choice
last <- (first + DT_trials$N - 1)
# if N=1 transform int to 1-d array
last<-as.array(last)
# define the values for the rewards: if upper resp, value = 1
value <- ifelse(T$response==2, 1, 0)
n_trials <- nrow(T)

#Count number of blocks
blocks <- aggregate(T$block ~ T$subjID, FUN = max )[2]
blocks <- blocks$`T$block`
ifelse(is.null(dim(blocks)),blocks<-as.array(blocks))

# Final list for STAN
# ----------------------------------------------------
dat <- list("N" = n_subj, "T"=n_trials,"RTbound" = 0.15,"minRT" = minRT, 
            "iter" = T$trial, "response" = T$response, 
            "stim_assoc" = T$aStim, "stim_nassoc" = T$vStimNassoc, 
            "RT" = T$RT, "first" = first, "last" = last, "value"=value, 
            "n_stims"=stims_per_block*blocks)

#save list as file to read later
setwd(diroutput)
save(dat,file="Gathered_list_for_Stan")
save(T,file="Gathered_data")



 