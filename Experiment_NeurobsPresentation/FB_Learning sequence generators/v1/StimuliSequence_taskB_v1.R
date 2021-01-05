rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr","cowplot","tidyr","psych","ggpubr","gridExtra","raster")
lapply(Packages, require, character.only = TRUE)
#################################

diroutput<- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/Experiment_NeurobsPresentation/sequence generators/v1"


nblocks <- 4 
seqs <- list()
for (b in 1:nblocks){
    
    
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
      if (seqSound[i]==1) { seqMatch[i] <- 11      # assign predetermined code (1st number is symbol, 2nd number is marker) depending on the sound in a given trial
      }else if(seqSound[i]==2) {seqMatch[i] <- 13
      }else if(seqSound[i]==3) {seqMatch[i] <- 21
      }else if(seqSound[i]==4) {seqMatch[i] <- 22
      }else if(seqSound[i]==5) {seqMatch[i] <- 32
      }else if(seqSound[i]==6) {seqMatch[i] <- 33
      }
    }
    # Note: use the function "table(seqMatch)" to count frequencies
    
    ## Mismatched pairs sequence with additional distractor (coded as 4) 
    #-----------------------------
    
    allcombis <- as.numeric(unlist(unite(expand.grid(c(symbol,4),c(marker,4)),"",sep="",remove=TRUE)))
    seqMissmatch <-  rep(allcombis,(nRepMatches*nUniqueMatches)/length(allcombis))#repeat all possible combinations until completing the number of trials in sequence
    if(length(seqMissmatch)!=length(seqSound)) {                 }
    #seqMissmatch <- c(seqMissmatch,allcombis[1:(length(seqSound)-length(seqMissmatch))])  #repeat some combinations if it has too little n trials, until seqmissmatch has same length as seqMatch
    c <- 0 
    # Shuffle the missmatch pairs if (1) There are two consecutive repetions OR (2) the pair in the missmatch in a given trial is the same as the one in the match array
    while (length(which(diff(seqMissmatch)==0))>0 || length(which((seqMatch-seqMissmatch)==0))>0) { #
      c <- c+ 1
      print(c + 1)
      seqMissmatch <- sample(seqMissmatch)
    }
    
    ## Manual adding of Distractors (test)
    # Adding distractors Symbols to mismatch sequence (replace one trial from each symbol )
    #seqMissmatch[sample(which(seqMissmatch == '11'),2)] <- c(41,14)
    #seqMissmatch[sample(which(seqMissmatch == '12'),2)] <- c(42,14)
    #seqMissmatch[sample(which(seqMissmatch == '13'),2)] <- c(43,14)
    
    #seqMissmatch[sample(which(seqMissmatch == '21'),2)] <- c(41,24)
    #seqMissmatch[sample(which(seqMissmatch == '22'),2)] <- c(42,24)
    #seqMissmatch[sample(which(seqMissmatch == '23'),2)] <- c(43,24)
    
    #seqMissmatch[sample(which(seqMissmatch == '31'),2)] <- c(41,34)
    #seqMissmatch[sample(which(seqMissmatch == '32'),2)] <- c(42,34)
    #seqMissmatch[sample(which(seqMissmatch == '33'),2)] <- c(43,34)
    
    
    # COMBINE and SAVE ################################################
    seq <-cbind(seqSound,seqMatch,seqMissmatch)
    seqs[[b]]<-as.data.frame(seq)
    
}    
    
    setwd(diroutput)
    for (i in 1:length(seqs)){
      xlsx::write.xlsx(seqs[[i]],'seqs_taskB.xlsx',sheetName=paste0('Block',i),row.names = FALSE,append = TRUE)
    }


## COUNT specific type of trials
#-----------------------------------------
#sameSymbol <-  which(as.numeric(substr(seqMatch,1,1))-as.numeric(substr(seqMissmatch,1,1))==0)
#sameMarker <-  which(as.numeric(substr(seqMatch,2,2))-as.numeric(substr(seqMissmatch,2,2))==0)

