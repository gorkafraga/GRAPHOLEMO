LEMO_Func_LMM_outliers <- function(formula_fixed,formula_random,Data,resThreshold,givemeplots) {
    Packages <- c("nlme","emmeans","cowplot","ggplot2","sjPlot") #Load libraries (you must install packages before)
    lapply(Packages, library, character.only = TRUE)#
  
      
    # RUN MODEL FIT and repeats model if there are outliers... until no more outliers are found
    #---------------------------------------------------------------------------------------
    iter <- 0 
    modeldata <<- Data
    excludedRows <<- c()
    repeat{
      iter <- iter + 1
        fit  <<- nlme::lme( fixed = formula_fixed,
                      random = formula_random,
                      data = modeldata, 
                      na.action = na.omit,
                      method="REML") 
        
        # Gather residuals, find row index of outliers
        allresi <- unlist(residuals(fit,type="normalized",asList = TRUE))
        outliers <- as.numeric(sapply(strsplit(names(which(abs(allresi) > resThreshold)),".",fixed=TRUE),"[[",2))
        
        # If outliers exclude those rows from dataset.
        if (length(outliers)!=0){
          excludedRows <<- c(excludedRows,outliers) 
          modeldata <<- Data[-excludedRows,] 
          print(iter) 
        }
        
        # When there are no more outliers break the repeat loop 
        if (length(outliers)==0) {  
          print(paste0('Done at ',iter,' iteration'))
          break   
        } 
    }
    allresi <<-allresi
    # save the data rows that were excluded and summarize exclusion
    summaryOut <<- Data[excludedRows,] 
    excludedRows_id <<- as.character(paste0(rownames(plyr::match_df(dat2use, summaryOut)),collapse=','))
    excludedRows_n <<- length(excludedRows)
    excludedRows_percent <<- round((length(excludedRows)*100)/nrow(Data),2)
    excludedRows_table <<- as.data.frame(cbind(excludedRows_id,excludedRows_n,excludedRows_percent))
    plot(fit)
    
    ## Table of effects 
    options(contrasts = c(factor = "contr.helmert", ordered = "contr.poly"))
    Teffects <<- nlme::anova.lme(fit,type="marginal")
    Teffects <<- cbind(rownames(Teffects),Teffects)
    colnames(Teffects)[1] <- "Effect"
    
    print(Teffects)
    
    # title with model formula
    modeltitle <<- gsub(" ","",paste0("Fixed:(",c(eval(fit$call[[2]])),") Random:(",c(fit$call[[4]]),")"))
    
    # Plot of effects 
    if (givemeplots==1){
      plot_fit <<- as.grob(plot(fit,main=modeltitle))
    }
    
    # CONTRAST-----------------------------------------------------------------
    #options(contrasts = c(factor = "contr.helmert", ordered = "contr.poly"))
    fixfact <- strsplit(strsplit(as.character(formula_fixed),'~')[[3]],'\\*') # take the fixed factors part of the formula
    
    
    # ContrastS with all interactions
    formula_contrast <- as.formula(paste0('pairwise~ ',paste0(fixfact[[1]],collapse="*")))
    cons <- emmeans::emmeans(fit,formula_contrast,adjust="Tukey")
    #tables
    dfcons <<- data.frame(cons$contrasts)
    mymmeans <<- data.frame(cons$emmeans)
    #plots
    if (givemeplots==1){
      plot_contrastP <- as.grob(pwpp(cons$emmeans,comparisons=TRUE)+ theme_bw())
      plot_contrastMeans <- as.grob(plot(cons$emmeans,comparisons=TRUE,adjust='Tukey')+ theme_bw())
      title <- cowplot::ggdraw()+draw_label(paste0(as.character(formula_contrast),collapse=""))
      tmp <- cowplot::plot_grid(plot_contrastP,plot_contrastMeans,ncol=2)   
      combiplot <<- cowplot::plot_grid(title,tmp,ncol=1,rel_heights=c(0.1,1))
    }
    
    if (length(fixfact[[1]])>2){         
      # other combinations 
      combis <-  combn(unlist(fixfact),length(unlist(fixfact))-1, FUN=paste, collapse="|")
      combiplots <-list()
      additionalContrasts <<- list() 
      for (c in 1:length(combis)){
        formula_contrast <- as.formula(paste0('pairwise~ ',combis[c]))
        additionalContrasts[[c]] <<- emmeans(fit,formula_contrast,adjust="Tukey") 
        #plots
        if (givemeplots==1){
          plot_contrastP <- as.grob(pwpp(cons$emmeans,comparisons=TRUE)+ theme_bw())
          plot_contrastMeans <- as.grob(plot(cons$emmeans,comparisons=TRUE,adjust='Tukey')+ theme_bw())
          title <- cowplot::ggdraw()+draw_label(paste0(as.character(formula_contrast),collapse=" "))
          tmp <- cowplot::plot_grid(plot_contrastP,plot_contrastMeans,ncol=2)   
          tmp <-cowplot::plot_grid(title,tmp,ncol=1,rel_heights=c(0.1,1))
          
          combiplots[[c]] <-local ({
            print(tmp)
          })
          additionalContrasts<<-additionalContrasts
        }
      }
      if (givemeplots==1){
        combiplotsLong<<-do.call(gridExtra::grid.arrange,combiplots)
      }
    } else {
      print('no additional contrasts possible')
    }
}

