start <- 1
end <- 1000

par(mfrow=c(4,1))
plot(specNorm[start:end],type='l')
plot(zscores[start:end],type='l')
plot(bcAmps[start:end],type='l')
plot(snr[start:end],type='l')


plot(rnorm(end),type='l')

# Sequence of plots with some random values
for (t in 1:15){
    v <- rnorm(500)
    vz <- vector()
    vsnr <- vector()
    vbcamp <- vector()
    for (i in 1:200){
      neighbours <- v[(i+1):(i+21)]
      vz[i] <- (v[i]-mean(neighbours))/sd(neighbours)
      vsnr[i] <- v[i]/mean(neighbours)
      vbcamp[i] <- v[i] - mean(neighbours)
    }
    par(mfrow=c(3,1))
    plot(v[1:length(vsnr)],type='l')
    #plot(vz,type='l')
    plot(vsnr,type='l')
    plot(vbcamp,type='l')
    Sys.sleep(1.4)
    dev.off()
    rm(v)
}
