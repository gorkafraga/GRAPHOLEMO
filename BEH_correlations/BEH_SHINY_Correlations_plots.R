  Packages <- c("shiny","ggplot2","GGally","cowplot","dplyr","ggExtra","raster")
  lapply(Packages, library, character.only = TRUE, invisible())
  
  rm(list=ls(all=TRUE))#clear all
  #-------------------------------------------------------------------------------
  # REGRESSION PLOTS with Correlations
  #-------------------------------------------------------------------------------
  # read data
  alldat <- haven::read_sav('O:/studies/grapholemo/analysis/LEMO_GFG/beh/LEMO_cogni_fbl.sav')
  diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/beh/stats_associations_modelcogni'
  setwd(diroutput)
   
  
  # correlation method 
  mymethod <- "pearson" 
  
  # filter 
  alldat <- alldat[which(alldat$Exclude_all==0),]
  # Pre-Select some data
  #selected_predictor <- colnames(alldat)[c(grep('FBL*.*_t1*',colnames(alldat)),grep('LEMO_RLDDM32*',colnames(alldat)))]
  selected_predictor <- colnames(alldat)[c(grep('FBL*.*_t1*',colnames(alldat)),grep('LEMO_rlddm_32*',colnames(alldat)))]
  #selected_predicted <- vars[c(grep('Know*_T*',vars),grep('^SLRT*_T*',vars),grep('^HRT*_T*',vars),grep('^RAN*_T*',vars),grep('^HAWIK*_T*',vars))]
  selected_predicted <- colnames(alldat)[c(grep('*raw$',colnames(alldat)),grep('*_pr$',colnames(alldat)))]
  selected <- c(selected_predicted,selected_predictor)
  
  #°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸
  
  #                SHINY APP 
  
  # °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸                
  
   correxplore <- function (alldat) {
    shinyApp(
                # User inputs 
                ui = pageWithSidebar(
                  headerPanel('Correlations à la carte'),
                  sidebarPanel(
                    checkboxInput("checkbox", label = "Show Boxplot (untick to find outliers)", value = TRUE,width = 500),
                    selectInput('exclude', 'Select subjects to exclude', alldat$Subj_ID,selected= c('gpl016','gpl018','gpl028','gpl033'),multiple = TRUE),
                    selectInput('ycol', 'Select dependent (y) variable', selected_predicted,selected = selected_predicted[[3]],multiple = FALSE),
                    selectInput('xcol', 'select predictor (x) variable ', selected_predictor,selected = selected_predictor[[3]],multiple = FALSE), 
                    selectInput('boxSize', 'box size', c(5:20),c(5:20)[5]),
                    selectInput('pointColor', 'choose point color',colors(),colors()[653]),
                    selectInput('lineColor', 'choose line and box color',colors(),colors()[which(colors() == "darkorchid4")]),
                    sliderInput(inputId = "opt.cex",label = "Point Size (cex)",min = 1, max = 10, step = 0.25, value = 8,25),
                    sliderInput(inputId = "opt.cexaxis",label = "Axis Text Size (cex.axis)",min = 10, max = 50, step = 1, value = 21) 
                    
                   ),
                  mainPanel(
                    #plotOutput('plot1',width = "100%", height = "800px")
                    plotOutput('plot1',width = "100%", height = "900px",click="plot_click"),
                    verbatimTextOutput("info")
                  ) 
                ),
                
    # Server using User inputs 
    server = function(input, output,session) {
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
       })
  }
  
 correxplore(alldat)
 #runApp(correxplore(alldat),launch.browser = getOption("C:/Program Files (x86)/Google/Chrome/Application/chrome.exe", interactive()))
   
