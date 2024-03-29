# READ CSV FILES WITH TABLE OF RESULTS
rm(list=ls())
parentdir <- 'O:/studies/grapholemo/analysis/LEMO_GFG/mri/2ndLevel/FeedbackLearning/FBL_B/LEMO_rlddm_v32/'
files <-  dir(parentdir,'^2Lv_regre*')


for (f in 1:length(files)) { 
      dirinput <- paste0(parentdir,files[f],'/summary/')
      diroutput <- dirinput
      print('.')
      print(paste0('Checking ',  files[f]))
      
      # contrast loop
      for (i in 2:9) {
        #fileinput <- paste0('Results_Table_con_000',i,'_1.txt')
         
          fileinput <- paste0('Results_Table_con000',i,'_1.txt')
          if (i > 9){
            fileinput <- paste0('Results_Table_con00',i,'_1.txt')
          }
         
        
        
        
        print(fileinput)
        # Read table
        #----------------------- 
        setwd(dirinput)
        dat <- read.delim(fileinput,sep="\t",skip=1)
        # trim , leave only clusteres wehre FWE corr is < 0.05 
        trimdat <- dat[which(dat$p.FWE.corr. < 0.05),]
        colnames(trimdat)[(ncol(trimdat)-2):ncol(trimdat)] <- c('xcoord','ycoord','zcoord')
        if (nrow(trimdat)==0){
          print(paste0('no suprathreshold results in ',fileinput))
        } else {
          #  Format for saving
          myT<- cbind(fileinput,
                      trimdat$xcoord,
                      trimdat$ycoord,
                      trimdat$zcoord,
                      round(trimdat$p.FWE.corr.,4),
                      round(trimdat$p.unc.,4),
                      round(trimdat$equivk,2),
                      round(trimdat$equivZ,2),
                      round(trimdat$T,2),
                      round(trimdat$p.FWE.corr..1,4),
                      round(trimdat$p.unc..1,4),
                      round(min(dat$T),3))
          myT <- as.data.frame(myT)
          colnames(myT) <- c('file','xcoord','ycoord','zcoord','cluster_pFWE','cluster_punc','cluster_k','peak_Z','peak_T','peak_pFWE','peak_punc','T_heightThresh')
          
          # save 
          writexl::write_xlsx(myT,paste0(diroutput,'/',gsub('.txt','_clean.xlsx',fileinput)))
          
        }
      }
} 
