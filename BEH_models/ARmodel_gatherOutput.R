#.libPaths() #assign(".lib.loc", "C:/Program Files/R/R-3.6.1/library", envir = environment(.libPaths))
rm(list=ls(all=TRUE)) # remove all variables (!)
Packages <- c("readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr")
lapply(Packages, require, character.only = TRUE)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")
#---------------------------------------------------------------------------------------------------------------------------------
#    ____       _   _                             _               _      __                       ____  _     ____  ____  __  __  
#   / ___| __ _| |_| |__   ___ _ __    ___  _   _| |_ _ __  _   _| |_   / _|_ __ ___  _ __ ___   |  _ \| |   |  _ \|  _ \|  \/  | 
#  | |  _ / _` | __| '_ \ / _ | '__|  / _ \| | | | __| '_ \| | | | __| | |_| '__/ _ \| '_ ` _ \  | |_) | |   | | | | | | | |\/| | 
#  | |_| | (_| | |_| | | |  __| |    | (_) | |_| | |_| |_) | |_| | |_  |  _| | | (_) | | | | | | |  _ <| |___| |_| | |_| | |  | | 
#   \____|\__,_|\__|_| |_|\___|_|     \___/ \__,_|\__| .__/ \__,_|\__| |_| |_|  \___/|_| |_| |_| |_| \_|_____|____/|____/|_|  |_| 
#    |_|                                                                                                                                                             
#
#  - Write a table per subject with parameters per trial
#  - Write table with subject-level parameters
#  - Parameters can be mean centered (optional setting)
#
#=============================================================================================================================
# INPUTS
choiceModel <- 'rlddm_v12'

dirinput <- paste("O:/studies/allread/mri/analysis_GFG/stats/task/model/Preproc_19ss/output_",choiceModel,sep="")
dirPreprocessed <- "O:/studies/allread/mri/analysis_GFG/stats/task/model/Preproc_19ss"
diroutput <- dirinput

# Parameters of interest
list_param_bySubject <- c("a","a_mod","tau","v_mod") 
list_param_byTrial <- c("as_chosen","as_active","as_inactive","pe_tot_hat","pe_pos_hat","pe_neg_hat","v_hat")  #, "ev_hat"

# SETTINGS ???
meancenter=1
givemeplots = 1

# FUNCTION to mean center parameters (used later) 
center_colmeans <- function(x) {
  xcenter = colMeans(x)
  x - rep(xcenter, rep.int(nrow(x), ncol(x)))
}


# READ DATA
setwd(dirinput)
load(paste(dirPreprocessed,"/Preproc_data",sep="")) #read gathered data (that will be combined with model parameters later)
load(paste(dirPreprocessed,"/Preproc_list",sep="")) #read list with gather data input for model
fit <- readRDS(paste(dirinput,"/fit_rlddm.rds",sep="")) # read model output
fitX <- extract(fit) # extract values  in list
found_parameters <- unique(sapply(strsplit(names(fit),'[',fixed = TRUE),"[",1)) # list of unique parameters in the fit (lp_ = log posterior )

# retrive some info from the current model 
niterations <- fit@stan_args[[1]]$iter 
nburnin <- fit@stan_args[[1]]$warmup
nchains <- length(fit@stan_args)



#------------------------------------------------------------------------------------------------------
# Gather parameters
#------------------------------------------------------------------------------------------------------
# per subject 
subjs <- datTable[, .N, by = subjID][,1]
param_bySubject<- array("NA",dim=c(datList$N,length(list_param_bySubject)))
for (i in 1:length(list_param_bySubject)){
  for (ii in 1:datList$N){
    currpara<- paste0(list_param_bySubject[i],"[",ii,"]")
    param_bySubject[ii,i] <- round(rstan::summary(fit,pars=currpara)$summary[1],6)
  }
}
colnames(param_bySubject) <- list_param_bySubject
param_bySubject <- cbind(subjs, param_bySubject)
param_bySubject$subjID <- as.factor(param_bySubject$subjID)

#  per trial
param_byTrial<- array("NA",dim=c(datList$T,length(list_param_byTrial)))
for (i in 1:length(list_param_byTrial)){
    for (ii in 1:datList$T){  
      currpara<- paste0(list_param_byTrial[i],"[",ii,"]")
      #print(currpara)
      param_byTrial[ii,i] <- round( rstan::summary(fit,pars=currpara)$summary[1],6)
    }
}
colnames(param_byTrial) <- list_param_byTrial
datTable_pm <- cbind(datTable,param_byTrial)

# mean-center parameters
if (meancenter == 1){
    param2center <- c('pe_tot_hat','pe_pos_hat','pe_neg_hat','v_hat') 
    datTable_mc <- data.frame(matrix(ncol = length(param2center), nrow = dim(datTable)[1]))
    colnames(datTable_mc) <- paste("mc_",param2center, sep="")
    for(s in 1:datList$N){
      currsubj = as.character(subjs[s])
      #select data for this subject and transform to numeric
      dat2center <- as.matrix(datTable_pm[which(datTable_pm$subjID==currsubj),param2center,with=FALSE])
      dat2center <-  apply(dat2center,2,as.numeric)
      # SAVE mean centered data for this subject (use main table subjID to select rows)
      datTable_mc[which(datTable_pm$subjID==currsubj), ] <-  center_colmeans(dat2center)
    }
  }

gData <- cbind(datTable_pm,datTable_mc) # Gather per trial and their mean-centered transform into the main data table



#------------------------------------------------------------------------------------------------------
# Prepare data for plots (add some new indexes)
# ------------------------------------------------------------------------------------------------------
if (givemeplots ==1){
  # [Data preparations]
     # ocurrance index per stimuli type
    gData$trialPerStim <-0
    for (ss in 1:dim(subjs)[1]){ #subject loop
      tmpT <-gData[which(gData$subjID  %in%  subjs[ss])]
       for (tt in unique(tmpT$aStim)){   #trial type loop
         tmpT[which( tmpT$aStim== tt)]$trialPerStim <- seq.int(nrow(tmpT[which(tmpT$aStim== tt)]))
      }
      gData[which(gData$subjID  %in%  subjs[ss])] <-tmpT
    }
    
    # New trial index that resets at block 2 (needed for some plots )
    gData$newTrialIdx <- 0
    for (ss in 1:dim(subjs)[1]){
      subidx <- which(gData$subjID %in% subjs[ss]) 
      
      for (b in unique(gData[subidx,]$block)){ #block loop
        gData[which(gData$subjID %in% subjs[ss] & gData$block==b)]$newTrialIdx <- seq.int(nrow(gData[which(gData$subjID %in% subjs[ss] & gData$block==b)]))
      }
    }

    
#===============================================================================
# MODEL DIAGNOSTIC PLOTS for MCMC draws using Bayesplot 
#===============================================================================
    
pars2plot <-  c("mu_a", "mu_v_mod") 
# Diagnostics
#-----------------    
color_scheme_set("red")
#diagnostics <- stan_diag (fit)   
#rhat <- stan_rhat(fit) 
color_scheme_set("red")
rhatPlot <- mcmc_rhat(rhat=rhat(fit)) + theme(axis.title.y=element_blank())
neffRatio<- mcmc_neff(neff_ratio(fit)) +  theme(axis.text.x=element_text(angle=0))

#areas and density
#-----------------
color_scheme_set("red")
areas <- list()
for (i in 1:length(pars2plot)){
areas[[i]] <-     
    mcmc_areas( fit,  pars =pars2plot[i],
       prob = 0.8, # 80% intervals
      prob_outer = 0.99, # 99%
      point_est = "mean") +
      xlab("80% probability") + 
      theme(axis.text.y=element_text(angle=90))
    
}

color_scheme_set("purple")
#mcmc_dens(fit, pars4mcmc)
areas_byChain<- mcmc_dens_overlay(fit, pars2plot)+ theme_dark()

# Violins 
#-----------
color_scheme_set("teal")
violin<- mcmc_violin(fit, pars = pars2plot) + 
  theme_bw(12)

# histograms
#------------
color_scheme_set("red")
histo <- 
  mcmc_hist(fit, pars = pars2plot) +
  theme_bw(12)  +
  xlab("Histograms")

color_scheme_set("brightblue")
histo_byChain <- 
    mcmc_hist_by_chain(fit, pars = pars2plot) +
    theme_bw(12)  +
    ggtitle("Histogram by chain") 

# Traces
#------------
nutsPara <- nuts_params(fit)
color_scheme_set("viridisB")
traces <-  
  mcmc_trace(fit, pars = pars2plot,facet_args = list(ncol = 1, strip.position = "left"), window = c(0,500),np = nutsPara) +
     theme_dark() + 
     ggtitle("Traces")
    
  
#others 
#---------
#mcmc_intervals(fit, pars = pars4mcmc)
#mcmc_dens_overlay(fit, pars =pars4mcmc)
#mcmc_violin(fit, pars = pars4mcmc) 
#mcmc_trace_highlight(fit, pars = pars4mcmc, highlight = 4)
    
w1 <- 1/4
w2 <- .3
w3 <- .3
combo <- ggdraw() +
  draw_plot(histo, x = 0, y = .5, width = w1 , height = .5) +
  draw_plot(areas[[1]], x = w1, y = .5, width = w1/2 , height = .5) +
  draw_plot(areas[[2]], x = w1+(w1/2), y = .5, width = w1/2 , height = .5)  + 
  draw_plot(rhatPlot, x = 2*w1, y = .5, width = w1, height = .5) +
  draw_plot(neffRatio, x = 3*w1, y = .5, width = w1, height = .5) + 
  draw_plot(traces, x = 0, y = 0, width = 2*w1, height  = .5) + 
  draw_plot(areas_byChain, x = 2*w1, y = 0, width = w1*2, height  = .5) 

combo <-  annotate_figure(combo,text_grob(paste(fit@model_name," had ",nchains," chains of ",niterations, " iterations (",nburnin, " burn-in)"),color = "purple", face = "bold", size = 12)) #+ 


# Save 
   setwd(diroutput)
   outputname <- paste("Diagnostics_",choiceModel,".jpg",sep="")
   ggsave(outputname,combo,width = 350, height = 310, dpi=150, units = "mm")

}

 #------------------------------------------------------------------------------------------------------#
# PLOTS  AND SUMMARY TABLES #
 #------------------------------------------------------------------------------------------------------
   datTable$trialIdxPerStim <-0
   for (ss in unique(datTable$subjID)){
     tmpT <-datTable[which(datTable$subjID==ss)]
     for (tt in unique(datTable$aStim)){
       tmpT[which( tmpT$aStim== tt)]$trialIdxPerStim <- seq.int(nrow(tmpT[which(tmpT$aStim== tt)]))
     }
     datTable[which(datTable$subjID==ss)] <-tmpT
   }
   # New trial index that resets at block 2 (for some plots )
   datTable$newTrialIdx <- 0
   for (ss in unique(datTable$subjID)){
     subidx<-which(datTable$subjID==ss) 
     for (b in unique(datTable[subidx,]$block)){
       datTable[which(datTable$subjID==ss & datTable$block==b)]$newTrialIdx <- seq.int(nrow(datTable[which(datTable$subjID==ss & datTable$block==1)]))
     }
   }
   
   
    # PARAMETERS PER SUBJECT
   param2plot <- list_param_bySubject
   rainbow <-  c("orange","darkgreen","dodgerblue4")
   PLO <- list()
   for (i in 1:length(param2plot)){
     xdat <- as.factor(1)
     ydat <-as.numeric(pull(param_bySubject,param2plot[i]))
     
      PLO[[i]] <- ggplot(data=param_bySubject, aes(x=xdat,y=ydat)) +
              geom_flat_violin(position = position_nudge(x = 0.0, y = 0.02), adjust = .9, trim = FALSE, alpha = .7,colour=rainbow[i],fill=rainbow[i]) +
              geom_point(aes(x=as.numeric(xdat)-0.06),fill = rainbow[i], color="black",position=position_jitter(0.05,0,3), size = 2.5, alpha=.5,shape=21) +
             #scale_fill_manual(values = cols ) +
             #scale_colour_manual(values = cols ) +
             geom_boxplot(aes(x=as.numeric(xdat)-0.15),width = .03,size=.8, fill=rainbow[i],outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
             stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
             stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 3,color="black",fill="black",alpha = 1)+
             theme_bw(12)+ 
             labs(x="",y=param2plot[i])+
             theme(title = element_text(size=10),
                   axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                   axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                   axis.text.x = element_text(angle = 45,size=10,color="black"),
                   axis.text.y = element_text(size=0,color="black"),
                   axis.title.x = element_text(size=10,color="black"),
                   plot.caption = element_text(colour ="red"))
   }
   
   
   # SOME TRIAL-BASED ESTIMATES (association strength)
   reg2plot <- c("pe_pos_hat","pe_neg_hat","v_hat","as_chosen","as_active")
   rainbow2 <-  c("orange","darkgreen","dodgerblue4")
    
   
   TRIALPLO <- list()
   for (i in 1:length(reg2plot)){ 
     xdat <-  gData$trialPerStim
     ydat <-as.numeric(pull(gData,reg2plot[1]))
     
     TRIALPLO[[i]] <- 
       ggplot(data=gData, aes_string(x=xdat,y=ydat)) +
       geom_point(fill="black",alpha=.3,size=1.5) +
       #scale_fill_manual(values = cols ) +
       #scale_colour_manual(values = cols ) +
       #geom_boxplot(aes(x=as.numeric(xdat)-0.15),width = .03,size=.8, fill=rainbow[i],outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
       #stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
       #stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 3,color="black",fill="black",alpha = 1) +
       stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1,color="red",alpha = .8) +
       stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",size = 1,fill="red",alpha = .2) +
       stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 1,fill="red",color="black",alpha = 1) +
       facet_wrap(~aStim, nrow = 2)+
       #coord_flip()+ 
       theme_bw(12)+ 
       labs(x="repetition",y=reg2plot[i])+
       theme(title = element_text(size=10),
             axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
             axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
             axis.text.x = element_text(angle = 45,size=10,color="black"),
             axis.text.y = element_text(size=10,color="black"),
             axis.title.x = element_text(size=10,color="black"),
             plot.caption = element_text(colour ="red"))  #+ 
      # scale_x_continuous(breaks = seq(0,length(unique(T$trialIdxPerStim)),1))  # play with y axis ticks and range 
     
   }
#   
#   
#   
#   thing2plot <- "pe_pos"
#   PEPLO <-  ggplot(data=param_pertrial, aes_string(x="newTrialIdx",y=thing2plot)) +
#     geom_point(fill="black",alpha=.3,size=1.5 ) +
#     geom_hline(yintercept=0,color = "black",linetype="dashed", size=.1) +
#     #scale_fill_manual(values = cols ) +
#     #scale_colour_manual(values = cols ) +
#     #geom_boxplot(aes(x=as.numeric(xdat)-0.15),width = .03,size=.8, fill=rainbow[i],outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
#     #stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
#     #stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 3,color="black",fill="black",alpha = 1) +
#     stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1,color="red",alpha = .8) +
#     stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",size = 1,fill="red",alpha = .2) +
#     stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 1,fill="red",color="black",alpha = 1) +
#     #facet_wrap(~block, nrow = 2)+
#     #coord_flip()+ 
#     theme_bw(12)+ 
#     labs(x="trial",y=thing2plot)+
#     theme(title = element_text(size=10),
#           axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
#           axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
#           axis.text.x = element_text(angle = 45,size=10,color="black"),
#           axis.text.y = element_text(size=10,color="black"),
#           axis.title.x = element_text(size=10,color="black"),
#           plot.caption = element_text(colour ="red")) 
#   
#   
#   #####################
#   # COMBINE FIGURES   
#   combo <- 
#     ggdraw() +
#     draw_plot(traces, x = 0, y = .75, width = .5, height = .25) +
#     draw_plot(denso, x = .5, y = .75, width = .5, height = .25) +
#     draw_plot(PLO[[1]], x = 0, y = .5, height = .23,width  = .16) + 
#     draw_plot(PLO[[2]], x = .16, y = .5,height = .23, width = .16) + 
#     draw_plot(PLO[[3]], x = .32, y = .5, height = .23, width = .16) 
#    #draw_plot(TRIALPLO[[1]], x = .5, y = .37, width = .5, height = .37) +  
#    # draw_plot(TRIALPLO[[2]], x = .5, y = 0, width = .5, height = .37)
#   
#   combo <-
#     annotate_figure(combo,text_grob(paste("RLDDM Model overview ( N = ",dim(subjs)[1],")",sep=""),color = "blue", face = "bold", size = 12)) #+ 
#    # draw_plot_label(label = c("A", "B", "C"), col="black",size = 12, x = c(0, 0, 0), y = c(.98,.75,.5))
#   
#   
#   # Save 
#   setwd(diroutput)
#   outputname <- paste("PLOT_",dim(subjs)[1],"ss.jpg")
#   ggsave(outputname,combo,width = 350, height = 310, dpi=300, units = "mm")
#   
# }
   
   
   
   
   
   #===============================================================================
   # SAVE MODEL PARAMETERS per trial and subject
   #===============================================================================
   # write trial-by-trial parameters as file for each subject individually
   #   for(i in 1:datList$N){
   #     subj = as.character(subjs[i])
   #     write.table(param_pertrial[which(param_pertrial$subjID==subj),],paste0(diroutput,"/",subj,"_rlddm_parameters",".csv"),
   #                 quote=FALSE, sep=",", row.names=FALSE, col.names=TRUE)
   #   }
   #   cat("wrote trial-by-trial parameters\n")
   #   
   # #------------------------------------------------------------------------------------------------------
   # # SUBJECT PARAMETERS #
   # #------------------------------------------------------------------------------------------------------
   # 
   #   eta_pos <- rep("NA",datList$N)
   #   for (i in 1:datList$N){
   #     index <- paste0("eta_pos[",i,"]")
   #     eta_pos[i] <- rstan::summary(fit,pars=index)$summary[1]
   #   }
   #   eta_pos <- as.double(eta_pos)
   #   
   #   eta_neg <- rep("NA",datList$N)
   #   for (i in 1:datList$N){
   #     index <- paste0("eta_neg[",i,"]")
   #     eta_neg[i] <- rstan::summary(fit,pars=index)$summary[1]
   #   }
   #   eta_neg <- as.double(eta_neg)
   #   
   #   a <- rep("NA",datList$N)
   #   for (i in 1:datList$N){
   #     index <- paste0("a[",i,"]")
   #     a[i] <- rstan::summary(fit,pars=index)$summary[1]
   #   }
   #   a <- as.double(a)
   #   
   #   v_mod <- rep("NA",datList$N)
   #   for (i in 1:datList$N){
   #     index <- paste0("v_mod[",i,"]")
   #     v_mod[i] <- rstan::summary(fit,pars=index)$summary[1]
   #   }
   #   v_mod <- as.double(v_mod)
   #   
   #   tau <- rep("NA",datList$N)
   #   for (i in 1:datList$N){
   #     index <- paste0("tau[",i,"]")
   #     tau[i] <- rstan::summary(fit,pars=index)$summary[1]
   #   }
   #   tau <- as.double(tau)
   #   
   #   subject_parameters <- cbind(v_mod=as.array(v_mod),a=as.array(a),tau=as.array(tau),eta_pos=as.array(eta_pos),eta_neg=as.array(eta_neg))
   #   
   #   if(meancenter == 1){
   #     sp_matrix <- as.matrix(subject_parameters)
   #     sp_matrix_centered <- center_colmeans(sp_matrix)
   #     subject_parameters <- data.frame(sp_matrix_centered)
   #   }
   #   subject_parameters <- cbind(subjID=unique(param_pertrial$subjID),subject_parameters)
   #   
   #   # write out subject parameters
   #   write.table(subject_parameters, paste0(diroutput,"/rlddm_subject_parameters.csv"), sep=",", row.names=FALSE, col.names=TRUE,quote = FALSE) 
   #   cat("wrote subject parameters\n")
   #   cat("returning parameters\n")
   #   out <- list("tria-by-trial_parameters" = param_pertrial, "subject_parameters" = subject_parameters)
   # 
   #  
   #   
   #   
   # if (givemeplots == 1){
   #   
#   