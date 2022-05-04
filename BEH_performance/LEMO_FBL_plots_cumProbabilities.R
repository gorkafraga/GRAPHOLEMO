rm(list=ls())
library(openxlsx)
library(plotly)
library(ggplot2)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")

###############################################################################################
# Read data with the calculated cumulative probabilities

###############################################################################################
# files and directories
task <- 'FBL_A'
raw <- haven::read_sav(paste0('O:/studies/grapholemo/analysis/LEMO_GFG/beh/LEMO_fbl_probabilities.sav'))
diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/beh/stats_task/plots_taskPerformance/'
setwd(diroutput)



# Plots 
dat <- raw[which(raw$task==task),]
dat$ProbCum_block <- as.factor(dat$ProbCum_block)
levels(dat$ProbCum_block) <- c('Block 1', 'Block 2')

dat$ProbCum_stim <- as.factor(dat$ProbCum_stim)
levels(dat$ProbCum_stim) <- paste0('S',levels(dat$ProbCum_stim))

dat$ProbCum_rep <- as.numeric(dat$ProbCum_rep) 


p1 <-
  ggplot(dat,aes(x=ProbCum_rep,y=ProbCum_value,color=ProbCum_stim)) + 
  stat_summary(aes(color=ProbCum_stim),fun = mean,geom = "line",size = 1.2,alpha=0.8) +
  stat_summary(aes(fill=ProbCum_stim),fun.data = mean_cl_boot,geom = "ribbon",size = 0,alpha = 0.15,colour=NA) +
  facet_wrap(~ProbCum_block,nrow = 1)+
  scale_y_continuous(breaks = seq(0,8))+ expand_limits( y=c(0,8))+ 
  theme_bw() +
  theme(text = element_text(size=25))

p2 <-
  ggplot(dat,aes(x=ProbCum_rep,y=ProbCum_value,color=ProbCum_stim)) + 
  stat_summary(aes(color=ProbCum_stim),fun = mean,geom = "line",size = 1.2,alpha=0.8) +
  stat_summary(aes(fill=ProbCum_stim),fun.data = mean_cl_boot,geom = "ribbon",size = 0,alpha = 0.2,colour=NA) +
  facet_wrap(~ProbCum_block*ProbCum_stim,nrow = 2)+
  scale_y_continuous(breaks = seq(0,8)) + expand_limits( y=c(0,8))+  
  theme_bw()


p3 <-
  ggplot(dat,aes(x=ProbCum_rep,y=ProbCum_value)) + 
  geom_point(aes(fill=subjID),size=1,shape=23)+
  geom_line(aes(color=subjID))+
  #stat_summary(aes(color=ProbCum_stim),fun = mean,geom = "line",size = 1.2,alpha=0.8) +
  #stat_summary(aes(fill=ProbCum_stim),fun.data = mean_cl_boot,geom = "ribbon",size = 0,alpha = 0.2,colour=NA) +
  facet_wrap(~ProbCum_block*ProbCum_stim,nrow = 2)+
  scale_y_continuous(breaks = seq(0,8))+ expand_limits( y=c(0,8))+ 
  theme_bw()


#save 
ggsave(plot = p1,filename = paste0(diroutput,"/",task,"_cumProbabilities_facetBlock.jpg"),height=130,width = 175,dpi = 300,units="mm")
ggsave(plot = p2,filename = paste0(diroutput,"/",task,"_cumProbabilities_facetStimBlock.jpg"),height=140,width = 225,dpi = 300,units="mm")
ggsave(plot = p3,filename = paste0(diroutput,"/",task,"_cumProbabilities_perSubject.jpg"),height=250,width = 225,dpi = 150,units="mm")
