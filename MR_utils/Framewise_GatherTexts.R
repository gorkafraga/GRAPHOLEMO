# GATHER TEXT FILES AND SAVE IN EXCEL
#Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("xlsx")
lapply(Packages, require, character.only = TRUE)
masterfile <- 'O:/studies/grapholemo/LEMO_Master.xlsx'
task <- 'symCtrl_post'

dirinput <- paste0('O:/studies/grapholemo/analysis/LEMO_GFG/mri/preprocessing/',task)
diroutput <- paste0('O:/studies/grapholemo/analysis/LEMO_GFG')
gatherall = 1

if (gatherall==1){
      runs <- c('run1','run2')
  
      if (length(grep("symC", task) == 1)==1){
        runs <-''
        
      }
      
     
      
      #read subjects from master
      masterdat <-read.xlsx(masterfile,sheet = 'MRI')
      masterdat <-dplyr::select(masterdat,'subjID')
      masterdat$subjID  <-tolower(masterdat$subjID)
      
      
      allfiles <- dir(dirinput,pattern = '*bold.csv',recursive=TRUE)
      for (r in 1:length(runs)){
       files <-  allfiles[grep(runs[r],allfiles)]
       subjects <- unlist(lapply(strsplit(files,"/"),'[',1)) # obtain subject list from files directory
        
        gathered <- list()
        for (f in 1:length(files)) {
          dat <- read.csv(paste(dirinput,'/',files[f],sep=''),sep='\t')
          summary <-  cbind(round(mean(dat$X0),3),round(max(dat$X0),3),length(which(dat$X0>0.99)))
          gathered[[f]] <- as.data.frame(cbind(subjects[f],basename(files[f]),summary))
        }
        
        G <- data.table::rbindlist(gathered)
        colnames(G) <-c("subjID","file",paste0(paste0("FWD_",task,"_"),runs[r],"_mean"),paste0(paste0("FWD_",task,"_"),runs[r],"_max"),paste0(paste0("FWD_",task,"_"),runs[r],"_nAbove1"))
        
        setwd(diroutput)
        Gmerged <- merge(masterdat,G,by="subjID",all = TRUE)
        Gmerged[is.na(Gmerged)] <- ''
        
        if (length(grep("symC", task) == 1)==1){
          outputfilename <- paste0('Gathered_FWD_',task,'.xlsx')
        } else {
          outputfilename <- paste0('Gathered_FWD_',task,'_',runs[r],'.xlsx')
          
        }
        write.xlsx(Gmerged,outputfilename,row.names = FALSE)
      }
      


} else if (gatherall==0){

  files2merge <- dir(diroutput,pattern = '*.xls',recursive=FALSE)
  gathered <- list()
  for (f in 1:length(files2merge)) {
    dat <- read.xlsx(paste(diroutput,'/',files2merge[f],sep=''),sheetIndex = 1)
     gathered[[f]] <- as.data.frame(dat)
  }
  
  G<-dplyr::bind_cols(gathered)
  setwd(diroutput)
  write.xlsx(G,'FWD_gathered.xlsx',row.names = FALSE)
  
}