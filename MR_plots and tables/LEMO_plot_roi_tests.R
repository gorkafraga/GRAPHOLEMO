rm(list=ls())
library(openxlsx)
library(plotly)
library(ggplot2)
library(gridExtra)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")

#  Summarize Beta values from ROI analysis
###############################################################################################
task <- 'FBL_B'
beta_type <- 'eigen' # eigen, mean or median 


dirinput <- paste0('O:/studies/grapholemo/analysis/LEMO_GFG/mri/2ndLevel/FeedbackLearning/',task,'/2Lv_GLM0_thirds_exMiss/ROI_',beta_type)
diroutput <- dirinput
setwd(dirinput)
# firt compile beta values for ROIs from the different contrasts
files <- dir(dirinput,pattern='ROIs.*._con*.*.csv')
dat <- list()
for (f in 1:length(files)){
  tmpwide <- read.csv(paste0(dirinput,'/', files[f]))
  dat[[f]] <- tidyr:::pivot_longer(tmpwide,cols=colnames(tmpwide)[-1], values_to='values')

}
dlong <- do.call(rbind,dat)
dlong <- tidyr:::separate(dlong, name,c('roi','con')) # split rois and contrasts as different values 
dlong$con <- as.factor(dlong$con)
dlong$roi <- as.factor(dlong$roi)
dlong$subject <- as.factor(dlong$subject)
levels(dlong$con) <- c('S1-3','S3-1','F1-3','F3-1','S1','S3','F1','F3')

 
#summary stats
dlong$network <- ''
dlong$network[which(dlong$roi %in% c('LFusi','RFusi','LSTG','RSTG','LPrecentral','RPrecentral'))] <- "groupA"
dlong$network[which(dlong$roi %in% c('LPutamen','RPutamen','LCaudate','RCaudate' ))] <- 'groupB'
dlong$network[which(dlong$roi %in% c('LHippocampus','RHippocampus','LInsula','RInsula'))] <- 'groupC'
dlong$network[which(dlong$roi %in% c('LmidCingulum','RmidCingulum','LSupramarginal','RSupramarginal'))] <- 'groupD'
 

# Make basic plotting function 
baseplot <- function(datcurr,ds) {
  gg <- 
    ggplot(datcurr,aes(x=con,y=values)) +
    geom_hline(yintercept=0,size=.1,linetype='dashed' ) + 
    geom_point(aes(fill=con),shape=23, size = .4,alpha=.2) + 
    geom_boxplot(aes(fill=con,color=con),width=.5,alpha=.3,outlier.alpha=.3,outlier.size = .4,fatten=NULL, notch=TRUE,lwd=.1) +
    #
    geom_errorbar(data=ds, aes(x= con,ymin=values-ci,ymax=values+ci),lwd=1,width=.1)+
    geom_point(data=ds,aes(x=con,y=values,fill=con),shape=21,size = 2) +
    facet_wrap(~roi) +
    scale_color_manual(values=colormap)+
    scale_fill_manual(values=colormap)+
    theme_bw() +
    theme(axis.title.x =element_blank(),
          axis.title=element_text(size=14),
          axis.text = element_text(size=12),
          axis.text.x = element_text(angle=-45),
          panel.grid.major = element_blank())+
    scale_y_continuous(name=paste0(beta_type, ' values') ,limits = c(-15,15),breaks=c(-15,-10,-5,0,5,10,15),labels=c('', -10, -5,0,5,10,''))
  
}


colormap <- c('dodgerblue1','dodgerblue4','green3','green4','deepskyblue','deepskyblue3','chartreuse','chartreuse4')

# Create PLOTS for each roi 
networks <- c('groupA','groupB','groupC','groupD')
rois <- unique(dlong$roi)
for (i in 1:length(rois)){
  datcurr <- dlong[which(dlong$roi == rois[i]),]
  ds <-Rmisc::summarySE(datcurr,measurevar="values",groupvars = c("roi","con")) 
  
  #CAll plot func
  gg <- baseplot(datcurr,ds)
  #print(gg)
  # Save 
  ggsave(paste0(diroutput,'/rois_',beta_type,'_',task,'_',rois[i],'.jpg'),plot=gg, units = 'mm', height = 125, width = 125,dpi = 300)
}




# Create PLOTS per group of ROIs
 ggs <- list()
 networks <- c('groupA','groupB','groupC','groupD')
 for (i in 1:length(networks)){
   datcurr <- dlong[which(dlong$network == networks[i]),]
   ds <-Rmisc::summarySE(datcurr,measurevar="values",groupvars = c("roi","con")) 
   #CAll plot func
   gg <- baseplot(datcurr,ds)
   # Remove legend preserving plot dimensions in the first three plots
    if (i <4){
      gg <- gg + theme(axis.title.x = element_blank(),
                       legend.text = element_text(color = "white"),
                       legend.title = element_text(color = "white"),
                       legend.key = element_rect(fill = "white"))+
        guides(color = guide_legend(override.aes = list(color="white")))+ 
        guides(fill = guide_legend(override.aes = list(fill="white")))
    }
    ggs[[i]]<- gg  
 }
 
combi <- ggpubr::ggarrange(ggs[[1]],ggs[[2]],ggs[[3]],ggs[[4]],labels=c('A','B','C','D'))
 #print(combi)
# Save 
 ggsave(paste0(diroutput,'/rois_',beta_type,'_',task,'.jpg'),plot=combi, units = 'mm', height = 325, width = 325,dpi = 300)
 
 
#######################################################
 
 # A plot with Hemisphere in x axis , per roi for the contrasts of interest
 
 dlong$hemis <- substr(dlong$roi,1,1)
 dlong$roi <-  substr(dlong$roi,2,nchar(as.character(dlong$roi)))
 dlong$roi <- as.factor(dlong$roi)
 dlong$hemis <- as.factor(dlong$hemis)
 
 colormap <- c('green3','dodgerblue1')
 # Create PLOTS for each roi  
 rois <- unique(dlong$roi)
 for (i in 1:length(rois)){
   datcurr <- dlong[which(dlong$roi == rois[i] & dlong$con =='S3-1'),]
   
   ds <-Rmisc::summarySE(datcurr,measurevar="values",groupvars = c("hemis","roi","con")) 
   
   #CAll plot func
   gg <-
     ggplot(datcurr,aes(x=hemis,y=values)) +
     geom_hline(yintercept=0,size=.1,linetype='dashed' ) + 
     geom_point(aes(fill=hemis),shape=23, size = .4,alpha=.2) + 
     geom_boxplot(aes(fill=hemis,color=hemis),width=.5,alpha=.3,outlier.alpha=.3,outlier.size = .4,fatten=NULL, notch=TRUE,lwd=.1) +
     #
     geom_errorbar(data=ds, aes(x= hemis,ymin=values-ci,ymax=values+ci),lwd=1,width=.1)+
     geom_point(data=ds,aes(x=hemis,y=values,fill=hemis),shape=21,size = 2) +
     facet_wrap(~roi) +
     scale_color_manual(values=colormap)+
     scale_fill_manual(values=colormap)+
     theme_bw() +
     theme(axis.title.x =element_blank(),
           axis.title=element_text(size=14),
           axis.text = element_text(size=12),
           axis.text.x = element_text(angle=0),
           panel.grid.major = element_blank())+
     scale_y_continuous(name=paste0(beta_type, ' values (S31)') ,limits = c(-15,15),breaks=c(-15,-10,-5,0,5,10,15),labels=c('', -10, -5,0,5,10,''))
   #print(gg)
   # Save 
   ggsave(paste0(diroutput,'/rois_',beta_type,'_',task,'_',rois[i],'_s31.jpg'),plot=gg, units = 'mm', height = 100, width = 75,dpi = 300)
 }
  # other contrast
 
 for (i in 1:length(rois)){3
   datcurr <- dlong[which(dlong$roi == rois[i] & dlong$con =='F3-1'),]
   
   ds <-Rmisc::summarySE(datcurr,measurevar="values",groupvars = c("hemis","roi","con")) 
   
   #CAll plot func
   gg <-
     ggplot(datcurr,aes(x=hemis,y=values)) +
     geom_hline(yintercept=0,size=.1,linetype='dashed' ) + 
     geom_point(aes(fill=hemis),shape=23, size = .4,alpha=.2) + 
     geom_boxplot(aes(fill=hemis,color=hemis),width=.5,alpha=.3,outlier.alpha=.3,outlier.size = .4,fatten=NULL, notch=TRUE,lwd=.1) +
     #
     geom_errorbar(data=ds, aes(x= hemis,ymin=values-ci,ymax=values+ci),lwd=1,width=.1)+
     geom_point(data=ds,aes(x=hemis,y=values,fill=hemis),shape=21,size = 2) +
     facet_wrap(~roi) +
     scale_color_manual(values=colormap)+
     scale_fill_manual(values=colormap)+
     theme_bw() +
     theme(axis.title.x =element_blank(),
           axis.title=element_text(size=14),
           axis.text = element_text(size=12),
           axis.text.x = element_text(angle=0),
           panel.grid.major = element_blank())+
     scale_y_continuous(name=paste0(beta_type, ' values (F31)') ,limits = c(-15,15),breaks=c(-15,-10,-5,0,5,10,15),labels=c('', -10, -5,0,5,10,''))
   #print(gg)
   # Save 
   ggsave(paste0(diroutput,'/rois_',beta_type,'_',task,'_',rois[i],'_f31.jpg'),plot=gg, units = 'mm', height = 100, width = 75,dpi = 300)
 }
 
 
 # arrange in grid
 #library(grid)
 #grid:::grid.newpage()
 #grid:::pushViewport(viewport(layout = grid.layout(nrow = 2, ncol = 2)))
 ## A helper function to define a region on the layout
 #define_region <- function(row, col){
#   viewport(layout.pos.row = row, layout.pos.col = col)
# }
# print(ggs[[1]], vp = define_region(row = 1, col = 1))  
# print(ggs[[2]], vp = define_region(row = 1, col = 2))    
# print(ggs[[3]], vp = define_region(row = 2, col = 1))   
# print(ggs[[4]], vp = define_region(row = 2, col = 2))   
 
  