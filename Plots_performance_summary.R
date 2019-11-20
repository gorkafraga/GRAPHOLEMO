#Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr")
lapply(Packages, library, character.only = TRUE)
 
#set inputs
dirinput <- "O:/studies/grapholemo/log_tests"
diroutput <- dirinput
task <- "FeedLearn"
ntrials <- 40

setwd(dirinput)
files <- dir(pattern=paste("*.",task,".*.txt",sep=""))

#read data per file and combine in array
datalist <- list()
for (i in 1:length(files)){
  # data 
  D <- read_delim(files[i],"\t", escape_double = FALSE, locale = locale(), trim_ws = TRUE, skip_empty_rows=TRUE)
  
  # Get indexes per feedback (b) /response type.
  idx_miss <- which(D$fb==2)
  idx_hit <- which(D$fb==1)
  idx_err <- which(D$fb==0)
  # add a column with a response type label
  D$respType <- 0
  D$respType[idx_miss] <- 'miss'
  D$respType[idx_hit] <- 'hit'
  D$respType[idx_err] <- 'error'  
  
  #PLOT: Scatter  RTs per fb type
  #------------------------------------------------------------------------------
  ylims <- c(0,4000)
  ysep <- 250
  cols <-  c("forestgreen","firebrick1","yellow") #set your own color palette! 
  #scat_RTs <- 
    ggplot(data = D, aes(x = D$trial, y = D$rt, colour = respType)) +
              #geom_vline(xintercept = 0,color="grey" ) + # add lines at strategic points
              geom_vline(xintercept = 10,color="grey" ) +
              geom_vline(xintercept = 20,color="grey" ) +
              geom_vline(xintercept = 30,color="grey" ) +
      
              geom_hline(yintercept = 0,linetype = "dashed",color="blue" ) + # add lines at strategic points
              geom_hline(yintercept = 2000,linetype = "dashed",color="blue" ) + # add lines at strategic points
              geom_point(aes(fill=respType,shape=respType),alpha = .8,size=3.5,color="black", stroke = .16) + 
              scale_shape_manual(values=c(21,21,17)) +
              labs(title =files[i], y = "RT", x = "Trial Number") + # add some lables and title
              theme_classic() + # you can play around with different themes with preset background grids, axis lines etc
              scale_y_continuous(limits = ylims, breaks = (seq(ylims[1],ylims[2],ysep)), labels= (seq(ylims[1],ylims[2],ysep)))+  # play with y axis ticks and range
              scale_x_continuous(breaks = seq(0,ntrials,5)) +  # play with y axis ticks and range 
              theme(axis.text.x = element_text(angle = 45,colour = "black",size=10, hjust = 1)) +   
              scale_fill_manual(values=cols) +
              scale_color_manual(values=cols) 
  
  #PLOT: Density RTs per fb type
  #------------------------------------------------------------------------------
  ylims <- c(0,4000)
  ysep <- 250
  cols <-  c("forestgreen","firebrick1","yellow") #set your own color palette! 
  scat_RTs <- ggplot(data = D, aes(x = D$trial, y = D$rt, colour = respType)) +
    geom_hline(yintercept = 0,linetype = "dashed",color="blue" ) + # add lines at strategic points
    geom_hline(yintercept = 2000,linetype = "dashed",color="blue" ) + # add lines at strategic points
    geom_point(aes(fill=respType,shape=respType),alpha = .8,size=3.5,color="black", stroke = .16) + 
    scale_shape_manual(values=c(21,21,17)) +
    labs(title =files[i], y = "RT", x = "Trial Number") + # add some lables and title
    theme_classic() + # you can play around with different themes with preset background grids, axis lines etc
    scale_y_continuous(limits = ylims, breaks = (seq(ylims[1],ylims[2],ysep)), labels= (seq(ylims[1],ylims[2],ysep)))+  # play with y axis ticks and range 
    theme(axis.text.x = element_text(angle = 45,colour = "black",size=10, hjust = 1)) +   
    scale_fill_manual(values=cols) +
    scale_color_manual(values=cols) 
  #D$trial <- as.numeric(D$trial)
  #D <- D[which(D$block==1|D$block==2|D$block==3|D$block==4),]  #exclude practice trials and unnecessary rows (e.g., with avg_resp). It should have now 200 x 4 = 800 rows
  D <- cbind(rep(as.integer(substr(files[i],1,2)),dim(D)[1]),D)
  #D<-D[D$resp!=0,] # remove 'too slow ' responses 
  colnames(D)[1] <- "subjID"
  colnames(D)[grep("rt",colnames(D))] <- "RT" 
  D[grep("RT",colnames(D))] <- D[grep("RT",colnames(D))]/1000 # RTs in seconds
  D <- as_tibble(cbind(D,paste(D$vFile,D$aFile)))
  colnames(D)[ncol(D)] <- "pair"
  D["hit"] = "NA"
  for (j in 1:max(as.numeric(D$trial))){
    if (D[j,]$fb == 1){
      D[j,]$hit = j
    }
    else D[j,]$hit = "NA"
  }
  datalist[[i]] <- D
}

Gather <- as_tibble(data.table::rbindlist(datalist, fill=TRUE)) # combine all data frames in one
#Save as CSV
setwd(diroutput)
write.table(Gather,file = paste("performance_all_",task,".txt",sep=""),sep="\t",row.names = FALSE,quote=FALSE)

x1 = factor(Gather$hit, levels=1:36)
Gather <- cbind(Gather, x1)

subj <- unique(Gather$subjID)
df_subj <- list()
for (i in 1:length(subj)){
  df_subj[[i]] <- subset(Gather, subjID == subj[i])
  blocks <- unique(df_subj[[i]]$block)
  for (j in 0:(length(blocks)-1)){
    data <- subset(Gather, subjID==i & block==j & hit!="NA")
    p<-ggplot(data, aes(x=x1, color=pair)) + 
      geom_histogram(breaks=seq(1, 36, by=1), fill="white", stat="count")+
      scale_x_discrete(drop = FALSE)+
      geom_density(alpha=.2, fill="#FF6666") 
    ggsave(p, file=paste("Hits Distribution","Subj_",i,"_B",j,".png", sep=""),width = 6, height = 6, scale=1)
  }
}

data <- subset(Gather, subjID=1 & block=1 & hit!="NA")
p<-ggplot(Gather, aes(x=hit, color=pair)) + 
  geom_histogram(color="black", fill="white")+
  geom_density(alpha=.2, fill="#FF6666") 
p

rhat(ddm_model2)
printFit(ddm_model2)
