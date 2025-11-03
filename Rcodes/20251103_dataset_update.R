

# Author: Elizaveta Shcherbinina 
# Last Update Date: 03.Nov.2025

# packages 
library(dplyr)
library(tidyr)

# data

# original
old <- read.csv("data/202509011_landindex_clim_poll_soil_fsize.csv", header = TRUE, sep = ",") # import 20250908_surroundland_landindex_SR_clim_soil_fsize

# arbuscular
AM1000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_AM_3_1000m.csv", header = TRUE, sep = ",")
AM1000 <- AM1000[,2:8]
AM1000$radius_m <- 1000
AM1000$fungi <- "AM"
glimpse(AM1000)

AM2500 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_AM_3_2500m.csv", header = TRUE, sep = ",")
AM2500 <- AM2500[,2:8]
AM2500$radius_m <- 2500
AM2500$fungi <- "AM"
glimpse(AM2500)

AM5000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_AM_3_5000m.csv", header = TRUE, sep = ",")
AM5000 <- AM5000[,2:8]
AM5000$radius_m <- 5000
AM5000$fungi <- "AM"
glimpse(AM5000)

# ectomycorrhiza
EcM1000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_EcM_3_1000m.csv", header = TRUE, sep = ",")
EcM1000 <- EcM1000[,2:8]
EcM1000$radius_m <- 1000
EcM1000$fungi <- "EcM"
glimpse(EcM1000)

EcM2500 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_EcM_3_2500m.csv", header = TRUE, sep = ",")
EcM2500 <- EcM2500[,2:8]
EcM2500$radius_m <- 2500
EcM2500$fungi <- "EcM"
glimpse(EcM2500)

EcM5000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_EcM_3_5000m.csv", header = TRUE, sep = ",")
EcM5000 <- EcM5000[,2:8]
EcM5000$radius_m <- 5000
EcM5000$fungi <- "EcM"
glimpse(EcM5000)

# soil

soil1000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_SoilGrids_20251103\\20251102_soilvalues_1000m.csv", header = TRUE, sep = ",")
soil1000$radius_m <- 1000

soil2500 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_SoilGrids_20251103\\20251102_soilvalues_2500m.csv", header = TRUE, sep = ",")
soil2500$radius_m <- 2500

soil5000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_SoilGrids_20251103\\20251102_soilvalues_5000m.csv", header = TRUE, sep = ",")
soil5000$radius_m <- 5000

# merging

# old
glimpse(old)
p1 <- old[2:79]
p2 <- old[245:267]

# soil
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


