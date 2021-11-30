rm(list=ls())
library(openxlsx)
library(plotly)
library(ggplot2)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")

###############################################################################################
#  Summarize behavioral data with plots

###############################################################################################
# files and directories
raw <- haven::read_sav('O:/studies/grapholemo/analysis/LEMO_GFG/beh/LEMO_beh_fbl_long.sav')
diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/beh/Plots_taskPerformance'
setwd(diroutput)
 
# first subject filter to the data 
dat <- raw[raw$fb==1,]
dat <- dat[!is.na(dat$third),]
dat$block <- as.factor(dat$block)
  levels(dat$block) <- c('b1','b2')
dat$third <- as.factor(dat$third)
dat$task  <- as.factor(dat$task)

#summary stats
ds <-Rmisc::summarySE(dat,measurevar="proportionPerThird",groupvars = c("third","block","task"))


# ACCURACY LINE PLOT
    gfig<-   ggplot(dat,aes(x=third,y=proportionPerThird,group=block))+
     # geom_flat_violin(aes(x=third,fill = third),position = position_nudge(x = 0.3, y = 0), adjust = .8, trim = TRUE, alpha = .5, colour = "gray45")+
      geom_errorbar(data=ds, aes(x= third,ymin=proportionPerThird-ci,ymax=proportionPerThird+ci,color=block),lwd=1,width=.1)+
      geom_line(data=ds,aes(color=block),lwd=1.5)+
     geom_point(data=ds,aes(x=third,y=proportionPerThird,fill=block),shape=21,size =5)+
      labs(title = paste0("N = ",unique(ds$N),""),lims=c(.6,1))+ 
      theme_bw()+
      theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(size=12,color="black",angle=30,hjust = 1),
            axis.text.y = element_text(size=12,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) 
     
    gfig <- gfig + facet_grid(~task)
    gfig
    #save 
    ggsave(plot = gfig,filename = paste0(diroutput,"/FBL_accuracy.jpg"),height=250,width = 210,dpi = 150,units="mm")
         
  
# ACCURACY BOX PLOT
 gfig<-  ggplot(dat,aes(x=third,y=proportionPerThird))+
     geom_boxplot(aes(group=third,fill=third))+
     facet_grid(~task*block,as.table = TRUE)+
    geom_hline(yintercept=.5, linetype="dashed", color = "red", size=1)+
      labs(title = paste0("N = ",length(unique(dat$subjID)),""))+ 
      theme_bw()+
      theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(size=12,color="black",angle=30,hjust = 1),
            axis.text.y = element_text(size=12,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) 
    
     gfig
    #save 
    ggsave(plot = gfig,filename = paste0(diroutput,"/FBL_accuracy_boxplots.jpg"),height=250,width = 200,dpi = 150,units="mm")
    
    
    
# RT BOX PLOT
    
    # first subject filter to the data 
    dat <- raw[raw$fb!=2,]
    dat <- dat[!is.na(dat$third),]
    dat$block <- as.factor(dat$block)
    levels(dat$block) <- c('b1','b2')
    dat$third <- as.factor(dat$third)
    dat$task  <- as.factor(dat$task)
    dat$fb  <- as.factor(dat$fb)
      levels(dat$fb) <- c('errors','hits')
      

    
    gfig<-  ggplot(dat,aes(x=fb,y=meanRT))+
      geom_boxplot(aes(group=fb,fill=fb))+
      facet_grid(~task*block,as.table = TRUE)+
       labs(title = paste0("N = ",length(unique(dat$subjID)),""))+ 
      theme_bw()+
      theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(size=12,color="black",angle=30,hjust = 1),
            axis.text.y = element_text(size=12,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) 
    
     gfig
    #save 
    ggsave(plot = gfig,filename = paste0(diroutput,"/FBL_rt_boxplots.jpg"),height=250,width = 225,dpi = 150,units="mm")
    