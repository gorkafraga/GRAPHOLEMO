# -----------------------------------------------------------------
# Summarize LEMO task performance 
# - Gather logs from your fMRI preprocessing folder 
# - Compute performance summary per quartile and thirds
# - Save data set in long and wide formats for later analysis
# ----------------------------------------------------------------
#Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr","cowplot","tidyr","psych","ggpubr","gridExtra","xlsx")
lapply(Packages, require, character.only = TRUE)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")


#set ins and outs
task <- "FBL_B"
dirinput <-"O:/studies/grapholemo/analysis/LEMO_GFG/mri/preprocessing" # no  / at the end 
diroutput <-paste0("O:/studies/grapholemo/analysis/LEMO_GFG/beh/")
ntrials <- 48
plotme <- 0
morestats <- 0 

# find files 
setwd(dirinput)
files <-dir(dirinput,paste0('gpl.*.-',task,'.*.txt'),recursive=TRUE,ignore.case = TRUE,full.names = FALSE)

# optional subject selection (previous versions)
  #`%!in%` = Negate(`%in%`) 
  #files <- files[which(substr(files,1,6) %!in% c("AR1025","AR1063"))] # use this to exclude subjects
  #files <- files[which(substr(files,1,6) %in% c("AR1025","AR1063"))] # use tthis to include subjects from a list of subjects
  #subjects <- subjects[which(subjects %!in% c("AR1025","AR1063"))] # use this to exclude subjects

# gather all logs, add basic summary stats ------------------------------------
dataList<-list()
cumuList<-list()
for (i in 1:length(files)){
  #Read File 
  D <- read_delim(paste0(dirinput,'/',files[i]),"\t", escape_double = FALSE, locale = locale(), trim_ws = TRUE, skip_empty_rows=TRUE)
  subject <- substr(sapply(strsplit(files[i],"/"), `[`,6),1,6) #subject ID are the 6 first characters from filename,i.e., last element after splitting fullpath name...
  
  if (any(grepl('FBtype',colnames(D)))){ 
    D <- D[,-which(names(D)=='FBtype')]
    #correct shifted column names
    colnames(D)[which(colnames(D)=='vSymbol')] <- 'aFile'
    colnames(D)[grep('aFile',colnames(D))[2]] <- 'vSymbol'
  }
  
  if (any(grepl('LeftIsMatch',colnames(D)))){ D <- D[,-which(names(D)=='LeftIsMatch')]}
  
  # Check trials
  if (dim(D)[1] > ntrials) {
    D <-  D[7:dim(D)[1],] # in task B the first 6 rows are junk from practice trials
  }
  
  if (dim(D)[1] != ntrials) {cat(files[f]," does not have ",ntrials, "!! script STOPS.\n")
    next
  } else {
    cat("File OK (",dim(D)[1]," trials)","\nProceeding with ",files[i],"...\n")
    
    # Get indexes per feedback (b) /response type.
    idx_miss <- which(D$fb==2)
    idx_hit <- which(D$fb==1)
    idx_err <- which(D$fb==0)
    # add a column with a response type label
    D$respType <- 0
    D$respType[idx_miss] <- 'miss'
    D$respType[idx_hit] <- 'hit'
    D$respType[idx_err] <- 'error'  
    D$respType <- as.factor(D$respType)
    
    # # Gather counts per respType per stimuli
     hits_per_sound <-  D %>% 
       filter(fb==1) %>%
       group_by(aStim,.drop = FALSE) %>%
       tally() 
     errors_per_sound <-  D %>% 
       filter(fb==0) %>%
       group_by(aStim,.drop = FALSE) %>%
       tally() 
     miss_per_sound <-  D %>% 
       filter(fb==2) %>%
       group_by(aStim,.drop = FALSE) %>%
       tally() 
     
    
    # Gather cumulative probability per stimuli
    D$fbmin <- D$fb   
    D$fbmin[which(D$fbmin==0)] <- -1
    D$fbmin[which(D$fbmin==2)] <- 0
    tmplist <- split(D,D$aStim) # split by audio type
    for (ii in 1:length(tmplist)) {
      cumSum <- tmplist[[ii]] %>%  select(fbmin) %>% cumsum() # apply cumsum function to fb column 
      tmplist[[ii]]$cumSum <- cumSum
    }
    cumsums <- as.data.frame(unlist(lapply(tmplist,"[[",max(lengths(tmplist))))) #extract last column from the list and unlist
    cumsums <- cbind(separate(data = as.data.frame(rownames(cumsums)),col=1,into = c("stim","rep")),cumsums) # rearrange as data frame 
    colnames(cumsums) <- c("stim","rep","value")
    cumsums$rep  <- as.numeric(gsub("fbmin","",cumsums$rep))
    cumsums$stim <- as.factor(cumsums$stim)
    rownames(cumsums) <- c()
    cumuScore <- cbind(rep(subject,dim(D)[1]),D$block,cumsums)
    colnames(cumuScore)[1:2] <- c("subjID","block")
    colnames(cumuScore)<- paste0('ProbCum_',colnames(cumuScore))
    colnames(cumuScore)[1] <- c("subjID")
    
    cat("cumulative scores calculated\n")
    
    # Separate the data in quartile
    D$quartile <- unlist(lapply(seq(dim(D)[1]/(dim(D)[1]/4)),rep,(dim(D)[1]/4)))
    D$third <- unlist(lapply(seq(dim(D)[1]/(dim(D)[1]/3)),rep,(dim(D)[1]/3)))
    
    
    D2save <- cbind(rep(subject,dim(D)[1]),D)
    colnames(D2save)[1] <- "subjID"
    dataList[[i]]<- D2save
    cumuList[[i]]<- cumuScore
  }  

}    
#  
# Merge in a single Table  
DAT <- data.table::rbindlist(dataList,fill=TRUE) 
CUMU <- data.table::rbindlist(cumuList,fill=TRUE)
write.csv(CUMU,paste(diroutput,"/",task,"_cumulative_probabilities.csv",sep=""),row.names = FALSE,na = "")


 
# Accu summary
accu <- DAT %>%  group_by(subjID,block,fb,quartile,.drop = FALSE) %>%  tally()
rt <- DAT %>%  group_by(subjID,block,fb,quartile,.drop = FALSE) %>% summarize(meanRT = mean(rt))
dlong <- merge(accu,rt,by=c('subjID','block','fb','quartile'))
dlong$meanRT <- round(dlong$meanRT,2)
dlong$count <- dlong$n
dlong$proportionPerQuartile <- round(dlong$n/(ntrials/4),2)

accuThirds <- DAT %>%  group_by(subjID,block,fb,third,.drop = FALSE) %>%  tally()
rtThirds <- DAT %>%  group_by(subjID,block,fb,third,.drop = FALSE) %>% summarize(meanRT = mean(rt))
dlongThirds <- merge(accuThirds,rtThirds,by=c('subjID','block','fb','third'))
dlongThirds$meanRT <- round(dlongThirds$meanRT,2)
dlongThirds$count <- dlongThirds$n
dlongThirds$proportionPerThird<- round(dlongThirds$n/(ntrials/3),2)

###
dlongFull <-dlong %>% complete(subjID,nesting(block,fb,quartile),fill = list(n = 0)) # Make explicit the missing values ! nw length should be nsubjects x blocks x quartile x fb 
dlongFull$third <- NA
dlongFull$proportionPerThird <- NA

dlongFullThirds <-dlongThirds %>% complete(subjID,nesting(block,fb,third),fill = list(n = 0))
dlongFullThirds$quartile <- NA
dlongFullThirds$proportionPerQuartile <- NA

# MERGE,  add task identifier  and save 
#dlongmerged <-
dlongmerged <- rbind(dlongFull,dlongFullThirds)
dlongmerged$task  <- task
dlongmerged$subjID<-tolower(dlongmerged$subjID)
write.csv(dlongmerged,paste(diroutput,"/",task,"_Performance_long.csv",sep=""),row.names = FALSE,na="")
 


########## simplify and convert to wide format
long1 <- dlongmerged[which(dlongmerged$fb==1),c('subjID','block','quartile','third','proportionPerQuartile','proportionPerThird','count','meanRT')] 
long1$quartile <- paste0('q',long1$quartile)
long1$third <- paste0('t',long1$third)
long1$block <- paste0('b',long1$block)
wide <- pivot_wider(long1,names_from = c('block','quartile','third'),values_from = c('meanRT','proportionPerQuartile','proportionPerThird','count'))
wide$subjID<-tolower(wide$subjID)

names(wide) <- paste(gsub('_','',task),names(wide),sep='_')
# remove useless columns 
wide <- wide[,!grepl('*.proportionPerThird.*tNA',names(wide))]
wide <- wide[,!grepl('*.proportionPerQuartile.*qNA',names(wide))]
names(wide)<-gsub('_tNA','',names(wide))
names(wide)<-gsub('qNA_','',names(wide))
#

write.csv(wide,paste(diroutput,"/",task,"_Performance_wide.csv",sep=""),row.names = FALSE,na = "")

 