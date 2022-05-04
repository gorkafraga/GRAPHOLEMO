#remotes:::install_github("yunshiuan/label4MRI")
rm(list=ls())
library(label4MRI)
# SEARCH MNI LABELS FROM A SET OF COORDINATES
#-------------------------------------------------------
dirinput<- 'O:/studies/grapholemo/analysis/LEMO_GFG/mri/regions_of_interest/neurosynth_images_downloads' 
diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/mri/regions_of_interest' 
setwd(diroutput)
files <- dir(dirinput,pattern='peaks_*.*.csv')
   
for (f in 1:length(files)){
     fileinput <- files[f]
     dat <- read.csv(paste0(dirinput,'/',fileinput),skip = 1)
     #dat <- readxl::read_xlsx(paste0(dirinput,'/',fileinput))
     #coords <-  as.data.frame(do.call(rbind,strsplit(dat$`xyz(mm)`,' ')))
     coords <- cbind(dat$x,dat$y,dat$z)
    label <- list()
    distances <- list()
    for (i in 1:nrow(coords)){
      if (!is.na(coords[i,1])) {
        info <- label4MRI::mni_to_region_name(x = coords[i,1],
                                               y= coords[i,2],
                                              z = coords[i,3])
        
         label[[i]] <- info$aal.label
         distances[[i]] <- round(info$aal.distance,2)
         print(i)
      }else{
        print(i)
        label[[i]] <-''
        distances[[i]] <- ''
      }
    }
    
    myregions <- as.data.frame(cbind(do.call(rbind,label),
                                do.call(rbind,distances)))
    
    tab2save <- cbind(dat,myregions)
    colnames(tab2save)[(ncol(tab2save)-1):ncol(tab2save)] <- c('aal','dist')
    #colnames(tab2save) <- c('x','y','z','aal','dist')
    #save
    writexl::write_xlsx(tab2save,paste0(diroutput,'/',gsub('.csv','.xlsx',paste0('Regions_',fileinput)))
)
}