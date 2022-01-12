# Function to compute frequency metrics in a single channel  ############################################################################

computeMeasures <- function(specmeans){         
     
    #function to get the surrounding bins. For a given bin take the bins located 10 bins before and after, skipping two surrounding bins
       getSurroundingBins <- function(specNorm,bin) {
            count <- 0
            surroundingData <<- vector()
            surroundings <- c(c((bin-2)-10):(bin-2),c(bin+2):((bin+2)+10))
            for (b in surroundings){ if (b < 1 || b > length(specNorm)) {} else { 
              surroundingData[count] <<- specNorm[b]
               count <- count + 1
            }} 
       }
       
       
      # Normalize spectrum ------------------------------------------------------------------------------------------------------  
       spec <- as.numeric(specmeans) 
       spec <<-spec
       specNorm <<- (spec/(srate*durSecs)) *10^5 # divide spectrum by the number of data points. Multiple for scaling
       
       #Calculate SNR ------------------------------------------------------------------------------------------------------  
       snr <- vector(mode="numeric", length=length(specNorm))
       for (bin in 1:length(specNorm)) {
         getSurroundingBins(specNorm,bin)
         snr[bin] <- specNorm[bin]/mean(surroundingData)
       }  
       snr <<- snr
       #rm(surroundingData)
       
       #Calculate BC data ------------------------------------------------------------------------------------------------------  
       bcAmps <- vector(mode="numeric", length=length(specNorm))
       for (bin in 1:length(specNorm)) {
         getSurroundingBins(specNorm,bin)
         bcAmps[bin] <- specNorm[bin]-mean(surroundingData)
       }  
       bcAmps <<- bcAmps
       # rm(surroundingData)
       
       #Calculate Zscores ------------------------------------------------------------------------------------------------------        
       zscores <- vector(mode="numeric", length=length(specNorm))
       for (bin in 1:length(specNorm)) {
         getSurroundingBins(specNorm,bin)
         zscores[bin] <- (specNorm[bin]-mean(surroundingData))/sd(surroundingData)
       }  
       zscores <<- zscores
       #rm(surroundingData)
       
} 