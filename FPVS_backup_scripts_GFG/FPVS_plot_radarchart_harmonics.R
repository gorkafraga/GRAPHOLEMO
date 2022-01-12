rm(list=ls(all=TRUE))
libraries <- c('dplyr','data.table','ggplot2','ggradar')
lapply(libraries, library, character.only = TRUE, invisible())

# Spider plot of harmonics 
#-------------------------------------------------------------------------------------------



# Define input directories and go to input dir
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/c_gathered_frequencies"
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/plots"

#files    

files <-dir(dirinput,pattern=paste("*.bcAmp.*all.csv$",sep=""),recursive = TRUE)   # specify a pattern if you want to narrow search. Else, it  takes everything in both subdirectories

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
  idxcols2plot <-  c(grep('OddH01',colnames(df)),
                     grep('OddH02',colnames(df)),
                     grep('OddH03',colnames(df)),
                     grep('OddH04',colnames(df)),
                     grep('OddH05',colnames(df)))
  
  ##################################################
  # PLOT 
  #=====================================================
  
  # Clusters
  leftChans <- c("058","059","060","064","065","066","068","069","070")
  rightChans <- c("096","091","085","095","090","084","094","089","083")
  
  
  # Plot left and right hemispheres  separate, then merge in subplot
  op <- par(mar = c(1, 1, 1, 1))
  jpeg(paste0(diroutput,'/Radar_',currgroup,'_',currmeasure,'_',currcond,'.jpg'),units = 'mm',height=200,width=250,res=150)
  
  #-------------------
  par(mfrow = c(1,2))
  
  # PLOT 1 
  df2plot <- df[which(df$chans %in% leftChans),c(grep('chan',colnames(df)),idxcols2plot)]
  df2plot<- df2plot[,-1]
  df2plot <- rbind(1,-0.02,df2plot) # required for radarchart
  #prepare colormaps 
  colors_border= rev(RColorBrewer::brewer.pal(20,'Dark2'))
  colors_in=alpha(colors_border,0.1)
  
  # RADAR CHART
  radarchart(df2plot,plwd=2,plty = 1.,  
             pcol=colors_border ,  pfcol=colors_in,
             cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,20,5), cglwd=0.8,
             vlcex=0.8,title=paste0('LEFT_',currgroup,'_',currmeasure,'_',currcond))
  
  par(xpd=TRUE)    
  legend(x=1, y=.2, legend = rownames(df2plot[-c(1,2),]), bty = "n", pch=20 , col=colors_border , text.col = "black", cex=1., pt.cex=1)
  par(xpd=FALSE) 
  
  # PLOT 2 
  df2plot <- df[which(df$chans %in% rightChans),c(grep('chan',colnames(df)),idxcols2plot)]
  df2plot<- df2plot[,-1]
  df2plot <- rbind(1,-0.02,df2plot) # required for radarchart
  #prepare colormaps 
  colors_border= rev(RColorBrewer::brewer.pal(20,'Dark2'))
  colors_in=alpha(colors_border,0.1)
  # RADAR CHART
  radarchart(df2plot,plwd=2,plty = 1.,  
             pcol=colors_border ,  pfcol=colors_in,
             cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,20,5), cglwd=0.8,
             vlcex=0.8,title=paste0('RIGHT_',currgroup,'_',currmeasure,'_',currcond))
  
  par(xpd=TRUE)
  legend(x=1, y=.2, legend = rownames(df2plot[-c(1,2),]), bty = "n", pch=20 , col=colors_border , text.col = "black", cex=1., pt.cex=1)
  par(xpd=FALSE) 
  #------------------- 
  # 
  dev.off()
  
}
