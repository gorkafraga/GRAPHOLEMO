rm(list=ls(all=TRUE)) # re all 
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr","ggplotify","grid")
lapply(Packages, require, character.only = TRUE)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")
#=============================================================================================================================
#
#  GATHER OUTPUT FROM MODEL FIT
#
#=============================================================================================================================


dirinput <- choose.dir('O:/studies/allread/mri/analysis_GFG/stats/task/modelling/model_choiceRT/Preproc_ChoiceRTddm_84ss/')
dirPreprocessed <-dirinput
diroutput <- dirinput
fileinput <- "ddm_fit.rds" # model to read

# READ MODEL FIT 
#--------------------------------------------
setwd(dirinput)
datTable <- read.table("datTable.txt")
fit <- readRDS(fileinput) # read model output

# retrive some info from the current model 
modelname<- fit$fit@model_name
niterations <- fit$fit@stan_args[[1]]$iter
nburnin <- fit$fit@stan_args[[1]]$warmup
nchains <-  length(fit$fit@stan_args)
found_parameters <- names(fit$parVals)
   
 
maintitle <- paste(modelname," had ",nchains," chains of ",niterations, " iterations (",nburnin, " burn-in)")
# PLOTS
#----------------------------------------------------------------------------------------------------------
# basic histograms
setwd(diroutput)
jpeg(file="Histograms.jpg",width = 300,height = 250,units = 'mm', res = 150)
plot.new()
plot(fit)
title(main=maintitle,line = +3)
dev.off()
# summary of main parameters 
paranames <- c("alpha","beta","delta","tau")
sPARA <- fit$allIndPars
sPARA <- gather(fit$allIndPars,"parameter","value",paranames)
sPARA$parameter <- as.factor(sPARA$parameter)
#rainclouds <- 
raincloud <- list()
rainbow<- c("firebrick2","darkgreen","deepskyblue3","darkorange")
for (p in 1:length(paranames)){
  raincloud[[p]] <-   local  ({
                       rcplot <- 
                          ggplot(subset(sPARA,parameter==paranames[p]),aes(x=1,y=value),fill=rainbow[p],color=rainbow[p])+ 
                          geom_point(aes(x=as.numeric(1)-0.1,y=value),shape=21,alpha=.7,size=3,fill=rainbow[p]) + 
                          geom_flat_violin(aes(x=as.numeric(1)+0.1),alpha=.3,fill=rainbow[p]) + 
                          geom_boxplot(aes(x=as.numeric(1)),width=.1,fill=rainbow[p]) + 
                          stat_summary(aes(x=as.numeric(1)+0.1),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.05,size = 1,alpha = 1) +  
                          stat_summary(aes(x=as.numeric(1)+0.1),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 4,color="black",fill="black",alpha = 1) +
                          labs(x  = paranames[p],y="") +
                          theme_bw(12)+
                          theme(axis.text.x = element_text(angle = 45,size=12,color="white"))
                         print(rcplot)
                        })
}
# traces
traces <- as.grob(traceplot(fit$fit,pars=c("mu_alpha","mu_beta","mu_delta","mu_tau")))
# put together
combo <- ggdraw() + 
   draw_plot(raincloud[[1]],x=0,y=0,width=1/4,height=1/2) +
   draw_plot(raincloud[[2]],x=1/4,y=0,width=1/4,height=1/2) + 
   draw_plot(raincloud[[3]],x=2/4,y=0,width=1/4,height=1/2) + 
   draw_plot(raincloud[[4]],x=3/4,y=0,width=1/4,height=1/2) + 
   draw_plot(traces,x=0,y=1/2,width=1,height=1/2) 

combo <-  annotate_figure(combo,text_grob(maintitle,color = "purple", face = "bold", size = 12))
ggsave("Summary.jpg",combo,width = 350, height = 310, dpi=150, units = "mm")

