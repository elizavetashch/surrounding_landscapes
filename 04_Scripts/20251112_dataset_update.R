
# Author: Elizaveta Shcherbinina
# Last Update: 12. Nov 2025

# read
data <- read.csv("C:\\Users\\lisa7\\Documents\\20250810_surrounding_landscapes\\12_OldData\\20251111_data.csv")

# choose
colnames <-  colnames(data)
centre.cols <- grep("\\.centre\\.(2500|5000)$", names(data), value = TRUE)

# exclude 2500 and 5000
df <- data[,!colnames %in% centre.cols]

# rename
colnames(df) <- gsub("\\.centre\\.1000$", ".centre", colnames(df))

# save 
write.csv(df, ".\\03_Data\\20251112_data.csv",
          row.names = FALSE)