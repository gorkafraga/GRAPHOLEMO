# Average electrodes and export normalized spectra and  SNR, Baseline corrected amplitudes, Z scores from normalized spectra
#======================================================================================================================
# Export a .csv file per channel: Subjects as rows, data point as columns
# First row contains the frequencies
#------------------------------------------------------------------------------------------------------------------------------
# Clear all, load libs 
rm(list=ls(all=TRUE))
libraries <- c('tibble','data.table','svDialogs','tictoc','ggplot2')
lapply(libraries, library, character.only = TRUE, invisible())
source('N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/scripts_FPVS_GFG/FPVS_function_computeMe.R')


# Define input directories and go to input dir
dirinput <- c("N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/a_data_from_Analyzer")
diroutput <- c("N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/e_clusters_computedMeasures")


condition <- c("CSinFF","PWinFF","WinFF","FFinW","CSinW")
# Define some data and FFT parameters
srate <- 512
durSecs <- 40 # length of recording in sec (strings: 40s, AV: 54.82 s, LinPL: 53.3)
ntimepoints <- srate * (durSecs/2)
freqresol <-0.025
freqs <- seq(0,srate/2,freqresol)
freqs <-freqs[1:length(freqs)-1]


# Loop thru conditions, then subjects, channels
for (c in 1:length(condition)) {
  currCondition <- condition[c]
  print(currCondition)
  files<- dir(dirinput,pattern=paste("*._",currCondition,".txt$",sep="")) 
  
  #[1] Gather all subjects for this condition with their ID
  ############################################################
  allsubjects <- list()
  allsubjectsID <- list()
  tic()
  for (f in 1:length(files)){
    # Read data, trim out electrode labels (2 cols) and use them as rownames. Colnames are frequency bins labels
    print(f)
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
  
  #[2] Compute channel clusters and [3] call function to compute frequency-based measures(SNR,Z,etc)
  #############################################################################################
  # - Loop thru subjects
  # - Cluster channels of interest
  # - Run function to extract measures from spec
  # - Output file per  Each grand average will be a list of length = n channels, each list element will have a table with all measures for that channel
  
  clusterLeft<- c("065","069","070") 
  clusterRight <- c("083","089","090")
  measurenames <-  c('specmeans','specNorm','zscores','bcAmps','snr')
  
  
  # compute average of each cluster,compute measures and gather them in a list per cluster , with as many elements as subjects. In each element there is a table with 'measure type' as row , columns are data points
  left <- list()
  right <- list()
  for (subj in 1:length(allsubjects)){
    # Select cluster data
    clusterIdx_l <- which(chanlabels %in% clusterLeft) 
    clusterIdx_r <- which(chanlabels %in% clusterRight) 
    
    currSubj_data <- allsubjects[[subj]]
    # Averages  
    specmeans <-  colMeans(currSubj_data[clusterIdx_l,1:ntimepoints])
    computeMeasures(specmeans)
    left[[subj]]  <-   rbind(specmeans,specNorm,zscores,bcAmps,snr)
    rm(list = measurenames)
    
    specmeans <-  colMeans(currSubj_data[clusterIdx_r,1:ntimepoints])
    computeMeasures(specmeans)
    right[[subj]]  <-   rbind(specmeans,specNorm,zscores,bcAmps,snr)
    
    print(subj)
  }
  
  
  # function to gather each measure in a table with subjects as rows (data points as columns)  
  convert2table <-
    function(clusterData,clusterName,currCondition,measurenames){
      mytable  <-  as.data.frame(do.call(rbind,clusterData),optional = TRUE)  
      
      for (mes in 1:length(measurenames)) {
        currmeasurerows <- mytable[grep(measurenames[mes], rownames(mytable)),]
        rownames(currmeasurerows) <- paste0(unlist(allsubjectsID),'_',clusterName)
        data.table::fwrite(currmeasurerows, paste0(diroutput,'/',currCondition,'_',measurenames[mes],'_',clusterName,'.csv'),row.names=TRUE)
        
      }
    }
  
  
  lists2convert <- c("left","right")
  for (L in 1:length(lists2convert)){
    clusterData = get(lists2convert[L])
    clusterName = eval(lists2convert[L])
    currCondition = eval(currCondition)
    convert2table(clusterData,clusterName,currCondition,measurenames) #output will be 'tableGA' 
    
  }
  
}
