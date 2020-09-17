
#Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr","cowplot","tidyr","psych","ggpubr","gridExtra")
lapply(Packages, require, character.only = TRUE)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")

#set ins and outs
dirinput <-"N:/studies/Grapholemo/Methods/Scripts/grapholemo/Experiment_NeurobsPresentation/FB_Learning_Adults/Task_A/Log Files" 
diroutput <-"N:/studies/Grapholemo/Methods/Scripts/grapholemo/Experiment_NeurobsPresentation/FB_Learning_Adults/Task_A/Log Files/summary" 
task <- "FeedLearn"
ntrials <- 48


#loop thru files
setwd(dirinput)
files <- dir(dirinput,'*.FeedLearn_.*.txt',recursive = TRUE)
files <- files[grep('^Whole_*',files)]

setwd(dirinput)
for (i in 1:length(files)){
  #Read File ge
  D <- read_delim(files[i],"\t", escape_double = FALSE, locale = locale(), trim_ws = TRUE, skip_empty_rows=TRUE)
  
  if (dim(D)[1] != ntrials) {
    cat("This file has ",dim(D)[1]," trials instead of ",ntrials,"!!",
                "\nAborting file ",files[i],"!!")
    next
  } else {
    
  cat("File OK (",dim(D)[1]," trials)","\nProceeding with ",files[i],"...\n")
  
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
  
                  
  # Gather cumulative probability per stimuli
    D$fbmin <- D$fb   
    D$fbmin[which(D$fbmin==0)] <- -1
    D$fbmin[which(D$fbmin==2)] <- 0
    tmplist <- split(D,D$aStim) # split by audio type
    for (ii in 1:length(tmplist)) {
      cumSum <- tmplist[[ii]] %>%  select(fbmin) %>% cumsum() # apply cumsum function to fb column 
      tmplist[[ii]]$cumSum <- cumSum
    }
   cumsums <- as.data.frame(unlist(lapply(tmplist,"[[",max(lengths(tmplist))))) #extract last column from the list and unlist
   cumsums <- cbind(separate(data = as.data.frame(rownames(cumsums)),col=1,into = c("stim","rep")),cumsums) # rearrange as data frame 
   colnames(cumsums) <- c("stim","rep","value")
   cumsums$rep  <- as.numeric(gsub("fbmin","",cumsums$rep))
   cumsums$stim <- as.factor(cumsums$stim)
   rownames(cumsums) <- c()
   
  # Separate the data in quartile
  D$quartile <- unlist(lapply(seq(dim(D)[1]/(dim(D)[1]/4)),rep,(dim(D)[1]/4)))
  
  # Count correct  trials in quartile
  hits_per_quart <-  D[which(D$fb==1),] %>%  group_by(quartile,.drop = FALSE) %>% tally()
  propHits_per_quart<- cbind(hits_per_quart,round(hits_per_quart$n/(dim(D)[1]/4),2)) 
  colnames(propHits_per_quart)[3] <- "hit_prop"
  
  # RT summary
  rts_per_quart <-  D %>% filter(fb <2)  %>% select(c(rt,quartile)) %>% group_by(quartile,.drop = FALSE) %>%  summarize(mean(rt))
  rts_overall <-  as.numeric(D %>% filter(fb <2)  %>% select(c(rt)) %>% summarize(mean(rt)))
  rts_table<- rbind(rts_per_quart,c("overall",rts_overall))
  colnames(rts_table) <- c("quartile","meanRT")
  rts_table$meanRT <-round(as.numeric(rts_table$meanRT),2)
  
  colnames(propHits_per_quart)[3] <- "hit_prop"
  
  # bias in button presses (explore if subject pressed always the same):
  buttons <- D %>% group_by(resp) %>% tally()
  buttons$proportion <- buttons$n/dim(D)[1]
  colnames(buttons)<- c("button","count","proportion")
  buttons <- select(buttons, c(button,proportion))
  buttons_report <- paste("Button (",paste(buttons$button,collapse=";"),") response proportion from all responses: ",paste(buttons$proportion,collapse=";"),sep="")
  
  # PLOT preparations......
  #........................
  ylims <- c(500,2500)
  ysep <- 250
  cols <-  c("firebrick1","forestgreen","black") #set your own color palette! 
  myshapemap <-c(21,21,17)
  if (length(idx_err)==0){
      cols <- c("forestgreen","black") 
      myshapemap <-c(21,17)  
  }
  # add note if there were responses < 500 
  if (length(which(D$rt<500 & D$rt>0))!=0){
    RT_note <- paste("[!]",length(which(D$rt<500 & D$rt>0)), "responses faster than 500 ms!")
  } else { RT_note <- c("")}
  
  #PLOT: Scatter  RTs per fb type
  #------------------------------------------------------------------------------
  scat_RTs <-  ggplot(data = D, aes(x = D$trial, y = D$rt, colour = respType)) +
              #geom_vline(xintercept = 0,color="grey" ) + # add lines at strategic points
              geom_vline(xintercept = 10,color="grey" ) +
              geom_vline(xintercept = 20,color="grey" ) +
              geom_vline(xintercept = 30,color="grey" ) +
              geom_hline(yintercept = 2500,linetype = "dashed",color="darkorange" ) + # add lines at strategic points  
              geom_hline(yintercept = 0,linetype = "dashed",color="blue" ) + # add lines at strategic points
              geom_hline(yintercept = 2000,linetype = "dashed",color="blue" ) + # add lines at strategic points
              geom_point(aes(fill=respType,shape=respType),alpha = .8,size=3,color="black", stroke = .16) + 
              scale_shape_manual(values=myshapemap) +
              labs(title ="RTs trial sequence", y = "RT", x = "Trial Number",caption=RT_note,
                   subtitle = paste("Missing ",length(idx_miss)," trial(s)",sep="")) + # add some lables and title
              scale_y_continuous(limits = ylims, breaks = (seq(ylims[1],ylims[2],ysep)), labels= (seq(ylims[1],ylims[2],ysep)))+  # play with y axis ticks and range
              scale_x_continuous(breaks = seq(0,ntrials,5)) +  # play with y axis ticks and range 
              theme_bw(12)+
              theme(title = element_text(size=10),plot.caption = element_text(colour ="red"),
                axis.text.x = element_text(angle = 45,colour = "black",size=10, hjust = 1)) +   
              scale_fill_manual(values=cols) +
              scale_color_manual(values=cols) 
  
 print("scat_RT plot created\n")        
  #PLOT: Density RTs per fb type
  #------------------------------------------------------------------------------
   Dt <- D[c(idx_hit,idx_err),]
   Dt<- Dt[order(Dt$trial),] # sort by trial
   title_dense <- "RTs distributions"
   caption_dense <- paste("Miss: ",length(idx_miss),"\nHits: ",length(idx_hit),"\nErrors: ",length(idx_err))
   dense_RTs<- 
           ggplot(data=Dt, aes(x=respType,y=rt,group=respType)) +
           geom_hline(yintercept = 2500,linetype="dashed",color="darkorange") +
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
          labs(x="freq",y="RT",title = title_dense, caption=RT_note, subtitle = caption_dense)+
           theme(title = element_text(size=10),
                 axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                 axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                 axis.text.x = element_text(angle = 45,size=10,color="black"),
                 axis.text.y = element_text(size=10,color="black"),
                 axis.title.x = element_text(size=10,color="black"),
                 plot.caption = element_text(colour ="red"))+
          scale_y_continuous(limits = ylims, breaks = (seq(ylims[1],ylims[2],ysep)), labels= (seq(ylims[1],ylims[2],ysep)))
    
   cat("Dense_RT plot created\n")      
   #PLOT: Cummulative probabilities for each repetition of a sound
   #------------------------ ------------------------------------------------------
    cum_lines <-  
     ggplot(cumsums, aes(x= rep, y=value, fill=stim))+
                  geom_point(aes(fill=stim),shape=21,size=2.5,alpha=.8,color="black") +
                  geom_hline(yintercept = 0,linetype="dashed",color="red") +
                  geom_line(aes (color=stim)) +
                  facet_wrap( ~stim, ncol=4)+
                  labs(x="repetition",y="cumulative score",title="Cumulative scores per sound",subtitle="(hit=+1,error=-1,miss=0)") +
                  theme_bw(12) +
                  scale_x_continuous(breaks = unique(cumsums$rep),labels= unique(cumsums$rep)) + 
                  theme(title = element_text(size=10),
                       axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                       axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                       axis.text.x = element_text(angle = 45,size=10,color="black"),
                       axis.text.y = element_text(size=10,color="black"),
                       axis.title.x = element_text(size=10,color="black")) 
   cat("cum_lines plot created\n")       
   #PLOT: overall performance plot and info
   #------------------------------------------------------------------------------
   line_propHits <-  ggplot(propHits_per_quart, aes(x= quartile, y=hit_prop))+
                     geom_hline(yintercept = 0.5,linetype="dashed",color="blue") +
                     geom_point() +
                     geom_line() +
                     geom_point(shape=21,size=3,alpha=1,color="black",fill="black") +
                     labs(y="Proportion of hits",title="Overall accuracy",subtitle="per quartile") +
                     theme_bw(12) +
                     scale_x_continuous(breaks = unique(cumsums$rep),labels= unique(cumsums$rep)) + 
                     theme(title = element_text(size=10),
                           axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                           axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                           axis.text.x = element_text(angle = 45,size=10,color="black"),
                           axis.text.y = element_text(size=10,color="black"),
                           axis.title.x = element_text(size=10,color="black")) +
                     scale_y_continuous(limits = c(0,1),breaks=seq(0,1,0.1))
   cat("line_propHits plot created\n")        
   # Summary Tables
   #------------------------------------------------------------------------------
    accu_table <- rbind(select(propHits_per_quart,c(quartile,hit_prop)),c("overall",length(which(D$fb==1))/dim(D)[1]))
   colnames(accu_table) <- c("quartile","accu")
   T <- tableGrob(cbind(accu_table,select(rts_table,meanRT)),rows=NULL)

   
#===========================
#Combine plots in figure
#===========================
combo <-  ggdraw() + draw_plot(scat_RTs, x = 0, y = .5, width = .5, height = .5) +
                     draw_plot(dense_RTs, x = .5, y = .5, width = .5, height = .5) +
                     draw_plot(cum_lines, x = 0, y = 0, width = .5, height = .5)+
                     draw_plot(line_propHits, x = .5, y =0, width = .25, height = .5)+
                     draw_plot(T, x = .75, y = 0, width = .25, height = .5)

#add some annotations
combo <-  annotate_figure(combo,text_grob(files[i], color = "blue", face = "bold", size = 12),
          fig.lab.pos="bottom",bottom = text_grob(buttons_report, color = "black",size=9))
       
# SAVE ~~~~~O ~~O 
setwd(diroutput)

#subject <- strsplit(files[i],'/')[[1]][1]
#filename <-files[i]
#outputname <- gsub('.txt','.jpg',paste('PLOT_',subject,substr(filename,nchar(filename)-6,nchar(filename)),sep=''))
outputname <- gsub('.txt','.jpg',paste('PLOT_',files[i],sep=""))

ggsave(outputname,combo,width = 350, height = 310, dpi=300, units = "mm")
cat(i,"-done.\n")
setwd(dirinput)
}}         