# Patrick Haller, January 2020
# Adapted by David Willinger
##########################
# LOADING AND PREPARING  #
##########################

gather_data <- function(files){
  # summarize all data in 1 data frame
  datalist <- list()
  for (i in 1:length(files)){
    no_col <- max(count.fields(files[i], sep = "\t"))
    D <- read_delim(
      files[i],"\t", escape_double = FALSE, locale = locale(), trim_ws = TRUE)
    
    D <- cbind(subjID = rep(basename(dirname(files[i])),dim(D)[1]),D)
    datalist[[i]] <- D
  }
  transformed <- data.table::rbindlist(datalist) # combine all data frames in on
  return(transformed)
}


data_preprocess = function(datainput, masterfile) { 
  
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
  setwd(datainput)
  
  #Some starting info
  nblocks <- 2              
  ntrials <- 40             # trials per block
  stims_per_block <- 4      # number of stimuli to be learned per block
  RTbound <- 0.150         # set a limit for implausibly fast responses  (previously 150 ms)
  #files <- basename(dir(pattern=paste("*.4stim_.*",".txt",sep=""), recursive=TRUE))
  #files <-sapply(strsplit(files,"/"),"[",2) #take just filename without subject's directory
  taskpattern<- "FeedLearn_MRI"
  print('select subjects')
  # READ SUBJECTS LIST
  #--------------------------------------------------------------------
  T <- xlsx::read.xlsx(file = masterfile,sheetName= "Lists_subsamples") 
  selection <- menu(colnames(T),graphics=TRUE,title="Choose list")
  
  subjects  <- T[selection]
  subjects <- subjects[!is.na(subjects)]
  
  print(subjects)
  # select log/txt files from selected subjects
  #--------------------------------------------------------------------
  print('reading logs')
  files <- dir(pattern=paste("*.4stim_.*",".txt",sep=""), recursive=TRUE)
  files <- files[which(substr(files,1,6) %in% subjects)]  # take log files of those subjects
  
  print(files)
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
        #raw$vSymbolCorrect[ii]  <- substr(raw$vSymbols,which(jnk==raw$aStim[ii]),which(jnk==raw$aStim[ii]))
        
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
  input_data <- list("N" = n_subj,
                  "T"=n_trials,
                  "RTbound" = RTbound,
                  "minRT" = minRT, 
                  "iter" = datTable$trial,
                  "response" = datTable$response, 
                  "stim_assoc" = datTable$aStim,
                  "stim_nassoc" = datTable$vStimNassoc, 
                  "RT" = datTable$RT, 
                  "first" = first, 
                  "last" = last,
                  "value"=value, 
                  "n_stims"=stims_per_block*blocks,
                  "trials" = DT_trials$N,
                  "iter" = 1:n_trials) 
  
  dir.create('../preprocessed_task_performance/', showWarnings = FALSE)
  raw_data <- datTable
  save(input_data, file = "../preprocessed_task_performance/performance_data.Rda")
  save(raw_data, file = "../preprocessed_task_performance/raw_data.Rda")
  
  return(input_data)
  
}

data_preprocess_patrick = function(datainput, input){
  # this function either loads a pre-existing rds file containing
  # task performance data of the feedback learning task (load)
  # or preprocesses a new set of txt-files containing task performance
  # data from the feedback-learning task
  if(input == "load"){
    cat("loading existing rds file\n")
    source <- paste0(datainput, "/preprocessed_task_performance/")
    file <- dir(path = source,pattern="_list.rds")
    if(length(file)==1){
      rlddm_list <- readRDS(paste0(source,file))
      return(rlddm_list)
    }
    if(length(file)==0){
      cat("no file detected!\n")
    }
    else{
      cat("found more than 1 file!\n")
    }
  }
  if(input == "preprocess"){
    cat("preprocessing raw txt files\n")
    source <- paste0(datainput, "/raw_task_performance/")
    files <- dir(path = source, pattern="*.txt", recursive=TRUE)
    raw_data <- gather_data(paste0(source,files))
    
    block_correspondences <- read_csv(paste0(datainput,"/raw_task_performance/block_correspondences.csv"), col_names = TRUE)
    cat("block correspondences loaded")
    
    colnames(raw_data)[1] <- "subjID"
    raw_data$rt <- raw_data$rt/1000
    names(raw_data)[names(raw_data)=="rt"] <- "RT"
    
    DT_trials <- raw_data[, .N, by = subjID]
    subjs <- DT_trials$subjID
    n_subj    <- length(subjs)
    raw_data$block <- as.integer(raw_data$block)
    
    # reorder blocks with respect to presented order
    for (subj in subjs){
      sub <- which(raw_data$subjID==subj)
      correspondence <- block_correspondences[which(block_correspondences$subjID == subj),]
      if( NA %in% match(raw_data[sub,]$block,correspondence[2:3])){
        cat("No correspondence for subj ",correspondence$subjID)
        
      }
      else{
        raw_data[sub,]$block <- match(raw_data[sub,]$block,correspondence[2:3])
      }
    }
    
    raw_data <- raw_data[
      with(raw_data, order(subjID,block,trial)),
      ]
    
    # automatically filter missed responses (since RT = 0)
    raw_data <- raw_data[which(raw_data$RT > 0.15),]
    raw_data$trial <- as.integer(raw_data$trial)
    #raw_data$trial_subj <- rep("NA",nrow(raw_data))
    # since we discarded some observations, we have to assign new trial numbers 
    for (subj in subjs){
      sub <- which(raw_data$subjID==subj)
      raw_data[sub,]$trial <- seq.int(nrow(raw_data[sub,]))
    }
    
    DT_trials_per_block <- raw_data[, .N, by = list(subjID,block)]
    raw_data$block <- as.factor(raw_data$block)
    
    # # rename blocks
    # for (subj in subjs){
    #   sub <- which(raw_data$subjID==subj)
    #   n1 <- DT_trials_per_block[which(DT_trials_per_block==subj),]$N[1]
    #   b1 <-rep("1",n1)
    #   n2 <- DT_trials_per_block[which(DT_trials_per_block==subj),]$N[2]
    #   b2 <- rep("2",n2)
    #  
    #   raw_data[sub]$block <- c(b1,b2)
    # }
    # raw_data$block <- as.integer(raw_data$block)
    
    
    # raw data: fb = 0 incorrect, fb = 1 correct, (fb = 2 missed)
    # encoding for simulation: lower (incorrect) response=1, upper (correct) response =2 
    raw_data$response = raw_data$fb+1
    raw_data$aStim <- as.double(raw_data$aStim)
    # split vstim columns
    
    raw_data$vStim1 <- as.double(raw_data$vStim1)
    raw_data$vStim2 <- as.double(raw_data$vStim2)
    
    # assign every stimulus pair for each block a unique number
    raw_data[which(raw_data$block==2),]$aStim = raw_data[which(raw_data$block==2),]$aStim + 4
    raw_data[which(raw_data$block==2),]$vStim1 = raw_data[which(raw_data$block==2),]$vStim1 + 4
    raw_data[which(raw_data$block==2),]$vStim2 = raw_data[which(raw_data$block==2),]$vStim2 + 4
    
    raw_data$vStimNassoc <- ifelse(raw_data$aStim==raw_data$vStim1,raw_data$vStim2,raw_data$vStim1)
    
    DT_trials <- raw_data[, .N, by = subjID]
    
    # get minRT
    minRT <- with(raw_data, aggregate(RT, by = list(y = subjID), FUN = min)[["x"]])
    ifelse(is.null(dim(minRT)),minRT<-as.array(minRT))
    
    
    first <- which(raw_data$trial==1)
    # if N=1 transform int to 1-d array
    first<-as.array(first)
    # last is a Sx1 matrix identifying all last trials of a subject for each choice
    last <- (first + DT_trials$N - 1)
    # if N=1 transform int to 1-d array
    last<-as.array(last)
    # define the values for the rewards: if upper resp, value = 1
    value <- ifelse(raw_data$response==2, 1, 0)
    n_trials <- nrow(raw_data)
    
    #blocks <- tapply(raw_data$block,raw_data$subjID, max,simplify = TRUE)
    raw_data$block <- as.integer(raw_data$block)
    blocks <- aggregate( raw_data$block ~ raw_data$subjID, FUN = max )
    blocks <- blocks$`raw_data$block`
    # if N=1 transform int to 1-d array
    ifelse(is.null(dim(blocks)),blocks<-as.array(blocks))
    trials_per_subject <- DT_trials$N
    
    stims_per_block <- 4
    input_data <- list("N" = n_subj, "T"=n_trials,"RTbound" = 0.15,"minRT" = minRT, "iter" = raw_data$trial, "response" = raw_data$response, 
                "stim_assoc" = raw_data$aStim, "stim_nassoc" = raw_data$vStimNassoc, "RT" = raw_data$RT, "first" = first, "last" = last, "value"=value, 
                "n_stims"=stims_per_block*blocks, "trials"=trials_per_subject)  # names list of numbers
    cat("done preprocessing...\n")
    save(input_data, file = "data/preprocessed_task_performance/pilots_performance_data.Rda")
    save(raw_data, file = "data/preprocessed_task_performance/raw_data.Rda")
    
    cat("wrote preprocessed data as Rda file\n")
    
    return(input_data)
  
    }
  
}
