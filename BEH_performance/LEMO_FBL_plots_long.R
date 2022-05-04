rm(list=ls())
library(openxlsx)
library(plotly)
library(ggplot2)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")

###############################################################################################
#  Summarize behavioral data with plots

###############################################################################################
# files and directories
raw <- haven::read_sav('O:/studies/grapholemo/analysis/LEMO_GFG/beh/LEMO_fbl_long.sav')
diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/beh/stats_task/Plots_taskPerformance_OK'
setwd(diroutput)
 
# first subject filter to the data 
dat <- raw[raw$fb==1,]
dat <- dat[!is.na(dat$third),]
dat$block <- as.factor(dat$block)
  levels(dat$block) <- c('Block 1','Block 2')
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
            axis.text.x = element_text(size=20,color="black",angle=0,hjust = 0.4),
            axis.text.y = element_text(size=20,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) +
      theme(text = element_text(size=25))
    
     
    gfig <- gfig + facet_grid(~task)
    gfig
    #save 
    ggsave(plot = gfig,filename = paste0(diroutput,"/FBL_accuracy.jpg"),height=130,width = 175,dpi = 300,units="mm")
         
  
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
    ggsave(plot = gfig,filename = paste0(diroutput,"/FBL_accuracy_boxplots.jpg"),height=130,width = 175,dpi = 300,units="mm")
    
    
    
# RT BOX PLOT
    
    # first subject filter to the data 
    dat <- raw[raw$fb!=2,]
    dat <- dat[!is.na(dat$third),]
    dat$block <- as.factor(dat$block)
    levels(dat$block) <- c('Block 1','Block 2')
    dat$third <- as.factor(dat$third)
    dat$task  <- as.factor(dat$task)
    dat$fb  <- as.factor(dat$fb)
      levels(dat$fb) <- c('inc','cor')
      

    
    gfig<-  
      ggplot(dat,aes(x=fb,y=meanRT))+
      
      
      geom_boxplot(aes(group=fb,fill=fb),alpha=.4,lwd=.5,width=.5)+
      facet_grid(~task*block,as.table = TRUE)+
       labs(title = paste0("N = ",length(unique(dat$subjID)),""))+ 
      theme_bw()+
      
      scale_fill_manual(values=c('firebrick','forestgreen'))+
      theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(size=20,color="black",angle=0,hjust = 0.4),
            axis.text.y = element_text(size=20,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) +
      theme(text = element_text(size=25))
    
    gfig
    #save 
    ggsave(plot = gfig,filename = paste0(diroutput,"/FBL_rt_boxplots_perFB.jpg"),height=130,width = 175,dpi = 300,units="mm")
    
    
   #----------------------
    
    levels(dat$block) <- c('1','2')
    gfig<-  
      ggplot(dat,aes(x=block,y=meanRT))+
      geom_boxplot(aes(group=block,fill=block))+
      facet_grid(~task,as.table = TRUE)+
      labs(title = paste0("N = ",length(unique(dat$subjID)),""))+ 
      theme_bw()+
      theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(size=20,color="black",angle=0,hjust = 1),
            axis.text.y = element_text(size=0,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) +
      theme(text = element_text(size=25))
    
    gfig
    #save 
    ggsave(plot = gfig,filename = paste0(diroutput,"/FBL_rt_boxplots.jpg"),height=130,width = 175,dpi = 300,units="mm")
    
    
    #--------------
    # RTs per task 
    dat <- dat[dat$fb=='cor',]
    
    ds_RT <-Rmisc::summarySE(dat[!is.na(dat$meanRT),],measurevar="meanRT",groupvars = c("third","block","task"))
    
    gfig<-  
      ggplot(dat,aes(x=third,y=meanRT,group=block))+
      # geom_flat_violin(aes(x=third,fill = third),position = position_nudge(x = 0.3, y = 0), adjust = .8, trim = TRUE, alpha = .5, colour = "gray45")+
      geom_errorbar(data=ds_RT, aes(x=third,ymin=meanRT-ci,ymax=meanRT+ci,color=block),lwd=1,width=.1) +
      facet_wrap(~task)+
      geom_line(data=ds_RT,aes(color=block),lwd=1.5) +
      geom_point(data=ds_RT,aes(x=third,y=meanRT,fill=block),shape=21,size =5)+
      labs(title = paste0("N = ",unique(ds$N),""),lims=c(.6,1))+ 
      theme_bw()+
      theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(size=20,color="black",angle=0,hjust = 0.4),
            axis.text.y = element_text(size=20,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) +
      theme(text = element_text(size=25))
    
    gfig
    #save 
    ggsave(plot = gfig,filename = paste0(diroutput,"/FBL_hitsRTs_pertask.jpg"),height=130,width = 175,dpi = 300,units="mm")
    #####################
    
    ds_RT <-Rmisc::summarySE(dat[!is.na(dat$meanRT),],measurevar="meanRT",groupvars = c("third","block"))
    
    ggplot(dat,aes(x=third,y=meanRT))+
      # geom_flat_violin(aes(x=third,fill = third),position = position_nudge(x = 0.3, y = 0), adjust = .8, trim = TRUE, alpha = .5, colour = "gray45")+
      geom_errorbar(data=ds_RT, aes(x=third,ymin=meanRT-ci,ymax=meanRT+ci),lwd=1,width=.1) +
      #facet_wrap(~task)+
      geom_line(data=ds_RT,lwd=1.5) +
      geom_point(data=ds_RT,aes(x=third,y=meanRT),shape=21,size =5)+
      labs(title = paste0("N = ",unique(ds$N),""),lims=c(.6,1))+ 
      theme_bw()+
      theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(size=20,color="black",angle=0,hjust = 0.4),
            axis.text.y = element_text(size=20,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) +
      theme(text = element_text(size=25))
    
    
    # RT HISTOGRAMS+=======
    # Select data
    dat <- raw[raw$fb!=2,]
    dat <- dat[!is.na(dat$third),]
    dat$block <- as.factor(dat$block)
    levels(dat$block) <- c('B1','B2')
    dat$third <- as.factor(dat$third)
    dat$task  <- as.factor(dat$task)
    dat$fb  <- as.factor(dat$fb)
    levels(dat$fb) <- c('inc','cor')

    gfig<-
      ggplot(dat,aes(x=meanRT,group=fb)) + 
      geom_histogram(aes(fill=fb),color='black')+
      facet_wrap(~fb*task) + 
      theme_bw()+
      theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(size=16,color="black",angle=-30,hjust = 0.2),
            axis.text.y = element_text(size=16,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) +
      theme(text = element_text(size=25))
      
    gfig
    #save 
    ggsave(plot = gfig,filename = paste0(diroutput,"/FBL_rt_histograms.jpg"),height=130,width = 125,dpi = 300,units="mm")
    
         