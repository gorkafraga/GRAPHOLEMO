rm(list=ls())
library(openxlsx)
library(plotly)
library(ggplot2)
library(gridExtra)
library(dplyr)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")

#  Summarize Beta values from ROI analysis
###############################################################################################
task_list <- c('FBL_A','FBL_B')
beta_type <- 'mean' # eigen, mean or median
model <- '2Lv_GLM0_thirds_exMiss'
diroutput <-  paste0('O:/studies/grapholemo/analysis/LEMO_GFG/mri/2ndLevel/FBL_taskDifferences','/',model)
dir.create(diroutput)

dlong_bothTasks <- list()
for (t in 1:length(task_list)){
    task <- task_list[t]  
    dirinput <- paste0('O:/studies/grapholemo/analysis/LEMO_GFG/mri/2ndLevel/',task,'/',model,'/ROI_',beta_type)
    setwd(dirinput)
    # firt compile beta values for ROIs from the different contrasts
    files <- dir(dirinput,pattern='ROIs.*._con*.*.csv')
    dat <- list()
      for (f in 1:length(files)){
        tmpwide <- read.csv(paste0(dirinput,'/', files[f]))
        dat[[f]] <- tidyr:::pivot_longer(tmpwide,cols=colnames(tmpwide)[-1], values_to='betas')
        
      }
    #merge2one table
    dlong <- do.call(rbind,dat)
    #formatting and grouping of regions
    dlong <- tidyr:::separate(dlong, name,c('roi','con')) # split rois and contrasts as different values 
    dlong$con <- as.factor(dlong$con)
    dlong$roi <- as.factor(dlong$roi)
    dlong$subject <- as.factor(dlong$subject)
    levels(dlong$con) <- c('S1-3','S3-1','F1-3','F3-1','S1','S3','F1','F3')
    dlong$network <- ''
    dlong$network[which(dlong$roi %in% c('LFusi','RFusi','LSTG','RSTG','LPrecentral','RPrecentral'))] <- "groupA"
    dlong$network[which(dlong$roi %in% c('LPutamen','RPutamen','LCaudate','RCaudate' ))] <- 'groupB'
    dlong$network[which(dlong$roi %in% c('LHippocampus','RHippocampus','LInsula','RInsula'))] <- 'groupC'
    dlong$network[which(dlong$roi %in% c('LmidCingulum','RmidCingulum','LSupramarginal','RSupramarginal'))] <- 'groupD'
  
    #add task information
    dlong$task <- task 
    # Merge with master
    dlong_bothTasks[[t]] <- dlong
}
# put together 
dlong_bothTasks <- do.call(rbind,dlong_bothTasks)


# Compute differences between tasks  add as variable 
taskDiff <- dlong_bothTasks %>% group_by(subject, roi,con,network) %>% summarize(betas = betas[task=='FBL_A'] - betas[task=='FBL_B'])
taskDiff$task <- 'FBL_AB'
taskDiff2 <- dlong_bothTasks %>% group_by(subject, roi,con,network) %>% summarize(betas = betas[task=='FBL_B'] - betas[task=='FBL_A'])
taskDiff2$task <- 'FBL_BA'

dlong2plot <- rbind(dlong_bothTasks, taskDiff,taskDiff2)
dlong2plot$network <- as.factor(dlong2plot$network)
dlong2plot$task <- as.factor(dlong2plot$task)


# Make basic plotting function 
baseplot <- function(datcurr,ds) {
  gg <- 
    
    ggplot(datcurr,aes(x=con,y=betas)) +
    geom_hline(yintercept=0,size=.1,linetype='dashed' ) + 
    geom_point(aes(fill=con),shape=23, size = .4,alpha=.4) + 
    geom_boxplot(aes(fill=con,color=con),width=.5,alpha=.3,outlier.alpha=.5,outlier.size = .4,fatten=NULL, notch=TRUE,lwd=.1) +
    #
    geom_errorbar(data=ds, aes(x= con,ymin=betas-ci,ymax=betas+ci),lwd=1,width=.1)+
    geom_point(data=ds,aes(x=con,y=betas,fill=con),shape=21,size = 2) +
    facet_wrap(~task) +
    scale_color_manual(values=colormap)+
    scale_fill_manual(values=colormap)+
    theme_bw() +
    theme(axis.title.x =element_blank(),
          axis.title=element_text(size=14),
          axis.text = element_text(size=12),
          axis.text.x = element_text(angle=-45),
          panel.grid.minor.y = element_blank())+
    scale_y_continuous(name=paste0(unique(datcurr$roi), ' beta (', beta_type, ')'),limits = c(-20,20),breaks=c(-15,-10,-5,0,5,10,15),labels=c('', -10, -5,0,5,10,''))
  
  
}
# define colors
colormap <- c('dodgerblue1','dodgerblue4','green3','green4','deepskyblue','deepskyblue3','chartreuse','chartreuse4')

# Create PLOTS for each roi 
rois <- unique(dlong$roi)
for (i in 1:length(rois)){
  datcurr <- dlong2plot[which(dlong2plot$roi == rois[i] & dlong2plot$task != 'FBL_BA'),]
   ds <-Rmisc::summarySE(datcurr,measurevar="betas",groupvars = c("roi","con","task")) 
  
  #CAll plot func
  gg <- baseplot(datcurr,ds)
  print(gg)
  # Save 
  ggsave(paste0(diroutput,'/Beta_taskDiff_',beta_type,'_',model,'_',rois[i],'.jpg'),plot=gg, units = 'mm', height = 200, width = 250,dpi = 300)
}


