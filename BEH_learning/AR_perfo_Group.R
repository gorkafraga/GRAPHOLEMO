
#Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr", "data.table", "ggplot2","tibble","nlme","lme4","pwr","dplyr","cowplot","tidyr","psych","ggpubr","gridExtra","xlsx")
lapply(Packages, require, character.only = TRUE)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")

#set ins and outs
dirinput <-"O:/studies/allread/mri/analysis_GFG/stats/task/logs" 
diroutput <-"O:/studies/allread/mri/analysis_GFG/stats/task/performance/learn_12_19ss" 
task <- "FeedLearn"
ntrials <- 40


#loop thru files
setwd(dirinput)
files <- dir(dirinput,'*._4stim_.*.txt',recursive = TRUE)
files <- files[grep('^AR*',files)]

dataList<-list()
cumuList<-list()
for (i in 1:length(files)){
  #Read File 
  D <- read_delim(files[i],"\t", escape_double = FALSE, locale = locale(), trim_ws = TRUE, skip_empty_rows=TRUE)
  subject <- substr(files[i],1,6)
  if (dim(D)[1] != ntrials) {
    cat("This file has ",dim(D)[1]," trials instead of ",ntrials,"!!",
        "\nAborting file ",files[i],"!!")
    next
  } else {
    
    cat("File OK (",dim(D)[1]," trials)","\nProceeding with ",files[i],"...\n")
    
    # minor fix for some files with inconsistent headers
    if (length(which(colnames(D)=="vSymbols"))!=0) {
      D$vSymbol1 <- substr(D$vSymbols,1,1)
      D$vSymbol2 <- substr(D$vSymbols,2,2)
      tmpIdx <- which(colnames(D)=="vSymbols")
      D$vSymbolCorrect <- 0
      for (ii in 1:length(D$vStim1)) {
        jnk <- cbind(D$vStim1[ii],D$vStim2[ii])
        D$vSymbolCorrect[ii] <-	 jnk[which(jnk==D$aStim[ii])] 
      }
      D <- select(D,c(1:(tmpIdx-1)),length(D)-2,length(D)-1,length(D),c(1+tmpIdx:c(length(D)-2)))
      }
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
    cumuScore <- cbind(rep(subject,dim(D)[1]),D$block,cumsums)
    colnames(cumuScore)[1:2] <- c("subjID","block")
    
    cat("cumulative scores calculated\n")
    # Separate the data in quartile
    D$quartile <- unlist(lapply(seq(dim(D)[1]/(dim(D)[1]/4)),rep,(dim(D)[1]/4)))
    
    D2save <- cbind(rep(subject,dim(D)[1]),D)
    colnames(D2save)[1] <- "subjID"
    dataList[[i]]<- D2save
    cumuList[[i]]<- cumuScore
  }  

}    

# Merge in a single Table  
DAT <- data.table::rbindlist(dataList) 
CUMU <- data.table::rbindlist(cumuList) 

# Summary Tables
#------------------------------------------------------------------------------
# ACCU summary Count proportion correct  trials in quartile
D_per_quart <- DAT %>%  group_by(subjID,block,quartile,fb,.drop = FALSE) %>% tally()
D_per_quart$prop <- round(D_per_quart$n/(ntrials/4),2)
ACCU <- filter(D_per_quart,fb==1) %>% group_by(subjID,quartile,fb) %>%  summarise(hit_prop=mean(prop))


T_ACCU <- ACCU %>% group_by(quartile) %>% summarize(hit_prop=mean(hit_prop))
tmp <- cbind("overall",mean(ACCU$hit_prop))
colnames(tmp)<-colnames(T_ACCU)
T_ACCU <- rbind(T_ACCU,tmp)
T_ACCU$hit_prop <- round(as.numeric(T_ACCU$hit_prop),2)

# RT summary
rts_per_quart <- DAT %>%  group_by(subjID,block,quartile,fb,.drop = FALSE) %>%  summarize(meanRT = mean(rt))
rts_per_quart$meanRT <-round(as.numeric(rts_per_quart$meanRT),2)
RT <- filter(rts_per_quart,fb<2) 


T_RT <- RT %>% group_by(quartile) %>% summarize(meanRT=mean(meanRT))
tmp <- cbind("overall",mean(T_RT$meanRT))
colnames(tmp)<-colnames(T_RT)
T_RT <- rbind(T_RT,tmp)
T_RT$meanRT <- round(as.numeric(T_RT$meanRT),3)

# combine 
T <- tableGrob(cbind(T_ACCU,T_RT),rows=NULL)

# Some more summary indexes
idx_hit <- which(DAT$fb==1)    
idx_err <- which(DAT$fb==0)
idx_miss <- which(DAT$fb==2)

# CUMULATIVE SCORE Avg per subject to add to plot
SUCUMU <- CUMU %>% group_by(subjID,rep,stim) %>%  summarise(subAvg=mean(value))
nsubjects<- length(unique(DAT$subjID))

#-------------------------------------------------------
# ======================================================
#                     Summary 
# ======================================================
#------------------------------------------------------
# Code sessions (1 or 2)
DAT$session <- DAT$block
allSubjects <- unique(DAT$subjID)
for (ss in 1:length(allSubjects)){
  currSession <- DAT[which(DAT$subjID==allSubjects[ss]),session]
  currSession[which(currSession==min(currSession))] <- 1
  currSession[which(currSession==max(currSession))] <- 2
  
  DAT$session[which(DAT$subjID==allSubjects[ss])] <- currSession
  print('ok')
}
DAT$session <- as.integer(DAT$session)

tab2save <- cbind(DAT %>%  group_by(subjID,session,fb,.drop=FALSE) %>% tally())

Session1 <- cbind(DAT %>% filter(session==1) %>% filter(fb==0) %>% group_by(subjID,.drop=FALSE) %>% tally(),
                  DAT %>%  filter(session==1) %>% filter(fb==1) %>% group_by(subjID,.drop=FALSE) %>% tally(),
                  DAT %>%  filter(session==1) %>% filter(fb==2) %>% group_by(subjID,.drop=FALSE) %>% tally())
           Session1 <- Session1[,c(1,2,4,6)]
           colnames(Session1)<-c('subjID','Task_Learn1_inc','Task_Learn1_con','Task_Learn1_miss')
           
 Session2 <- cbind(DAT %>% filter(session==2) %>% filter(fb==0) %>% group_by(subjID,.drop=FALSE) %>% tally(),
                 DAT %>%  filter(session==2) %>% filter(fb==1) %>% group_by(subjID,.drop=FALSE) %>% tally(),
                 DAT %>%  filter(session==2) %>% filter(fb==2) %>% group_by(subjID,.drop=FALSE) %>% tally())
            Session2 <- Session2[,c(1,2,4,6)]
            colnames(Session2) <-c('subjID','Task_Learn2_inc','Task_Learn2_con','Task_Learn2_miss')
            
 AllSessions <- cbind(DAT %>%  filter(fb==0) %>% group_by(subjID,.drop=FALSE) %>% tally(),
                      DAT %>% filter(fb==1) %>% group_by(subjID,.drop=FALSE) %>% tally(),
                      DAT %>% filter(fb==2) %>% group_by(subjID,.drop=FALSE) %>% tally())
                AllSessions <- AllSessions[,c(1,2,4,6)]
                colnames(AllSessions) <-c('subjID','Task_Learn12_inc','Task_Learn12_con','Task_Learn12_miss')

# aggregate and save
tab2save <- cbind(AllSessions,Session1,Session2)
write.xlsx(tab2save,paste(diroutput,"/Performance_summary.xls",sep=""),row.names = FALSE)
 
#-------------------------------------------------------
# ======================================================
#                     PLOT 
# ======================================================
#------------------------------------------------------

    ylims <- c(500,2500)
    ysep <- 250
    #colorder <-c(which(levels(DAT$respType)=="hit"),which(levels(DAT$respType)=="error"),which(levels(DAT$respType)=="miss"))
    cols <-  c("","","") #set your own color palette! 
    cols[which(levels(DAT$respType)=="hit")]<-"forestgreen"
    cols[which(levels(DAT$respType)=="error")]<-"firebrick1"
    cols[which(levels(DAT$respType)=="miss")]<-"black"
    myshapemap <-c(21,21,17)
    myshapemap [which(levels(DAT$respType)=="hit")] <- 21
    myshapemap [which(levels(DAT$respType)=="error")] <- 21
    myshapemap [which(levels(DAT$respType)=="miss")] <- 21
    
    # Some annotations
    title_scat <- paste("RTs trial sequence (N = ",nsubjects,")",sep="")
    if (length(which(DAT$rt<500 & DAT$rt>0))!=0){
      RT_note <- paste("[!]",length(which(DAT$rt<500 & DAT$rt>0)), "responses faster than 500 ms!")
    } else { RT_note <- c("")}
    Miss_note<- paste("misses = ",round((100*length(idx_miss))/dim(DAT)[1],2)," % of ", dim(DAT)[1]," trials",sep="")
    #PLOT: Scatter  RTs per fb type
    #------------------------------------------------------------------------------
    scat_RTs <-
      ggplot(data = DAT, aes(x = trial, y = rt, colour = respType)) +
      #geom_vline(xintercept = 0,color="grey" ) + # add lines at strategic points
      geom_vline(xintercept = 10,color="grey" ) +
      geom_vline(xintercept = 20,color="grey" ) +
      geom_vline(xintercept = 30,color="grey" ) +
      geom_hline(yintercept = 2500,linetype = "dashed",color="darkorange" ) + # add lines at strategic points  
      geom_hline(yintercept = 0,linetype = "dashed",color="blue" ) + # add lines at strategic points
      geom_hline(yintercept = 2000,linetype = "dashed",color="blue" ) + # add lines at strategic points
      geom_point(aes(fill=respType,shape=respType),alpha = .2,size=1,shape=21,color="black", stroke = .6) + 
      stat_summary(aes(color=respType),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1,alpha = 1) +
      stat_summary(aes(fill=respType),position=position_dodge(0.03),colour = NA,fun.data = mean_cl_boot,geom = "ribbon",alpha = .2) +
      stat_summary(aes(fill=respType),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",color="black",shape=21,size = 1.5,alpha = 1) +
      scale_fill_manual(values=cols) +
      scale_color_manual(values=cols) +
      scale_shape_manual(values=myshapemap)  +
      labs(title = title_scat, y = "RT", x = "Trial Number",caption=RT_note,
           subtitle = Miss_note) + # add some lables and title
      coord_cartesian(ylim = ylims)+#, breaks = (seq(ylims[1],ylims[2],ysep)), labels= (seq(ylims[1],ylims[2],ysep)))+  # play with y axis ticks and range
      scale_x_continuous(breaks = seq(0,ntrials,5)) +  # play with y axis ticks and range 
      theme_bw(12)+
      theme(title = element_text(size=10),plot.caption = element_text(colour ="red"),
            axis.text.x = element_text(angle = 45,colour = "black",size=10, hjust = 1)) 
    
    print("scat_RT plot created\n")        
    #PLOT: Density RTs per fb type
    #------------------------------------------------------------------------------
    #Trim missing responses
    Dt <- DAT[c(idx_hit,idx_err),]
    Dt<- Dt[order(Dt$trial),] # sort by trial
    Dt$respType<- droplevels(Dt$respType)
    cols <-  c("","") #set your own color palette! 
    cols[which(levels(Dt$respType)=="hit")]<-"forestgreen"
    cols[which(levels(Dt$respType)=="error")]<-"firebrick1" 
    title_dense <- "RTs distributions"
    caption_dense <- paste("Miss: ",length(idx_miss),"(",round((100*length(idx_miss))/dim(DAT)[1],2)," %)",
                           "\nHits: ",length(idx_hit),"(",round((100*length(idx_hit))/dim(DAT)[1],2)," %)",
                           "\nErrors: ",length(idx_err),"(",round((100*length(idx_err))/dim(DAT)[1],2)," %)")
                           
    dense_RTs<- 
      ggplot(data=Dt, aes(x=respType,y=rt,group=respType)) +
      geom_hline(yintercept = 2500,linetype="dashed",color="darkorange") +
      geom_hline(yintercept = 2000,linetype="dashed",color="blue") +
      geom_flat_violin(aes(fill = respType,color=respType),position = position_nudge(x = 0.0, y = 0.02), adjust = .9, trim = FALSE, alpha = .1) +
      geom_point(aes(x=as.numeric(respType)-0.05,fill = respType),color="black",position=position_jitter(0.02,0,3), size = 1.5, alpha=.5,shape=21)+
      scale_fill_manual(values = cols ) +
      scale_colour_manual(values = cols ) +
      geom_boxplot(aes(x=as.numeric(respType)-0.12,group=respType,fill=respType),width = .03,size=.6, 
                   color="black",outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
      stat_summary(aes(x=as.numeric(respType)+0.03,color=respType),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
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
    title_cumu <- paste("Cumulative scores per sound (N = ",nsubjects,")",sep="")
    
    cum_lines <-  
      ggplot(CUMU, aes(x= rep, y=value, fill=stim))+
      #geom_point(aes(fill=stim),shape=21,size=2.5,alpha=.8,color="black") +
      #stat_summary(aes(color=stim),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
      stat_summary(aes(fill=stim,color=stim),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",size = .5,alpha = .2)+
      stat_summary(aes(fill=stim,color=stim),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",size = 1.75,alpha = .9)+
      stat_summary(aes(color=stim),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1) +
      #stat_summary(aes(color=stim),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
      #geom_hline(yintercept = 0,linetype="dashed",color="red") +
      facet_wrap( ~stim, ncol=4)+
      geom_point(data = SUCUMU,aes(y=subAvg, color=stim,group=subjID),size=.5,alpha=.5) +
      geom_line(data = SUCUMU, aes(y=subAvg,color=stim,group=subjID),size=.5,alpha=.5) +
      labs(x="repetition",y="cumulative score",title=title_cumu,subtitle="(hit=+1,error=-1,miss=0)") +
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
    title_accu <- paste("Overall accuracy (N = ",nsubjects,")",sep="")
    
   line_propHits <-
      ggplot(ACCU, aes(x= quartile, y=hit_prop))+
      geom_hline(yintercept = 0.5,linetype="dashed",color="blue") +
      stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",color="gray",size = .5,alpha = .2)+
      stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1) +
      stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.05,size = 1,alpha = 1)+  
      stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,fill="black",geom = "point",shape=21,
                   size = 3,alpha = 1)+
      geom_point(aes(group=subjID),size=.5,alpha=.5) +
      geom_line(aes(group=subjID),size=.5,alpha=.5) +
      #geom_point(shape=21,size=3,alpha=1,color="black",fill="black") +
      labs(y="Proportion of hits",title=title_accu,subtitle="per quartile") +
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
  
    
    #===========================
    #Combine plots in figure
    #===========================
    combo <-  ggdraw() + draw_plot(scat_RTs, x = 0, y = .5, width = .5, height = .5) +
      draw_plot(dense_RTs, x = .5, y = .5, width = .5, height = .5) +
      draw_plot(cum_lines, x = 0, y = 0, width = .5, height = .5)+
      draw_plot(line_propHits, x = .5, y =0, width = .25, height = .5)+
      draw_plot(T, x = .75, y = 0, width = .25, height = .5)
    
    #add some annotations
    combo <-  annotate_figure(combo,text_grob(paste("Group Summary (", nsubjects," subjects)",sep=""),
                                              color = "blue", face = "bold", size = 12))
    
    # SAVE ~~~~~O ~~O 
    setwd(diroutput)
    
    
    subject <- strsplit(files[i],'/')[[1]][1]
    filename <- strsplit(files[i],'/')[[1]][2]
    outputname <- gsub('.txt','.jpg',paste('GroupPerformance_',nsubjects,'ss',substr(filename,nchar(filename)-3,nchar(filename)),sep=''))
    
    
    ggsave(outputname,combo,width = 350, height = 310, dpi=300, units = "mm")
    cat("Done. File",outputname, " Saved in ", diroutput,"\n")
    setwd(dirinput)
          
