
# Original 20250813
# Modified 20250911

library(dplyr)
library(tidyr)

# Data read in 

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

# Organize the column order
d <- df_full %>% 
  select(-buffer_area)
d <- d %>% select(ma_id, measurement_id,study_id,buffer_radius,
                  bdod_bdod_0.5cm_mean_mean:clay_clay_60.100cm_mean_mean,
                  nitrogen_nitrogen_0.5cm_mean_mean:soc_soc_60.100cm_mean_mean)
# Check
glimpse(d)

# Pivot wider
d2 <- d %>% 
  pivot_wider(
  names_from = buffer_radius,
  values_from = c(bdod_bdod_0.5cm_mean_mean:soc_soc_60.100cm_mean_mean),
  names_glue = "{.value}.{buffer_radius}")

# Join
df_20250911 <- 
  left_join(df_current, d2, join_by("ma_id"=="ma_id", "study_id"=="study_id", "measurement_id"=="measurement_id"))

# Check
glimpse(df_20250911)

# Write
write.csv(df_20250911, "C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\20250911_soildata.csv",
          row.names = FALSE)
