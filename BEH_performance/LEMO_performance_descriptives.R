rm(list=ls(all=TRUE))  #clears all! 
Packages <- c("nlme","emmeans","haven","ggplotify","dplyr","readxl") #Load libraries (you mast install packages before)
lapply(Packages, library, character.only = TRUE) 
source('N:/studies/Grapholemo/Methods/Scripts/grapholemo/BEH_performance/LEMO_Func_LMM_outliers.R') # read function
#--------------------------------------------------------------------------------------------------------------
#  TABLE WITH DESCRIPTIVES 
# - Read data in long format
# - Gather descriptives and save in table
#--------------------------------------------------------------------------------------------------------------

# Edit Paths
dirinput <- "O:/studies/grapholemo/analysis/LEMO_GFG/beh/" 
diroutput <-  "O:/studies/grapholemo/analysis/LEMO_GFG/beh/stats/LMM_R/" 
dir.create(diroutput)
# File to read
fileinput <- "LEMO_beh_fbl_long.sav" 

# READ DATA 
raw <- haven::read_sav(paste0(dirinput,'/',fileinput))
raw <- as.data.frame(raw)

#Prepare dataset for analysis 
dat <- raw # work on a copy, keep original dataset 
#Filter data (use dplyr::filteruse):
dat <- dplyr::filter(dat , (fb == 1) )
dat <- dplyr::filter(dat , (task == taskpart) )
dat <- dplyr::filter(dat , !is.na(third))


# Ensure format of your variables (as.factor or as.numeric)
dat$proportionPerThird <- as.numeric(dat$proportionPerThird  )
dat$meanRT <- as.numeric(dat$meanRT)
dat$subjID <- as.factor(dat$subjID)
dat$third    <- as.factor(dat$third)
dat$task   <- as.factor(dat$task)
dat$block   <- as.factor(dat$block)

######################################################
# CREATE TABLE WITH ACCU DATA 

totalds<- cbind('total',Rmisc::summarySE(dat,measurevar="proportionPerThird",groupvars = c("task")))
colnames(totalds)[1] <- 'third'

ds <-
Rmisc::summarySE(dat,measurevar="proportionPerThird",groupvars = c("third","task")) %>%
    rbind(.,totalds)  %>%
    group_by(.) %>%
    group_split(., task)


ds_gathered <-   cbind(c(rep('fbl_a',4),rep('fbl_b',4)),
                         rbind(ds[[1]][1],ds[[2]][1]),
                         rbind(round(cbind(ds[[1]][4],ds[[1]][5]),2),
                               round(cbind(ds[[2]][4],ds[[2]][5]),2)))

colnames(ds_gathered)[1] <- 'task'
ds_gathered$summary <- paste(ds_gathered[,3],ds_gathered[,4],sep=' (') %>% paste(.,')',sep="")          
writexl::write_xlsx(ds_gathered,paste0(diroutput,"/Table_accu_acrossBlocks.xlsx")) #save in file

# CREATE TABLE WITH RT 

totalds<- cbind('total',Rmisc::summarySE(dat,measurevar="meanRT",groupvars = c("task")))
colnames(totalds)[1] <- 'third'

ds <-
  Rmisc::summarySE(dat,measurevar="meanRT",groupvars = c("third","task")) %>%
  rbind(.,totalds)  %>%
  group_by(.) %>%
  group_split(., task)

ds_gathered <-   cbind(c(rep('fbl_a',4),rep('fbl_b',4)),
                       rbind(ds[[1]][1],ds[[2]][1]),
                       rbind(round(cbind(ds[[1]][4],ds[[1]][5]),2),
                             round(cbind(ds[[2]][4],ds[[2]][5]),2)))


colnames(ds_gathered)[1] <- 'task'
ds_gathered$summary <- paste(ds_gathered[,3],ds_gathered[,4],sep=' (') %>% paste(.,')',sep="")          

writexl::write_xlsx(ds_gathered,paste0(diroutput,"/Table_RTs_acrossBlocks.xlsx")) #save in file

