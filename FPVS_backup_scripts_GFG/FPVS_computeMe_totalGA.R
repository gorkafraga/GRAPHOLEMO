# Make TOTAL grand averages (across conditions) from previously calculated frequency measures (specmeans,normspec, snr, bcamp , zscores)
#==========================================================================================================================================
  
# Clear all variables
rm(list=ls(all=TRUE))
#Load stuff
libraries <- c('tibble','data.table','svDialogs','tictoc','ggplot2')
lapply(libraries, library, character.only = TRUE, invisible())
source('N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/scripts_FPVS_GFG/FPVS_function_computeMeasures.R')
setwd(dirinput)

# Define input directories and go to input dir
dirinput <- c("N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/b_computed_measures")
diroutput <- c("N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/b_computed_measures/totalGAs")
srate <- 512
durSecs <-40 # length of recording in sec (strings: 40s, AV: 54.82 s, LinPL: 53.3)


# AVERAGE SPECTRA OVER ALL CONDITIONS (ALSO IN GROUPS OF CONDITIONS PER BASE) 
measurenames <-  c('specmeans')
condition <- c("CSinFF","PWinFF","WinFF","FFinW","CSinW")
for (mes in 1:length(measurenames)){
  currMeasure <- measurenames[mes]
  files<- dir(dirinput,pattern=paste("*.",currMeasure,".*GA_all.csv$",sep="")) 
  
  # There should be 5 files for each measurement collected in a listr of 5 elements
  measure_gathered <- list()
  for (f in 1:length(files)){
    raw <- as.data.frame(data.table::fread(paste0(dirinput,'/',files[f]),quote = "/",header = TRUE))
    channel <- gsub(paste0(currMeasure,'_'),'',raw[,1])
    dat <- raw[,2:ncol(raw)] #the actual data
    ntimepoints <- ncol(dat)
    nchans <- nrow(dat)
    measure_gathered[[f]] <- dat
  }
  
  #average channels of the five conditions
  ch_allconds_means <- as.data.frame(matrix(nrow =nchans,ncol = ntimepoints))
  ch_baseFF_means <- as.data.frame(matrix(nrow =nchans,ncol = ntimepoints))
  ch_baseW_means <-  as.data.frame(matrix(nrow =nchans,ncol = ntimepoints))
  for (ch in 1:nchans) {
      ch_allconds <- data.table::rbindlist(lapply(measure_gathered,'[',ch,1:ntimepoints))  #this is a table with 5 rows: i.e., the th row for each condition
      ch_allconds_means[ch,] <- colMeans(ch_allconds)
      ch_baseFF_means[ch,] <- colMeans(ch_allconds[grep('*inFF',condition),]) #select rows corresponding to conditions with FF as base
      ch_baseW_means[ch,] <- colMeans(ch_allconds[grep('*inW',condition),]) # ... 
      print(ch)
      
      
  }
  #add some info and formatting
  colnames(ch_allconds_means) <- colnames(dat)
  colnames(ch_baseFF_means) <- colnames(dat)
  colnames(ch_baseW_means) <- colnames(dat)
  
  ch_allconds_means <- cbind(channel,ch_allconds_means)
  ch_baseFF_means <- cbind(channel,ch_baseFF_means)
  ch_baseW_means <- cbind(channel,ch_baseW_means)
  ch_allconds_means$channel <- as.character(ch_allconds_means$channel )
  ch_baseFF_means$channel <- as.character(ch_baseFF_means$channel )
  ch_baseW_means$channel <- as.character(ch_baseW_means$channel )
  
  
  data.table::fwrite(ch_allconds_means, paste0(diroutput,'/',currMeasure,'_5Conds_GA_all.csv'),row.names=FALSE)
  data.table::fwrite(ch_baseFF_means, paste0(diroutput,'/',currMeasure,'_baseFF_GA_all.csv'),row.names=FALSE)
  data.table::fwrite(ch_baseW_means, paste0(diroutput,'/',currMeasure,'_baseW_GA_all.csv'),row.names=FALSE)
  
}


########################################################################################
# Read the newly created averages and compute the remaining measures per channel 
gafiles <-  dir(diroutput,pattern=paste("specmeans_.*._GA_all.csv",sep=""))
setwd(diroutput )
   for (ff in 1:length(gafiles)){
        print(gafiles[ff])   
        raw <- as.data.frame(data.table::fread(paste0(diroutput,'/',gafiles[ff]),quote = "/",header = TRUE))
        dat <- raw[,2:ncol(raw)] #the actual data
        ntimepoints <- ncol(dat)
        nchans <- nrow(dat)
        
        # create new empty tables to fill with new measures
        template_dataframe <- raw
        template_dataframe[1:nrow(template_dataframe),2:ncol(template_dataframe)] <- ''
        all_specNorm <- template_dataframe
        all_zscores <- template_dataframe
        all_bcAmps <- template_dataframe
        all_snr <- template_dataframe
        for (ch in 1:nchans) {
            spec <- as.data.frame(dat[ch,])
            # CALL function
            computeMeasures(specmeans = spec)
            # store output  
              all_specNorm[ch,2:ncol(all_specNorm)] <- specNorm
              all_zscores[ch,2:ncol(all_specNorm)] <- zscores
              all_bcAmps[ch,2:ncol(all_specNorm)] <- bcAmps
              all_snr[ch,2:ncol(all_specNorm)] <- snr
              print(ch)
        }
        
        
        data.table::fwrite(all_specNorm, paste0(diroutput,'/',gsub('specmeans', 'specNorm',gafiles[ff])),row.names=FALSE)
        data.table::fwrite(all_zscores, paste0(diroutput,'/',gsub('specmeans', 'zscores',gafiles[ff])),row.names=FALSE)
        data.table::fwrite(all_bcAmps, paste0(diroutput,'/',gsub('specmeans', 'bcAmps',gafiles[ff])),row.names=FALSE)
        data.table::fwrite(all_snr, paste0(diroutput,'/',gsub('specmeans', 'snr',gafiles[ff])),row.names=FALSE)
        
    }
         
        
  
  