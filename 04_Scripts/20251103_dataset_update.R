

# Author: Elizaveta Shcherbinina 
# Last Update Date: 06.Nov.2025

# packages 
library(dplyr)
library(tidyr)
library(janitor)

# data

# original
old <- read.csv("12_OldData/202509011_landindex_clim_poll_soil_fsize.csv", header = TRUE, sep = ",") # import 20250908_surroundland_landindex_SR_clim_soil_fsize

# arbuscular
AM1000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_AM_3_1000m.csv", header = TRUE, sep = ",")
AM1000 <- AM1000[,2:8]
AM1000$radius_m <- 1000
AM1000$fungi <- "am"
glimpse(AM1000)

AM2500 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_AM_3_2500m.csv", header = TRUE, sep = ",")
AM2500 <- AM2500[,2:8]
AM2500$radius_m <- 2500
AM2500$fungi <- "am"
glimpse(AM2500)

AM5000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_AM_3_5000m.csv", header = TRUE, sep = ",")
AM5000 <- AM5000[,2:8]
AM5000$radius_m <- 5000
AM5000$fungi <- "am"
glimpse(AM5000)

# ectomycorrhiza
EcM1000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_EcM_3_1000m.csv", header = TRUE, sep = ",")
EcM1000 <- EcM1000[,2:8]
EcM1000$radius_m <- 1000
EcM1000$fungi <- "ecm"
glimpse(EcM1000)

EcM2500 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_EcM_3_2500m.csv", header = TRUE, sep = ",")
EcM2500 <- EcM2500[,2:8]
EcM2500$radius_m <- 2500
EcM2500$fungi <- "ecm"
glimpse(EcM2500)

EcM5000 <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_Mycorrhiza_20251103\\20250211_EcM_3_5000m.csv", header = TRUE, sep = ",")
EcM5000 <- EcM5000[,2:8]
EcM5000$radius_m <- 5000
EcM5000$fungi <- "ecm"
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
                               pixel_first,meanfungi, stdDevfungi, varfungi,fungi) %>% 
                        rename(
                              fungi_firstpixel = pixel_first,
                              richness.mean = meanfungi, 
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
                             pixel_first, meanfungi, stdDevfungi, varfungi,fungi) %>% 
                      rename(
                        fungi_firstpixel = pixel_first,
                        richness.mean = meanfungi, 
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

soiltexture.orig <- read.csv("12_OldData/20251006_df_soiltype_unscaled.csv")
soiltexture <- soiltexture.orig

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


# Sample column names
colnames(df_20251103) <- gsub("^([^_]+)_\\1_(\\d+\\.\\d+cm)_.*?(firstpixel\\.\\d+)$", "\\1_\\2_\\3", colnames(df_20251103))
colnames(df_20251103) <- gsub("^([^_]+)_\\1_(\\d+\\.\\d+cm)_.*?(stdDev\\.\\d+)$", "\\1_\\2_\\3", colnames(df_20251103))
colnames(df_20251103) <- gsub("^([^_]+)_\\1_(\\d+\\.\\d+cm)_.*?(variance\\.\\d+)$", "\\1_\\2_\\3", colnames(df_20251103))

colnames(df_20251103) <- sub("firstpixel", "centre", colnames(df_20251103))

colnames(df_20251103) <- gsub("_", ".", colnames(df_20251103))

colnames(df_20251103) <- gsub("bdod", "bulk", colnames(df_20251103))

colnames(df_20251103) <- gsub("sr", "speciesrich", colnames(df_20251103))

colnames(df_20251103) <- gsub("phh2o", "ph", colnames(df_20251103))

colnames(df_20251103) <- gsub("temperature", "temperature.orig", colnames(df_20251103))
colnames(df_20251103) <- gsub("precipitation", "precipitation.orig", colnames(df_20251103))


# Calculate additional variables 

# 1
df.15.30.orig <- df_20251103 %>%
  mutate(
    silt.15.30cm.centre.1000 = replace_na(silt.15.30cm.centre.1000, 0),
    sand.15.30cm.centre.1000 = replace_na(sand.15.30cm.centre.1000, 0),
    clay.15.30cm.centre.1000 = replace_na(clay.15.30cm.centre.1000, 0)
  ) %>%
  mutate(
    total = silt.15.30cm.centre.1000 + sand.15.30cm.centre.1000 + clay.15.30cm.centre.1000,
    SAND = (sand.15.30cm.centre.1000 / total) * 100,
    SILT = (silt.15.30cm.centre.1000 / total) * 100,
    CLAY = (clay.15.30cm.centre.1000 / total) * 100
  ) %>% 
  filter(
    !is.na(SAND),
    !is.na(SILT),
    !is.na(CLAY)
  )

# 2
df.15.30 <- df.15.30.orig %>% 
  select(SAND, SILT, CLAY, total)
# 3 
glimpse(df.15.30)

# 4 
df.15.30 <- 
  df.15.30 %>% 
  mutate( soiltexture = soiltexture::TT.points.in.classes( 
    tri.data    = df.15.30[1:3], 
    class.sys   = "USDA.TT"
  ) )  

# 5
df.15.30 <- as.data.frame(df.15.30$soiltexture)

# 6
df.15.30 <- df.15.30 %>%
  mutate(rownumber = row_number())

# 7
df.15.30.long <- df.15.30 %>%
  pivot_longer(
    cols = -rownumber,
    names_to = "soiltexture.centre",
    values_to = "value"
  ) %>%
  filter(value == 1) %>%
  select(rownumber, soiltexture.centre)

# 8
df_20251103 <- df_20251103 %>%  mutate(rownumber = row_number())

# 9
df_20251106 <- df_20251103 %>%
  full_join(df.15.30.long, by = join_by(rownumber == rownumber)) %>% 
  select(-rownumber)

# Count NAs in each column
sum(is.na(df_20251106$soiltexture.1000)) # 30
sum(is.na(df_20251106$soiltexture.centre)) # 264

glimpse(soiltexture)

# Final Cleaning 
colnames(df_20251106) <- tolower(colnames(df_20251106))

colnames(df_20251106) <- gsub("fungi", "richness", colnames(df_20251106))

colnames(df_20251106) <- sub("fieldsize", "fieldsize.centre", colnames(df_20251106))

colnames(df_20251106) <- sub("crop.type", "crop.type.orig", colnames(df_20251106))
colnames(df_20251106) <- sub("climate.zone", "climate.zone.orig", colnames(df_20251106))
colnames(df_20251106) <- sub("soil.type", "soil.type.orig", colnames(df_20251106))
colnames(df_20251106) <- sub("region", "region.orig", colnames(df_20251106))
colnames(df_20251106) <- sub("country", "country.orig", colnames(df_20251106))
colnames(df_20251106) <- sub("country.orig.new", "country.new", colnames(df_20251106))

glimpse(df_20251106)

# Final rearrangement 
df_20251106.2 <- df_20251106 %>% 
  select(
    measurement.id, ma.id, study.id, control.id, title, reference, 
    author.year, study.pubyear, harvest.year, publication.to.harvest.year.difference, harvest.year.by.median, landcover.map.year,
    lat.long, latitude.decimal,longitude.decimal, country.new, region.orig, country.orig,  
    treatment,
    crop.type.orig,crop.type.orig.grouped.small, crop.type.orig.grouped.big,
    yield.unit, mean.yield.control.kgha, mean.yield.treatment.kgha, yield.sd.control, yield.sd.treatment,
    replicates.control.summed, replicates.treatment.summed, n.aggregated,
    soil.type.orig, temperature.orig, precipitation.orig, climate.zone.orig,
    lrr, lrr.vi, 
    sr:poll.dependent, 
    nat.hab.1000:simpsonsevenness.5000,
    fieldsize.centre:medium.area.m.1000, 
    am.richness.centre.1000:ecm.richness.variance.5000,
    bulk.0.5cm.centre.1000:soiltexture.centre
  )

meta <- df_20251106.2 %>% select(measurement.id, ma.id, study.id, control.id, title, reference, 
                                 author.year, study.pubyear, harvest.year, publication.to.harvest.year.difference, harvest.year.by.median, landcover.map.year,
                                 lat.long, latitude.decimal,longitude.decimal, country.new, region.orig, country.orig,  
                                 treatment,
                                 crop.type.orig,crop.type.orig.grouped.small, crop.type.orig.grouped.big,
                                 yield.unit, mean.yield.control.kgha, mean.yield.treatment.kgha, yield.sd.control, yield.sd.treatment,
                                 replicates.control.summed, replicates.treatment.summed, n.aggregated,
                                 soil.type.orig, temperature.orig, precipitation.orig, climate.zone.orig,
                                 lrr, lrr.vi)
species <- df_20251106.2 %>% select(sr:poll.dependent)
nathab <- df_20251106.2 %>% select(nat.hab.1000:simpsonsevenness.5000)
fieldsize <- df_20251106.2 %>% select(fieldsize.centre:medium.area.m.1000)
mycorrhiza <- df_20251106.2 %>% select(am.richness.centre.1000:ecm.richness.variance.5000)
soil <- df_20251106.2 %>% select(bulk.0.5cm.centre.1000:soiltexture.centre)

# NA plots
png(".\\05_Results\\supporting_images\\meta_na.png", width = 800, height = 600)
vis_miss(meta)
dev.off()

png(".\\05_Results\\supporting_images\\species_na.png", width = 800, height = 600)
vis_miss(species)
dev.off()

png(".\\05_Results\\supporting_images\\nathab_na.png", width = 800, height = 600)
vis_miss(nathab)
dev.off()

png(".\\05_Results\\supporting_images\\fieldsize_na.png", width = 800, height = 600)
vis_miss(fieldsize)
dev.off()

png(".\\05_Results\\supporting_images\\mycorrhiza_na.png", width = 800, height = 600)
vis_miss(mycorrhiza)
dev.off()

png(".\\05_Results\\supporting_images\\soil_na.png", width = 800, height = 600)
vis_miss(soil)
dev.off()

# Structure of the dataset 
colnames(meta)
colnames(species)
colnames(nathab)
colnames(fieldsize)
colnames(mycorrhiza)
colnames(soil)

# Soil Texture Triangle ---------------------------------------------------

plot.centre <- df.15.30.orig %>% 
  select(SAND, SILT, CLAY, soc.15.30cm.centre.1000) %>% 
  as.data.frame()

####### plot soil texture centre ###############
png(".\\images\\solitexture_centre.png", width = 600, height = 600)
TT.plot(
  class.sys   = "USDA.TT",
  tri.data    = plot.centre,
  main        = "Soil texture data (from centre data)"
) 
dev.off()
##############################################
plot.mean <- soiltexture.orig %>%
  mutate(
    silt_15.30cm_mean.1000 = replace_na(silt_15.30cm_mean.1000, 0),
    sand_15.30cm_mean.1000 = replace_na(sand_15.30cm_mean.1000, 0),
    clay_15.30cm_mean.1000 = replace_na(clay_15.30cm_mean.1000, 0)
  ) %>%
  mutate(
    total = silt_15.30cm_mean.1000 + sand_15.30cm_mean.1000 + clay_15.30cm_mean.1000,
    SAND = (sand_15.30cm_mean.1000 / total) * 100,
    SILT = (silt_15.30cm_mean.1000 / total) * 100,
    CLAY = (clay_15.30cm_mean.1000 / total) * 100
  ) %>% 
  filter(
    !is.na(SAND),
    !is.na(SILT),
    !is.na(CLAY)
  )%>% 
  as.data.frame()

####### plot soil texture mean ###############
png(".\\images\\soiltexture_mean.png", width = 600, height = 600)
TT.plot(
  class.sys   = "USDA.TT",
  tri.data    = plot.mean,
  main        = "Soil texture data (from mean data)"
) 
dev.off()
##############################################

# Write
write.csv(df_20251106.2, "C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\20251106_data.csv",
          row.names = FALSE)
# Write to Git 
write.csv(df_20251106.2, ".\\03_Data\\20251107_data.csv",
          row.names = FALSE)

# Save column names from the first dataset
saved_names <- colnames(df_20251106.2)

# Apply them to another dataset
colnames(df_20251106) <- saved_names
glimpse(df_20251106)
# 2. df2 entsprechend umsortieren und umbenennen
df2 <- df2[, saved_names]  # rearrange columns
colnames(df2) <- saved_names  # rename columns (optional, falls nötig)