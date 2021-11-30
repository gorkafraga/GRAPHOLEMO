
# ===========================================================================================================
Packages <- c("haven","gmodels", "ggplot2", "reshape2","readr","tibble","dplyr","purrr","shiny","shinycssloaders",
              "Rmisc","magrittr","tidyr","ggcorrplot","ggExtra","nlme")
lapply(Packages, library, character.only = TRUE, invisible())


# Ggplot2,  ggcorrplot and ggextra 

cols<-c("gray70","gray15","khaki2")


#  ways of reading data 
# read_delim(files[i],"\t", escape_double = FALSE, locale = locale(), trim_ws = TRUE, skip_empty_rows=TRUE) # if you have text file with some deliter
# dat <- read_sav(fileinput)
 readxl::read_xlsx()

 neuro2plot <- "nameofmyROIvariable"
 behave2plot <- "nameofmyBehavioralVariable"
 subjects2include <-  c('AR1001','AR1002')
 data2plot <- dat[which(dat$subjID %in% subjects2include),c(neuro2plot,behave2plot)]

 
# STATS run linear regression analysis 
 ################################################### 
 
 options(contrasts=c("contr.helmert","contr.poly"))
 modelfit <-lm(as.formula(paste(behave2plot,"~",neuro2plot,sep="")),data=data2plot,na.action = na.omit)# formula would readsomething like this: "SLRT_corr_pr~ROI_CAUDATE"
 
 rsquarevalue <- summary(modelfit)$r.squared
 regreVal <-  paste("R-squared = ",round(rsquarevalue,3),sep="")
 
 
 ###################################################
 #Plot with regression line and confidence intervals
plot1<-
  ggplot(data = data2plot, aes_string(x = data2plot$xvar, y = data2plot$yvar)) + # define axes of the plot  
  geom_point(alpha=.45,fill="black",size=3.2) +                                  # scatter plot (shape by group)
  geom_hline(yintercept=0,linetype="dashed",color="gray49")+                    # add horizontal line at 0 in y axis. 
  geom_smooth(method = "lm",fullrange=TRUE,alpha=.1,size=1,colour="red",fill="red") +  #this plots the regression line   (with CI? )
  theme_bw(15) +  # style and background
  theme(legend.position="bottom", legend.box = "horizontal")+  # style of legend and position 
 # scale_fill_manual(values = cols)+  # if you have groups or conditions you can define your color maps (cols was a variable with )
  #scale_colour_manual(values = cols)+
  labs(title=paste("Linear regression: ", regreVal,sep=""),subtitle = paste(nobs(fit)," observations",sep=""))     # add some title and subtitle and stuff
  #coord_cartesian(ylim=ylims,xlim=c(-10,5)) # I used this to fix some axis ranges across plots


# Combine with boxplots: adds boxplots in the margins  
margiPlot<- ggMarginal(plot1, type = 'boxplot', fatten=2,margins = 'both', size =15,alpha=.7, colour = 'tan3', fill = 'tan1')  
plot(margiPlot)