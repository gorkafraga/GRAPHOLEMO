
allfig <- list()
dpoints2search <- 1500:2000
spec <- specNorm[dpoints2search]
for (bin in 1:length(spec)) {
  
    count <- 0
    surroundingData <- vector()
    surroundingIdx <- vector()
    surroundings <- c(c((bin-2)-10):(bin-2),c(bin+2):((bin+2)+10))
    for (b in surroundings){ if (b < 1 || b > length(spec)) {} else { 
      surroundingData[count] <- spec[b]
      surroundingIdx[count] <- b
      count <- count + 1
    }
    }
    
      print(bin)
      df <- as.data.frame(spec)
      df$chunk <- NA
      df$chunk[surroundingIdx] <- df$spec[surroundingIdx]
      #
      df$highlight <- NA
      df$highlight[bin] <- df$spec[bin]
      #
      dflong<- tidyr::pivot_longer(df,cols = c('spec','chunk','highlight'))
      
      fig <-  
        
          ggplot(dflong,aes(y=value,x=1:dim(dflong)[1],color=name))+
          geom_line(aes(size=name)) +
          geom_point(aes(shape=name,size=name)) +
          scale_color_manual(values=c('red','blue','grey60'))+
          scale_size_manual(values=c(1,3,.2))+
          theme_bw()
  
      allfig[[bin]] <- fig
      #rm(surroundingData)
  }


#for (l in 1:dpoints2search[2]){
basemap <- allfig[1]
for (l in 1:10){
  print(allfig[[l]])
  Sys.sleep(2)
  dev.off
}
