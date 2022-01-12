# Harmonic Ranking based on Z scores
#-------------------------------------------------------------------------------------------
# - Read zscores based  on GA
# - Get data with electrodes as rows and gathered zscores for frequencies of interest
# - Ranking electrodes
library('dplyr')
library('data.table')
library('rlist')
library('ggplot2')
rm(list=ls(all=TRUE))

# Define input options
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats/lmm_GFG/exclDataOutliers/Base_FF"
diroutput <- dirinput

# find files with zscores
files <- dir(path = dirinput,pattern = '*.sav',recursive = TRUE )

# Go thru files
for (f in 1:length(files)){
  # read data   
  fileinput <- files[f]
  df <- haven::read_sav(paste0(dirinput,'/',files[f]))
  if (grep('exclDataOutliers',x = dirinput)){
     df <- df[which(df$Outliers_bcAmps_withinCond == 0 & df$Out_LMMCovaNix_bcAmps_FF_r3 ==0),]
  }else{
    df <- df[which(df$Out_LMMCovaNix_bcAmps_FF_r3 ==0),]
  }
  
   xvarname='hemisphere'
   yvarname='value'
   groupvarname = 'group'
   facetvarname1= 'cond'
   
  ## PLOT
    ggplot(df,aes_string(y=yvarname,x=xvarname))+ geom_point(aes_string(fill=groupvarname),shape=23)+
    facet_grid(facetvarname1)
  
    geom_hline(yintercept = 2.58,linetype='dashed',color='red')+
    theme_bw()+
    labs(y = 'z score',title =files[f])+
    scale_y_continuous(breaks=seq(round(min(dflong$score)),round(max(dflong$score)),1))+
    guides(fill=guide_legend(override.aes=list(shape=23)))
  
  
  ggsave(paste0(diroutput,'/',gsub('.csv','.jpg',basename(fileinput))),fig,width = 325, height = 150, dpi=150, units = "mm")    
}




