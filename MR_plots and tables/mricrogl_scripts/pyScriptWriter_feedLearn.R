rm(list=ls())
library('readr')

tasks <- c("FBL_A","FBL_B")

for (t in 1:length(tasks))  {
        task <- tasks[t]
        dirinput <- 'N:/studies/Grapholemo/Methods/Scripts/grapholemo/MR_plots and tables/mricrogl_scripts/'
        resultsfile <- paste0('O:/studies/grapholemo/analysis/LEMO_GFG/mri/2ndLevel/FeedbackLearning/Result_regions_2Lv_GLM0_thirds_exMiss.xlsx')
        epifolder <- paste0('O:/studies/grapholemo/analysis/LEMO_GFG/mri/2ndLevel/FeedbackLearning/',task,'/2Lv_GLM0_thirds_exMiss/')
        
        
        
        epifiles <- dir(epifolder,pattern="spmT_0001.nii",recursive=TRUE)
        
        diroutput <- 'O:/studies/grapholemo/analysis/LEMO_GFG/mri/visualizations_mricrogl/fbl/'
        
        setwd(diroutput)
        
        
        # read table with results
        dat <- readxl::read_xlsx(path = resultsfile)
        dat <- dat[grep(task,dat$file),]
        #t_thresh <- 3.2 #comment if you want this based on Table 
        maxT <- 10 # comment if you want it based on Table
        t_thresh <- 3.2
        
        
        allscripts <- list()
        contrast <- unique(substr(dat$file,
                                  unlist(gregexpr('con_',dat$file[1])),
                                  unlist(gregexpr('con_',dat$file[1]))+7 )) # find pattern in file name ssuming the all en with *con_xxxxx_1.xlsx
        
        for (c in 1:length(contrast)){
          
          # read results table
          curdat <- dat[grep(contrast[c],dat$file),] 
          
          # read coords 
          xs <- paste0(curdat$xcoord,collapse=' ')
          ys<- paste0(curdat$ycoord,collapse=' ')
          zs<- paste0(curdat$zcoord,collapse=' ')  
          # some inputs
          smallerClust <- min(as.numeric(curdat$cluster_k))
          
          
          voxels <- 27*min(as.numeric(curdat$cluster_k))
          mrfilename <- paste0(epifolder,'/',epifiles[grep(contrast[c],epifiles)])
          
          if (!exists('t_thresh')){
            t_thresh <- as.numeric(unique(curdat$T_heightThresh)) #if not set manually use this 
          }
          if (!exists('maxT')){
            maxT <- max(as.numeric(dat$peak_T))# If not set manually use max value from table with all contrasts   
          }
          
          outputfilename <- paste0(task,'_',gsub(".xlsx",
                                 paste0('_',contrast[c],'.png'),
                                 basename(resultsfile)))
          
          ############ EDIT LINES 
          # 
          template <-character()
          
          template[1] <- paste0("# CHUNK FOR ",contrast[c])
          template[2] <- "#Load basics"
          template[3] <- "import gl"
          template[4] <- "gl.resetdefaults()"
          template[5] <- "gl.bmpzoom(1)"
          template[6] <- "gl.loadimage(\"spm152\")"
          template[7] <- "gl.backcolor(255,255,255)"
          
          
          template[8] <- "# Specify slides ,file to load and  formats"
          template[9] <- paste0("gl.mosaic(\" L S ", xs,"; C ", ys, "; A ",zs," \")") 
          
          template[10] <- paste0("gl.overlayload(\"",gsub('/','//',paste(epifolder,epifiles[grep(contrast[c],epifiles)],sep='/')),"\")")
          template[11] <- paste0("gl.minmax(1,0,", maxT,")") 
          template[12] <- paste0("gl.colorname(1, \"4hot\")") 
          template[13] <- paste0("gl.removesmallclusters(1, ",t_thresh, " ,",voxels,",2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))")  
          template[14] <- paste0("gl.opacity(1,85)")
          template[15] <- paste0("gl.colorbarposition(1)")
          
          
          template[16] <- paste0("gl.savebmp('",gsub('/','//',paste0(diroutput,'/',outputfilename)),"')")
          template[17] <- "####"
          
          
          ##################################################
          #Add  chunk a list for gathering
          allscripts[[c]] <- template
          rm(template)
        }
        
        #combine  and save 
        scriptname <- gsub('.xlsx','.py',paste0('N:/studies/Grapholemo/Methods/Scripts/grapholemo/MR_plots and tables/mricrogl_scripts/MRICRO_',task,'_',basename(resultsfile)))
        
        
        write_lines(unlist(allscripts),scriptname)
        
}