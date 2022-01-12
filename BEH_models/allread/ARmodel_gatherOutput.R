rm(list=ls(all=TRUE)) # remove all 
Packages <- c("grid","gridExtra","readr","tidyr","dplyr","viridis","data.table","StanHeaders","rstan","hBayesDM","Rcpp","rstanarm","boot","loo","bayesplot","cowplot","ggpubr")
lapply(Packages, require, character.only = TRUE)
source("N:/Developmental_Neuroimaging/scripts/DevNeuro_Scripts/Misc_R/R-plots and stats/Geom_flat_violin.R")
#---------------------------------------------------------------------------------------------------------------------------------
#  GATHER MODEL PARAMETERS FROM FITS 

#  - Write a table per subject with parameters per trial
#  - Write table with subject-level parameters
#  - Parameters can be mean centered (optional setting)
#
#=============================================================================================================================
# INPUTS
model <- 'AR_rlddm_v12'

#dirinput <- paste0("O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM_fromLocal/GoodPerf_72/outputs/out_",model,"/")
dirinput <- paste0("G:/local_models/RLDDM_phtests/GoodPerf_72/Outputs_cmdstan/weak_out_",model,"/")
#dirPreprocessed <-"O:/studies/allread/mri/analysis_GFG/stats/task/modelling/RLDDM_fromLocal/GoodPerf_72/"
dirPreprocessed <-"G:/local_models/RLDDM_phtests/GoodPerf_72/"
diroutput <- paste0("G:/local_models/RLDDM_phtests/GoodPerf_72/Outputs_cmdstan/weak_out_",model)

# Parameters of interest

if (model=='AR_rlddm_v12' || model=='AR_rlddm_v22' || model=='AR_rlddm_v32'){
   list_param_bySubject <- c("a","tau","v_mod","eta_pos","eta_neg") 
   list_param_byTrial <- c("as_chosen","as_active","as_inactive","pe_tot_hat","pe_pos_hat","pe_neg_hat","v_hat")  #, "ev_hat"
   
} else if(model=='AR_rlddm_v11' || model=='AR_rlddm_v21' || model=='AR_rlddm_v31'){
   list_param_bySubject <- c("a","tau","v_mod","eta") 
   list_param_byTrial <- c("as_chosen","as_active","as_inactive","pe_tot_hat","pe_pos_hat","pe_neg_hat","v_hat")  #, "ev_hat"
} 

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
load(paste(dirPreprocessed,"/Preproc_data.rda",sep="")) #read gathered data (that will be combined with model parameters later)
load(paste(dirPreprocessed,"/Preproc_list.rda",sep="")) #read list with gather data input for model
fit <- readRDS(paste(dirinput,model,'.rds',sep="")) # read model output
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
      param_bySubject[ii,i] <- rstan::summary(fit,pars=currpara)$summary[1]
   }
}
colnames(param_bySubject) <- list_param_bySubject
param_bySubject <- cbind(subjs, param_bySubject)
param_bySubject$subjID <- as.factor(param_bySubject$subjID)

#  Expected values
ev_hat_values<- array("",c(datList$T,unique(datList$n_stims)))
for (i in 1:unique(max(datList$n_stims))){
   for (ii in 1:datList$T){  
      dim(datTable)[1]
      currpara<- paste0("ev_hat","[",ii,",",i,"]")
      #print(currpara)
      ev_hat_values[ii,i]  <-  rstan::summary(fit,pars=currpara)$summary[1]
   }
}
colnames(ev_hat_values) <- paste0("ev_hat_stim",1:unique(datList$n_stims))
datTable_ev <- cbind(ev_hat_values)

#  per trial
param_byTrial<- array("NA",dim=c(datList$T,length(list_param_byTrial)))
for (i in 1:length(list_param_byTrial)){
   for (ii in 1:datList$T){  
      currpara<- paste0(list_param_byTrial[i],"[",ii,"]")
      #print(currpara)
      param_byTrial[ii,i] <- rstan::summary(fit,pars=currpara)$summary[1]
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
      currsubj <-  as.character(subjs$subjID[s])
      # select data for this subject and transform to numeric
      dat2center <- as.matrix(datTable_pm[which(datTable_pm$subjID==currsubj),param2center,with=FALSE])
      dat2center <-  apply(dat2center,2,as.numeric)
      # SAVE mean centered data for this subject (use main table subjID to select rows)
      datTable_mc[which(datTable_pm$subjID==currsubj), ] <-  center_colmeans(dat2center)
   }
}

gData <- cbind(datTable_pm,datTable_mc,datTable_ev) # Gather per trial and their mean-centered transform into the main data table


###### save tables 
setwd(diroutput)
write.csv(gData,file="Parameters_perTrial.csv",row.names = FALSE)
write.csv(param_bySubject,file="Parameters_perSubject.csv",row.names = FALSE)




#------------------------------------------------------------------------------------------------------
# Prepare data for plots (add some new indexes)
# ------------------------------------------------------------------------------------------------------
if (givemeplots ==1){
   # [Data preparations]
   # ocurrance index per stimuli type
   gData$trialPerStim <-0
   for (ss in 1:dim(subjs)[1]){ #subject loop
      tmpT <-gData[which(gData$subjID  %in%  subjs$subjID[ss])]
      for (tt in unique(tmpT$aStim)){   #trial type loop
         tmpT$trialPerStim[which(tmpT$aStim== tt)] <- seq.int(nrow(tmpT[which(tmpT$aStim== tt)]))
      }
      gData$trialPerStim[which(gData$subjID  %in%  subjs$subjID[ss])] <- tmpT$trialPerStim
   }
   
   # New trial index that resets at block 2 (needed for some plots )
   gData$newTrialIdx <- 0
   for (ss in 1:dim(subjs)[1]){
      subidx <- which(gData$subjID %in% subjs$subjID[ss]) 
      
      for (b in unique(gData[subidx,]$block)){ #block loop
         gData$newTrialIdx[which(gData$subjID %in% subjs$subjID[ss] & gData$block==b)] <- seq.int(nrow(gData[which(gData$subjID %in% subjs$subjID[ss] & gData$block==b)]))
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
      mcmc_trace(fit, pars = pars2plot,facet_args = list(ncol = 1, strip.position = "left"), window = c(0,nburnin+niterations),np = nutsPara) +
      theme_dark() + 
      ggtitle(paste0("Traces"))
   
   
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
   
   combo <-  annotate_figure(combo,text_grob(paste(fit@model_name," had ",nchains," chains of ",niterations, " iterations ( " ,nburnin, " burn-in)"),color = "purple", face = "bold", size = 12)) #+ 
   
   
   # Save 
   setwd(diroutput)
   outputname <- paste("Diagnostics_",model,".jpg",sep="")
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
      datTable[which(datTable$subjID==ss & datTable$block==b)]$newTrialIdx <- seq.int(nrow(datTable[which(datTable$subjID==ss & datTable$block==b)]))
   }
}


# PARAMETERS PER SUBJECT
#----------------------------------------------------------------------------------------------------------
param2plot <- list_param_bySubject
#param_bySubject_long <- gather(param_bySubject,condition,value,list_param_bySubject,factor_key = TRUE)
#rainbow <-  c("orange","darkgreen","dodgerblue4","firebrick4")
rainbow <-  c("gold1","orange3","darkgreen","dodgerblue3","firebrick4")

PLO <- list()     
xdat <- as.factor(1)
for (j in 1:length(param2plot)){
   print(j)
   
   PLO[[j]] <- 
      PLO[[j]] <-  local ({
         ydat <-  as.numeric(unlist(select(param_bySubject,param2plot[j])))
         
         plo1 <- 
            ggplot(data=param_bySubject, aes(x=xdat,y=ydat)) +
            geom_flat_violin(stat='ydensity', adjust = .5, trim = FALSE, alpha = .7,colour=rainbow[j],fill=rainbow[j]) +
            geom_point(aes(x=as.numeric(xdat)-0.06),fill = rainbow[j], color="black",position=position_jitter(0.05,0,3), size = 2.5, alpha=.5,shape=21) +
            geom_boxplot(aes(x=as.numeric(xdat)-0.15),width = .03,size=.8, fill=rainbow[j],outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
            stat_summary(aes(x=as.numeric(xdat)+0.06,y=ydat),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1) +  
            stat_summary(aes(x=as.numeric(xdat)+0.06,y=ydat),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 3,color="black",fill="black",alpha = 1) +
            theme_bw(12) + 
            labs(x="",y=param2plot[j])+
            theme(title = element_text(size=14),
                  axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                  axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
                  axis.text.x = element_text(angle = 45,size=12,color="white"),
                  axis.text.y = element_text(size=10,color="black"),
                  plot.caption = element_text(colour ="red"))
         print(plo1)
      })
   
   #rm(ydat)
}

subjcombo <-do.call(grid.arrange,PLO)

#subjcombo <-   ggdraw() +
#draw_plot(PLO[[1]], x = 0, y = .5, width = 1/2 , height = .5) +
 #  draw_plot(PLO[[2]], x = 1/2 , y = .5, width = 1/2  , height = .5) +
 #  draw_plot(PLO[[3]], x =0 , y = 0, width = 1/2 , height = .5)  + 
 #  draw_plot(PLO[[4]], x =1/2, y = 0, width = 1/2 , height = .5) 

subjcombo <-  annotate_figure(subjcombo,text_grob(paste(fit@model_name," had ",nchains," chains of ",niterations, " iterations ( ",nburnin, " burn-in)"),color = "purple", face = "bold", size = 12)) #+ 
# Save 
setwd(diroutput)
outputname <- paste("SubjectParameters_",model,".jpg",sep="")
ggsave(outputname,subjcombo,width = 350, height = 310, dpi=150, units = "mm")


# SOME TRIAL-BASED ESTIMATES (association strength)
#----------------------------------------------------------------------------
#reg2plot <- c( "v_hat","as_chosen","as_active","as_inactive")
#reg2plot <- c( "as_chosen","as_active","as_inactive","v_hat")

reg2plot <- c( "mc_pe_pos_hat","mc_pe_neg_hat","mc_pe_tot_hat")
rainbow2 <-  c("orange","darkgreen","dodgerblue4")

TRIALPLO <- list()
for (i in 1:length(reg2plot)){ 
   xdat <- gData$trialPerStim
   
   TRIALPLO[[i]] <- local({
      
      trialplo1<- ggplot(data=gData, aes_string(x=xdat,y=as.numeric(pull(gData,reg2plot[i])))) +
         geom_point(fill="black",alpha=.3,size=1.5) +
         #scale_fill_manual(values = cols ) +
         #scale_colour_manual(values = cols ) +
         #geom_boxplot(aes(x=as.numeric(xdat)-0.15),width = .03,size=.8, fill=rainbow[i],outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
         #stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
         #stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 3,color="black",fill="black",alpha = 1) +
         stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1,color="red",alpha = .8) +
         stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",size = 1,fill="red",alpha = .2) +
         stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 1,fill="red",color="black",alpha = 1) +
         facet_wrap(~aStim, nrow = 1)+
         #coord_flip()+ 
         theme_bw(12)+ 
         labs(x="repetition",y=reg2plot[i])+
         theme(title = element_text(size=10),
               axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
               axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
               axis.text.x = element_text(angle = 45,size=10,color="black"),
               axis.text.y = element_text(size=10,color="black"),
               axis.title.x = element_text(size=10,color="white"),
               plot.caption = element_text(colour ="red"))  #+ 
      # scale_x_continuous(breaks = seq(0,length(unique(T$trialIdxPerStim)),1))  # play with y axis ticks and range 
      if (i ==length(reg2plot)){
         trialplo1 <-  trialplo1  + theme(axis.title.x=element_text(color="black"))
      }
      
      print(trialplo1)
   })
}

PEcombo <- 
   ggdraw() +
   draw_plot(TRIALPLO[[1]], x = 0, y = 0, width = 1 , height = 1/3) +
   draw_plot(TRIALPLO[[2]], x = 0 , y = 1/3, width = 1  , height = 1/3) +
   draw_plot(TRIALPLO[[3]], x =0, y = 2/3, width = 1 , height = 1/3)  
#draw_plot(TRIALPLO[[4]], x = 0, y = 3/4, width = 1 , height = 1/4) 

PEcombo <- annotate_figure(PEcombo,text_grob(paste(fit@model_name," had ",nchains," chains of ",niterations, " iterations ( ",nburnin, " burn-in)"),color = "purple", face = "bold", size = 12)) #+ 
# Save 
setwd(diroutput)
outputname <- paste("PredictionError_",model,".jpg",sep="")
ggsave(outputname,PEcombo,width = 350, height = 310, dpi=150, units = "mm")

#-------------------------------------------------------------------------------------------------------------------------------------------
#    
#-------------------------------------------------------------------------------------------------------------------------------------------
reg2plot <- c( "as_chosen","as_inactive","as_active")
rainbow2 <-  c("orange","darkgreen","dodgerblue4")
TRIALPLO <- list()
for (i in 1:length(reg2plot)){ 
   xdat <- gData$trialPerStim
   
   TRIALPLO[[i]] <- 
      ggplot(data=gData, aes_string(x=xdat,y=as.numeric(pull(gData,reg2plot[i])))) +
      geom_point(fill="black",alpha=.3,size=1.5) +
      #scale_fill_manual(values = cols ) +
      #scale_colour_manual(values = cols ) +
      #geom_boxplot(aes(x=as.numeric(xdat)-0.15),width = .03,size=.8, fill=rainbow[i],outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
      #stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
      #stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 3,color="black",fill="black",alpha = 1) +
      stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1,color="darkorange",alpha = .8) +
      stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",size = 1,fill="darkorange",alpha = .2) +
      stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 1,fill="darkorange",color="black",alpha = 1) +
      facet_wrap(~aStim, nrow = 1)+
      #coord_flip()+ 
      theme_bw(12)+ 
      labs(x="repetition",y=reg2plot[i])+
      theme(title = element_text(size=10),
            axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
            axis.text.x = element_text(angle = 45,size=10,color="black"),
            axis.text.y = element_text(size=10,color="black"),
            axis.title.x = element_text(size=10,color="white"),
            plot.caption = element_text(colour ="red"))  #+ 
   # scale_x_continuous(breaks = seq(0,length(unique(T$trialIdxPerStim)),1))  # play with y axis ticks and range 
   
   if (i == length(reg2plot)){
      TRIALPLO[[i]] <-  TRIALPLO[[i]] + theme(axis.title.x=element_text(color="black"))
   }
}
AScombo <- 
   ggdraw() +
   draw_plot(TRIALPLO[[1]], x = 0, y = 0, width = 1 , height = 1/3) +
   draw_plot(TRIALPLO[[2]], x = 0 , y = 1/3, width = 1  , height = 1/3) +
   draw_plot(TRIALPLO[[3]], x =0, y = 2/3, width = 1 , height = 1/3)  
#draw_plot(TRIALPLO[[4]], x = 0, y = 3/4, width = 1 , height = 1/4) 

AScombo <- annotate_figure(AScombo,text_grob(paste(fit@model_name," had ",nchains," chains of ",niterations, " iterations ( ",nburnin, " burn-in)"),color = "purple", face = "bold", size = 12)) #+ 
# Save 
setwd(diroutput)
outputname <- paste("AsocStrength_",model,".jpg",sep="")
ggsave(outputname,AScombo,width = 350, height = 310, dpi=150, units = "mm")
#   
#      
#   

#-------------------------------------------------------------------------------------------------------------------------------------------
#    
#-------------------------------------------------------------------------------------------------------------------------------------------
reg2plot <- c( "mc_v_hat")
# reg2plot <- c( "mc_v_hat")
rainbow2 <-  c("orange","darkgreen","dodgerblue4")

TRIALPLO <- list()
for (i in 1:length(reg2plot)){  
   TRIALPLO[[i]] <- 
      local({          ydat <- as.numeric(pull(gData,reg2plot[i]))
      if (length(which(is.na(ydat))) !=0) {
         ydat<- 666
      }   
      xdat <- gData$trialPerStim
      
      trialplo1<- ggplot(data=gData, aes(x=xdat,y=ydat)) +
         geom_point(fill="black",alpha=.3,size=1.5) +
         #scale_fill_manual(values = cols ) +
         #scale_colour_manual(values = cols ) +
         #geom_boxplot(aes(x=as.numeric(xdat)-0.15),width = .03,size=.8, fill=rainbow[i],outlier.size = .7, outlier.shape = 8,outlier.alpha = 1, alpha = 0.4) +
         #stat_summary(aes(x=as.numeric(xdat)+0.06),position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "errorbar",width=.02,size = 0.9,alpha = 1)+  
         #stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 3,color="black",fill="black",alpha = 1) +
         stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "line",size = 1,color="darkorange",alpha = .8) +
         stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "ribbon",size = 1,fill="darkorange",alpha = .2) +
         stat_summary(position=position_dodge(0.03),fun.data = mean_cl_boot,geom = "point",shape=21,size = 1,fill="darkorange",color="black",alpha = 1) +
         facet_wrap(~aStim, nrow = 1)+
         #coord_flip()+ 
         theme_bw(12)+ 
         labs(x="repetition",y=reg2plot[i])+
         theme(title = element_text(size=10),
               axis.line.y = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
               axis.line.x = element_line(color = gray.colors(10)[3], size = 1, linetype = "solid"),
               axis.text.x = element_text(angle = 45,size=10,color="black"),
               axis.text.y = element_text(size=10,color="black"),
               axis.title.x = element_text(size=10,color="white"),
               plot.caption = element_text(colour ="red"))  #+ 
      # scale_x_continuous(breaks = seq(0,length(unique(T$trialIdxPerStim)),1))  # play with y axis ticks and range 
      if (i == length(reg2plot)){
         
         trialplo1 <-  trialplo1  + theme(axis.title.x=element_text(color="black"))
      }
      print(trialplo1)
      #rm(ydat)
      
      })
}


trialCombo <- 
   ggdraw() +
   draw_plot(TRIALPLO[[1]], x = 0, y = 0, width = 1 , height = 1/3) 
#draw_plot(TRIALPLO[[2]], x = 0 , y = 1/3, width = 1  , height = 1/3)  
#draw_plot(TRIALPLO[[4]], x = 0, y = 3/4, width = 1 , height = 1/4) 

trialCombo <- annotate_figure(trialCombo,text_grob(paste(fit@model_name," had ",nchains," chains of ",niterations, " iterations ( ",nburnin, " burn-in)"),color = "purple", face = "bold", size = 12)) #+ 
# Save 
setwd(diroutput)
outputname <- paste("trialParam_",model,".jpg",sep="")
ggsave(outputname,trialCombo,width = 350, height = 310, dpi=150, units = "mm")
#   
#-------------------------------------------------------------------------------------------------------------------------------------------
#    
#-------------------------------------------------------------------------------------------------------------------------------------------
trialCombo <- 
   ggdraw() +
   draw_plot(TRIALPLO[[1]], x = 0, y = 0, width = 1 , height = 1/3) 
#draw_plot(TRIALPLO[[2]], x = 0 , y = 1/3, width = 1  , height = 1/3)  
#draw_plot(TRIALPLO[[4]], x = 0, y = 3/4, width = 1 , height = 1/4) 

trialCombo <- annotate_figure(trialCombo,text_grob(paste(fit@model_name," had ",nchains," chains of ",niterations, " iterations ( ",nburnin, " burn-in)"),color = "purple", face = "bold", size = 12)) #+ 
# Save 
setwd(diroutput)
outputname <- paste("trialParam_",model,".jpg",sep="")
ggsave(outputname,trialCombo,width = 350, height = 310, dpi=150, units = "mm")

#save script
scriptfile <- rstudioapi::getActiveDocumentContext()$path
scriptfilepattern <- gsub(":","",sub(":","",gsub("-","",sub(" ","",Sys.time()))))
file.copy(scriptfile,gsub('//','/',paste0(diroutput,paste0('/code_',scriptfilepattern,'_',gsub(".R$",".txt",basename(scriptfile))))))