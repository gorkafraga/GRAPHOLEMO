libraries <- c('dplyr','tidyr','plotly','ggplot2','Rmisc')
lapply(libraries, library, character.only = TRUE, invisible())
rm(list=ls(all=TRUE))
########################################################################################

# MERGE neural and behavioral sets and transform to long 

########################################################################################
# Define input directories and go to input dir
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/"
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats_newGroups"
fileinput <- "FPVS_beh.sav"
set2mergewith <- 'N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/f_clusters_gathered_frequencies/FPVS_gathered_freqs.csv'



setwd(diroutput)
# Read and prepare neural set with neural
df2 <- as.data.frame(data.table::fread(set2mergewith,sep=","))
df2 <- df2[order(df2$subject),]

# Read and prepare Behavioral data set 
raw <- haven::read_sav(paste0(dirinput,'/',fileinput))
raw <- as.data.frame(raw) # make sure it was read as d
# rename vars and create some dummy variables to merge with the long neural set
raw$subject <-as.factor(as.character(raw$subject))
raw$groupELFESLRTcomb <- as.factor(raw$groupELFESLRTcomb)
raw$group1625_SLRTsep_OR <- as.factor(raw$group1625_SLRTsep_OR)
raw$group1625_SLRTmean <- as.factor(raw$group1625_SLRTmean)
raw$group1625_ELFESLRTWsep_strict <- as.factor(raw$group1625_ELFESLRTWsep_strict)
raw$group1625_ELFESLRTWPWsep_strict <- as.factor(raw$group1625_ELFESLRTWPWsep_strict)
raw$group1030_SLRTmean <- as.factor(raw$group1030_SLRTmean)
raw$group1625_SLRTELFEmean <- as.factor(raw$group1625_SLRTELFEmean)
raw$grade <-  as.factor(raw$grade) 


###### merge in wide format 
dfmerged <- merge(raw,df2,by = c('subject'),all.x = TRUE,all.y=TRUE,sort=TRUE)
dfmerged$subject <- as.character(dfmerged$subject)
dfmerged$groupELFESLRTcomb <- as.character(dfmerged$groupELFESLRTcomb)
dfmerged$group1625_SLRTsep_OR <- as.character(dfmerged$group1625_SLRTsep_OR)
dfmerged$group1625_SLRTmean <- as.character(dfmerged$group1625_SLRTmean)
dfmerged$group1625_ELFESLRTWsep_strict <- as.character(dfmerged$group1625_ELFESLRTWsep_strict)
dfmerged$group1625_ELFESLRTWPWsep_strict <- as.character(dfmerged$group1625_ELFESLRTWPWsep_strict)
dfmerged$group1030_SLRTmean <- as.character(dfmerged$group1030_SLRTmean)
dfmerged$group1625_SLRTELFEmean <- as.character(dfmerged$group1625_SLRTELFEmean)
haven::write_sav(dfmerged, paste0(diroutput,'/FPVS_Master_behNeuro_newGroups.sav'))

