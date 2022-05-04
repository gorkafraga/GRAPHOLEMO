Packages <- c("shiny","ggplot2","GGally","cowplot","dplyr","ggExtra","raster")
lapply(Packages, library, character.only = TRUE, invisible())

 
    # Server using User inputs 
    server <- function(input, output,session) {
              # data selection  
              selectedData <- reactive({
                 `%nin%` = Negate(`%in%`)
                  dat <- alldat[which(alldat$Subj_ID %nin% input$exclude),]
                  na.omit(dat[, c('Subj_ID',input$xcol,input$ycol)])
                  
                  
            
                })
              observeEvent(input$go, {
                # 0 will be coerced to FALSE
                # 1+ will be coerced to TRUE
                v$doPlot <- input$go
              })
              # Plot 
              output$plot1 <- renderPlot({
                
                       cols<-c("gray70","gray15","khaki2")
                        #selectedData() %>% ggpairs(.,mapping = ggplot2::aes_string(fill=input$group),color="black",
                        options(contrasts=c("contr.helmert","contr.poly"))
                        fit<-lm(as.formula(paste(input$ycol,"~",input$xcol,sep="")),data=selectedData(),na.action = na.omit)
                        regreVal <-  paste("R-squared = ",round(summary(fit)$r.squared,3),sep="")
                        
                        plot0 <-      selectedData() %>%   ggplot(., aes_string(x = input$xcol,y = input$ycol)) +
                                            geom_point(fill=input$pointColor,shape=21,alpha=.7,size=input$opt.cex,stroke = 1.4) +
                                            geom_hline(yintercept=0,linetype="dashed",color="gray49")+
                                            geom_vline(xintercept=0,linetype="dashed",color="gray49")+
                                            geom_smooth(method = "lm",fullrange=TRUE,alpha=.1,size=1,colour=input$lineColor,fill=input$lineColor) + 
                                            theme_bw(15) +
                                            theme(legend.position="bottom", legend.box = "horizontal")+
                                            scale_fill_manual(values = cols)+
                                            scale_colour_manual(values = cols)+
                                            labs(title=paste("Linear regression (N =", nobs(fit),") ", regreVal,', p = ',round(as.data.frame(summary(fit)$coefficients)$P[2],3),sep=""),
                                                 subtitle = paste(input$xcol," AND ",input$ycol,sep=""))   +
                                            theme(title = element_text(size=input$opt.cexaxis+2),
                                                  axis.text.x = element_text(size=input$opt.cexaxis,color="black"),
                                                  axis.text.y = element_text(size=input$opt.cexaxis,color="black"),
                                                  axis.title.x = element_text(size=input$opt.cexaxis,color="black"))
                      
                     plot1 <- ggMarginal(plot0,type = 'boxplot', fatten=3,margins = 'both', size = as.numeric(input$boxSize),alpha=.5, colour = input$lineColor, fill = input$lineColor)  
                    
                         if (input$checkbox==TRUE) {
                           print(plot1)
                         } else {
                           plot(plot0) + coord_fixed(ratio = 1/5)
                         }
                    
                  }, height = 600, width=1000)
              
            
                  output$info <- renderPrint({
                          nearPoints(selectedData(), input$plot_click, threshold = 10, maxpoints = 10, addDist = TRUE)
                    
                })
    }
 
   
