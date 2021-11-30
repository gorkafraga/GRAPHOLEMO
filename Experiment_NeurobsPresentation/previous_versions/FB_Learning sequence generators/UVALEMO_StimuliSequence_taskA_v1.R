rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr","cowplot","tidyr","psych","ggpubr","gridExtra","writexl")
lapply(Packages, require, character.only = TRUE)
#################################
diroutput<- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/Experiment_NeurobsPresentation/FB_Learning sequence generators"

audioseq <- list()
for (i in 1) {
  seq <- c(3,6,2,1,5,2,5,4,1,3,5,4,2,4,3,4,6,3,1,6,1,3,5,4,6,1,6,1,4,1,6,5,3,4,6,2,5,3,2,3,2,5,2,1,5,2,4,6)
  ii <-0 
  while (length(which(diff(sort(c(which(seq==1),c(which(seq==2)))))==1)>2) ||
         length(which(diff(sort(c(which(seq==3),c(which(seq==4)))))==1)>2) ||
         length(which(diff(sort(c(which(seq==5),c(which(seq==6)))))==1)>2) ||
         length(which(abs(diff(seq))==0)>0)){
         
    seq <- sample(seq)
    ii <- ii+1
    print(ii)
  }
  audioseq[[i]] <-seq
}

chunk1 <- c(3,5)
chunk2 <- c(4,6)














audioseq <- list()
for (i in 1:4) {
seq <- c(3,6,2,1,5,2,5,4,1,3,5,4,2,4,3,4,6,3,1,6,1,3,5,4,6,1,6,1,4,1,6,5,3,4,6,2,5,3,2,3,2,5,2,1,5,2,4,6)
  ii <-0 
  while (length(which(abs(diff(seq))==0)>0)){
           seq <- sample(seq)
           ii <- ii+1
           print(ii)
  }
  audioseq[[i]] <-seq
}

# visual 

nreps <- 8
visualseq <- list()
for (b in 1:length(audioseq)){
  visualseq[[b]] <- rep(0,length(audioseq[[b]]))
  
  tmp<- sample(which(audioseq[[b]]==1))
  visualseq[[b]][tmp[1:(nreps/2)]] <- 1
  visualseq[[b]][tmp[1+(nreps/2):length(tmp)]] <- 2
  
  tmp<- sample(which(audioseq[[b]]==2))
  visualseq[[b]][tmp[1:(nreps/2)]] <- 2
  visualseq[[b]][tmp[1+(nreps/2):length(tmp)]] <- 1
     
  tmp<- sample(which(audioseq[[b]]==3))
  visualseq[[b]][tmp[1:(nreps/2)]] <- 3
  visualseq[[b]][tmp[1+(nreps/2):length(tmp)]] <- 4
  
  tmp<- sample(which(audioseq[[b]]==4))
  visualseq[[b]][tmp[1:(nreps/2)]] <- 4
  visualseq[[b]][tmp[1+(nreps/2):length(tmp)]] <- 3       
  
  tmp<- sample(which(audioseq[[b]]==5))
  visualseq[[b]][tmp[1:(nreps/2)]] <- 5
  visualseq[[b]][tmp[1+(nreps/2):length(tmp)]] <- 6
  
  tmp<- sample(which(audioseq[[b]]==6))
  visualseq[[b]][tmp[1:(nreps/2)]] <- 6
  visualseq[[b]][tmp[1+(nreps/2):length(tmp)]] <- 5
          
 #bb <-0 
#  while (length(which(abs(diff(visualseq[[b]]))==0)>0)){
#    visualseq[[b]] <- sample(visualseq[[b]])
#    ii <- ii+1
#    print(ii)
#  }
 
               
}
table2save <- data.frame(rbind(matrix(unlist(audioseq), nrow=length(audioseq), byrow=TRUE),
                    matrix(unlist(visualseq), nrow=length(visualseq), byrow=TRUE)))

colnames(table2save) <-c(1:length(table2save))
rownames(table2save) <- c(paste0('Audio',1:4),paste0('Visual',1:4))

# Save each sequence in one sheet
setwd(diroutput)
xlsx::write.xlsx(table2save,'Seqs_UVALEMO_A.xlsx',row.names = TRUE)























####################################################################################
audioseqB <- list() 
audioseqB[[1]] <- c(5, 2, 6, 1, 4, 2, 4, 3, 6, 5, 1, 2, 5, 4, 6, 2, 5, 6, 4, 1, 4, 5, 4, 6, 2, 4, 3, 1, 2, 3, 1, 3, 6, 5, 6, 5, 2, 3, 1, 3, 1, 4, 3, 6, 1, 3, 2, 5)
audioseqB[[2]] <- c(1, 3, 6, 3, 6, 2, 1, 4, 2, 1, 2, 6, 5, 1, 3, 5, 2, 6, 4, 5, 2, 3, 6, 4, 3, 5, 6, 4, 1, 5, 6, 5, 4, 5, 3, 1, 4, 3, 6, 1, 2, 3, 4, 2, 4, 2, 1, 5)
audioseqB[[3]] <- c(1, 2, 1, 5, 2, 3, 4, 2, 5, 4, 5, 6, 4, 2, 3, 6, 3, 1, 6, 3, 4, 6, 3, 1, 3, 1, 4, 5, 4, 2, 6, 1, 3, 5, 6, 1, 5, 4, 1, 2, 5, 6, 2, 6, 5, 2, 4, 3)
audioseqB[[4]] <- c(4, 6, 4, 3, 1, 6, 4, 5, 4, 2, 6, 5, 2, 5, 3, 6, 3, 5, 6, 4, 1, 2, 4, 3, 6, 1, 3, 1, 6, 2, 5, 2, 1, 3, 1, 4, 5, 2, 5, 1, 2, 4, 2, 1, 3, 5, 3, 6)
 
nreps <- 8
visualseqB <- list()
for (b in 1:length(audioseq)){
  visualseqB[[b]] <- rep(0,length(audioseqB[[b]]))
  
  tmp<- sample(which(audioseqB[[b]]==1))
  visualseqB[[b]][tmp[1:(nreps/2)]] <- 1
  visualseqB[[b]][tmp[1+(nreps/2):length(tmp)]] <- 2
  
  tmp<- sample(which(audioseqB[[b]]==2))
  visualseqB[[b]][tmp[1:(nreps/2)]] <- 2
  visualseqB[[b]][tmp[1+(nreps/2):length(tmp)]] <- 1
  
  tmp<- sample(which(audioseqB[[b]]==3))
  visualseqB[[b]][tmp[1:(nreps/2)]] <- 3
  visualseqB[[b]][tmp[1+(nreps/2):length(tmp)]] <- 4
  
  tmp<- sample(which(audioseqB[[b]]==4))
  visualseqB[[b]][tmp[1:(nreps/2)]] <- 4
  visualseqB[[b]][tmp[1+(nreps/2):length(tmp)]] <- 3       
  
  tmp<- sample(which(audioseqB[[b]]==5))
  visualseqB[[b]][tmp[1:(nreps/2)]] <- 5
  visualseqB[[b]][tmp[1+(nreps/2):length(tmp)]] <- 6
  
  tmp<- sample(which(audioseqB[[b]]==6))
  visualseqB[[b]][tmp[1:(nreps/2)]] <- 6
  visualseqB[[b]][tmp[1+(nreps/2):length(tmp)]] <- 5
  
}
table2save <- data.frame(rbind(matrix(unlist(audioseqB), nrow=length(audioseqB), byrow=TRUE),
                               matrix(unlist(visualseqB), nrow=length(visualseqB), byrow=TRUE)))

colnames(table2save) <-c(1:length(table2save))
rownames(table2save) <- c(paste0('Audio',1:4),paste0('Visual',1:4))

# Save each sequence in one sheet
setwd(diroutput)
xlsx::write.xlsx(table2save,'Seqs_UVALEMO_B.xlsx',row.names = TRUE)
 