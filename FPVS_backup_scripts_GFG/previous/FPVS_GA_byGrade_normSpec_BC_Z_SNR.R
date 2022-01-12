# Export normalized spectra and  SNR, Baseline corrected amplitudes, Z scores from normalized spectra
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
library(wesanderson)

# Define input directories and go to input dir
#dirinput <- c("O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/SingleSubj/newGroupsComb_elRankTop3/by_grade/Poor_2nd", "O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/SingleSubj/newGroupsComb_elRankTop3/by_grade/Poor_3rd","O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/SingleSubj/newGroupsComb_elRankTop3/by_grade/Typical_2nd","O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/SingleSubj/newGroupsComb_elRankTop3/by_grade/Typical_3rd")
#dirinput <- c("O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/SingleSubj/newGroupsComb_elRankTop3/by_grade/Gap_2nd", "O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/SingleSubj/newGroupsComb_elRankTop3/by_grade/Gap_3rd")

dirinput <- c("O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/GA/newClassificationELFESLRTcomb/new_PoolElRankTop3/Poor_2nd", "O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/GA/newClassificationELFESLRTcomb/new_PoolElRankTop3/Poor_3rd","O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/GA/newClassificationELFESLRTcomb/new_PoolElRankTop3/Typical_2nd","O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/GA/newClassificationELFESLRTcomb/new_PoolElRankTop3/Typical_3rd","O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/GA/newClassificationELFESLRTcomb/new_PoolElRankTop3/Gap_2nd", "O:/studies/allread/analyses/EEG_FPVS/eeg/SNR/202103_Paper_T1_GroupComp/in/GA/newClassificationELFESLRTcomb/new_PoolElRankTop3/Gap_3rd")
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/data/GA_allChans_Z_BC_etc"

group <- c("Poor2","Poor3", "Typ2", "Typ3", "Gap2", "Gap3") #needed for loop for filenaming.

#group <- c("Poor_2nd","Poor_3rd","Typ_2nd","Typ_3rd") #needed for loop for filenaming.
#group <- c("Gap_2nd","Gap_3rd") #needed for loop for filenaming.
##ATTENTION: also need to change dirinput!!


#loop through poor and typ, and gap files


# Pop up
#sID.input <- dlgInput("Enter filename prefix showing subj ID (e.g., AllRead_pilot** or GA or Pooling_GA",'AllRead_pilot**' )$res
#cond.input <-  dlgInput("Enter filename prefix showing subj ID (e.g., AllRead_pilot** or GA or Pooling_GA",'**Pool1_FFT_FFinW**' )$res
#cond.input <- "*.Pool2_FFT_FFinW" #FFinW, "*.Pool2_FFT_WinFF", "*.Pool2_FFT_CSinFF", "*.Pool2_FFT_PWinFF", "*.Pool2_FFT_CSinW", "*.Pool2_FFT_AV", "*.Pool2_FFT_LinPL"
for (pt in 1:length(dirinput)) {
 # setwd(dirinput[pt]) #pt = poor typical
  
  # Pop up
  #sID.input <- dlgInput("Enter filename prefix showing subj ID (e.g., AllRead_pilot** or GA or Pooling_GA",'AllRead_pilot**' )$res
  #cond.input <-  dlgInput("Enter filename prefix showing subj ID (e.g., AllRead_pilot** or GA or Pooling_GA",'**Pool1_FFT_FFinW**' )$res
  cond.input <- c("*._WinFF", "*._FFinW", "*._CSinFF", "*._PWinFF", "*._CSinW")
  #cond.input <- c("*.Pool2_FFT_AV") 
  #cond.input <- c("*.Pool2_FFT_LinPL") 
  #cond.input <- c("*.Pool2_FFT_WinFF")
  #loop through conditions
  for (c in 1:length(cond.input)) {    
    # Define input file: select pattern
    files<- dir(dirinput[pt],pattern=paste("*.",cond.input[c],".*.txt$",sep=""))  # dir(pattern="p*.*.*.txt$")
    
    
    #loop through conditions
    
    # input the channels of interest 
    mychans <-   c("LOT","ROT") #e.g., #c(51,58,64,52,59,65,68,69,70,71,72)#c(58,59,64,65,66,68,69,70,73,74,82,83,84,88,89,90,91,94,95,96,"VREF") #e.g., #c(51,58,64,52,59,65,68,69,70,71,72)
    #mychans <- c('1', 	'2', 	'3', 	'4', 	'5', 	'6', 	'7', 	'8', 	'9', 	'10', 	'11', 	'12', 	'13', 	'14', 	'15', 	'16', 	'17', 	'18', 	'19', 	'20', 	'21', 	'22', 	'23', 	'24', 	'25', 	'26', 	'27', 	'28', 	'29', 	'30', 	'31', 	'32', 	'33', 	'34', 	'35', 	'36', 	'37', 	'38', 	'39', 	'40', 	'41', 	'42', 	'43', 	'44', 	'45', 	'46', 	'47', 	'48', 	'49', 	'50', 	'51', 	'52', 	'53', 	'54', 	'55', 	'56', 	'57', 	'58', 	'59', 	'60', 	'61', 	'62', 	'63', 	'64', 	'65', 	'66', 	'67', 	'68', 	'69', 	'70', 	'71', 	'72', 	'73', 	'74', 	'75', 	'76', 	'77', 	'78', 	'79', 	'80', 	'81', 	'82', 	'83', 	'84', 	'85', 	'86', 	'87', 	'88', 	'89', 	'90', 	'91', 	'92', 	'93', 	'94', 	'95', 	'96', 	'97', 	'98', 	'99', 	'100', 	'101', 	'102', 	'103', 	'104', 	'105', 	'106', 	'107', 	'108', 	'109', 	'110', 	'111', 	'112', 	'113', 	'114', 	'115', 	'116', 	'117', 	'118', 	'119', 	'120', 	'121', 	'122', 	'123', 	'124', 	'125', 	'126', 	'127', 	'128', 'Cz'
    #)
    
    # Define some characteristics of the data and FFT parameters
    srate <- 512
    durSecs <-40 # length of recording in sec (strings: 40s, AV: 54.82 s, LinPL: 53.3)
    ntimepoints <- srate * (durSecs/2)
    freqresol <-0.025
    
    # frequencies 
    freqs <- seq(0,srate/2,freqresol)
    freqs <-freqs[1:length(freqs)-1]
    # -------------------------------------------------------------------------------------------------------------------------------------------
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
            # if (length(unique(currSpecData))>2) { 
            #     currSpecData <- currSpecData[currSpecData!=max(currSpecData) & currSpecData!=min(currSpecData)] # exclude min and max 
            # }
            snr[bin] <- specNorm[bin]/mean(currSpecData)
            
          }else if (((bin-10)<= 0) & (bin > 2) & ((bin+10) < length(specNorm))) {
            currSpecData <- as.numeric(cbind(specNorm[1:(bin-2)],specNorm[(bin+2):(bin+10)]))
            # if (length(unique(currSpecData))>2) { 
            #     currSpecData <- currSpecData[currSpecData!=max(currSpecData) & currSpecData!=min(currSpecData)]
            # }
            snr[bin] <- specNorm[bin]/mean(currSpecData)
            
          } else if (((bin-10)<= 0) & (bin <= 2) & ((bin+10) < length(specNorm))) {
            currSpecData <- as.numeric(specNorm[(bin+2):(bin+10)])
            # if (length(unique(currSpecData))>2) { 
            #     currSpecData <- currSpecData[currSpecData!=max(currSpecData) & currSpecData!=min(currSpecData)]
            # }
            snr[bin] <- specNorm[bin]/mean(currSpecData)
            
          } else if ((bin-10) >  0 & (bin+10) >=length(specNorm) ) {
            currSpecData <- as.numeric(cbind(specNorm[(bin-10):(bin-2)],specNorm[(bin+2):length(specNorm)]))
            # if (length(unique(currSpecData))>2) { 
            #     currSpecData <- currSpecData[currSpecData!=max(currSpecData) & currSpecData!=min(currSpecData)]
            # }
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
            # if (length(unique(currSpecData))>2) { 
            #   currSpecData <- currSpecData[currSpecData!=max(currSpecData) & currSpecData!=min(currSpecData)]
            # } 
            zscores[bin] <- (specNorm[bin]-mean(currSpecData))/sd(currSpecData)
            
          } else if (((bin-10)<= 0) & (bin <= 2) & ((bin+10) < length(specNorm))) {
            currSpecData <- as.numeric(specNorm[(bin+2):(bin+10)])
            # if (length(unique(currSpecData))>2) { 
            #   currSpecData <- currSpecData[currSpecData!=max(currSpecData) & currSpecData!=min(currSpecData)]
            # }
            zscores[bin] <- (specNorm[bin]-mean(currSpecData))/sd(currSpecData)
            
          } else if ((bin-10) >  0 & (bin+10) >= length(specNorm) ) {
            currSpecData <- as.numeric(cbind(specNorm[(bin-10):(bin-2)],specNorm[(bin+2):length(specNorm)]))
            # if (length(unique(currSpecData))>2) { 
            #   currSpecData <- currSpecData[currSpecData!=max(currSpecData) & currSpecData!=min(currSpecData)]
            # }
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
        
        ###added the name_repair part due to the following warning message:
        ##<deprecated>
        #message: The `x` argument of `as_tibble.matrix()` must have column names if `.name_repair` is omitted as of tibble 2.0.0.
        #Using compatibility `.name_repair`.
        #This warning is displayed once every 8 hours.
        #------------------------------------------------------------------------------------------------------ 
        # end subject loop
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
      outnameZ<- paste("GA_T1_Ex_",group[pt],"_Z_ch",mychans[ch],"_",condName,".csv",sep="")
      if(length(dir(pattern = outnameZ))== 1) {
        print("file found!!!! rename existing file!!!!!")
      } else {write.csv(z2save,file = outnameZ,row.names = FALSE)
      }
      
      outnameSNR <- paste("GA_T1_Ex_",group[pt],"_SNR_ch",mychans[ch],"_",condName,".csv",sep="")
      #write.csv(snr2save,file =outnameSNR,row.names = FALSE)
      if(length(dir(pattern = outnameSNR))== 1) {
        print("file found!!!! rename existing file!!!!!")
      } else {write.csv(snr2save,file = outnameSNR,row.names = FALSE)
      }
      
      
      outnameBCAMPS <- paste("GA_T1_Ex_",group[pt],"_BCamp_ch",mychans[ch],"_",condName,".csv",sep="")
      if(length(dir(pattern = outnameBCAMPS))== 1) {
        print("file found!!!! rename existing file!!!!!")
      } else {write.csv(bcAmps2save,file = outnameBCAMPS,row.names = FALSE)
      }
      
      outnamenormSpec <- paste("GA_T1_Ex_",group[pt],"_NormSpec_ch",mychans[ch],"_",condName,".csv",sep="")
      #write.csv(normSpec2save,file = outnamenormSpec,row.names = FALSE)
      if(length(dir(pattern = outnamenormSpec))== 1) {
        print("file found!!!! rename existing file!!!!!")
      } else {write.csv(normSpec2save,file = outnamenormSpec,row.names = FALSE)
      }
    }
  }
}

