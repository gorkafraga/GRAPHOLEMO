# Make grand averages and export normalized spectra and  SNR, Baseline corrected amplitudes, Z scores from normalized spectra
#======================================================================================================================
# Export a .csv file per channel: Subjects as rows, data point as columns
# First row contains the frequencies
#------------------------------------------------------------------------------------------------------------------------------
# Clear all variables
rm(list=ls(all=TRUE))
#Load
library(tictoc)
library(tibble)
library(data.table)
library(svDialogs)
library(ggplot2)
source('N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/scripts_FPVS_GFG/FPVS_betafunction_computeMeasures.R')

# Define input directories and go to input dir
dirinput <- c("N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/a_data_test")
diroutput <- c("N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/a_data_test")



# Define some data and FFT parameters
srate <- 512
durSecs <-40 # length of recording in sec (strings: 40s, AV: 54.82 s, LinPL: 53.3)
ntimepoints <- srate * (durSecs/2)
freqresol <-0.025
freqs <- seq(0,srate/2,freqresol)
freqs <-freqs[1:length(freqs)-1]

# Files   
files<- dir(dirinput,pattern=paste("*.txt$",sep="")) 
  
  #[1] Gather all subjects for this condition with their ID
  ############################################################
  allsubjects<-list()
  allsubjectsID<-list()
  tic()
  for (f in 1:length(files)){
    # Read data, trim out electrode labels (2 cols) and use them as rownames. Colnames are frequency bins labels
    
    fileinput <- files[f]
    raw <- as.data.frame(data.table::fread(paste0(dirinput,'/',files[f]),quote = "/"))
    dat <- raw[1:129,] # exclude last two channel (always LOT, ROT)
    
    # Rename channels 1:129, format with leading 0s (exclude last two electrodes which are always ROT, LOT). The order in the rest may change due to interpolation 
    currentChans <- dat[,2]
    currentChans[which(currentChans=='Cz')] <- '000' #rename Cz to prevent errors in the next line
    currentChans <-sprintf("%03d",as.numeric(currentChans)) # add leading zeros to scalp channels with numeric labels
    currentChans[which(currentChans=='000')] <- 'Cz' # name it back as Cz
    rownames(dat) <- currentChans
    dat[,2] <-currentChans
    if (f ==1){
      chanlabels<-currentChans # use the first dataset as reference for channel labels
    }
    
    #IMPORTANT: sort rows according to your channels in ascending order so all files have the same 
    dat<- dat[order(dat[,2],decreasing=FALSE),]
    
    # Trim channel info so only numbers are kept
    dat<- dat[,3:ncol(dat)]
    colnames(dat) <- freqs 
    
    #add to group lists
    allsubjects[[f]] <- dat
    allsubjectsID[[f]] <-substr(fileinput,1,4)
    
  }
  toc()
  
  #[2] Compute grand averages and [3] call function to compute frequency-based measures(SNR,Z,etc)
  #############################################################################################
   
  measurenames <-  c('specmeans','specNorm','zscores','bcAmps','snr')
  
  # For each channel: 
  #1)gather all subjects in a table
  # 2) Compute the average of those subjects or a selection of them 
  # 3) After averaging subjects run function to extract all measure
  # 4) Each grand average will be a list of length = n channels, each list element will have a table with all measures for that channel
  
  tic()
  nchans <-nrow(allsubjects[[1]])
  GA_all<-list()
  for (ch in 1:nchans) {
    print(ch)
    ch_allSubj <- data.table::rbindlist(lapply(allsubjects,'[',ch,1:ntimepoints))
    # Averages  
    specmeans<- colMeans(ch_allSubj)
    # CALL FUNCTION
    betacomputeMeasures(specmeans)
    
    # Fix  Zscores, which may be NAs in the tail (when standard dev = 0 )
    print(paste0(length(which(is.na(zscores))),' NAs in zscores'))
    if (length(which(is.na(zscores)))>0) {
      print(paste0('NAs start at freq ', min(freqs[which(is.na(zscores))])))
    } 
    zscores[is.na(zscores)]<- 0
    
    GA_all[[ch]]  <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
    #rm(list= measurenames)
    
  }
  toc()
  
  
  
  # function to gather each measure in a table, write the channel name and save as csv     
  convert2table <-
    function(listGA,listGAname,measurenames){
      
      mytable  <-  as.data.frame(do.call(rbind,listGA),optional = TRUE)  
      for (mes in 1:length(measurenames)) {
        currmeasurerows <- mytable[grep(measurenames[mes], rownames(mytable)),]
        rownames(currmeasurerows) <- paste0(measurenames[mes],'_',chanlabels[1:length(rownames(currmeasurerows))])
        data.table::fwrite(currmeasurerows, paste0(diroutput,'/',measurenames[mes],'_',listGAname,'_beta.csv'),row.names=TRUE)
        
      }
    }
  
  lists2convert <- c("GA_all")
  for (L in 1:length(lists2convert)){
    listGA = get(lists2convert[L])
    listGAname = eval(lists2convert[L])
     convert2table(listGA,listGAname,measurenames) #output will be 'tableGA' 
    
  }
  

  