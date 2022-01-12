# Harmonic Ranking based on Z scores
#-------------------------------------------------------------------------------------------
# - Read zscores based  on GA
# - Get data with electrodes as rows and gathered zscores for frequencies of interest
# - Ranking electrodes
library('dplyr')
library('data.table')
library('rlist')
library('ggplot2')
rm(list=ls(all=TRUE))

# Define input options
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/c_gathered_frequencies/"
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/d_rankings/rank_harmonics_zscores/"
zthreshold <- 2.58

# find files with zscores
files <- dir(path = dirinput,pattern = '*zscores.*',recursive = TRUE )

# Go thru files
for (f in 1:length(files)){
  # read data   
  fileinput <- files[f]
  df <- as.data.frame(data.table::fread(paste0(dirinput,'/',fileinput),sep = ",",header = TRUE))
  
  
  # long transform 
  dflong<- tidyr::pivot_longer(df, cols= grep(x=colnames(df),pattern='*.H.*'),names_to ='harmonic',values_to = 'score')
  dflong$type <- sapply(strsplit(dflong$harmonic,'H'),'[[',1)
  dflong$harmonic <- paste0('H',sapply(strsplit(dflong$harmonic,'H'),'[[',2))
  
  #introduce dummy variables to highlighting some values
  dflong$highlight <- ''
  dflong$highlight[which(dflong$score>zthreshold)] <- 'on'
  dflong$highlight[which(dflong$score<zthreshold)] <- 'off'
  dflong$highlight <- as.factor(dflong$highlight)
  # channels of interest
  dflong$coi <- ''
  dflong$coi[which(dflong$chans %in% c('065', '069','070','083','089','090'))] <- 'occip'
  
  ## PLOT
  fig <-     
    ggplot(dflong,aes(y=score,x=harmonic))+ geom_point(aes(fill=chans,shape=coi,alpha=highlight,size=highlight))+ 
    scale_shape_manual(values= c(21,24)) +
    scale_alpha_manual(values= c(.1,1),guide='none') +
    scale_size_manual(values= c(2,4),guide='none') +
    scale_fill_discrete() +
    facet_grid(~type)+
    geom_hline(yintercept = 2.58,linetype='dashed',color='red')+
    theme_bw()+
    labs(y = 'z score',title =files[f])+
    scale_y_continuous(breaks=seq(round(min(dflong$score)),round(max(dflong$score)),1))+
    guides(fill=guide_legend(override.aes=list(shape=23)))
  
  
  ggsave(paste0(diroutput,'/',gsub('.csv','.jpg',basename(fileinput))),fig,width = 325, height = 150, dpi=150, units = "mm")    
}




