rm(list=ls())
library(openxlsx)
library(plotly)
library(ggplot2)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")

###############################################################################################
#  Summarize behavioral data with plots

###############################################################################################
# files and directories
#master <- read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Cognitive",detectDates = TRUE)
fileinput <- 'LEMO_cogni_fbl.sav'
dirinput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/beh/'
diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/beh/stats_cognitive/'
setwd(diroutput)

tests <- c('slrt','lgvt','rst','wais','ran','rias')
# first subject filter to the data 
urmaster <- haven::read_sav(paste0(dirinput,'/',fileinput))
urmaster <- urmaster[urmaster$Exclude_all==0,]


# Begin loop of plots per test
descriptives <- list()
counter <- 1
for (i in 1:length(tests)){
  master <- urmaster # reset data set for each test (outliers are excluded in each test)
  
  #Exclude outliers for this test 
  master <- urmaster[ urmaster[,grep(paste0('Exclude_',tests[i]),colnames(urmaster))] != 1,]
  
  # Assign the expected score type and pattern search for current test 
  if (tests[i]=='rias') {
    typescore <- c('raw','pr')
    testpattern <- 'rias'  
  
  } else if (tests[i]=='lgvt'){
    typescore <- c('tval','_pr')
    testpattern <- 'lgvt'
    
  } else if (tests[i]== 'ran' ) {
    typescore <- c('raw')
    testpattern <- 'ran.*.time.*'
    
  } else if (tests[i]== 'wais' ) {
    typescore <- c('raw')
    testpattern <- 'wais.*.tot*'
      
  } else if (tests[i]== 'slrt' ) {
    typescore <- c('raw','pr')
    testpattern <- 'slrt.*corr*'
    
  } else if (tests[i]== 'rst'){
    typescore <- c('raw','pr')
    testpattern <- 'rst_short1_wsum'
    
  }
  
  # Loop thru type of scores in each test 
  for (ii in 1:length(typescore)){
    
    idx1 <- grep(paste0('^',testpattern,'.*.',typescore[ii],'.*'), colnames(master))
    vars2read <- colnames(master)[idx1]
    if (grepl('slrt',testpattern)) {
      
      if (typescore[ii] =='pr'){
        vars2read <- vars2read[grep("*_pr",vars2read)]  
        print (vars2read)
      }
      
    }
    
    
    #prepare data
    dat2plot <- dplyr::select(master,all_of(c('Subj_ID','Sex',vars2read)))
    dat2plot_long <- tidyr::pivot_longer(dat2plot,all_of(vars2read))
    dat2plot_long <- dat2plot_long[which(!is.na(dat2plot_long$value)),]
    testname<- tests[i]
    #
    dat2plot_long$name <- as.factor(dat2plot_long$name)
    dat2plot_long$Sex <-as.factor(dat2plot_long$Sex)
        levels(dat2plot_long$Sex) <- c('female','male')
    
    
    # ggplot with Sex Facet 
    #---------------------------------------
    ds <-Rmisc::summarySE(dat2plot_long,measurevar="value",groupvars = c("Sex","name"))
     
    gfig <- 
      ggplot(dat2plot_long,aes(x=name,y=value))+
      geom_point(aes(x=name,y=value,fill= name),alpha=.3,shape=21)+
      geom_flat_violin(aes(fill = name),position = position_nudge(x = 0.2, y = 0), adjust = .8, trim = FALSE, alpha = .3, colour = "white")+
      geom_boxplot(aes(fill=name,color=name),outlier.shape = 8,outlier.size=1,notch = FALSE,outlier.fill = "black",outlier.alpha = 1,alpha=.2,width =.2,fatten=.5)+
      geom_errorbar(data=ds, aes(x= as.numeric(name)+.2,ymin=value-ci,ymax=value+ci,color=name),lwd=1,width=.1)+
      geom_point(data=ds,aes(x=as.numeric(name)+.2,y=value,fill=name),shape=21,size =4)+
      theme_bw() +
      labs(title = paste0(testname," (N = ",paste0(paste0(unique(ds$Sex),"(",unique(ds$N),")"),collapse=","),")")) + 
      theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(size=12,color="black",angle=30,hjust = 1),
            axis.text.y = element_text(size=12,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) +
     facet_grid(~Sex,scales="free")
    
    if (length(vars2read) > 2) {
      ggsave(plot = gfig,filename = paste0(diroutput,"/Boxplots_perGender_",testname,"_",typescore[ii],".jpg"),height=220,width = 70*length(vars2read),dpi = 150,units="mm")
    } else if (length(vars2read)==1) {
      ggsave(plot = gfig,filename = paste0(diroutput,"/Boxplots_perGender_",testname,"_",typescore[ii],".jpg"),height=220,width = 160*length(vars2read),dpi = 150,units="mm")
    } else {
      ggsave(plot = gfig,filename = paste0(diroutput,"/Boxplots_perGender_",testname,"_",typescore[ii],".jpg"),height=220,width = 100*length(vars2read),dpi = 150,units="mm")
    }
    
    print(paste0(tests[i],' plot saved'))
    
    
    # GGPlOTS without Sex facet 
    #-----------------------------------------------
    rm (gfig)
    rm(ds)
    
    ds <-Rmisc::summarySE(dat2plot_long,measurevar="value",groupvars = c("name")) 
   
     gfig <- 
      ggplot(dat2plot_long,aes(x=name,y=value))+
      geom_point(aes(x=name,y=value,fill= name),position = position_jitter(w = 0.1, h = 0),alpha=.3,shape=21)+
      geom_flat_violin(aes(fill = name),position = position_nudge(x = 0.2, y = 0), adjust = .8, trim = TRUE, alpha = .3, colour = "white")+
      geom_boxplot(aes(fill=name,color=name),outlier.shape = 8,outlier.size=1,notch = FALSE,outlier.fill = "black",outlier.alpha = 1,alpha=.2,width =.2,fatten=.5)+
      geom_errorbar(data=ds, aes(x= as.numeric(name)+.2,ymin=value-ci,ymax=value+ci,color=name),lwd=1,width=.1)+
      geom_point(data=ds,aes(x=as.numeric(name)+.2,y=value,fill=name),shape=21,size =4)+
      theme_bw() +
      labs(title = paste0(testname," (N = ",paste0(paste0(unique(ds$Sex),"(",unique(ds$N),")"),collapse=","),")")) + 
      theme(axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(size=12,color="black",angle=30,hjust = 1),
            axis.text.y = element_text(size=12,color="black"),
            axis.title.x = element_text(size=12,color="black"),
            axis.title.y = element_text(size=12,color="black")) 
     
    if (length(vars2read) > 2) {
      ggsave(plot = gfig,filename = paste0(diroutput,"/Boxplots_",testname,"_",typescore[ii],".jpg"),height=220,width = 70*length(vars2read),dpi = 150,units="mm")
    } else if (length(vars2read)==1) {
      ggsave(plot = gfig,filename = paste0(diroutput,"/Boxplots_",testname,"_",typescore[ii],".jpg"),height=220,width = 160*length(vars2read),dpi = 150,units="mm")
    } else {
      ggsave(plot = gfig,filename = paste0(diroutput,"/Boxplots_",testname,"_",typescore[ii],".jpg"),height=220,width = 100*length(vars2read),dpi = 150,units="mm")
    }
    
    print(paste0(tests[i],' plot saved'))
    counter <- counter + 1
    
    # plotly 
    #-----------------------------------------------
    fig <- plotly::plot_ly(dat2plot_long,x =~name,y =~value,type='box',color=~name,boxpoints="outliers")
    htmlwidgets::saveWidget(fig, paste0(diroutput,"/Boxplots_",testname,"_",typescore[ii],".html"), selfcontained = F,libdir = "lib")
     
    # save descriptives (not separated by sex)
    minmax <- aggregate(dat2plot_long$value,by=list(dat2plot_long$name),function(x) cbind(min(x), max(x)))[,2]
    
    descriptives[[counter]] <-  cbind(ds,minmax)
    
      }
}
# Save table with descriptives 
#----------------------------
tbl <- data.table::rbindlist(descriptives)
tbl$value <- round(tbl$value,2)
tbl$sd <- round(tbl$sd,2)
tbl$se <- round(tbl$se,2)
tbl$ci <- round(tbl$ci,2)
colnames(tbl)[7:8] <- c("min","max")
tbl$minmax <- paste0('[', round(tbl$min,2),'-',round(tbl$max,2),']')
tbl$meansd <- paste0(round(tbl$value,2),' (',round(tbl$sd,2),')')
#tbl$minmax<- paste0(round(tbl$value,2),' (',round(tbl$sd,2),')')
 
xlsx::write.xlsx(tbl,file = 'LEMO_cogni_descriptives.xlsx')
