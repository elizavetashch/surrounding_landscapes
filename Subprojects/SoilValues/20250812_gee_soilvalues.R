

library(dplyr)
# Data read in ------------------------------------------------------------

df_1000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\20250812_soilvalues_1000m.csv")
df_2500 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\20250812_soilvalues_2500m.csv")
df_5000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\20250812_soilvalues_5000m.csv")

df_current <- read.csv("C:\\Users\\lisa7\\Documents\\20250810_surrounding_landscapes\\data\\20241216_data_processed.csv")

# Combine all data frames into one
df_1000$buffer_radius <- "1000"
df_2500$buffer_radius <- "2500"
df_5000$buffer_radius <- "5000"

df_full <- bind_rows(df_1000,df_2500,df_5000)
df_full$buffer_radius <- as.numeric(df_full$buffer_radius)
df_full$buffer_area <- pi * (df_full$buffer_radius ^ 2)
df_full$.geo <- NULL
df_full$system.index <- NULL

df_20250813 <- 
  left_join(df_current, df_full, join_by("ma_id"=="ma_id", "study_id"=="study_id", "measurement_id"=="measurement_id"))

summary(df_20250813)

write.csv(df_20250813, "C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\20250813_data.csv")
