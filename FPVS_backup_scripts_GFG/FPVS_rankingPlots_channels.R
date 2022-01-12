rm(list=ls(all=TRUE))
libraries <- c('dplyr','data.table','ggplot2')
lapply(libraries, library, character.only = TRUE, invisible())

# Electrode Ranking based on Z scores
#-------------------------------------------------------------------------------------------
# - Read zscores based  on GA
# - Get data with electrodes as rows and gathered zscores for frequencies of interest
# - Ranking electrodes


# Define input directories and go to input dir
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/c_gathered_frequencies"
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/d_rankings/rank_channels"

#files    

files <-dir(dirinput,pattern=paste("*.csv$",sep=""),recursive = TRUE)   # specify a pattern if you want to narrow search. Else, it  takes everything in both subdirectories

alltogether <- list()
for (f in 1:length(files)){
  fileinput <-files[f]
  df <- as.data.frame(data.table::fread(paste0(dirinput,'/',fileinput),sep = ",",header = TRUE))
  
  # read relevant info  (current condition,measure,group, etc)
  currgroup <- df$grouping[1]
  currcond <- df$cond[1]
  currmeasure<- df$measure[1]
  
  # Define electrodes and index of the relevant columns
  chanLabels <-  df$chans
  idxcols2rank <- c(grep('*.harmsum_all$',colnames(df)),
                    grep('*.harmsum_sep$',colnames(df))) 
  
  ranks <- data.frame(matrix(nrow=length(chanLabels),ncol=length(idxcols2rank)))
  
  for (i in 1:length(idxcols2rank)){
    ranks[,i] <- chanLabels[order(-df[,idxcols2rank[i]])] #
    colnames(ranks)[i] <- paste0('RankCh_',colnames(df)[idxcols2rank[i]])
    
  }
  
  ranks$RankN <- 1:length(chanLabels)
  ranks <- relocate(ranks, RankN)# move rank numbers to first colum
  # Add relevant info
  ranks$group <- currgroup
  ranks$cond <- currcond
  ranks$measure <- currmeasure
  ranks <- relocate(ranks, c('group','cond','measure'))# move to the beginning beginning
  #  save table  
  data.table::fwrite(ranks, paste0(diroutput,'/RankCh_',currgroup,'_',currmeasure,'_',currcond,'.csv'),row.names=FALSE)
  
  
  
  
  #plot
  rankslong <- tidyr::pivot_longer(ranks,-RankN)
  rankslong <- rankslong[which(rankslong$RankN <6),]
  rankslong <- rankslong[grep("harmsum_sep",rankslong$name),]
  
  fig <- ggplot(rankslong,aes(x=RankN,y = value,group=name))+geom_point(aes(fill=name),shape=23,size=5,alpha=.7,position=position_dodge(width = .2))+ theme_bw() + 
    labs(y="electrode label",title = paste0("Ranking electrodes ",currgroup,"_",currmeasure,"_",currcond))
  # save plot
  ggsave(fig, filename = paste0(diroutput,'/RankCh_',currgroup,'_',currmeasure,'_',currcond,'.jpg'),width = 150,height =200,units='mm')
  
  alltogether[[f]] <- ranks
}

allranks <- data.table::rbindlist(alltogether)
# Save  all ranks gathered 
data.table::fwrite(allranks, paste0(diroutput,'/Gathered_ranking_channels.csv'),row.names=FALSE)


