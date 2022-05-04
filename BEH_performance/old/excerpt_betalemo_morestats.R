
if (morestats == 1) {
  
  # Summary Tables for plot 
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
  rts_per_quart$meanRT <-round(as.numeric(rts_per_quart$meanRT),3)
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
  #      Summary  TABLE TO SAVE
  # ======================================================
  #------------------------------------------------------
  # Code sessions (1 or 2)
  DAT$session <- DAT$block
  allSubjects <- unique(DAT$subjID)
  for (ss in 1:length(allSubjects)){
    currSession <- DAT[which(DAT$subjID==allSubjects[ss]),session]
    if (length(unique(currSession)) == 2) {
      minidx <- which(currSession==min(currSession))
      maxidx <- which(currSession==max(currSession))
      
      currSession[minidx] <- 1
      currSession[maxidx] <- 2
      
    } else if (length(unique(currSession)) == 1)  {
      print(paste("One session in ", allSubjects[ss],sep=""))
      currSession[] <- 1 
    }
    
    DAT$session[which(DAT$subjID==allSubjects[ss])] <- currSession
    print(paste(length(unique(currSession)),' sessions',sep=""))
  }
  DAT$session <- as.integer(DAT$session)
  
  # Get mean reaction time per session (block) and participant. Same  for accuracy
  summary <-  data.frame(matrix(ncol = 17, nrow = nsubjects))
  for (s in 1:nsubjects){
    sDat <- DAT[which(DAT$subjID==unique(DAT$subjID)[s])]
    
    # RTs and ACCU per session and over both 
    sDatses1 <- sDat[which(sDat$session==1),]
    L1_rt_inc <- mean(sDatses1$rt[which(sDatses1$fb==0)],na.rm=TRUE)
    L1_rt_corr <- mean(sDatses1$rt[which(sDatses1$fb==1)],na.rm=TRUE)
    L1_n_inc <- length(sDatses1$fb[which(sDatses1$fb==0)])
    L1_n_corr <- length(sDatses1$fb[which(sDatses1$fb==1)])
    L1_n_miss <- length(sDatses1$fb[which(sDatses1$fb==2)])
    L1_blockId <- unique(sDatses1$block)
    if (length(L1_blockId)==0) { 
      L1_blockId<- NaN
      L1_n_corr<- NaN
      L1_n_inc<- NaN
      L1_n_miss<- NaN}
    
    
    sDatses2 <- sDat[which(sDat$session==2),]
    L2_rt_inc <- mean(sDatses2$rt[which(sDatses2$fb==0)],na.rm=TRUE)
    L2_rt_corr <- mean(sDatses2$rt[which(sDatses2$fb==1)],na.rm=TRUE)
    L2_n_inc <- length(sDatses2$fb[which(sDatses2$fb==0)])
    L2_n_corr <- length(sDatses2$fb[which(sDatses2$fb==1)])
    L2_n_miss <- length(sDatses2$fb[which(sDatses2$fb==2)])
    L2_blockId <- unique(sDatses2$block)
    if (length(L2_blockId)==0) { 
      L2_blockId<- NaN
      L2_n_corr<- NaN
      L2_n_inc<- NaN
      L2_n_miss<- NaN}
    
    #both sessions  
    L12_rt_inc <- mean(mean(c(L1_rt_inc,L2_rt_inc)),na.rm=TRUE)
    L12_rt_corr <- mean(mean(c(L1_rt_corr,L2_rt_corr)),na.rm=TRUE)
    L12_n_inc <- length(sDat$fb[which(sDat$fb==0)])
    L12_n_corr <- length(sDat$fb[which(sDat$fb==1)])
    L12_n_miss <- length(sDat$fb[which(sDat$fb==2)])
    
    combined <-  cbind(L1_blockId,L2_blockId,L1_rt_corr,L1_rt_inc,L2_rt_corr,L2_rt_inc,L12_rt_corr,L12_rt_inc,
                       L1_n_corr,L1_n_inc,L1_n_miss,L2_n_corr,L2_n_inc,L2_n_miss,L12_n_corr,L12_n_inc,L12_n_miss)
    summary[s,]<- combined
    header  <- colnames(combined)
    
  }
  summary <- cbind(unique(DAT$subjID),summary)
  colnames(summary)  <- c("subjID",header)
  
  # Combine accu and RT summary table
  write.csv(summary,paste(diroutput,"/",task,"_Perform_summary.csv",sep=""),row.names = FALSE)
  
}
if (plotme ==  1 ){
  #-------------------------------------------------------
  # ======================================================
  #                     PLOTS
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
  outputname <- gsub('.txt','.jpg',paste(task,'GroupPerformance_',nsubjects,'ss',substr(filename,nchar(filename)-3,nchar(filename)),sep=''))
  
  
  ggsave(outputname,combo,width = 350, height = 310, dpi=300, units = "mm")
  cat("Done. File",outputname, " Saved in ", diroutput,"\n")
  setwd(dirinput)
}          
