# PLOT computed frequency measures
#-------------------------------------------------------------------------------------------
# - read csv with z scores, SNR, specNorm etc 
# - gather and plot

library('dplyr')
library('data.table')
library('ggplot2')
library('plotly')
rm(list=ls(all=TRUE))
# Define input directories and go to input dir
dirinput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/b_computed_measures/groupGAs"
diroutput <- "N:/Users/gfraga/_Misc/CHRISTINA/FPVS_redo/c_gathered_frequencies/plots_groupGAs"
setwd(dirinput)


condition <- c("CSinFF","PWinFF","WinFF","FFinW","CSinW")
group <- c("all","typ","poor","gap","typ_2nd","poor_2nd","gap_2nd","typ_3rd","poor_3rd","gap_3rd","2nd","3rd")

c<-1

for (c in 1:length(condition)){
        currcond <- condition[c]
 
        for (g in 1:length(group)){
                currgroup <- group[g]
                # find files 
                files <- dir(path = dirinput,pattern = paste0(currcond,'.*.GA_',currgroup,'.csv'))
                
                figs <- list()
                for (f in 1:length(files)){  
                        print(f)
                        #read data and transform to long 
                        df <- as.data.frame(data.table::fread(files[f],sep = ",",header = TRUE)) # this should be much faster read of the dataset
                        df[,1] <- sapply(strsplit(df[,1],'_'),'[[',2)
                        colnames(df)[1] <- 'channel'
                        dflong<- tidyr::pivot_longer(df,cols = 2:dim(df)[2],names_to = 'bin')
                        
                        # retrieve some info
                        freqbins <- unique(dflong$bin)
                        
                        ######### PLOT ####################################################################
                        # plot settings
                        minfreq <-0.5
                        maxfreq <- 120
                        freqs2plot <- as.character(round(seq(minfreq,maxfreq,0.025),2))
                        # trimmed set 
                        d2plot <- dflong
                        d2plot <- d2plot[which(d2plot$bin %in% freqs2plot),]
                        
                        
                        # PLOTLY
                        fig <- plot_ly(d2plot, type = 'scatter', mode = 'lines',line=list(width=1)) 
                        
                        for (i in 1:length(df$channel)){
                                newd2plot <- d2plot[which(d2plot$channel==df$channel[i]),]   
                                fig <- add_trace(p=fig,data = newd2plot,x = ~bin, y=~value)  %>% layout(showlegend = T)
                                options(warn = -1)
                                
                        }
                        if(grepl('zscores*',files[f])){
                                fig <- add_segments(p = fig,y=2.58,yend=2.58,x=minfreq,xend=maxfreq,line = list(dash = "dash",color='firebrick'))
                        }
                        fig <- layout(p=fig,xaxis = list(rangeslider = list(visible=FALSE,thickness=0.05,bgcolor='lightgreen',yaxis=list(range=c(0,0.0001)))))
                        #fig <- layout(p=fig,title=files[f]) 
                        #print(fig)
                        figs[[f]] <- fig
                }
                
                
                #---- GGplot line plot with ribbon ----
                #d2plot$channel <- as.factor (d2plot$channel)
                #d2plot$bin <- as.numeric(d2plot$bin)
                
                #ggp <- ggplot(d2plot,aes(x=bin, y= value))+ 
                #    stat_summary(fun.data = mean_cl_boot,geom = "ribbon",linetype=0,fill='red',alpha = 0.3) + 
                #    stat_summary(fun = mean,geom = "line",size = .1,alpha=0.8,color='black') + theme_bw()
                #ggp <- ggplotly(ggp)
                #  
                
                # # Gather multiple plots in a page 
   
                if (length(files)==5){
                  fig1idx <-grep('specmeans*',files)
                  fig2idx <- grep('specNorm*',files)
                  fig3idx <- grep('zscores*',files)
                  fig4idx <- grep('snr*',files)
                  fig5idx <- grep('bcAmps*',files)
                        
                  plot2save1 <- subplot(figs[[fig1idx]],figs[[fig2idx]],nrows=2) %>%
                   layout(annotations = list( 
                     list( 
                       x = 0.07,  
                       y = 1.0,  
                       text = files[fig1idx],  
                       xref = "paper",  
                       yref = "paper",  
                       xanchor = "center",  
                       yanchor = "bottom",  
                       showarrow = FALSE 
                     ),  
                     list( 
                       x = 0.07,  
                       y = 0.46,  
                       text = files[fig2idx],  
                       xref = "paper",  
                       yref = "paper",  
                       xanchor = "center",  
                       yanchor = "bottom",  
                       showarrow = FALSE 
                     )))
                  htmlwidgets::saveWidget(plot2save1, 
                                          paste0(diroutput,"/Specs_",currcond,"_",currgroup,"_beta.html"), 
                                          selfcontained = F,libdir = "lib")
                  
                   plot2save2 <-  subplot(figs[[fig3idx]],figs[[fig4idx]],figs[[fig5idx]],nrows=3) %>%
                    layout(annotations = list( 
                      list( 
                        x = 0.07,  
                        y = 1.0,  
                        text = files[fig3idx],  
                        xref = "paper",  
                        yref = "paper",  
                        xanchor = "center",  
                        yanchor = "bottom",  
                        showarrow = FALSE 
                      ),  
                      list( 
                        x = 0.07,  
                        y = 0.66,  
                        text = files[fig4idx],  
                        xref = "paper",  
                        yref = "paper",  
                        xanchor = "center",  
                        yanchor = "bottom",  
                        showarrow = FALSE 
                      ),
                      list( 
                        x = 0.07,  
                        y = 0.3,  
                        text = files[fig5idx],  
                        xref = "paper",  
                        yref = "paper",  
                        xanchor = "center",  
                        yanchor = "bottom",  
                        showarrow = FALSE 
                      )))
                   
                   htmlwidgets::saveWidget(plot2save2, 
                                           paste0(diroutput,"/Measures_",currcond,"_",currgroup,"_beta.html"), 
                                           selfcontained = F,libdir = "lib")
                  }
                                     
  }
}
        
        
         