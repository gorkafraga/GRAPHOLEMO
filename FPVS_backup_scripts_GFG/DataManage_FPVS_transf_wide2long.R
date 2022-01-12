libraries <- c('dplyr','tidyr','plotly','ggplot2','Rmisc')
lapply(libraries, library, character.only = TRUE, invisible())
rm(list=ls(all=TRUE))
########################################################################################

# TRANSFORM TO LONG FORMAT, GATHER and PLOT

########################################################################################
# Define input directories and go to input dir
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats/"
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats/"
fileinput <- "FPVS_behNeuro.sav"

setwd(diroutput)
# read 
typelist <- c('snr','specNorm','bcAmps', 'zscores')
valuetype <- 'Oddharmsum_sep'



gatherset <- list()
for (t in 1:length(typelist)){
   type <- typelist[t]
   #select
    df <- as.data.frame( haven::read_sav(paste0(dirinput,'/',fileinput))) 
    df <- select(df, c('subject','group','grade','rias_nix_T1','prozentrang_nix_T1',names(df)[grep(paste0('^',type,'.*.',valuetype,'$'),colnames(df))]))
    
    # Filter 
    df <- dplyr::filter(df ,(group!= 'Gap' & group!='x')) 
    
    # turn to long format
    dflong <- pivot_longer(df, cols = grep(paste0('*',type,'.*.',valuetype),names(df)),names_to = c('type','hemisphere','cond'),names_sep = '_')
    dflong$group <-  as.factor(dflong$group)
    dflong$grade <- as.character(dflong$grade)
    dflong$hemisphere <-  as.character(dflong$hemisphere)
    dflong$cond < as.character(dflong$cond)
    
   
    # PLOT! ###########
    dflong2plot<- dflong[which(dflong$subject!='GA_T'),]
    pd <- position_dodge(0.75) 
    # compute descriptive statistics
    Ds <- summarySEwithin(dflong2plot ,measurevar='value', withinvars=c("hemisphere","cond","grade"),idvar = "subject",betweenvars = c('group'))
    
  
    fig <- ggplot(dflong2plot, aes(x = cond, y = value,fill=group)) + 
      geom_boxplot(size=.5,alpha=0.15,outlier.alpha = 1,lwd=2)+
      geom_point(data=Ds,aes(x= cond,y = value,fill=group),size=4,color="black",pch=21,alpha=1,position=pd) +
      geom_errorbar(data=Ds,aes(x= cond, ymin=value-ci, ymax=value+ci,color=group),width=.05, size= 1, position=pd) +
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
table2save$group<- as.character(table2save$group)

#######
#save data set 
haven::write_sav(table2save, paste0(diroutput,'/FPVS_gathered_long.sav'))



