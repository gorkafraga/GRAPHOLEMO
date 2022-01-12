# Gather  scores from specific frequencies  
#-------------------------------------------------------------------------------------------
# - read csv with z scores, SNR, specNorm etc 
# - Find target frequency bins and collect  scores at those freqs per subject 

library('dplyr')
library('data.table')
library('rlist')
rm(list=ls(all=TRUE))
# Define input directories and go to input dir
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/data/GA_allChans_Z_BC_etc"
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/"

# find files
setwd(dirinput)


listgroups <- c('Poor2','Poor3','Typ2','Typ3','Gap2','Gap3')


# LOOP thru groups and then thru files for that group
allgathergroups <-list()
for (gg in 1:length(listgroups)){
  
  files <-  dir(pattern=paste0('*.',listgroups[gg],'.*.csv')) # find all files
        
        # Input target frequencies (in Hz) (harmonics that were consecutively >1.97/significant for at least one condition)
        myfreqs <- c(1.2,2.4,3.6,4.8,7.2)
        myfreqsAV <- c(0.88,1.75, 2.62,3.5,5.25)#c(0,0.875,1.75, 2.625,3.5,4.375)
        myfreqsLinPL <- c(0.9,1.8, 2.7,3.6,5.4)#c(0,0.9,1.8, 2.7,3.6,4.5)
        myBasefreqs <- c(6,12,18,24,30,36,42) 
        myBasefreqsAV <- c(4.38, 8.75, 13.12, 17.5, 21.88, 26.25, 30.62)#c(4.38, 8.75, 13.15, 17.53, 21.9)#c(0,0.875,1.75, 2.625,3.5,4.375)
        myBasefreqsLinPL <- c(4.5, 9, 13.5, 18, 22.5, 27, 31.5)#c(0,0.9,1.8, 2.7,3.6,4.5)
        
        #Check filename consistency
        checknames<- list()
        for (f in 1:length(files)){
          checknames[[f]] <-  length(strsplit(files[f],"_","")[[1]])
        }
          if (sum(diff(unlist(checknames)))!=0){
            print('There is no consistency in the number of parts in your filenames')
            rm(files)
          }
        
        
        #File Loop
        #----------------------------------------------------------------------------------------------------
        allgathered <- list()
        
        for (f in 1:length(files)){
          df <- as.data.frame(data.table::fread(files[f],sep = ",")) # this should be much faster read of the dataset
          dat <- df[,4:dim(df)[2]]
          
          # retrieve some important info
          fnamesplit <-strsplit(files[f],"_","")
          condition <- gsub(".csv","",fnamesplit[[1]][as.numeric(lapply(fnamesplit,grep, pattern="*.csv"))]) # splits file name by "_", applies a function to find the piece containing extension and deletes the extension from that part 
          type <- fnamesplit[[1]][5] #6th element of the list (of the split filename) is the type description!
          
          sourcefiles <- unique(df$file)   
          group <- unique(df$group)
          mychans <- unique(df$chan)
          freqbins <- as.numeric(colnames(dat))
          colnames(dat) <- freqbins
          
          
          ######################################################################################
          # ODDBALLS
          ######################################################################################
          #SEARCH ODDBALL HARMONICS index target columns. Certain files had different frequencies: use conditional
          if (length(grep("*AV",files[f]))==1) {
            freqs2search <- myfreqsAV
            print("finding myfreqsAV")
          }else if (length(grep("*LinPL",files[f]))==1) {
            freqs2search <- myfreqsLinPL
            print("finding myfreqsLinPL")
          } else {
            freqs2search <- myfreqs
            print("finding myfreqs")
          }
          colidxs <- which(freqbins %in% freqs2search) 
          # make calculations
          if (length(colidxs)!=length(freqs2search)) {
            print('ay ay Abort !! something went wrong matching the file column names and your myfreqs variable.')
          } else {
            
            # take the data
            outdf <-  dat[,c(colidxs)]
           
            # # CorrEx SLRT-ELFE-combined criteria analysis 
            No.OBHarm_all <- 1:5
            No.OBHarm_sepFFbase <- 1:5
            No.OBHarm_sepWbase <- 1:4
            No.OBHarm_sepAV <- 0
            No.OBHarm_sepLinPL <- 0
            No.OBHarm_singles <- 0
            
         
            OBharmsum_all <- rowSums(outdf[No.OBHarm_all])  #sum of 4 harmonics
            OBharmsum_sepFFbase <- rowSums(outdf[No.OBHarm_sepFFbase])
            OBharmsum_sepWbase <- rowSums(outdf[No.OBHarm_sepWbase])
            OBharmsum_sepAV <- rowSums(outdf[No.OBHarm_sepAV])
            OBharmsum_sepLinPL <- rowSums(outdf[No.OBHarm_sepLinPL])
            OBharmsum_singles <- rowSums(outdf[No.OBHarm_singles])
            
            
            if (length(grep("*AV",files[f]))==1) {
              OBharmsum_sep <- OBharmsum_sepAV
              outdf <- cbind(outdf,OBharmsum_all,OBharmsum_sep, OBharmsum_singles)
            } 
            else if (length(grep("*LinPL",files[f]))==1) {
              OBharmsum_sep <- OBharmsum_sepLinPL
              outdf <- cbind(outdf,OBharmsum_all,OBharmsum_sep, OBharmsum_singles)
            } 
            else if (length(grep("*inFF",files[f]))==1) {
              OBharmsum_sep <- OBharmsum_sepFFbase
              OBharmsum_singles <- 0
              outdf <- cbind(outdf,OBharmsum_all,OBharmsum_sep, OBharmsum_singles)
            } 
            else if (length(grep("*inW",files[f]))==1) {
              OBharmsum_sep <- OBharmsum_sepWbase
              OBharmsum_singles <- 0
              outdf <- cbind(outdf,OBharmsum_all,OBharmsum_sep, OBharmsum_singles)
            }
          }
          
          
          ######################################################################################
          #BASES
          ######################################################################################
          # Search BASE HARMONICS index target columns. Certain files had different frequencies: use conditional
          if (length(grep("*AV",files[f]))==1) {
            Basefreqs2search <- myBasefreqsAV
            print("finding myBasefreqsAV")
          }else if (length(grep("*LinPL",files[f]))==1) {
            Basefreqs2search <- myBasefreqsLinPL
            print("finding myBasefreqsLinPL")
          } else {
            Basefreqs2search <- myBasefreqs
            print("finding myBasefreqs")
          }
          colidxsBase <- which(freqbins %in% Basefreqs2search) 
          
          #make calculations
          if (length(colidxsBase)!=length(Basefreqs2search)) {
            print('ay ay Abort !! something went wrong matching the file column names and your myfreqs variable.')
          } else {
            
            # take the data
            outdfBase <-  dat[,c(colidxsBase)]
            
            
            #CorrEX      ################################################################
            #SLRTmean and SLRT-ELFE-combined criteria analysis stay the same
            No.BaseHarm_all <- 1:7
            No.BaseHarm_sepCScond <- 1:7
            No.BaseHarm_sepWFFcond <- 1:7
            No.BaseHarm_sepAV <- 1:2
            No.BaseHarm_sepLinPL <- 1:6
            No.BaseHarm_singles <- 1:6
             
            Baseharmsum_all <- rowSums(outdf[No.BaseHarm_all])  #sum of 4 harmonics
            Baseharmsum_sepCScond <- rowSums(outdf[No.BaseHarm_sepCScond]) #conditions CSinFF/W
            Baseharmsum_sepWFFcond <- rowSums(outdf[No.BaseHarm_sepWFFcond]) #conditions WinFF/FFinW
            Baseharmsum_sepAV <- rowSums(outdf[No.BaseHarm_sepAV])
            Baseharmsum_sepLinPL <- rowSums(outdf[No.BaseHarm_sepLinPL])
            Baseharmsum_singles <- rowSums(outdf[No.BaseHarm_singles])
            
            
            if (length(grep("*AV",files[f]))==1) {
              Baseharmsum_sep <- Baseharmsum_sepAV
              outdfBase <- cbind(outdfBase,Baseharmsum_all,Baseharmsum_sep, Baseharmsum_singles)
            } 
            else if (length(grep("*LinPL",files[f]))==1) {
              Baseharmsum_sep <- Baseharmsum_sepLinPL
              outdfBase <- cbind(outdfBase,Baseharmsum_all,Baseharmsum_sep, Baseharmsum_singles)
            } 
            else if (length(grep("*CSin",files[f]))==1) {
              Baseharmsum_singles <- 0
              Baseharmsum_sep <- Baseharmsum_sepCScond
              outdfBase <- cbind(outdfBase,Baseharmsum_all,Baseharmsum_sep, Baseharmsum_singles)
            } 
            else if ((length(grep("*FFinW",files[f]))==1) | (length(grep("*WinFF",files[f]))==1)) {
              Baseharmsum_singles <- 0
              Baseharmsum_sep <- Baseharmsum_sepWFFcond
              outdfBase <- cbind(outdfBase,Baseharmsum_all,Baseharmsum_sep, Baseharmsum_singles)
            }
            
            
            outdf <- cbind(outdf,outdfBase)   ##combine oddball and base info into one
            
            #name columns; columns at this point are just the frequencies e.g. 0.88 ->replace
            #colnames(outdf) <- gsub("[.]","pt",paste0(colnames(outdf),"hz"))   # replaces . for 'pt' to avoid problems reading variable name. M<aybe is nicer to use labels like base and harmo1,harmo2 instead 
            colnames(outdf) <- gsub("[.]","pt",paste0(paste(type,mychans,condition,sep="_"),"_",colnames(outdf),"hz"))   # replaces . for 'pt' to avoid problems reading variable name. M<aybe is nicer to use labels like base and harmo1,harmo2 instead 
            
            ##add subject file info
            gathered <- cbind(as.data.frame(substr(sourcefiles,1,4)),group,mychans,condition,type,sourcefiles,outdf)
            #gathered <- cbind(as.data.frame(substr(sourcefiles,1,4)),sourcefiles,outdf)
            colnames(gathered)[1] <- "subject"
            colnames(gathered)[2] <- "group"
            colnames(gathered)[3] <- "channel"
            colnames(gathered)[4] <- "condition"
            colnames(gathered)[5] <- "type"
            allgathered[[f]] <- gathered  ##what does this do?
            
            #if (grepl("*AV.csv",files[f])) {
            #  AVgathered[[f]] <- gathered
            #}else if (grepl("*LinPL.csv",files[f])) {
            #  LinPLgathered[[f]] <- gathered
            #} else {
            #  stringsgathered[[f]] <- gathered
            #}
            
            #obj_name = deparse(substitute(preffix))
            
            #setwd(diroutput)
            #outputfilename <- paste0(preffix,".csv",sep="")
            #if(length(dir(pattern = outputfilename))== 1) {
            #  print("file found!!!! rename existing file!!!!!")
            #} else {write.csv(allgathered[[f]],file = paste0(diroutput,'/',outputfilename),row.names = FALSE)
            #}
            rm (freqs2search)
            setwd(dirinput)
          }
        }
 allgathergroups[[gg]] <- allgathered
}
        
#put alltogether        
combinedcols <- lapply(allgathergroups,function(x) rlist::list.cbind(x))
table2save <- rbindlist(combinedcols)

#split group info into group and class
table2save$Class <- as.vector(sapply(table2save$group, function(x) substr(x,nchar(x),nchar(x))))
table2save$Group <-as.vector(sapply(table2save$group, function(x) substr(x,1,nchar(x)-1)))
table2save <- table2save %>% relocate('Group',.after="subject")
table2save <- table2save %>% relocate('Class',.after="Group")
table2save$Subj <- table2save$subject
#Remove redundant information
table2save <- select(table2save,unique(colnames(table2save)))
table2save <- select(table2save,which(!grepl('channel.*',names(table2save))))
table2save <- select(table2save,which(!grepl('condition*',names(table2save))))
table2save <- select(table2save,which(!grepl('group*',names(table2save))))
table2save <- select(table2save,which(!grepl('type*',names(table2save))))
table2save <- select(table2save,which(!grepl('sourcefiles.*',names(table2save))))
table2save <- select(table2save,which(!grepl('subject.*',names(table2save))))

table2save <- dplyr::rename(table2save,subject=Subj)
table2save <- table2save %>% relocate('subject',.before="Group")


filename_Final <- paste0("FPVS_gatheredBins_GA",".csv",sep="")

if(length(dir(pattern = filename_Final))== 1) {
  print("file found!!!! rename existing file!!!!!")
} else {
  write.csv(table2save,file = paste0(diroutput,'/',filename_Final),row.names = FALSE)
  haven::write_sav(table2save,paste0(diroutput,gsub('.csv','.sav',filename_Final)))
}


