.libPaths()

#assign(".lib.loc", "C:/Program Files/R/R-3.5.2/library", envir = environment(.libPaths))

# after successful installation, load required packages
library("StanHeaders")
library("rstan")
options(mc.cores = 4)
library("Rcpp")
library("hBayesDM")
library("boot")
library("readr")
library("tidyr")
library("dplyr")
library("viridis")
library("bayesplot")
library("rstanarm")

##########################
# LOADING AND PREPARING  #
##########################

gather_data <- function(files){
  # summarize all data in 1 data frame
  datalist <- list()
  for (i in 1:length(files)){
    no_col <- max(count.fields(files[i], sep = "\t"))
    D <- read_delim(
      files[i],"\t", escape_double = FALSE, locale = locale(), trim_ws = TRUE)
    # change 1,12 for kids data!
    D <- cbind(rep(substr(files[i],1,12),dim(D)[1]),D)
    datalist[[i]] <- D
  }
  transformed <- data.table::rbindlist(datalist) # combine all data frames in on
  return(transformed)
}

## define paths
dirinput <- 'O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM/GoodPerf_42_PHtest'
data_path <- 'O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM/GoodPerf_42_PHtest'

block_correspondences <- read_csv(paste0(data_path,"/block_correspondences.csv"), col_names = TRUE)

### load data
setwd(paste0(data_path,"/copy_source_files"))
files <- dir(pattern=".txt", recursive=TRUE)
raw_data <- gather_data(files)

colnames(raw_data)[1] <- "subjID"
raw_data$rt <- raw_data$rt/1000
names(raw_data)[names(raw_data)=="rt"] <- "RT"

DT_trials <- raw_data[, .N, by = subjID]
subjs <- DT_trials$subjID
n_subj    <- length(subjs)

# reorder blocks with respect to presented order
for (subj in subjs){
  sub <- which(raw_data$subjID==subj)
  correspondence <- block_correspondences[which(block_correspondences$subj == subj),]
  raw_data[sub,]$block <- match(raw_data[sub,]$block,correspondence[2:4])
}

raw_data <- raw_data[
  with(raw_data, order(subjID,block,trial)),
  ]


# automatically filter missed responses (since RT = 0)
raw_data <- raw_data[which(raw_data$RT > 0.2),]
raw_data$trial <- as.integer(raw_data$trial)
#raw_data$trial_subj <- rep("NA",nrow(raw_data))
# since we discarded some observations, we have to assign new trial numbers 
for (subj in subjs){
  sub <- which(raw_data$subjID==subj)
  raw_data[sub,]$trial <- seq.int(nrow(raw_data[sub,]))
}

# add trials per block to data frame
iter <- vector()
DT_trials_per_block <- raw_data[, .N, by = list(subjID,block)]
for(i in 1:length(DT_trials_per_block$N)){
  iter <- append(iter,(seq.int(1,DT_trials_per_block[i,]$N)))
}
raw_data$iter <- iter

trials_block <- vector()
for(i in 1:length(DT_trials_per_block$N)){
  trials_block <- append(trials_block,(rep(DT_trials_per_block[i,]$N,DT_trials_per_block[i,]$N)))
}

# raw data: fb = 0 incorrect, fb = 1 correct, (fb = 2 missed)
# encoding for simulation: lower (incorrect) response=1, upper (correct) response =2 
raw_data$response = raw_data$fb+1

# raw_data$nonresponse = abs(raw_data$fb-2) # not used atm

raw_data$aStim <- as.double(raw_data$aStim)
# split vstim columns
raw_data <- raw_data %>% separate(vStims, c("vStim1", "vStim2"),sep="\\_")
raw_data$vStim1 <- as.double(raw_data$vStim1)
raw_data$vStim2 <- as.double(raw_data$vStim2)

# assign every stimulus pair for each block a unique number
raw_data[which(raw_data$block==2),]$aStim = raw_data[which(raw_data$block==2),]$aStim + 8
raw_data[which(raw_data$block==2),]$vStim1 = raw_data[which(raw_data$block==2),]$vStim1 + 8
raw_data[which(raw_data$block==2),]$vStim2 = raw_data[which(raw_data$block==2),]$vStim2 + 8

raw_data[which(raw_data$block==3),]$aStim = raw_data[which(raw_data$block==3),]$aStim + 16
raw_data[which(raw_data$block==3),]$vStim1 = raw_data[which(raw_data$block==3),]$vStim1 + 16
raw_data[which(raw_data$block==3),]$vStim2 = raw_data[which(raw_data$block==3),]$vStim2 + 16

raw_data$vStimNassoc <- ifelse(raw_data$aStim==raw_data$vStim1,raw_data$vStim2,raw_data$vStim1)

save(raw_data, file = paste0(data_path,"/raw_data_preprocessed.Rda"))

DT_trials <- raw_data[, .N, by = subjID]
trials_subj <- DT_trials[["N"]]


# get minRT
minRT <- with(raw_data, aggregate(RT, by = list(y = subjID), FUN = min)[["x"]])
ifelse(is.null(dim(minRT)),minRT<-as.array(minRT))

first <- which(raw_data$trial==1)
# if N=1 transform int to 1-d array
first<-as.array(first)
# last is a Sx1 matrix identifying all last trials of a subject for each choice
last <- (first + DT_trials$N - 1)
# if N=1 transform int to 1-d array
last<-as.array(last)
# define the values for the rewards: if upper resp, value = 1
value <- ifelse(raw_data$response==2, 1, 0)
n_trials <- nrow(raw_data)

#blocks <- tapply(raw_data$block,raw_data$subjID, max,simplify = TRUE)
blocks <- aggregate( raw_data$block ~ raw_data$subjID, FUN = max )
blocks <- blocks$`raw_data$block`
# if N=1 transform int to 1-d array
ifelse(is.null(dim(blocks)),blocks<-as.array(blocks))

stims_per_block <- 8
dat <- list("N" = n_subj, "T"=n_trials,"RTbound" = 0.1,"minRT" = minRT, "iter" = iter, "trials" = trials_block, "response" = raw_data$response, 
                   "stim_assoc" = raw_data$aStim, "stim_nassoc" = raw_data$vStimNassoc, "RT" = raw_data$RT, "first" = first, "last" = last, "value"=value, "n_stims"=stims_per_block*blocks)

save(dat, file = paste0(data_path,"/rlddm_input_paper.Rda"))
