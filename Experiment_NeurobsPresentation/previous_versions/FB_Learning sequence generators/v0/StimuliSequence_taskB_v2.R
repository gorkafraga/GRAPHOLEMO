rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr","cowplot","tidyr","psych","ggpubr","gridExtra")
lapply(Packages, require, character.only = TRUE)
#################################
# variables
marker <- c(1:3) # 1 = extends phoneme 2 = adds phoneme 'sch'. 3 = changes phoneme
sound  <- c(1:6)
symbol <- c(1:3)

nUniqueMatches <- length(sound)
nRepMatches <- 8

## Sound sequence  (avoid consecutive repetition)
# ----------------------------
seqSound <- rep(sound,nRepMatches)
seqSound <- sample(seqSound)
while (length(which(diff(seqSound)==0))>0){
  seqSound<- sample(seqSound)  #shuffle if there are consec repetitions
}

##  Matched pairs sequence
#-----------------------------
seqMatch <- rep(0,length(seqSound))
for (i in 1:length(seqMatch)){
  if (seqSound[i]==1) { seqMatch[i] <- 11      # assign predetermined code (1 number is symbol, 2 number is marker) depending on the sound in a given trial
  }else if(seqSound[i]==2) {seqMatch[i] <- 13
  }else if(seqSound[i]==3) {seqMatch[i] <- 21
  }else if(seqSound[i]==4) {seqMatch[i] <- 22
  }else if(seqSound[i]==5) {seqMatch[i] <- 32
  }else if(seqSound[i]==6) {seqMatch[i] <- 33
  }
}
# Note: use the function "table(seqMatch)" to count frequencies

## Mismatched pairs sequence
#-----------------------------
allcombis <- expand.grid(symbol,marker) # all possible combinations between symbols and markers 
allcombis <-  as.numeric(paste(allcombis[,1],allcombis[,2],sep="")) # as 2 digits number vector

seqMissmatch <- rep(allcombis,(nRepMatches*nUniqueMatches)/length(allcombis)) #repeat all possible combinations until completing the number of trials in sequence
if(length(seqMissmatch)!=length(seqSound)) {                 }
seqMissmatch <- c(seqMissmatch,allcombis[1:(length(seqSound)-length(seqMissmatch))])  #repeat some combinations if it has too little n trials, until seqmissmatch has same length as seqMatch

c <- 0 
# Shuffle the missmatch pairs if (1) There are two consecutive repetions OR (2) the pair in the missmatch in a given trial is the same as the one in the match array
while (length(which(diff(seqMissmatch)==0))>0 || length(which((seqMatch-seqMissmatch)==0))>0) { #
  c <- c+ 1
  print(c + 1)
  seqMissmatch <- sample(seqMissmatch)
}

seq <-cbind(seqSound,seqMatch,seqMissmatch)

## COUNT specific type of trials
#-----------------------------------------
sameSymbol <-  which(as.numeric(substr(seqMatch,1,1))-as.numeric(substr(seqMissmatch,1,1))==0)
sameMarker <-  which(as.numeric(substr(seqMatch,2,2))-as.numeric(substr(seqMissmatch,2,2))==0)

