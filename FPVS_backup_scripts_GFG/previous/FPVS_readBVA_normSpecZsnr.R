# Export normalized spectra and  SNR, Baseline corrected amplitudes, Z scores from normalized spectra
#======================================================================================================================
# Export a .csv file per subject and condition channels as rows, data point as columns
# First row contains the frequencies
#------------------------------------------------------------------------------------------------------------------------------
# Clear all variables
rm(list=ls(all=TRUE))
#Load 
library(tibble)
library(data.table)
library(svDialogs)
library(ggplot2)
library(wesanderson)

# Define input directories and go to input dir
dirinput <- c("O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/SingleSubj/newGroupsComb_elRankTop3/by_grade/Gap_2nd", "O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/SingleSubj/newGroupsComb_elRankTop3/by_grade/Gap_3rd")
diroutput <- c("N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo")


group <- c("Gap_2nd","Gap_3rd") #needed for loop for filenaming.


#loop through poor and typ files
for (pt in 1:length(dirinput)) {
  
  cond.input <- c("*.Pool_ElRankTop3_FFT_WinFF", "*.Pool_ElRankTop3_FFT_FFinW", "*.Pool_ElRankTop3_FFT_CSinFF", "*.Pool_ElRankTop3_FFT_PWinFF", "*.Pool_ElRankTop3_FFT_CSinW")
  
  #loop through conditions
  for (c in 1:length(cond.input)) {    
    # Define input file: select pattern
    files<- dir(dirinput[pt],pattern=paste("*.",cond.input[c],".*.txt$",sep=""))  # dir(pattern="p*.*.*.txt$")
    
    # input the channels of interest 
    mychans <-   c("LOT","ROT") #e.g., #c(51,58,64,52,59,65,68,69,70,71,72)#c(58,59,64,65,66,68,69,70,73,74,82,83,84,88,89,90,91,94,95,96,"VREF") #e.g., #c(51,58,64,52,59,65,68,69,70,71,72)
  
    # Define some characteristics of the data and FFT parameters
    srate <- 512
    durSecs <-40 # length of recording in sec (strings: 40s, AV: 54.82 s, LinPL: 53.3)
    ntimepoints <- srate * (durSecs/2)
    freqresol <-0.025
    
    # frequencies 
    freqs <- seq(0,srate/2,freqresol)
    freqs <-freqs[1:length(freqs)-1]
    
    
    # Begin loop thru Channels  // Then thru files
    # -------------------------------------------------------------------------------------------------------------------------------------------
    setwd(dirinput)
    # Loop input channels 
    datalist_snr <- list()
    datalist_z <- list()
    datalist_normSpec <- list()
    datalist_bcAmps <- list()
    for (ch in 1:length(mychans)) {
      #for (f in 1:3){
      for (f in 1:length(files)){
        fileinput <- files[f]
        
        S <- as.data.frame(data.table::fread(paste0(dirinput[pt],'/',fileinput),quote = "/"))
        # find channel
        chansInData <- S[,2] # chan labels in data
        S <- S[,3:dim(S)[2]] #exclude first two columns with the name of the electrodes (e.g., "EEG"  "1"). This may be in one column depending on your labels!
        
        # get data from current channel
        currchanidx <- which(chansInData==mychans[ch])
        spec <- S[currchanidx,] # getdata only for current channel
        spec <- as.numeric(spec) 
        
        # Normalize spectrum ------------------------------------------------------------------------------------------------------  
        specNorm <- (spec/(srate*durSecs)) *10^5 # divide spectrum by the number of data points. Multiple for scaling
        
        #Calculate SNR ------------------------------------------------------------------------------------------------------  
        snr <- vector(mode="numeric", length=length(specNorm))
        for (bin in 1:length(specNorm)) {
          if ((bin-10) > 0 & (bin+10) < length(specNorm) ) {
            # get amplitudes from the surrounding 20 frequency bins
            currSpecData <- as.numeric(cbind(specNorm[(bin-10):(bin-2)],specNorm[(bin+2):(bin+10)]))
            snr[bin] <- specNorm[bin]/mean(currSpecData)
            
          }else if (((bin-10)<= 0) & (bin > 2) & ((bin+10) < length(specNorm))) {
            currSpecData <- as.numeric(cbind(specNorm[1:(bin-2)],specNorm[(bin+2):(bin+10)]))
            snr[bin] <- specNorm[bin]/mean(currSpecData)
            
          } else if (((bin-10)<= 0) & (bin <= 2) & ((bin+10) < length(specNorm))) {
            currSpecData <- as.numeric(specNorm[(bin+2):(bin+10)])
            snr[bin] <- specNorm[bin]/mean(currSpecData)
            
          } else if ((bin-10) >  0 & (bin+10) >=length(specNorm) ) {
            currSpecData <- as.numeric(cbind(specNorm[(bin-10):(bin-2)],specNorm[(bin+2):length(specNorm)]))
            snr[bin] <- specNorm[bin]/mean(currSpecData)
          } 
        }  
        rm(currSpecData)
        
        #Calculate BC data ------------------------------------------------------------------------------------------------------  
        bcAmps <- vector(mode="numeric", length=length(specNorm))
        for (bin in 1:length(specNorm)) {
          if ((bin-10) > 0 & (bin+10) < length(specNorm) ) {
            # get amplitudes from the surrounding 20 frequency bins
            currSpecData <- as.numeric(cbind(specNorm[(bin-10):(bin-2)],specNorm[(bin+2):(bin+10)]))
            bcAmps[bin] <- specNorm[bin]-mean(currSpecData)
            
          }else if (((bin-10)<= 0) & (bin > 2) & ((bin+10) < length(specNorm))) {
            currSpecData <- as.numeric(cbind(specNorm[1:(bin-2)],specNorm[(bin+2):(bin+10)]))
            bcAmps[bin] <- specNorm[bin]-mean(currSpecData)
            
          } else if (((bin-10)<= 0) & (bin <= 2) & ((bin+10) < length(specNorm))) {
            currSpecData <- as.numeric(specNorm[(bin+2):(bin+10)])
            bcAmps[bin] <- specNorm[bin]-mean(currSpecData)
            
          } else if ((bin-10) >  0 & (bin+10) >=length(specNorm) ) {
            currSpecData <- as.numeric(cbind(specNorm[(bin-10):(bin-2)],specNorm[(bin+2):length(specNorm)]))
            bcAmps[bin] <- specNorm[bin]-mean(currSpecData)
          } 
        }  
        rm(currSpecData)
        
        #Calculate Zscores ------------------------------------------------------------------------------------------------------        
        zscores <- vector(mode="numeric", length=length(specNorm))
        for (bin in 1:length(specNorm)) {
          if ((bin-10) > 0 & (bin+10) < length(specNorm) ) {
            # get amplitudes from the surrounding 20 frequency bins
            currSpecData <- as.numeric(cbind(specNorm[(bin-10):(bin-2)],specNorm[(bin+2):(bin+10)]))
            # if (length(unique(currSpecData))>2) { 
            #   currSpecData <- currSpecData[currSpecData!=max(currSpecData) & currSpecData!=min(currSpecData)]
            # }
            zscores[bin] <- (specNorm[bin]-mean(currSpecData))/sd(currSpecData)
            
          }else if (((bin-10)<= 0) & (bin > 2) & ((bin+10) < length(specNorm))) {
            currSpecData <- as.numeric(cbind(specNorm[1:(bin-2)],specNorm[(bin+2):(bin+10)]))
            zscores[bin] <- (specNorm[bin]-mean(currSpecData))/sd(currSpecData)
            
          } else if (((bin-10)<= 0) & (bin <= 2) & ((bin+10) < length(specNorm))) {
            currSpecData <- as.numeric(specNorm[(bin+2):(bin+10)])
            zscores[bin] <- (specNorm[bin]-mean(currSpecData))/sd(currSpecData)
            
          } else if ((bin-10) >  0 & (bin+10) >= length(specNorm) ) {
            currSpecData <- as.numeric(cbind(specNorm[(bin-10):(bin-2)],specNorm[(bin+2):length(specNorm)]))
            zscores[bin] <- (specNorm[bin]-mean(currSpecData))/sd(currSpecData)
          }
        }  
        rm(currSpecData)
        
        #------------------------------------------------------------------------------------------------------         
        # save in list of arrays 
        datalist_bcAmps[[f]] <-  as_tibble(t(c(fileinput,group[pt],mychans[ch],round(bcAmps,6))),.name_repair = "unique")
        datalist_snr[[f]] <-  as_tibble(t(c(fileinput,group[pt],mychans[ch],round(snr,6))),.name_repair = "unique")
        datalist_z[[f]] <- as_tibble(t(c(fileinput,group[pt],mychans[ch],round(zscores,6))),.name_repair = "unique")
        datalist_normSpec[[f]] <- as_tibble(t(c(fileinput,group[pt],mychans[ch],round(specNorm,6))),.name_repair = "unique")
     }

      # Make header
      header <-   c("file","group","chan",format(round(freqs,2),nsmall=2))
      
      # gather
      bcAmps2save <- data.table::rbindlist(datalist_bcAmps)
      colnames(bcAmps2save) <- header
      snr2save <- data.table::rbindlist(datalist_snr)
      colnames(snr2save) <- header
      
      
      z2save<- data.table::rbindlist(datalist_z)
      colnames(z2save) <- header
      
      normSpec2save<- data.table::rbindlist(datalist_normSpec)
      colnames(normSpec2save) <- header 
      
      # save 
      setwd(diroutput)
      condName <- gsub("\\*.","",cond.input[c])
      outnameZ<- paste("SS_T1_Ex_",group[pt],"_Z_ch",mychans[ch],"_",condName,".csv",sep="")
      if(length(dir(pattern = outnameZ))== 1) {
        print("file found!!!! rename existing file!!!!!")
      } else {write.csv(z2save,file = outnameZ,row.names = FALSE)
      }
      
      outnameSNR <- paste("SS_T1_Ex_",group[pt],"_SNR_ch",mychans[ch],"_",condName,".csv",sep="")
      #write.csv(snr2save,file =outnameSNR,row.names = FALSE)
      if(length(dir(pattern = outnameSNR))== 1) {
        print("file found!!!! rename existing file!!!!!")
      } else {write.csv(snr2save,file = outnameSNR,row.names = FALSE)
      }
      
      
      outnameBCAMPS <- paste("SS_T1_Ex_",group[pt],"_BCamp_ch",mychans[ch],"_",condName,".csv",sep="")
      if(length(dir(pattern = outnameBCAMPS))== 1) {
        print("file found!!!! rename existing file!!!!!")
      } else {write.csv(bcAmps2save,file = outnameBCAMPS,row.names = FALSE)
      }
      
      outnamenormSpec <- paste("SS_T1_Ex_",group[pt],"_NormSpec_ch",mychans[ch],"_",condName,".csv",sep="")
      #write.csv(normSpec2save,file = outnamenormSpec,row.names = FALSE)
      if(length(dir(pattern = outnamenormSpec))== 1) {
        print("file found!!!! rename existing file!!!!!")
      } else {write.csv(normSpec2save,file = outnamenormSpec,row.names = FALSE)
      }
    }
  }
}

