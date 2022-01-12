libraries <- c('dplyr','tidyr','plotly','ggplot2','Rmisc')
lapply(libraries, library, character.only = TRUE, invisible())
rm(list=ls(all=TRUE))
########################################################################################

# TRANSFORM TO LONG FORMAT, GATHER and PLOT

########################################################################################
# Define input directories and go to input dir
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats_newGroups/"
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats_newGroups/"
fileinput <- "FPVS_Master_behNeuro_newGroups.sav"

setwd(diroutput)
# read 
typelist <- c('snr','specNorm','bcAmps', 'zscores')
valuetype <- 'Oddharmsum_sep'



gatherset <- list()
for (t in 1:length(typelist)){
   type <- typelist[t]
   #select
    df <- as.data.frame( haven::read_sav(paste0(dirinput,'/',fileinput))) 
    df <- select(df, c('subject','groupELFESLRTcomb','group1625_SLRTsep_OR','group1625_SLRTmean','group1625_ELFESLRTWsep_strict','group1625_ELFESLRTWPWsep_strict','group1030_SLRTmean', 'group1625_SLRTELFEmean','grade','rias_nix_T1','prozentrang_nix_T1',names(df)[grep(paste0('^',type,'.*.',valuetype,'$'),colnames(df))]))
    
    # Filter 
    # df <- dplyr::filter(df ,(groupELFESLRTcomb!= 'Gap' & groupELFESLRTcomb!='x')) 
    # df <- dplyr::filter(df ,(group1625_SLRTsep_OR!= 'Gap' & group1625_SLRTsep_OR!='x'))
    # df <- dplyr::filter(df ,(group1625_SLRTmean!= 'Gap' & group1625_SLRTmean!='x'))
    # df <- dplyr::filter(df ,(group1625_ELFESLRTWsep_strict!= 'Gap' & group1625_ELFESLRTWsep_strict!='x'))
    # df <- dplyr::filter(df ,(group1625_ELFESLRTWPWsep_strict!= 'Gap' & group1625_ELFESLRTWPWsep_strict!='x'))
    # df <- dplyr::filter(df ,(group1030_SLRTmean!= 'Gap' & group1030_SLRTmean!='x'))
    # df <- dplyr::filter(df ,(group1625_SLRTELFEmean!= 'Gap' & group1625_SLRTELFEmean!='x'))

    # turn to long format
    dflong <- pivot_longer(df, cols = grep(paste0('*',type,'.*.',valuetype),names(df)),names_to = c('type','hemisphere','cond'),names_sep = '_')
    dflong$groupELFESLRTcomb <- as.factor(dflong$groupELFESLRTcomb)
    dflong$group1625_SLRTsep_OR <- as.factor(dflong$group1625_SLRTsep_OR)
    dflong$group1625_SLRTmean <- as.factor(dflong$group1625_SLRTmean)
    dflong$group1625_ELFESLRTWsep_strict <- as.factor(dflong$group1625_ELFESLRTWsep_strict)
    dflong$group1625_ELFESLRTWPWsep_strict <- as.factor(dflong$group1625_ELFESLRTWPWsep_strict)
    dflong$group1030_SLRTmean <- as.factor(dflong$group1030_SLRTmean)
    dflong$group1625_SLRTELFEmean <- as.factor(dflong$group1625_SLRTELFEmean)
    dflong$grade <- as.character(dflong$grade)
    dflong$hemisphere <-  as.character(dflong$hemisphere)
    dflong$cond < as.character(dflong$cond)
    
   
    # PLOT! ###########
    dflong2plot<- dflong[which(dflong$subject!='GA_T'),]
    pd <- position_dodge(0.75) 
    # compute descriptive statistics
    Ds <- summarySEwithin(dflong2plot ,measurevar='value', withinvars=c("hemisphere","cond","grade"),idvar = "subject",betweenvars = c('groupELFESLRTcomb'))
    
  
    fig <- ggplot(dflong2plot, aes(x = cond, y = value,fill=groupELFESLRTcomb)) + 
      geom_boxplot(size=.5,alpha=0.15,outlier.alpha = 1,lwd=2)+
      geom_point(data=Ds,aes(x= cond,y = value,fill=groupELFESLRTcomb),size=4,color="black",pch=21,alpha=1,position=pd) +
      geom_errorbar(data=Ds,aes(x= cond, ymin=value-ci, ymax=value+ci,color=groupELFESLRTcomb),width=.05, size= 1, position=pd) +
      facet_grid(~hemisphere*grade)+ 
      labs(y=type ,title =paste0(type, ' of ',valuetype))+
      theme_bw()
    print(fig)
    # save 
    ggsave(paste0(diroutput,'/',type,'_',valuetype,'.jpg'),fig,height = 200, width= 350,dpi = 150,units = 'mm' )
    
    
    gatherset[[t]] <- dflong
    
}

table2save <- data.table::rbindlist(gatherset)
table2save <- as.data.frame(table2save)


#new var to specify base type
table2save$base <- ""
table2save$base[grep('inW',table2save$cond)] <- 'W'
table2save$base[grep('inFF',table2save$cond)] <- 'FF'
#rename some variables
table2save$subject<-as.character(table2save$subject)
table2save$groupELFESLRTcomb<- as.character(table2save$groupELFESLRTcomb)
table2save$group1625_SLRTsep_OR <- as.character(dflong$group1625_SLRTsep_OR)
table2save$group1625_SLRTmean <- as.character(dflong$group1625_SLRTmean)
table2save$group1625_ELFESLRTWsep_strict <- as.character(dflong$group1625_ELFESLRTWsep_strict)
table2save$group1625_ELFESLRTWPWsep_strict <- as.character(dflong$group1625_ELFESLRTWPWsep_strict)
table2save$group1030_SLRTmean <- as.character(dflong$group1030_SLRTmean)
table2save$group1625_SLRTELFEmean <- as.character(dflong$group1625_SLRTELFEmean)


#######
#save data set 
haven::write_sav(table2save, paste0(diroutput,'/FPVS_gathered_long_newGroups.sav'))



