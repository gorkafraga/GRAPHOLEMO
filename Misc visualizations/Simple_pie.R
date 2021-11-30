# Simple Pie Chart
slices <- c(1, 1,1, 1,39)
mycolors <- c("indianred","indianred1","indianred2","indianred3","lightgreen")
lbls <- c("MR scanner failed", "Drop out", "Incidental finding", "MR safety exclusion", "Inclusion")
newlbls <- paste(lbls, " (", slices, ")", sep="")
#plot
pie(slices, labels = newlbls, main="MR participants", init.angle = 30, col =mycolors,
    cex=2)
