#
#  GATHER OUTPUT FROM RLDDM MODEL 
# --------------------------------------
#  - Write a table per subject with parameters per trial
#  - Write table with subject-level parameters
#  - Parameters can be mean centered (optional setting)
#
#=====================================================================================

#.libPaths()
#assign(".lib.loc", "C:/Program Files/R/R-3.6.1/library", envir = environment(.libPaths))
#Clear all and Load libraries
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr")
lapply(Packages, require, character.only = TRUE)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")
#------------------------------------------------------------------------------------------------------
#set dirs
choiceModel <- 'rlddm1_v1'
dirinput <- paste("O:/studies/allread/mri/analysis_GFG/stats/task/model/Preproc_19ss/output_",choiceModel,sep="")
dirPreprocessed <- "O:/studies/allread/mri/analysis_GFG/stats/task/model/Preproc_19ss"
diroutput <- dirinput
#modelpath <- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan"
# Some settings
meancenter=1
givemeplots = 1
#------------------------------------------------------------------------------------------------------
# Read data and fit 
setwd(dirinput)
load(paste(dirPreprocessed,"/Preproc_data",sep="")) #read gathered data (that will be combined with model parameters later)
load(paste(dirPreprocessed,"/Preproc_list",sep="")) #read list with gather data input for model
fit <- readRDS(paste(dirinput,"/fit_rlddm.rds",sep="")) # read model output

paramsInFit <- unique(sapply(strsplit(params,'[',fixed = TRUE),"[",1)) # list of unique parameters in the fit
#lp_ is the log posterior 
#------------------------------------------------------------------------------------------------------
# function to mean center parameters (used later)
center_colmeans <- function(x) {
  xcenter = colMeans(x)
  x - rep(xcenter, rep.int(nrow(x), ncol(x)))
}
#------------------------------------------------------------------------------------------------------
  
  subjs <- datTable[, .N, by = subjID][,1]
  ###############################
  ## TRIAL-BY-TRIAL PARAMETERS ##
  ###############################
  
  v_hat <- rep("NA",datList$T)
  for (i in 1:datList$T){
    index <- paste0("v_hat[",i,"]")
    v_hat[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  v_hat <- as.double(v_hat)
  
  # association strength of active (i.e. correct) stimulus pair
  #as_active <- rep("NA",datList$T)
  #for (i in 1:datList$T){
  #  index <- paste0("as_active[",i,"]")
  #  as_active[i] <- rstan::summary(fit,pars=index)$summary[1]
  #}
  #as_active <- as.double(as_active)
  
  # association strength of inactive (i.e. incorrect) stimulus pair
  #as_inactive <- rep("NA",datList$T)
  #for (i in 1:datList$T){
  #  index <- paste0("as_inactive[",i,"]")
 #   as_inactive[i] <- rstan::summary(fit,pars=index)$summary[1]
#  }
 # as_inactive <- as.double(as_inactive)
  
 # as_chosen <- rep("NA",datList$T)
#  for (i in 1:datList$T){
#    index <- paste0("as_chosen[",i,"]")
#    as_chosen[i] <- rstan::summary(fit,pars=index)$summary[1]
#  }
# as_chosen <- as.double(as_chosen)
  
  # prediction errors
  pe_tot_hat <- rep("NA",datList$T)
  for (i in 1:datList$T){
    index <- paste0("pe_tot_hat[",i,"]")
    pe_tot_hat[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  pe_tot_hat <- as.double(pe_tot_hat)
  
  # prediction errors
  pe_pos_hat <- rep("NA",datList$T)
  for (i in 1:datList$T){
    index <- paste0("pe_pos_hat[",i,"]")
    pe_pos_hat[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  pe_pos_hat <- as.double(pe_pos_hat)
  
  # prediction errors
  pe_neg_hat <- rep("NA",datList$T)
  for (i in 1:datList$T){
    index <- paste0("pe_neg_hat[",i,"]")
    pe_neg_hat[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  pe_neg_hat <- abs(as.double(pe_neg_hat))
  
  
   # add the trial-by-trial regressors to the original dataset
 # param_pertrial <- cbind(datTable[,1:9],datTable[,18],datTable[,14:16],
              #           pe_pos=as.array(pe_pos_hat),pe_neg=as.array(pe_neg_hat), pe_tot=as.array(pe_tot_hat),
               #          as_active=as.array(as_active),as_inactive=as.array(as_inactive), as_chosen =as.array(as_chosen),
                #         drift=as.array(v_hat))
  param_pertrial <- cbind(datTable,pe_pos=as.array(pe_pos_hat),pe_neg=as.array(pe_neg_hat), pe_tot=as.array(pe_tot_hat), drift=as.array(v_hat))
  
  # mean-center parameters
  if (meancenter == 1){
    for(i in 1:datList$N){
      subj = as.character(subjs[i])
      param_bySubj <- as.matrix(param_pertrial[which(param_pertrial$subjID==subj),c('pe_pos','pe_neg','pe_tot','drift')])
      param_bySubj <- center_colmeans(param_bySubj)
      param_pertrial[which(param_pertrial$subjID==subj),c('pe_pos','pe_neg','pe_tot','drift')] <- data.frame(param_bySubj)
    }
  }
  
  # write trial-by-trial parameters as file for each subject individually
  for(i in 1:datList$N){
    subj = as.character(subjs[i])
    write.table(param_pertrial[which(param_pertrial$subjID==subj),],paste0(diroutput,"/",subj,"_rlddm_parameters",".csv"),
                quote=FALSE, sep=",", row.names=FALSE, col.names=TRUE)
  }
  cat("wrote trial-by-trial parameters\n")
  
  ########################
  ## SUBJECT PARAMETERS ##
  ########################
  
  eta_pos <- rep("NA",datList$N)
  for (i in 1:datList$N){
    index <- paste0("eta_pos[",i,"]")
    eta_pos[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  eta_pos <- as.double(eta_pos)
  
  eta_neg <- rep("NA",datList$N)
  for (i in 1:datList$N){
    index <- paste0("eta_neg[",i,"]")
    eta_neg[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  eta_neg <- as.double(eta_neg)
  
  a <- rep("NA",datList$N)
  for (i in 1:datList$N){
    index <- paste0("a[",i,"]")
    a[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  a <- as.double(a)
  
  v_mod <- rep("NA",datList$N)
  for (i in 1:datList$N){
    index <- paste0("v_mod[",i,"]")
    v_mod[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  v_mod <- as.double(v_mod)
  
  tau <- rep("NA",datList$N)
  for (i in 1:datList$N){
    index <- paste0("tau[",i,"]")
    tau[i] <- rstan::summary(fit,pars=index)$summary[1]
  }
  tau <- as.double(tau)
  
  subject_parameters <- cbind(v_mod=as.array(v_mod),a=as.array(a),tau=as.array(tau),eta_pos=as.array(eta_pos),eta_neg=as.array(eta_neg))
  
  if(meancenter == 1){
    sp_matrix <- as.matrix(subject_parameters)
    sp_matrix_centered <- center_colmeans(sp_matrix)
    subject_parameters <- data.frame(sp_matrix_centered)
  }
  subject_parameters <- cbind(subjID=unique(param_pertrial$subjID),subject_parameters)
  
  # write out subject parameters
  write.table(subject_parameters, paste0(diroutput,"/rlddm_subject_parameters.csv"), sep=",", row.names=FALSE, col.names=TRUE,quote = FALSE) 
  cat("wrote subject parameters\n")
  cat("returning parameters\n")
  out <- list("tria-by-trial_parameters" = param_pertrial, "subject_parameters" = subject_parameters)

 
  
  
if (givemeplots == 1){
  
  #############################
  # PLOTS  AND SUMMARY TABLES #
  #############################  
  datTable$trialIdxPerStim <-0
  for (ss in unique(datTable$subjID)){
    tmpT <-datTable[which(datTable$subjID==ss)]
    for (tt in unique(datTable$aStim)){
      tmpT[which( tmpT$aStim== tt)]$trialIdxPerStim <- seq.int(nrow(tmpT[which(tmpT$aStim== tt)]))
    }
    datTable[which(datTable$subjID==ss)] <-tmpT
  }
  # New trial index that resets at block 2 (for some plots )
  datTable$newTrialIdx <- 0
  for (ss in unique(datTable$subjID)){
    subidx<-which(datTable$subjID==ss) 
    for (b in unique(datTable[subidx,]$block)){
      datTable[which(datTable$subjID==ss & datTable$block==b)]$newTrialIdx <- seq.int(nrow(datTable[which(datTable$subjID==ss & datTable$block==1)]))
    }
  }
  
  # MODEL RESULTS
  traces <- traceplot(fit, pars = c("mu_a", "mu_tau", "mu_v_mod"))+  theme_bw(12)
  
  #traces <- traceplot(fit, pars = c("mu_alpha", "mu_v_mod","mu_tau", "lp__"))+
   # theme_bw(12)
  
  histo <- stan_hist(fit, pars = c("mu_a","mu_v_mod","mu_tau"))+  theme_bw(12)    
  
  denso <-  stan_dens(fit, pars = c("mu_a","mu_v_mod","mu_tau"))+ theme_bw(12)    
  
  # PARAMETERS PER SUBJECT
  param2plot <- c("a","tau","v_mod")
  rainbow <-  c("orange","darkgreen","dodgerblue4")
  PLO <- list()
  for (i in 1:length(param2plot)){
    xdat <- as.factor(1)
    PLO[[i]] <- ggplot(data=subject_parameters, aes_string(x=xdat,y=param2plot[i])) +
      geom_flat_violin(position = position_nudge(x = 0.0, y = 0.02), adjust = .9, trim = FALSE, alpha = .1,colour=rainbow[i],fill=rainbow[i]) +
      geom_point(aes(x=as.numeric(xdat)-0.06),fill = rainbow[i], color="black",position=position_jitter(0.02,0,3), size = 2.5, alpha=.5,shape=21) +
      #scale_fill_manual(values = cols ) +
      #scale_colour_manual(values = cols ) +
      geom_boxplot(aes(x=as.numeric(xdat)-0.15),width = .03,size=.8, fill=rainbow[i],outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
      stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
      stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 3,color="black",fill="black",alpha = 1)+
      theme_bw(12)+ 
      labs(x="",y=param2plot[i])+
      theme(title = element_text(size=10),
            axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(angle = 45,size=10,color="black"),
            axis.text.y = element_text(size=0,color="black"),
            axis.title.x = element_text(size=10,color="black"),
            plot.caption = element_text(colour ="red"))
  }
  
  
  # SOME TRIAL-BASED ESTIMATES (association strength)
  reg2plot <- c("pe_pos","pe_neg","drift")
  rainbow2 <-  c("orange","darkgreen","dodgerblue4")
  param_pertrial$newTrialIdx <- datTable$newTrialIdx
  param_pertrial$trialIdxPerStim <- datTable$trialIdxPerStim
  param_pertrial$aStim <- as.factor(param_pertrial$aStim)
  TRIALPLO <- list()
  for (i in 1:length(reg2plot)){ 
    TRIALPLO[[i]] <- 
      ggplot(data=param_pertrial, aes_string(x="trialIdxPerStim",y=reg2plot[i])) +
      geom_point(fill="black",alpha=.3,size=1.5) +
      #scale_fill_manual(values = cols ) +
      #scale_colour_manual(values = cols ) +
      #geom_boxplot(aes(x=as.numeric(xdat)-0.15),width = .03,size=.8, fill=rainbow[i],outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
      #stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
      #stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 3,color="black",fill="black",alpha = 1) +
      stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1,color="red",alpha = .8) +
      stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",size = 1,fill="red",alpha = .2) +
      stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 1,fill="red",color="black",alpha = 1) +
      facet_wrap(~aStim, nrow = 2)+
      #coord_flip()+ 
      theme_bw(12)+ 
      labs(x="repetition",y=param_pertrial[i])+
      theme(title = element_text(size=10),
            axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(angle = 45,size=10,color="black"),
            axis.text.y = element_text(size=10,color="black"),
            axis.title.x = element_text(size=10,color="black"),
            plot.caption = element_text(colour ="red"))  + 
      scale_x_continuous(breaks = seq(0,length(unique(T$trialIdxPerStim)),1))  # play with y axis ticks and range 
    
  }
  
  
  
  thing2plot <- "pe_pos"
  PEPLO <-  ggplot(data=param_pertrial, aes_string(x="newTrialIdx",y=thing2plot)) +
    geom_point(fill="black",alpha=.3,size=1.5 ) +
    geom_hline(yintercept=0,color = "black",linetype="dashed", size=.1) +
    #scale_fill_manual(values = cols ) +
    #scale_colour_manual(values = cols ) +
    #geom_boxplot(aes(x=as.numeric(xdat)-0.15),width = .03,size=.8, fill=rainbow[i],outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
    #stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
    #stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 3,color="black",fill="black",alpha = 1) +
    stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1,color="red",alpha = .8) +
    stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",size = 1,fill="red",alpha = .2) +
    stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 1,fill="red",color="black",alpha = 1) +
    #facet_wrap(~block, nrow = 2)+
    #coord_flip()+ 
    theme_bw(12)+ 
    labs(x="trial",y=thing2plot)+
    theme(title = element_text(size=10),
          axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
          axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
          axis.text.x = element_text(angle = 45,size=10,color="black"),
          axis.text.y = element_text(size=10,color="black"),
          axis.title.x = element_text(size=10,color="black"),
          plot.caption = element_text(colour ="red")) 
  
  
  #####################
  # COMBINE FIGURES   
  combo <- 
    ggdraw() +
    draw_plot(traces, x = 0, y = .75, width = .5, height = .25) +
    draw_plot(denso, x = .5, y = .75, width = .5, height = .25) +
    draw_plot(PLO[[1]], x = 0, y = .5, height = .23,width  = .16) + 
    draw_plot(PLO[[2]], x = .16, y = .5,height = .23, width = .16) + 
    draw_plot(PLO[[3]], x = .32, y = .5, height = .23, width = .16) 
   #draw_plot(TRIALPLO[[1]], x = .5, y = .37, width = .5, height = .37) +  
   # draw_plot(TRIALPLO[[2]], x = .5, y = 0, width = .5, height = .37)
  
  combo <-
    annotate_figure(combo,text_grob(paste("RLDDM Model overview ( N = ",dim(subjs)[1],")",sep=""),color = "blue", face = "bold", size = 12)) #+ 
   # draw_plot_label(label = c("A", "B", "C"), col="black",size = 12, x = c(0, 0, 0), y = c(.98,.75,.5))
  
  
  # Save 
  setwd(diroutput)
  outputname <- paste("PLOT_",dim(subjs)[1],"ss.jpg")
  ggsave(outputname,combo,width = 350, height = 310, dpi=300, units = "mm")
  
}
  