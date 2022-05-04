  Packages <- c("shiny","haven","ggplot2","GGally","cowplot","dplyr","ggExtra","raster")
  lapply(Packages, library, character.only = TRUE, invisible())
  
  #rm(list=ls(all=TRUE))#clear all
  #-------------------------------------------------------------------------------
  # REGRESSION PLOTS with Correlations
  #-------------------------------------------------------------------------------
  # read data
  alldat <- haven::read_sav('LEMO_cogni_fbl.sav')
  
   
  
  # correlation method 
  mymethod <- "pearson" 
  
  # filter 
  alldat <- alldat[which(alldat$Exclude_all==0),]
  # Pre-Select some data
  selected_predictor <- colnames(alldat)[grep('FBL*.*_t',colnames(alldat))]
  #selected_predicted <- vars[c(grep('Know*_T*',vars),grep('^SLRT*_T*',vars),grep('^HRT*_T*',vars),grep('^RAN*_T*',vars),grep('^HAWIK*_T*',vars))]
  selected_predicted <- colnames(alldat)[c(grep('*raw$',colnames(alldat)),grep('*_pr$',colnames(alldat)))]
  selected <- c(selected_predicted,selected_predictor)
  
   
  #                SHINY APP 
  
   
 
                # User inputs 
                pageWithSidebar(
                  headerPanel('Correlations ? la carte'),
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
                )
                
 