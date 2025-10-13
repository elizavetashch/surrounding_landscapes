options(scipen = 999) # disable scientific notation


# read the data
df_unscaled <- read.csv("data/202509011_landindex_clim_poll_soil_fsize.csv", header = TRUE, sep = ",") # import 20250908_surroundland_landindex_SR_clim_soil_fsize
df_unscaled <- as.data.frame(lapply(df_unscaled, function(x) if(is.numeric(x)) round(x, 2) else x)) # Round everything to 2 decimals
str(df_unscaled)

library(dplyr)
library(tidyr)

# add the soil
df_unscaled_soiltype <- df_unscaled %>%
  mutate(
    total= (silt_15.30cm_mean.1000+sand_15.30cm_mean.1000+clay_15.30cm_mean.1000),
    SAND = (sand_15.30cm_mean.1000 / total)*100,
    SILT = (silt_15.30cm_mean.1000 / total)*100,
    CLAY = (clay_15.30cm_mean.1000 / total)*100
  ) %>%
  filter(!is.na(SAND), !is.na(SILT), !is.na(CLAY)) %>%
  mutate(X = row_number())

# which do have NA in soil textures 

dfsoiltype <- 
  df_unscaled_soiltype %>% 
  mutate( soiltype = soiltexture::TT.points.in.classes( 
    tri.data    = df_unscaled_soiltype[269:271], 
    class.sys   = "USDA.TT"
  ) )  

# Step 1: Convert matrix column to a proper data frame
dfsoiltype <- as.data.frame(dfsoiltype$soiltype)

# Step 2: Add row identifiers (optional but useful)
dfsoiltype <- dfsoiltype %>%
  mutate(X = row_number())

soiltype_long <- dfsoiltype %>%
  pivot_longer(
    cols = -X,
    names_to = "soiltype",
    values_to = "value"
  ) %>%
  filter(value == 1) %>%
  select(X, soiltype)

df_long <- df_unscaled_soiltype %>%
  full_join(soiltype_long, by = join_by(X == X)) %>% 
  select(-X)

df_na <- df_unscaled %>%
  mutate(
    total= (silt_15.30cm_mean.1000+sand_15.30cm_mean.1000+clay_15.30cm_mean.1000),
    SAND = (sand_15.30cm_mean.1000 / total)*100,
    SILT = (silt_15.30cm_mean.1000 / total)*100,
    CLAY = (clay_15.30cm_mean.1000 / total)*100,
    soiltype = NA
  ) %>%
  filter(is.na(SAND), is.na(SILT), is.na(CLAY))%>% 
  select(-X)

df_1384 <- bind_rows(df_long, df_na)

# change the latitude 
df_1384 <- df_1384 %>% 
  mutate(latitude_reversed = case_when(
    latitude_decimal < 0 ~ -latitude_decimal,
    TRUE ~ latitude_decimal
  ))

write.csv(df_1384, "data/20251006_df_soiltype_unscaled.csv", row.names = FALSE)

    
# Scale the new dataset 
df <- as.data.frame(lapply(df_1384, function(x) if(is.numeric(x)) round(x, 2) else x))
str(df)


exclude_vars <- c(
  "LRR", "LRR_vi", "ma_id", "measurement_id", "study_id", "control_id",
  "author_year", "study_pubyear", "harvest_year", "longitude_decimal",
  "latitude_decimal", "harvest_year_by_median", "poll_dependent"
)

df <- df %>%
  mutate(across(
    .cols = where(is.numeric) & !all_of(exclude_vars),
    .fns  = scale
  ))

write.csv(df, "data/20251006_df_soiltype_scaled.csv", row.names = FALSE)

#########
# SOIL TYPES: 
#########

# soiltype_results_clean$term <- factor(soiltype_results_clean$term,
#                                       levels = c("soiltypeClLo","soiltypeLo", "soiltypeLoSa",
#                                                  "soiltypeSa", "soiltypeSaCl", "soiltypeSaClLo",
#                                                  "soiltypeSaLo", "soiltypeSiCl", "soiltypeSiClLo",
#                                                  "soiltypeSiLo"),
#                                       labels = c("ClayLoam","Loam", "LoamySand",
#                                                  "Sand","SandyClay","SandyClayLoam",
#                                                  "SandyLoam", "SiltyClay", "SiltyClayLoam",
#                                                  "SiltyLoam"))