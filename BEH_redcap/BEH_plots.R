rm(list=ls())
library(openxlsx)
library(plotly)
library(ggplot2)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")

###############################################################################################
#  Summarize behavioral data with plots

###############################################################################################
# files and directories
master <- read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Cognitive",detectDates = TRUE)
diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/beh/plots_cognitiveTests'
setwd(diroutput)
tests <- c('rias','lgvt','ran.*.time.*','wais.*.tot*','slrt.*corr*','rst_short1_wsum')
 # first subject filter to the data 
master <- master[master$Exclusion_MRI==1,]

# Begin loop of plots per test
counter <- 0 
figs <- list()
for (i in 1:length(tests)){
    if (tests[i]== 'slrt.*corr*' ) {
      typescore <- c('raw','pr')
      
    } else if (tests[i]=='lgvt'){
      typescore <- '_pr'
    } else if (tests[i]== 'rias'){
      typescore <- c('raw','pr')
    } else {
      typescore <- 'raw'
    }
  
  for (ii in 1:length(typescore)){
 
      idx1 <- grep(paste0('^',tests[i],'.*.',typescore[ii],'.*'), colnames(master))
      vars2read <- colnames(master)[idx1]
       if (grepl('slrt*',tests[i])) {
         if (typescore[ii] =='pr'){
           vars2read <- vars2read[grep("*_pr",vars2read)]  
           print (vars2read)
         }
         
       }
         
      
      #prepare data
      dat2plot <- dplyr::select(master,all_of(c('Subj_ID',vars2read)))
      dat2plot_long <- tidyr::pivot_longer(dat2plot,all_of(vars2read))
      dat2plot_long <- dat2plot_long[which(!is.na(dat2plot_long$value)),]
      testname<- gsub("\\.","",gsub(pattern = "\\*",replacement = "",x = tests[i]))
      
      # plotly! 
      fig <- plotly::plot_ly(dat2plot_long,x =~name,y =~value,type='box',color=~name,boxpoints="suspectedOutliers")
      htmlwidgets::saveWidget(fig, paste0(diroutput,"/Boxplots_",testname,"_",typescore[ii],".html"), selfcontained = F,libdir = "lib")
      
      # ggplot! 
        ds <- Rmisc::summarySE(dat2plot_long,measurevar="value",groupvars = "name")
   
      gfig <- 
        ggplot(dat2plot_long,aes(x=name,y=value))+
        geom_flat_violin(aes(fill = name),position = position_nudge(x = 0.3, y = 0), adjust = .8, trim = TRUE, alpha = .5, colour = "gray45")+
        geom_boxplot(aes(fill=name),color="black",outlier.shape = 8,outlier.size=2,outlier.fill = "black",outlier.alpha = 1,alpha=.2,width =.2)+
        geom_errorbar(data=ds, aes(x= name,ymin=value-ci,ymax=value+ci,color=name),lwd=1,width=.1)+
        geom_point(data=ds,aes(x=name,y=value,fill=name),shape=21,size =5)+
        labs(title = paste0(testname," (N = ",length(unique(dat2plot_long$Subj_ID)),")")) + 
        theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
              axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
              axis.text.x = element_text(size=12,color="black",angle=30,hjust = 1),
              axis.text.y = element_text(size=12,color="black"),
              axis.title.x = element_text(size=12,color="black"),
              axis.title.y = element_text(size=12,color="black"))
          
          
      if (length(vars2read) > 2) {
        ggsave(plot = gfig,filename = paste0(diroutput,"/Boxplots_",testname,"_",typescore[ii],".jpg"),height=250,width = 70*length(vars2read),dpi = 150,units="mm")
      } else if (length(vars2read)==1) {
        ggsave(plot = gfig,filename = paste0(diroutput,"/Boxplots_",testname,"_",typescore[ii],".jpg"),height=250,width = 160*length(vars2read),dpi = 150,units="mm")
      } else {
        ggsave(plot = gfig,filename = paste0(diroutput,"/Boxplots_",testname,"_",typescore[ii],".jpg"),height=250,width = 100*length(vars2read),dpi = 150,units="mm")
      }
        
      
      #add to list of figs
      counter <- counter + 1 
      print(counter)
      figs[[counter]] <- fig
      
  }
}



