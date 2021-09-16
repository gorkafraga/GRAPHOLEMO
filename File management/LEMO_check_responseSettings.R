rm(list=ls(all=TRUE))#clear all

# Check Response Counterbalancing GRAPHOLEMO
#-----------------------------------------------------
dirinput <-"O:/studies/grapholemo/analysis/LEMO_GFG/mri/preprocessing"
diroutput <- "O:/studies/grapholemo/analysis/LEMO_GFG/"

files <- dir(dirinput,paste0('gpl.*.-','fbl_a','.*.txt'),recursive=TRUE,ignore.case = TRUE,full.names = FALSE)
subjects<- unique(substr(basename(files),1,6))

respCounterbalance <- list()
for (s in 1:length(subjects)){
  
  currfiles <- files[grep(subjects[s],files)]
  if (length(currfiles)> 1 ) {
    for (f in 1:length(currfiles)){
        tab <- read.table(paste(dirinput,currfiles[f],sep='/'),header = TRUE)
       
        if (purrr::is_empty(grep('LeftIsMatch',names(tab)))){
             print(paste0('found no column LeftIsMatch in ', currfiles[f])) 
          respCounterbalance[[s]] <- as.data.frame(t(c(subjects[s],'',basename(currfiles[[f]]))))
          
        } else {
          respCounterbalance[[s]] <- as.data.frame(t(c(subjects[s],tab$LeftIsMatch[1],basename(currfiles[[f]]))))
        }
    } 
  }

}
table2save <- data.table::rbindlist(respCounterbalance,fill = TRUE)
names(table2save) <- c('Subj_ID','leftIsMatch','file')

# save 
xlsx::write.xlsx(table2save,paste0(diroutput,'/response_counterbalancing.xls'))


