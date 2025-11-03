

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


# Organize the datasets ---------------------------------------------------


# old
glimpse(old)
p1 <- old[2:79]
p2 <- old[245:267]
old <- bind_cols(p1,p2)
# AM
AM_full <- bind_rows(AM1000,AM2500,AM5000) # bind rows 
AM_full <- AM_full%>% select(ma_id, measurement_id,study_id,radius_m, # order the columns
                               pixel_first, stdDevfungi, varfungi,fungi) %>% 
                        rename(
                              fungi_firstpixel = pixel_first,
                              fungi_stdDev = stdDevfungi,
                              fungi_variance = varfungi,
                              fungi_type = fungi
                              )
AM_full_wide <- AM_full %>% # radius to wide format
  pivot_wider(
    names_from = c(radius_m, fungi_type),
    values_from = fungi_firstpixel:fungi_variance,
    names_glue = "{fungi_type}.{.value}.{radius_m}"
  )
# EcM
EcM_full <- bind_rows(EcM1000,EcM2500,EcM5000) # bind rows 
EcM_full <- EcM_full%>% select(ma_id, measurement_id,study_id,radius_m, # order the columns
                             pixel_first, stdDevfungi, varfungi,fungi) %>% 
                      rename(
                        fungi_firstpixel = pixel_first,
                        fungi_stdDev = stdDevfungi,
                        fungi_variance = varfungi,
                        fungi_type = fungi
                      )
EcM_full_wide <- EcM_full %>% # radius to wide format
  pivot_wider(
    names_from = c(radius_m, fungi_type),
    values_from = fungi_firstpixel:fungi_variance,
    names_glue = "{fungi_type}.{.value}.{radius_m}"
  )

# merge AM and EcM
AM_EcM <- left_join(
  AM_full_wide,
  EcM_full_wide,
  by = c("ma_id", "study_id", "measurement_id")
)

# soil
soil_full <- bind_rows(soil1000,soil2500,soil5000) # bind rows 
soil_full <- soil_full%>% select(ma_id, measurement_id,study_id,radius_m, # order the columns
                  bdod_bdod_0.5cm_mean_firstpixel:clay_clay_60.100cm_mean_variance,
                  nitrogen_nitrogen_0.5cm_mean_firstpixel:soc_soc_60.100cm_mean_variance)
soil_full_wide <- soil_full %>% # radius to wide format
  pivot_wider(
    names_from = radius_m,
    values_from = c(bdod_bdod_0.5cm_mean_firstpixel:soc_soc_60.100cm_mean_variance),
    names_glue = "{.value}.{radius_m}")

# Join the Soil Texture  ---------------------------------------------

soiltexture <- read.csv("data/20251006_df_soiltype_unscaled.csv")
glimpse(soiltexture)
soiltexture <- soiltexture %>% 
  select(ma_id, measurement_id,study_id, SAND, SILT, CLAY, soiltype) %>% 
  rename(soiltexture.1000 = soiltype,
         sand.percent.1000 = SAND, 
         silt.percent.1000 = SILT,
         clay.percent.1000 = CLAY)


# Join the data -----------------------------------------------------------

df_20251103 <- 
  left_join(old, AM_EcM, join_by("ma_id", "study_id", "measurement_id"))

df_20251103 <- 
  left_join(df_20251103, soil_full_wide, join_by("ma_id", "study_id", "measurement_id"))

df_20251103 <- 
  left_join(df_20251103, soiltexture, join_by("ma_id", "study_id", "measurement_id"))

# Check
glimpse(df_20251103)

# Write
write.csv(df_20251103, "C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\20251103_data.csv",
          row.names = FALSE)
# Write to Git 
write.csv(df_20251103, ".\\data\\20251103_data.csv",
          row.names = FALSE)


