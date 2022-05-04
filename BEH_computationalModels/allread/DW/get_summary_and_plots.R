# Patrick Haller, January 2020

get_summary_and_plots <- function(generated_data_in){
  
  generated_data <- generated_data_in
  mean(generated_data[which(generated_data$fb==1),]$RT)
  
  # mean RT correct
  mean(generated_data[which(generated_data$fb==2),]$RT)
  
  mean_rts = aggregate(raw_data$RT,
                       by = list(subjID = raw_data$subjID, fb= raw_data$fb),
                       FUN = mean)
  
  rtneg <- generated_data[which(generated_data$fb == 1),]$RT
  rtpos <- generated_data[which(generated_data$fb == 2),]$RT
  t.test(rtpos,rtneg)
  
  
  ### first, plot accuracies for entire dataset!
  
  dataList<-list()
  cumuList<-list()
  
  allsubjs <- unique(generated_data$subjID)
  names(generated_data)[names(generated_data) == "p_assoc"] <- "aStim"
  ntrials=40
  
  for(i in 1:500){
    D <- subset(generated_data, subjID==allsubjs[i])
    subject <- allsubjs[i]
    D$fb <- ifelse(D$fb==2,1,0)
    if (length(which(D$RT>=2.0)) > 0){
      D[which(D$RT>=2.0),]$fb = 2
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
    if (length(D$fbmin[which(D$fbmin==2)]) > 0){
      D$fbmin[which(D$fbmin==2)] <- 0
    }
    tmplist <- split(D,D$aStim) # split by audio type
    for (j in 1:length(tmplist)) {
      cumSum <- tmplist[[j]] %>%  select(fbmin) %>% cumsum() # apply cumsum function to fb column 
      tmplist[[j]]$cumSum <- cumSum
    }
    cumsums <- as.data.frame(unlist(lapply(tmplist,"[[",max(lengths(tmplist))))) #extract last column from the list and unlist
    cumsums <- cbind(separate(data = as.data.frame(rownames(cumsums)),col=1,into = c("stim","rep")),cumsums) # rearrange as data frame 
    colnames(cumsums) <- c("stim","rep","value")
    cumsums$rep  <- as.numeric(gsub("fbmin","",cumsums$rep))
    cumsums$stim <- as.factor(cumsums$stim)
    rownames(cumsums) <- c()
    cumuScore <- cbind(rep(subject,dim(D)[1]),D$block,cumsums)
    colnames(cumuScore)[1:2] <- c("subjID","block")
    
    #cat("cumulative scores calculated\n")
    # Separate the data in quartile
    # last expression (/12) adapt to the number of blocks!
    D$quartile <- unlist(lapply(seq(dim(D)[1]/(dim(D)[1]/4)),rep,(dim(D)[1]/12)))
    
    D2save <- cbind(rep(subject,dim(D)[1]),D)
    colnames(D2save)[1] <- "subjID"
    dataList[[i]]<- D2save
    cumuList[[i]]<- cumuScore
  }  
  
  # Merge in a single Table  
  DAT <- data.table::rbindlist(dataList) 
  DAT <- DAT[,2:ncol(DAT)]
  CUMU <- data.table::rbindlist(cumuList) 
  
  # Summary Tables
  #------------------------------------------------------------------------------
  # ACCU summary Count proportion correct  trials in quartile
  D_per_quart <- DAT %>%  group_by(subjID,block,quartile,fb,.drop = FALSE) %>% tally()
  D_per_quart$prop <- D_per_quart$n/(ntrials/4)
  ACCU <- filter(D_per_quart,fb==1) %>% group_by(subjID,quartile,fb) %>%  summarise(hit_prop=mean(prop))
  
  T_ACCU <- ACCU %>% group_by(quartile) %>% summarize(hit_prop=mean(hit_prop))
  tmp <- cbind("overall",mean(ACCU$hit_prop))
  colnames(tmp)<-colnames(T_ACCU)
  T_ACCU <- rbind(T_ACCU,tmp)
  T_ACCU$hit_prop <- round(as.numeric(T_ACCU$hit_prop),2)
  
  # RT summary
  rts_per_quart <- DAT %>%  group_by(subjID,block,quartile,fb,.drop = FALSE) %>%  summarize(meanRT = mean(RT))
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
  
  set.seed(1)
  subjects <- sample(1:500, 25)
  subjects <- paste0('synsubj',subjects)
  subjects_ACCU <- which(ACCU$subjID %in% subjects)
  ACCU_subset <- ACCU[subjects_ACCU,]
  
  title_accu <- ''
  p1 <- ggplot(ACCU, aes(x= quartile, y=hit_prop))+
    geom_hline(yintercept = 0.5,linetype="dashed",color="blue") +
    stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",color="gray",size = .5,alpha = .2)+
    stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1) +
    stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.05,size = 1,alpha = 1)+  
    stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,fill="black",geom = "point",shape=21,
                 size = 3,alpha = 1)+
    geom_line(data = ACCU_subset, aes(y=jitter(hit_prop),group=subjID),size=.2,alpha=.2) +
    geom_line(data = ACCU_subset, aes(y=jitter(hit_prop),group=subjID),size=.2,alpha=.2) +
    #geom_point(aes(group=subjID),size=.5,alpha=.5) +
    #geom_line(aes(group=subjID),size=.3,alpha=.2) +
    #geom_point(shape=21,size=3,alpha=1,color="black",fill="black") +
    labs(y="Proportion of successful trials",title=title_accu) +
    theme_bw(12) +
    scale_x_continuous(breaks = unique(cumsums$rep),labels= unique(cumsums$rep)) + 
    theme(title = element_text(size=10),
          axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
          axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
          axis.text.x = element_text(angle = 45,size=10,color="black"),
          axis.text.y = element_text(size=10,color="black"),
          axis.title.x = element_text(size=10,color="black")) +
    scale_y_continuous(limits = c(0.4,1),breaks=seq(0,1,0.1))
  cat("accuracy plot created\n") 
  
  
  
  
  ### for the cumsums, just take the 2nd block
  generated_data <- generated_data_in
  allsubjs <- unique(generated_data$subjID)
  names(generated_data)[names(generated_data) == "p_assoc"] <- "aStim"
  ntrials=40
  
  stimuli <- c(9:13)
  stimuli_idx <- which(generated_data$aStim %in% stimuli)
  
  generated_data <- generated_data[stimuli_idx,]
  generated_data$aStim <- as.factor(generated_data$aStim)
  levels(generated_data$aStim) <- c("1","2","3","4","5")
  
  dataList<-list()
  cumuList<-list()
  
  for(i in 1:500){
    D <- subset(generated_data, subjID==allsubjs[i])
    subject <- allsubjs[i]
    D$fb <- ifelse(D$fb==2,1,0)
    if (length(which(D$RT>=2.0)) > 0){
      D[which(D$RT>=2.0),]$fb = 2
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
    if (length(D$fbmin[which(D$fbmin==2)]) > 0){
      D$fbmin[which(D$fbmin==2)] <- 0
    }
    tmplist <- split(D,D$aStim) # split by audio type
    for (j in 1:length(tmplist)) {
      cumSum <- tmplist[[j]] %>%  select(fbmin) %>% cumsum() # apply cumsum function to fb column 
      tmplist[[j]]$cumSum <- cumSum
    }
    cumsums <- as.data.frame(unlist(lapply(tmplist,"[[",max(lengths(tmplist))))) #extract last column from the list and unlist
    cumsums <- cbind(separate(data = as.data.frame(rownames(cumsums)),col=1,into = c("stim","rep")),cumsums) # rearrange as data frame 
    colnames(cumsums) <- c("stim","rep","value")
    cumsums$rep  <- as.numeric(gsub("fbmin","",cumsums$rep))
    cumsums$stim <- as.factor(cumsums$stim)
    rownames(cumsums) <- c()
    cumuScore <- cbind(rep(subject,dim(D)[1]),D$block,cumsums)
    colnames(cumuScore)[1:2] <- c("subjID","block")
    
    #cat("cumulative scores calculated\n")
    # Separate the data in quartile
    # last expression (/12) adapt to the number of blocks!
    D$quartile <- unlist(lapply(seq(dim(D)[1]/(dim(D)[1]/4)),rep,(dim(D)[1]/4)))
    
    D2save <- cbind(rep(subject,dim(D)[1]),D)
    colnames(D2save)[1] <- "subjID"
    dataList[[i]]<- D2save
    cumuList[[i]]<- cumuScore
  }  
  
  # Merge in a single Table  
  DAT <- data.table::rbindlist(dataList) 
  DAT <- DAT[,2:ncol(DAT)]
  CUMU <- data.table::rbindlist(cumuList) 
  
  
  # Summary Tables
  #------------------------------------------------------------------------------
  # ACCU summary Count proportion correct  trials in quartile
  D_per_quart <- DAT %>%  group_by(subjID,block,quartile,fb,.drop = FALSE) %>% tally()
  D_per_quart$prop <- D_per_quart$n/(ntrials/4)
  ACCU <- filter(D_per_quart,fb==1) %>% group_by(subjID,quartile,fb) %>%  summarise(hit_prop=mean(prop))
  
  T_ACCU <- ACCU %>% group_by(quartile) %>% summarize(hit_prop=mean(hit_prop))
  tmp <- cbind("overall",mean(ACCU$hit_prop))
  colnames(tmp)<-colnames(T_ACCU)
  T_ACCU <- rbind(T_ACCU,tmp)
  T_ACCU$hit_prop <- round(as.numeric(T_ACCU$hit_prop),2)
  
  # RT summary
  rts_per_quart <- DAT %>%  group_by(subjID,block,quartile,fb,.drop = FALSE) %>%  summarize(meanRT = mean(RT))
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
  
  title_cumu <- "Cumulative scores per sound"
  
  set.seed(1)
  subjects <- sample(1:500, 25)
  subjects <- paste0('synsubj',subjects)
  subjects_CUMU <- which(CUMU$subjID %in% subjects)
  CUMU_subset <- CUMU[subjects_CUMU]
  SUCUMU <- CUMU_subset %>% group_by(subjID,rep,stim) %>%  summarise(subAvg=mean(value))
  
  p2 <-  ggplot(CUMU, aes(x= rep, y=value, fill=stim))+
    stat_summary(aes(fill=stim,color=stim),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",size = .5,alpha = .2)+
    stat_summary(aes(fill=stim,color=stim),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",size = 1.75,alpha = .9)+
    stat_summary(aes(color=stim),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1) +
    facet_wrap( ~stim, ncol=5)+
    #geom_point(data = SUCUMU,aes(y=subAvg, color=stim,group=subjID),size=.5,alpha=.5) +
    geom_line(data = SUCUMU, aes(y=jitter(subAvg),color=stim,group=subjID),size=.2,alpha=.2) +
    labs(x="repetition",y="cumulative learning score",title='',subtitle="(successful= +1; unsuccessful= -1; missed= 0)") +
    theme_bw(12) +
    scale_x_continuous(breaks = unique(cumsums$rep),labels= unique(cumsums$rep)) + 
    scale_y_continuous(breaks= c(-2,0,2,4,6,8)) +
    theme(title = element_text(size=10),
          axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
          axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
          axis.text.x = element_text(angle = 45,size=10,color="black"),
          axis.text.y = element_text(size=10,color="black"),
          axis.title.x = element_text(size=10,color="black")) +
    scale_fill_brewer(palette = "Dark2")+scale_colour_brewer(palette = "Dark2")
  cat("cumulative lines plot created\n")       
  

  out <- list("cumulative_lines" = p1, "accuracy" = p2)
  return(out)
} 