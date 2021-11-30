rm(list=ls())
library(openxlsx)
###############################################################################################
#  COLOR CODE YOUR TABLE WITH COGNITIVE TESTS ! 

# - Read master file (sheet with cognitive tests)
# - Define a color for each test, assign them to columns
# - Saves colored sheet in new file (prevents ovewriting your master ) you can check and copy to your master 

###############################################################################################
# red master 
master <- read.xlsx("O:/studies/grapholemo/LEMO_Master.xlsx", sheet  = "Cognitive",detectDates = TRUE)

# define colors for each test 
tests <- c('rias','ran','wais','slrt','rst','lgvt','date','_exp')
colors <- RColorBrewer::brewer.pal(10,'Set3')

#  SAVE WITH STYLE  
wb <-createWorkbook()
addWorksheet(wb, "styled")
writeData(wb, 1, master, startRow = 1, startCol = 1)
for (c in 1:length(tests)) {
  hs1 <- createStyle(fgFill =colors[c], halign = "CENTER", border = "Bottom", fontColour = "black")  
  idx1 <- grep(paste0('^',tests[c],'*'), colnames(master))
  addStyle(wb, sheet = 1, hs1, rows = 1, cols = idx1, gridExpand = TRUE)
}

saveWorkbook(wb,"O:/studies/grapholemo/Table_styled.xlsx", overwrite = TRUE)

 

