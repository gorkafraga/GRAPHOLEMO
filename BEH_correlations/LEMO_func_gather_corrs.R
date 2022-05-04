# Run linear regression and correlations (pearson, spearman, also with log transforms)
#---------------------------------------------------------------------------------------------------------------------------------
# - In the linear regression first variable (Neuro) is input as predictor. Second var (behavioral) is input as predicted
# - input variables must be column names in the dataset (newD)
# - Saves r-squared and p values plot in a csv file
func_gather_corrs <- function(neuro,all_behave,newD){
  regs <- c()
  for (j in 1:length(neuro)){
    for (k in 1:length(all_behave)){
      #trim data
      neurovar <- neuro[j] #select variables for correlation
      behvar <- all_behave[k]
      data2use <- newD[,c(neurovar,behvar)]
      
      if (length(which(!is.na(data2use[,1])))==0)  { j <- j + 1 
      disp(j)
      }else {
        if (length(which(!is.na(data2use[,2])))==0) { k <- k + 1 
        } else {
          #regression for 1 group
          options(contrasts=c("contr.helmert","contr.poly"))
          fit <<-lm(as.formula(paste(behvar,"~",neurovar,sep="")),data=data2use,na.action = na.omit)
          regreVal <-  paste("R-squared = ",round(summary(fit)$r.squared,3),sep="")
          
          #Save info in table
          spearman_rho <- round(cor(data2use[,behvar],data2use[,neurovar],method='spearman',use="complete.obs"),2)
          spearman_p <- round(cor.test(data2use[,behvar],data2use[,neurovar],method='spearman',use="complete.obs",exact = FALSE)$p.value,3)
          
          pearson_r <- round(cor(data2use[,behvar],data2use[,neurovar],method='pearson',use="complete.obs"),2)
          pearson_p <- round(cor.test(data2use[,behvar],data2use[,neurovar],method='pearson',use="complete.obs")$p.value,3)
          
          spearmanCor_behavLogT <- round(cor(log10(data2use[,behvar]),data2use[,neurovar],method='spearman',use="complete.obs"),2)
          pearsonCor_behavLogT <- round(cor(log10(data2use[,behvar]),data2use[,neurovar],method='pearson',use="complete.obs"),2)
          pvalue <- round(as.data.frame(summary(fit)$coefficients)$P[2],3)
          
          regs <- rbind(regs,c(neurovar,behvar,round(summary(fit)$r.squared,3),pvalue,nobs(fit),spearman_rho,spearman_p,pearson_r,pearson_p,spearmanCor_behavLogT,pearsonCor_behavLogT))
          rm(spearman_rho)
          rm(spearman_p)
          rm(pearson_r)
          rm(pearson_p)
          
          
        }
      }}
    colnames(regs) <- c("predictor","predicted","R-squared","p-value","sample","spearman_rho","spearman_p","pearson_r","pearson_p","spearmanR_behavLogT","pearsonR_behavLogT")
  }
  return(as.data.frame(regs))
}

