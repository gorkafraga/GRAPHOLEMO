libraries <- c('dplyr','tidyr','plotly','ggplot2','Rmisc')
lapply(libraries, library, character.only = TRUE, invisible())
rm(list=ls(all=TRUE))
########################################################################################

# MERGE neural and behavioral sets and transform to long 

########################################################################################
# Define input directories and go to input dir
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/"
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/stats"
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
raw$group <- as.factor(raw$group)
raw$grade <-  as.factor(raw$grade) 


###### merge in wide format 
dfmerged <- merge(raw,df2,by = c('subject'),all.x = TRUE,all.y=TRUE,sort=TRUE)
dfmerged$subject <- as.character(dfmerged$subject)
dfmerged$group <- as.character(dfmerged$group)
haven::write_sav(dfmerged, paste0(diroutput,'/FPVS_behNeuro.sav'))

