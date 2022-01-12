# Patrick Haller, January 2020

library(readr, rstudioapi, data.table, dplyr, tidyr)

dirinput <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
datainput <- paste0(dirinput, "/data/raw_task_performance")
setwd(datainput)

files <- dir(pattern=".txt", recursive=TRUE)

gather_data <- function(files){
  # summarize all data in 1 data frame
  datalist <- list()
  for (i in 1:length(files)){
    no_col <- max(count.fields(files[i], sep = "\t"))
    D <- read_delim(
      files[i],"\t", escape_double = FALSE, locale = locale(), trim_ws = TRUE)
    # change 1,12 for kids data!
    D <- cbind(subjID = rep(basename(dirname(files[i])),dim(D)[1]),D)
    datalist[[i]] <- D
  }
  data <- data.table::rbindlist(datalist) # combine all data frames in on
  data$aStim = as.factor(data$aStim)
  data$resp = as.factor(data$resp)
  data$fb = as.factor(data$fb)
  data$subjID <- as.factor(data$subjID)
  
  # redefine fb for visualization
  data$fbprime <- rep("NA",nrow(data))
  data[which(data$fb==0),]$fbprime = -1
  data[which(data$fb==1),]$fbprime = 1
  data[which(data$fb==2),]$fbprime = 0
  
  return(data)
}

## load data
data <- gather_data(files)


### COMPUTE ACCURACY SCORE FOR ALL SUBJECTS ###
data_cumsum <- data %>% group_by(subjID,block) %>% mutate(csum = cumsum(fbprime))
data_cumsum <- data_cumsum[which(data_cumsum$trial==40),]

mean_learning_score = aggregate(data_cumsum$csum,
                     by = list(subjID = data_cumsum$subjID),
                     FUN = mean)

# map learning scores to a range [0, 1]
mean_learning_score$x = (mean_learning_score$x - (-40)) / 80
colnames(mean_learning_score) <- c("subjID","learning_score")
mean_learning_score$subjID <-  unique(raw_data$subjID)

### compute average RTs ###
data_nomiss <- data[which(data$resp!=0),]

mean_rts = aggregate(data_nomiss$rt,
                     by = list(subjID = data_nomiss$subjID),
                     FUN = mean)

mean_rts_split = aggregate(data_nomiss$rt,
                     by = list(subjID = data_nomiss$subjID, fb= data_nomiss$fb),
                     FUN = mean)

mean_rts_split <- spread(mean_rts_split, fb, x)
mean_rts <- merge(mean_rts, mean_rts_split)
colnames(mean_rts) <- c("subjID","average_rt","neg_rt","pos_rt")
mean_rts$subjID <-  unique(data$subjID)

# merge in 1 data frame
performance_data <- merge(mean_learning_score,mean_rts)

save(performance_data, file=paste0(dirinput, "/outputs/performance_data.Rda"))

     