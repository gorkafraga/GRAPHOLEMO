# Make grand averages and export normalized spectra and  SNR, Baseline corrected amplitudes, Z scores from normalized spectra
#======================================================================================================================
# Export a .csv file per channel: Subjects as rows, data point as columns
# First row contains the frequencies
#------------------------------------------------------------------------------------------------------------------------------
# Clear all variables
rm(list=ls(all=TRUE))
#Load 
library(tibble)
library(data.table)
library(svDialogs)
library(ggplot2)
source('N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/scripts_FPVS_GFG/FPVS_function_computeMeasures.R')

# Define input directories and go to input dir
dirinput <- c("N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/a_data_from_Analyzer")
diroutput <- c("N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/b_computed_measures")
masterfile <- c("N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/FPVS_beh.sav")

condition <- c("CSinFF","PWinFF","WinFF","FFinW","CSinW")
# Define some data and FFT parameters
srate <- 512
durSecs <-40 # length of recording in sec (strings: 40s, AV: 54.82 s, LinPL: 53.3)
ntimepoints <- srate * (durSecs/2)
freqresol <-0.025
freqs <- seq(0,srate/2,freqresol)
freqs <-freqs[1:length(freqs)-1]

# read behavioral master for subject's group and grade info 
master <- haven::read_sav(masterfile)
#Get indices of subjects for each group 
subjectList_poor <-       master$subject[which(master$group=="Poor")]
subjectList_typ <-        master$subject[which(master$group=="Typ")]
subjectList_gap <-        master$subject[which(master$group=="Gap")]
subjectList_2nd <-        master$subject[which(master$grade==2)]
subjectList_3rd <-        master$subject[which(master$grade==3)]
subjectList_poor_2nd <-   master$subject[which(master$group=="Poor" & master$grade==2)]
subjectList_typ_2nd <-    master$subject[which(master$group=="Typ" & master$grade==2)]
subjectList_gap_2nd <-    master$subject[which(master$group=="Gap" & master$grade==2)]
subjectList_poor_3rd <-   master$subject[which(master$group=="Poor" & master$grade==3)]
subjectList_typ_3rd <-    master$subject[which(master$group=="Typ" & master$grade==3)]
subjectList_gap_3rd <-    master$subject[which(master$group=="Gap" & master$grade==3)]

# Loop thru conditions, then subjects, channels
for (c in 1:length(condition)) {
      currCondition <- condition[c]
     files<- dir(dirinput,pattern=paste("*.",currCondition,".txt$",sep="")) 
     
     #[1] Gather all subjects for this condition with their ID
     ############################################################
     allsubjects <- list()
     allsubjectsID <- list()
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
     
       GA_all <- list()
       GA_typ <- list()
       GA_poor <- list()
       GA_gap <- list()
       GA_2nd <- list()
       GA_3rd <- list()
       GA_typ_2nd <- list()
       GA_poor_2nd <- list()
       GA_gap_2nd <- list()
       GA_typ_3rd <- list()
       GA_poor_3rd <- list()
       GA_gap_3rd <- list()
       measurenames <-  c('specmeans','specNorm','zscores','bcAmps','snr')
       
      # For each channel: 
       #1)gather all subjects in a table
       # 2) Compute the average of those subjects or a selection of them 
       # 3) After averaging subjects run function to extract all measure
       # 4) Each grand average will be a list of length = n channels, each list element will have a table with all measures for that channel
       
      tic()
      nchans <-nrow(allsubjects[[1]])
      for (ch in 1:nchans) {
         ch_allSubj <- data.table::rbindlist(lapply(allsubjects,'[',ch,1:ntimepoints))
        # Averages  
         specmeans<- colMeans(ch_allSubj)
         computeMeasures(specmeans)
         GA_all[[ch]]  <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         #
         specmeans  <-  colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_2nd),])
         computeMeasures(specmeans)
         GA_2nd[[ch]]  <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         # 
         specmeans <-  colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_3rd),])
         computeMeasures(specmeans)
         GA_3rd[[ch]]  <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         #
         specmeans <- colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_typ),])
         computeMeasures(specmeans)
         GA_typ[[ch]] <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         
         specmeans <- colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_poor),])
         computeMeasures(specmeans)
         GA_poor[[ch]] <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         
         specmeans <- colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_gap),])
         computeMeasures(specmeans)
         GA_gap[[ch]]  <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         #
         specmeans <- colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_typ_2nd),])
         computeMeasures(specmeans)
         GA_typ_2nd[[ch]]  <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         
         specmeans <- colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_poor_2nd),])         
         computeMeasures(specmeans)
         GA_poor_2nd[[ch]] <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         
         specmeans <- colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_gap_2nd),])
         computeMeasures(specmeans)
         GA_gap_2nd[[ch]]  <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         #
         specmeans <- colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_typ_3rd),])
         computeMeasures(specmeans)
         GA_typ_3rd[[ch]]  <-  rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         
         specmeans <-  colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_poor_3rd),])
         computeMeasures(specmeans)
         GA_poor_3rd[[ch]] <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
         
         specmeans <- colMeans(ch_allSubj[which(unlist(allsubjectsID) %in% subjectList_gap_3rd),])
         computeMeasures(specmeans)
         GA_gap_3rd[[ch]]  <- rbind(specmeans,specNorm,zscores,bcAmps,snr)
          rm(list= measurenames)
     print(ch)
      }
      toc()
 
  ##############################################################################

      
  # function to gather each measure in a table, write the channel name and save as csv     
 convert2table <-
        function(listGA,listGAname,currCondition,measurenames){
          
          mytable  <-  as.data.frame(do.call(rbind,listGA),optional = TRUE)  
          for (mes in 1:length(measurenames)) {
             currmeasurerows <- mytable[grep(measurenames[mes], rownames(mytable)),]
             rownames(currmeasurerows) <- paste0(measurenames[mes],'_',chanlabels[1:length(rownames(currmeasurerows))])
             data.table::fwrite(currmeasurerows, paste0(diroutput,'/',currCondition,'_',measurenames[mes],'_',listGAname,'.csv'),row.names=TRUE)
          
            }
        }
      
      lists2convert <- c("GA_all","GA_typ","GA_poor","GA_gap","GA_typ_2nd","GA_poor_2nd","GA_gap_2nd","GA_typ_3rd","GA_poor_3rd","GA_gap_3rd","GA_2nd","GA_3rd")
      for (L in 1:length(lists2convert)){
        listGA = get(lists2convert[L])
        listGAname = eval(lists2convert[L])
        currCondition = eval(currCondition)
        convert2table(listGA,listGAname,currCondition,measurenames) #output will be 'tableGA' 
        
      }
       
}