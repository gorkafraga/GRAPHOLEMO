# Patrick Haller, January 2020

library(Hmisc)
library(corrplot)
library(readr)
library(reshape2)
library(tidyr)

# helper function to center columns
center_colmeans <- function(x) {
  xcenter = colMeans(x)
  x - rep(xcenter, rep.int(nrow(x), ncol(x)))
}


dirinput <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
datainput <- paste0(dirinput, "/outputs/")
setwd(datainput)

load("performance_data.Rda")
parameters <- dir(pattern="rlddm_subject_parameters", recursive= FALSE)
slrt_wl <- dir(pattern="SLRT_WL*", recursive=FALSE)
slrt_pswl <- dir(pattern="SLRT_PSWL*", recursive=FALSE)
slrt_all <- dir(pattern="SLRT_all*", recursive=FALSE)

params_rlddm <- read_delim(
  parameters,",", escape_double = FALSE, locale = locale(), trim_ws = TRUE)

slrt_wl <- read_delim(
  slrt_wl,",", escape_double = FALSE, locale = locale(), trim_ws = TRUE)

slrt_pswl <- read_delim(
  slrt_pswl,",", escape_double = FALSE, locale = locale(), trim_ws = TRUE)

slrt_all <- read_delim(
  slrt_all,",", escape_double = FALSE, locale = locale(), trim_ws = TRUE)


###########################
##### ANALYZE SLRTS #######
###########################

# center performance data means
performance_data[,2:ncol(performance_data)] <- center_colmeans(performance_data[,2:ncol(performance_data)])

params_rlddm_pswl <- cbind(performance_data,params_rlddm,slrt_pswl)
params_rlddm_pswl_matrix <- as.matrix(params_rlddm_pswl[,2:ncol(params_rlddm_pswl)])

cor_rlddm_pswl <- rcorr(params_rlddm_pswl_matrix)
heatmap_rlddm_pswl <- cor_rlddm_pswl$r
colnames(heatmap_rlddm_pswl) <- c("acc","rt_avg","rt_neg","rt_pos","v_mod","db","nondt","lr_pos","lr_neg","pswr_corr","pswr_pr")
rownames(heatmap_rlddm_pswl) <- c("acc","rt_avg","rt_neg","rt_pos","v_mod","db","nondt","lr_pos","lr_neg","pswr_corr","pswr_pr")
p_mat_pswl <- cor_rlddm_pswl$P

col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(heatmap_rlddm_pswl, method = "color", col = col(200),  
         type = "upper", order = "hclust", 
         #addCoef.col = "black", # Add coefficient of correlation
         tl.col = "black", tl.srt = 60, #Text label color and rotation
         # Combine with significance level
         p.mat = p_mat_pswl,
         sig.level = c(.001, .01, .05), pch.cex =1 ,
         insig = "label_sig", pch.col = "white",
         # hide correlation coefficient on the principal diagonal
         diag = TRUE,
)



params_rlddm_wl <- cbind(performance_data[-c(8,14),],params_rlddm[-c(8,14),],slrt_wl)
params_rlddm_wl_matrix <- as.matrix(params_rlddm_wl[,2:ncol(params_rlddm_pswl)])


cor_rlddm_wl <- rcorr(params_rlddm_wl_matrix)
heatmap_rlddm_wl <- cor_rlddm_wl$r
colnames(heatmap_rlddm_wl) <- c("acc","rt_avg","rt_neg","rt_pos","v_mod","db","nondt","lr_pos","lr_neg","wr_corr","wr_pr")
rownames(heatmap_rlddm_wl) <- c("acc","rt_avg","rt_neg","rt_pos","v_mod","db","nondt","lr_pos","lr_neg","wr_corr","wr_pr")
p_mat_wl <- cor_rlddm_wl$P

col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(heatmap_rlddm_wl, method = "color", col = col(200),  
         type = "upper",
         #addCoef.col = "black", # Add coefficient of correlation
         tl.col = "black", tl.srt = 60, #Text label color and rotation
         # Combine with significance level
         p.mat = p_mat_wl,
         sig.level = c(.001, .01, .05), pch.cex =1 ,
         insig = "label_sig", pch.col = "white",
         # hide correlation coefficient on the principal diagonal
         diag = TRUE,
)