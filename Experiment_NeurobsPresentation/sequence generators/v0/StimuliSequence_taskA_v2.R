rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr","cowplot","tidyr","psych","ggpubr","gridExtra")
lapply(Packages, require, character.only = TRUE)
#################################
# variables
sound  <- c(1:6)
symbol <- c(1:6)

nUniqueMatches <- length(sound)
nRepMatches <- 8

## Sound sequence  (avoid consecutive repetition)
# ----------------------------
seqSound <- rep(sound,nRepMatches)
seqSound <- sample(seqSound)
while (length(which(diff(seqSound)==0))>0){
  seqSound<- sample(seqSound)  #shuffle if there are consec repetitions
}

## Symbol sequences 
#-----------------------------
seqMatch <- seqSound #matching symbols have same code as sounds

seqMissmatch <- sample(seqMatch)
c <- 0 
while (length(which(c(seqMissmatch-seqMatch)==0))>0 | length(which(diff(seqMissmatch)==0))>0) { # constrains:different from the Match in a given trial and  no consec repetitions
  c <- c+ 1
  print(c + 1)
  seqMissmatch <- sample(seqMissmatch)
}

#------------------------------------------------------------
seq <-cbind(seqSound,seqMatch,seqMissmatch)


