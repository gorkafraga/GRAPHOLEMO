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
#source("N:/Developmental_Neuroimaging/Scripts/Misc R/R-plots and stats/Geom_flat_violin.R")
#--------------------------------------
#set dirs
choiceModel <- 'rlddm1'
dirinput <- paste("O:/studies/allread/mri/analysis_GFG/stats/task/model/Preproc_19ss/output_",choiceModel,sep="")
dirPreprocessed <- "O:/studies/allread/mri/analysis_GFG/stats/task/model/Preproc_19ss"
diroutput <- dirinput
#modelpath <- "N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_models/Stan"
# Some settings
meancenter=1
#
setwd(dirinput)
load(paste(dirPreprocessed,"/Preproc_data",sep="")) #read gathered data (that will be combined with model parameters later)
load(paste(dirPreprocessed,"/Preproc_list",sep="")) #read list with gather data input for model
fit <- readRDS(paste(dirinput,"/fit_rlddm.rds",sep="")) # read model output

#----------------------------------------------------------------------------
# GET  DATA 
#----------------------------------------------------------------------------
# Extract results 
parVals <- rstan::extract(fit, permuted = TRUE)
fit_summary <- rstan::summary(fit)
print(fit_summary)


#####################################
# EXTRACT AND WRITE OUT PARAMETERS  #
#####################################
setwd(diroutput)

alpha <- rep("NA",dat$N)
for (i in 1:dat$N){
  index <- paste0("alpha[",i,"]")
  alpha[i] <- fit_summary$summary[index,1]
}
alpha <- as.double(alpha)


drift_mod <- rep("NA",dat$N)
for (i in 1:dat$N){
  index <- paste0("v_mod[",i,"]")
  drift_mod[i] <- fit_summary$summary[index,1]
}
drift_mod <- as.double(drift_mod)

tau <- rep("NA",dat$N)
for (i in 1:dat$N){
  index <- paste0("tau[",i,"]")
  tau[i] <- fit_summary$summary[index,1]
}
tau <- as.double(tau)

# delta = average of upper and lower response boundary
deltas <- rep("NA",dat$T)
for (i in 1:dat$T){
  index <- paste0("delta_hat[",i,"]")
  deltas[i] <- fit_summary$summary[index,1]
}
deltas <- as.double(deltas)

# association strength of active (i.e. correct) stimulus pair
assoc_active_pair <- rep("NA",dat$T)
for (i in 1:dat$T){
  index <- paste0("assoc_active_pair[",i,"]")
  assoc_active_pair[i] <- fit_summary$summary[index,1]
}
assoc_active_pair <- as.double(assoc_active_pair)

# association strength of inactive (i.e. incorrect) stimulus pair
assoc_inactive_pair <- rep("NA",dat$T)
for (i in 1:dat$T){
  index <- paste0("assoc_inactive_pair[",i,"]")
  assoc_inactive_pair[i] <- fit_summary$summary[index,1]
}
assoc_inactive_pair <- as.double(assoc_inactive_pair)

# prediction errors
pe_hat <- rep("NA",dat$T)
for (i in 1:dat$T){
  index <- paste0("pe_hat[",i,"]")
  pe_hat[i] <- fit_summary$summary[index,1]
}
pe_hat <- as.double(pe_hat)



# add the trial-by-trial regressors to the dataset
tbtregs <- cbind(pe=as.array(pe_hat),delta=as.array(deltas),drift=rep(0,dat$T),assoc_active=as.array(assoc_active_pair),assoc_inactive=as.array(assoc_inactive_pair))
tbtregs <-as.data.frame(tbtregs)
#tbtregs <- cbind(raw_data[,1:9],raw_data[,18],raw_data[,14:16],pe=as.array(pe_hat),delta=as.array(deltas),drift=rep(0,dat$T),assoc_active=as.array(assoc_active_pair),assoc_inactive=as.array(assoc_inactive_pair))
for(i in 1:dat$N){
  subj = as.character(T$subjID[i])
  tbtregs[which(tbtregs$subjID==subj),]$drift = tbtregs[which(tbtregs$subjID==subj),]$delta * drift_mod[i]
}
tbtregs <- cbind(T,tbtregs)

# INDIVIDUAL SUBJ PARAMETERS
#---------------------------

# write out parameters for each subject separately
n_subj<-length(unique(T$subjID))
for(i in 1:n_subj){
  subj = unique(T$subjID)[i]
  #cat(i,subj,"\n")
  write.table(tbtregs[which(tbtregs$subjID==subj),], paste0(subj,"_params",".csv"),
              quote=FALSE, sep=",", row.names=FALSE, col.names=TRUE)
}
# SUBJ PARAMETERS
#---------------------------
mean_drift <-  rep("NA",dat$N)
mean_drift <- aggregate(list(drift=tbtregs$drift),list(subjID=tbtregs$subjID), mean)
subj_params <- cbind(mean_drift,alpha,tau,drift_mod)

# write out subject parameters
write.table(subj_params, "subj_params.csv", sep=",", row.names=FALSE, col.names=TRUE,quote = FALSE)


#############################
# PLOTS  AND SUMMARY TABLES #
#############################
T$trialIdxPerStim <-0
for (ss in unique(T$subjID)){
  tmpT <-T[which(T$subjID==ss)]
  for (tt in unique(T$aStim)){
    tmpT[which( tmpT$aStim== tt)]$trialIdxPerStim <- seq.int(nrow(tmpT[which(tmpT$aStim== tt)]))
  }
 T[which(T$subjID==ss)] <-tmpT
}
# New trial index that resets at block 2 (for some plots )
T$newTrialIdx <- 0
for (ss in unique(T$subjID)){
  subidx<-which(T$subjID==ss) 
  for (b in unique(T[subidx,]$block)){
    T[which(T$subjID==ss & T$block==b)]$newTrialIdx <- seq.int(nrow(T[which(T$subjID==ss & T$block==1)]))
  }
}

# MODEL RESULTS
traces <- traceplot(fit, pars = c("mu_alpha", "mu_v_mod","mu_tau", "lp__"))+
  theme_bw(12)

histo <-
  stan_hist(fit, pars = c("mu_alpha","mu_v_mod","mu_tau"))+
  theme_bw(12)    

denso <-
  stan_dens(fit, pars = c("mu_alpha","mu_v_mod","mu_tau"))+
  theme_bw(12)    

# PARAMETERS PER SUBJECT
param2plot <- c("alpha","tau","drift_mod")
rainbow <-  c("orange","darkgreen","dodgerblue4")
PLO <- list()
for (i in 1:length(param2plot)){
  xdat <- as.factor(1)
  PLO[[i]] <- ggplot(data=subj_params, aes_string(x=xdat,y=param2plot[i])) +
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
reg2plot <- c("assoc_inactive","assoc_active")
rainbow2 <-  c("orange","darkgreen","dodgerblue4")
tbtregs$newTrialIdx <- T$newTrialIdx
tbtregs$trialIdxPerStim <- T$trialIdxPerStim
tbtregs$aStim <- as.factor(tbtregs$aStim)
TRIALPLO <- list()
for (i in 1:length(reg2plot)){ 
  TRIALPLO[[i]] <- 
    ggplot(data=tbtregs, aes_string(x="trialIdxPerStim",y=reg2plot[i])) +
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
    labs(x="repetition",y=reg2plot[i])+
    theme(title = element_text(size=10),
          axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
          axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
          axis.text.x = element_text(angle = 45,size=10,color="black"),
          axis.text.y = element_text(size=10,color="black"),
          axis.title.x = element_text(size=10,color="black"),
          plot.caption = element_text(colour ="red"))  + 
        scale_x_continuous(breaks = seq(0,length(unique(T$trialIdxPerStim)),1))  # play with y axis ticks and range 
    
}



thing2plot <- "pe"
PEPLO <-  ggplot(data=tbtregs, aes_string(x="newTrialIdx",y=thing2plot)) +
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
  draw_plot(PLO[[3]], x = .32, y = .5, height = .23, width = .16) +
  draw_plot(TRIALPLO[[1]], x = .5, y = .37, width = .5, height = .37) +  
  draw_plot(TRIALPLO[[2]], x = .5, y = 0, width = .5, height = .37)

combo <-
  annotate_figure(combo,text_grob(paste("RLDDM Model overview ( N = ", n_subj,")",sep=""),color = "blue", face = "bold", size = 12)) + 
  draw_plot_label(label = c("A", "B", "C"), col="black",size = 12, x = c(0, 0, 0), y = c(.98,.75,.5))
  

# Save 
setwd(diroutput)
outputname <- paste("PLOT_",n_subj,"ss.jpg")
ggsave(outputname,combo,width = 350, height = 310, dpi=300, units = "mm")

