rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr","cowplot","tidyr","psych","ggpubr","gridExtra","writexl")
lapply(Packages, require, character.only = TRUE)
#################################
diroutput<- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/Experiment_NeurobsPresentation/sequence generators/v1"
ntrials <- 48
nblocks <- 4 
seqs <- list()
for (b in 1:nblocks){
 
    seq<- rep(0,ntrials)
    seqSound <- sample(seqSound)
    while (length(which(diff(seqSound)==0))>0){
      seqSound<- sample(seqSound)  #shuffle if there are consec repetitions
    }
    
    ## Symbol sequences 
    #-----------------------------
    seqMatch <- seqSound #matching symbols have same code as sounds
    seqMissmatch <- rep(1:(length(sound)+2),nRepMatches-2) # mismatch sequence contains 2 additional distractors
    
    
    seqMissmatch <- sample(seqMissmatch)
    c <- 0 
    #while (length(which(diff(seqMissmatch)==0))>0) { # constrains:different from the Match in a given trial and  no consec repetitions
    while (length(which(c(seqMissmatch-seqMatch)==0))>0 | length(which(diff(seqMissmatch)==0))>0) { # constrains:different from the Match in a given trial and  no consec repetitions
      c <- c+ 1
      print(c + 1)
      seqMissmatch <- sample(seqMissmatch)
    }
    
    # Combine ------------------------------------------------------------
    seq <-cbind(seqSound,seqMatch,seqMissmatch)
    seqs[[b]]<-as.data.frame(seq)
    
}

# Save each sequence in one sheet
setwd(diroutput)
for (i in 1:length(seqs)){
    xlsx::write.xlsx(seqs[[i]],'Seqs_taskA.xlsx',sheetName=paste0('Block',i),row.names = FALSE,append = TRUE)
}
