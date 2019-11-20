
#Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr","cowplot","tidyr")
lapply(Packages, library, character.only = TRUE)
source("N:/Developmental_Neuroimaging/Scripts/Misc R/R-plots and stats/Geom_flat_violin.R")
#set inputs
dirinput <- "O:/studies/grapholemo/log_tests"
diroutput <- dirinput
task <- "FeedLearn"
ntrials <- 40


setwd(dirinput)
files <- dir(pattern=paste("*.",task,".*.txt",sep=""))

#read data per file and combine in array
datalist <- list()
i <- 3
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
  D$respType <- as.factor(D$respType)
  
  # Gather counts per respType per stimuli
  hits_per_sound <-  D %>% 
                    filter(fb==1) %>%
                    group_by(aStim,.drop = FALSE) %>%
                    tally() 
  
  errors_per_sound <-  D %>% 
                      filter(fb==0) %>%
                      group_by(aStim,.drop = FALSE) %>%
                      tally() 
                    
  miss_per_sound <-  D %>% 
                    filter(fb==2) %>%
                    group_by(aStim,.drop = FALSE) %>%
                    tally() 
  
                  
  cumSum <- D %>% group_by(aStim,.drop=FALSE) %>% cumsum()
  
  # Gather cumulative probability per stimuli
    tmplist <- split(D,D$aStim) # split by audio type
    for (ii in 1:length(tmplist)) {
      tmplist[[ii]]$fb[which(tmplist[[ii]]$fb==2)] <- 0  # set 'too slow responses' to zero
      cumSum <- tmplist[[ii]] %>%  select(fb) %>% cumsum() # apply cumsum function to fb column 
      tmplist[[ii]]$cumSum <- cumSum
    }
   cumsums <- as.data.frame(unlist(lapply(tmplist,"[[",max(lengths(tmplist))))) #extract last column from the list and unlist
   cumsums <- cbind(separate(data = as.data.frame(rownames(cumsums)),col=1,into = c("stim","rep")),cumsums) # rearrange as data frame 
   colnames(cumsums) <- c("stim","rep","value")
   cumsums$rep  <-as.numeric(gsub("fb","",cumsums$rep))
   cumsums$stim <- as.factor(cumsums$stim)
   rownames(cumsums) <- c()
   
  #PLOT: Scatter  RTs per fb type
  #------------------------------------------------------------------------------
  ylims <- c(500,2500)
  ysep <- 250
  cols <-  c("forestgreen","firebrick1","yellow") #set your own color palette! 
  myshapemap <-c(21,21,17)
 scat_RTs <-  ggplot(data = D, aes(x = D$trial, y = D$rt, colour = respType)) +
              #geom_vline(xintercept = 0,color="grey" ) + # add lines at strategic points
              geom_vline(xintercept = 10,color="grey" ) +
              geom_vline(xintercept = 20,color="grey" ) +
              geom_vline(xintercept = 30,color="grey" ) +
              geom_hline(yintercept = 0,linetype = "dashed",color="blue" ) + # add lines at strategic points
              geom_hline(yintercept = 2000,linetype = "dashed",color="blue" ) + # add lines at strategic points
              geom_point(aes(fill=respType,shape=respType),alpha = .8,size=3.5,color="black", stroke = .16) + 
              scale_shape_manual(values=myshapemap) +
              labs(title =files[i], y = "RT", x = "Trial Number") + # add some lables and title
              scale_y_continuous(limits = ylims, breaks = (seq(ylims[1],ylims[2],ysep)), labels= (seq(ylims[1],ylims[2],ysep)))+  # play with y axis ticks and range
              scale_x_continuous(breaks = seq(0,ntrials,5)) +  # play with y axis ticks and range 
              theme_bw(12)+
              theme(title = element_text(size=10),
                axis.text.x = element_text(angle = 45,colour = "black",size=10, hjust = 1)) +   
              scale_fill_manual(values=cols) +
              scale_color_manual(values=cols) 
  
    
  #PLOT: Density RTs per fb type
  #------------------------------------------------------------------------------
   Dt <- D[c(idx_hit,idx_err),]
   Dt<- Dt[order(Dt$trial),] # sort by trial
   title_dense <- "RTs distributions"
   caption_dense <- paste("Miss: ",length(idx_err),"\nHits: ",length(idx_hit),"\nErrors: ",length(idx_err))
   dense_RTs<- 
           ggplot(data=Dt, aes(x=respType,y=rt,group=respType)) +
           geom_hline(yintercept = 2000,linetype="dashed",color="blue") +
           geom_flat_violin(aes(fill = respType,color=respType),position = position_nudge(x = 0.0, y = 0.02), adjust = .9, trim = FALSE, alpha = .1) +
           geom_point(aes(x=as.numeric(respType)-0.05,shape= respType, fill = respType),color="black",position=position_jitter(0.02,0,3), size = 2, alpha=.5)+
           scale_fill_manual(values = cols ) +
           scale_colour_manual(values = cols ) +
           scale_shape_manual(values = myshapemap) +
           geom_boxplot(aes(x=as.numeric(respType)-0.12,group=respType,fill=respType),width = .03,size=.6, color="black", outlier.shape = 24, alpha = 0.4) +
           stat_summary(aes(x=as.numeric(respType)+0.03,color=respType),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.7,alpha = 1)+  
           stat_summary(aes(x=as.numeric(respType)+0.03,fill=respType),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 2,color="black",alpha = 1)+
           coord_flip()+ 
           theme_classic() +
          labs(x="freq",y="RT",title = title_dense,  subtitle = caption_dense)+
           theme(title = element_text(size=10),
                 axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                 axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                 axis.text.x = element_text(angle = 45,size=10,color="black"),
                 axis.text.y = element_text(size=10,color="black"),
                 axis.title.x = element_text(size=10,color="black"))+
          scale_y_continuous(limits = ylims, breaks = (seq(ylims[1],ylims[2],ysep)), labels= (seq(ylims[1],ylims[2],ysep)))
          
   #PLOT: Cummulative probabilities for each repetition of a sound
   #------------------------ ------------------------------------------------------
    cum_lines <-  
     ggplot(cumsums, aes(x= rep, y=value, fill=stim))+
                  geom_point(aes(fill=stim),shape=21,size=2.5,alpha=.8,color="black") +
                  geom_line(aes (color=stim)) +
                  facet_wrap( ~stim, ncol=4)+
                  labs(x="repetition",y="cumulative score",title="Cumulative scores",subtitle="per audio stimuli") +
                  theme_bw(12) +
                  scale_x_continuous(breaks = unique(cumsums$rep),labels= unique(cumsums$rep)) + 
                  theme(title = element_text(size=10),
                       axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                       axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                       axis.text.x = element_text(angle = 45,size=10,color="black"),
                       axis.text.y = element_text(size=10,color="black"),
                       axis.title.x = element_text(size=10,color="black")) 
                     
   
     
           
combo <- 
  ggdraw() + draw_plot(scat_RTs, x = 0, y = .5, width = .5, height = .5) +
                     draw_plot(dense_RTs, x = .5, y = .5, width = .5, height = .5) +
                     draw_plot(cum_lines, x = 0, y = 0, width = .5, height = .5)

ggsave("combo.jpg",combo,width = 350, height = 310, dpi=300, units = "mm")
  
         
         
         
         
         
         
    
  ylims <- c(0,4000)
  ysep <- 250
  cols <-  c("forestgreen","firebrick1","yellow") #set your own color palette! 
  dense_RTs <- ggplot(data = D, aes(x = D$trial, y = D$rt, colour = respType)) +
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
