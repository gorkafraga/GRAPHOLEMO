# Gather scores from specific frequencies  
#-------------------------------------------------------------------------------------------
# - read csv with z scores, SNR, specNorm etc 
# - Find target frequency bins and collect  scores at those freqs per subject 

library('dplyr')
library('data.table')
library('rlist')
rm(list=ls(all=TRUE))
# Define input directories and go to input dir
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/e_clusters_computedMeasures"
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/f_clusters_gathered_frequencies"
setwd(dirinput)


# Specify search patterns
measurenames <-  c('specmeans','specNorm','zscores','bcAmps','snr')
condition <- c("CSinFF","PWinFF","WinFF","FFinW","CSinW")
groups <- c('all','poor','typ','gap','poor_2nd','poor_3rd','typ_2nd','typ_3rd','2nd','3rd')

if (grepl('totalGAs',dirinput)){
  groups <- c("all","typ","poor","gap","typ_2nd","poor_2nd","gap_2nd","typ_3rd","poor_3rd","gap_3rd","2nd","3rd")
  condition <- c('5Conds','baseFF','baseW')  
  groups <- c('all')
  
} else if (grepl('*clusters*',dirinput)){
  
  condition <- c("CSinFF","PWinFF","WinFF","FFinW","CSinW")
  groups <- c('left','right')
  
}



# Input target frequencies (in Hz) (harmonics that were consecutively >1.97/significant for at least one condition)

myfreqs <- c(1.2,2.4,3.6,4.8,7.2,8.4,9.6)
myfreqsAllodds <- c(1.2,2.4,3.6,4.8,7.2,8.4,9.6)
myfreqsAV <- c(0.88,1.75, 2.62,3.5,5.25)
myfreqsLinPL <- c(0.9,1.8, 2.7,3.6,5.4)
myBasefreqs <- c(6,12,18,24,30,36,42,48) 
myBasefreqsAV <- c(4.38, 8.75, 13.12, 17.5, 21.88, 26.25, 30.62)
myBasefreqsLinPL <- c(4.5, 9, 13.5, 18, 22.5, 27, 31.5)

#Condition, measure, file Loops
#----------------------------------------------------------------------------------------------------
altogether <-list() 
counter <-1

for (c in 1:length(condition)) {
  currcond <- condition[c]
  for (m in 1:length(measurenames)) {
    currmeasure <- measurenames[m]
    for (g in 1:length(groups)){
      currgroup <- groups[g]
      # find files with Grand averages
      
      if (grepl('base',currcond) || grepl('5Conds',currcond))  {
        files <- dir(path = dirinput, pattern= paste0('^',currmeasure,'.*.',currcond,'.*.GA.*',currgroup,'.csv')) # find all files  
        print(files)
        
      } else if (grepl('*clusters*',dirinput)){ 
        files <-  dir(path = dirinput, pattern= paste0('^',currcond,'_',currmeasure,'_',currgroup,'.csv'))  
        
      } else {
        files <- dir(path = dirinput, pattern= paste0('^',currcond,'.*.',currmeasure,'*.GA_',currgroup,'.csv')) # find all files  
      }
      
      if (length(files)==0){ print('cannot find files!' )}
      
      
      #Go thru files
      allgathered <- list()
      for (f in 1:length(files)){
        df <- as.data.frame(data.table::fread(files[f],sep = ",",header = TRUE)) # this should be much faster read of the dataset
        chans <- df[,1]
        dat <- df[,2:ncol(df)]
        
        # retrieve some important info
        fnamesplit <-strsplit(files[f],"_","")
        freqbins <- as.numeric(colnames(dat))
        colnames(dat) <- freqbins
        
        # ODDBALLS
        #----------------------------------------------------------------------------------------------------------------------
        #SEARCH ODDBALL HARMONICS index target columns. Certain files had different frequencies: use conditional
        if (grepl("*AV",files[f])) {print("finding myfreqsAV") 
          freqs2search <- myfreqsAV
          
        }else if (grepl("*LinPL",files[f])) { print("finding myfreqsLinPL")
          freqs2search <- myfreqsLinPL
          
        }else if  (grepl('base',currcond) || grepl('5Conds',currcond))  { print("finding myfreqsAllodds")
          freqs2search <-  myfreqsAllodds 
          
        } else {print("finding my oddball frequencies") 
          freqs2search <- myfreqs
        }
        
        
        colidxs <- which(freqbins %in% freqs2search) 
        
        # make calculations
        if (length(colidxs)!=length(freqs2search)) {
          print('ay ay Abort !! something went wrong matching the file column names and your myfreqs variable.')
        } else {
          
          # take the data
          outdfOdd <-  dat[,c(colidxs)]
          
          # Define number of harmonics to sum
          nOddH_all <- 1:6
          nOddH_sepFFbase <- 1:6
          nOddH_sepWbase <- 1:5
          nOddH_sepAV <- 0
          nOddH_sepLinPL <- 0
          nOddH_sep5cond <- 1:5
          #
          Oddharmsum_all <- rowSums(outdfOdd[nOddH_all])  #sum of 4 harmonics
          Oddharmsum_sepFFbase <- rowSums(outdfOdd[nOddH_sepFFbase])
          Oddharmsum_sepWbase <- rowSums(outdfOdd[nOddH_sepWbase])
          Oddharmsum_sepAV <- rowSums(outdfOdd[nOddH_sepAV])
          Oddharmsum_sepLinPL <- rowSums(outdfOdd[nOddH_sepLinPL])
          Oddharmsum_sep5cond <- rowSums(outdfOdd[nOddH_sep5cond])
          
          if (grepl("*AV",files[f])) {
            Oddharmsum_sep <- Oddharmsum_sepAV
            Oddharmsum_sep_count <- length(nOddH_sepAV)
            
          } else if (grepl("*LinPL",files[f])) {
            Oddharmsum_sep <- Oddharmsum_sepLinPL
            Oddharmsum_sep_count <- length(nOddH_sepLinPL)
            
          } else if (grepl("*inFF",files[f])|| grepl("*baseFF",files[f])) {
            Oddharmsum_sep <- Oddharmsum_sepFFbase
            Oddharmsum_sep_count <- length(nOddH_sepFFbase)
            
          } else if (grepl("*inW",files[f]) || grepl("*baseW",files[f])) {
            Oddharmsum_sep <- Oddharmsum_sepWbase
            Oddharmsum_sep_count <- length(nOddH_sepWbase)
            
          } else if (grepl("*5Conds*",files[f])) {
            Oddharmsum_sep <- Oddharmsum_sep5cond
            Oddharmsum_sep_count <- length(nOddH_sep5cond)
          }
          outdfOdd <- cbind(outdfOdd,Oddharmsum_all,Oddharmsum_sep, Oddharmsum_sep_count)
        }
        
        
        
        #BASES
        #----------------------------------------------------------------------------------------------------------------------
        # Search BASE HARMONICS index target columns. Certain files had different frequencies: use conditional
        Basefreqs2search <- myBasefreqs
        
        colidxsBase <- which(freqbins %in% Basefreqs2search) 
        
        #make calculations
        if (length(colidxsBase)!=length(Basefreqs2search)) {
          print('ay ay Abort !! something went wrong matching the file column names and your myfreqs variable.')
        } else {
          
          # take the data
          outdfBase <-  dat[,c(colidxsBase)]
          
          # Define number of harmonics to sum
          nBaseH_all <- 1:7
          nBaseH_sepBaseW <- 1:7
          nBaseH_sep5cond <- 1:7
          nBaseH_sepCScond <- 1:7
          nBaseH_sepWFFcond <- 1:7
          
          nBaseH_sepAV <- 1:2
          nBaseH_sepLinPL <- 1:6
          
          # 
          Baseharmsum_all <- rowSums(outdfBase[nBaseH_all])  #sum of 4 harmonics
          Baseharmsum_sepCScond <- rowSums(outdfBase[nBaseH_sepCScond]) #conditions CSinFF/W
          Baseharmsum_sepWFFcond <- rowSums(outdfBase[nBaseH_sepWFFcond]) #conditions WinFF/FFinW
          Baseharmsum_sepAV <- rowSums(outdfBase[nBaseH_sepAV])
          Baseharmsum_sepLinPL <- rowSums(outdfBase[nBaseH_sepLinPL])
          Baseharmsum_sepBaseW <- rowSums(outdfBase[nBaseH_sepBaseW])
          Baseharmsum_sep5cond <- rowSums(outdfBase[nBaseH_sep5cond])
          
          
          
          if (grepl("*AV",files[f])) {
            Baseharmsum_sep <- Baseharmsum_sepAV
            Baseharmsum_sep_count <- length(nBaseH_sepAV)
            
          } else if (grepl("*LinPL",files[f])){
            Baseharmsum_sep <- Baseharmsum_sepLinPL
            Baseharmsum_sep_count <- length(nBaseH_sepLinPL)
            
          } else if (grepl("*CSin",files[f])){
            Baseharmsum_sep <- Baseharmsum_sepCScond
            Baseharmsum_sep_count <- length(nBaseH_sepCScond)
            
          } else if (grepl("*FFinW",files[f]) || grepl("*WinFF",files[f])){
            Baseharmsum_sep <- Baseharmsum_sepWFFcond
            Baseharmsum_sep_count <- length(nBaseH_sepWFFcond)
            
            
          } else if (grepl("*baseW",files[f])){
            Baseharmsum_sep <- Baseharmsum_sepBaseW
            Baseharmsum_sep_count <- length(nBaseH_sepBaseW)
            
          } else if (grepl("*baseW",files[f])){
            Baseharmsum_sep <- Baseharmsum_sep5cond
            Baseharmsum_sep_count <- length(nBaseH_sep5cond)
            
          } else if (grepl("*5Conds*",files[f])) {
            Baseharmsum_sep <- Baseharmsum_sep5cond
            Baseharmsum_sep_count <- length(nBaseH_sep5cond)
          }
          outdfBase <- cbind(outdfBase,Baseharmsum_all,Baseharmsum_sep,Baseharmsum_sep_count)
        }                   
        
        ##combine oddball and base info into one
        outdf <- cbind(outdfOdd,outdfBase)   
        
        
        #rename columns
        colnames(outdf) <- gsub("1.2","OddH01",colnames(outdf))
        colnames(outdf) <- gsub("2.4","OddH02",colnames(outdf))
        colnames(outdf) <- gsub("3.6","OddH03",colnames(outdf))
        colnames(outdf) <- gsub("4.8","OddH04",colnames(outdf))
        colnames(outdf) <- gsub("7.2","OddH05",colnames(outdf))
        colnames(outdf) <- gsub("8.4","OddH06",colnames(outdf))
        colnames(outdf) <- gsub("9.6","OddH07",colnames(outdf))
        
        colnames(outdf) <- gsub("^6$","BaseH01",colnames(outdf))
        colnames(outdf) <- gsub("12","BaseH02",colnames(outdf))
        colnames(outdf) <- gsub("18","BaseH03",colnames(outdf))
        colnames(outdf) <- gsub("24","BaseH04",colnames(outdf))
        colnames(outdf) <- gsub("30","BaseH05",colnames(outdf))
        colnames(outdf) <- gsub("36","BaseH06",colnames(outdf))
        colnames(outdf) <- gsub("42","BaseH07",colnames(outdf))
        colnames(outdf) <- gsub("48","BaseH08",colnames(outdf))
        
        
        ## Gather
        if (grepl('*clusters*',dirinput)) {
          grouping <- rep(currgroup,length(chans)) #make a column subject and chan info
          grouping <- sapply(strsplit(chans,'_'),'[[',1)
          chans <- sapply(strsplit(chans,'_'),'[[',2)
        } else{
          grouping <-paste0('GA_',rep(currgroup,length(chans))) #make a column with group and grade info  
        }
        
        cond <- rep(currcond,length(chans))
        measure <- rep(currmeasure,length(chans))
        
        gathered <- as.data.frame(cbind(grouping,measure,chans,cond,outdf))
        gathered$chans <- gsub(paste0(currmeasure,'_'),'',gathered$chans)
        
        
        # Add to the array for this measure
        allgathered[[f]] <- gathered   
        data.table::fwrite(gathered,file =  paste0(diroutput,'/',currcond,'_',currmeasure,'_',currgroup,'.csv'),row.names=FALSE)
        print(paste0("OUTPUTFILENAME .................",diroutput,'/',currcond,'_',currmeasure,'_',currgroup,'.csv'))
        
        # Add to biggest list of all 
        altogether[[counter]] <- allgathered[[f]]
        counter <- counter + 1 
        rm (list = c('outdf','dat','df','gathered'))
        
      }
      
      
    }
  } 
  
}

# If using the electrode clusters save the large dataset (wide formatted) to use in analysis 
if (grepl('*clusters*',dirinput)){
  alltogetherdf <- data.table::rbindlist(altogether)
  
  
  alltogetherdf_wide <- 
    tidyr::pivot_wider(alltogetherdf,
                       names_from = c('measure','chans','cond'),
                       values_from = colnames(alltogetherdf)[5:ncol(alltogetherdf)],
                       names_repair = "unique",
                       names_glue= "{measure}_{chans}_{cond}_{.value}")
  
  colnames(alltogetherdf_wide)[1] <- 'subject'
  data.table::fwrite(alltogetherdf_wide,file =  paste0(diroutput,'/FPVS_gathered_freqs.csv'),row.names=FALSE)
  
}
