
library(dplyr)

###  Merge the GEE outputs
fieldsize_5000m <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_fieldsize_20250906\\20250906_fieldsize_5000m.csv", colClasses = "character")
fieldsize_2500m <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_fieldsize_20250906\\20250906_fieldsize_2500m.csv", colClasses = "character")
fieldsize_1000m <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_fieldsize_20250906\\20250906_fieldsize_1000m.csv", colClasses = "character")

summary(fieldsize_5000m)
fieldsize_5000m <- fieldsize_5000m[ , !(names(fieldsize_5000m) %in% c("system.index", "metrics", ".geo"))]
fieldsize_2500m <- fieldsize_2500m[ , !(names(fieldsize_2500m) %in% c("system.index", "metrics", ".geo"))]
fieldsize_1000m <- fieldsize_1000m[ , !(names(fieldsize_1000m) %in% c("system.index", "metrics", ".geo"))]


fieldsize_5000m$bufferradius_m = 5000
fieldsize_2500m$bufferradius_m = 2500
fieldsize_1000m$bufferradius_m = 1000

fieldsize_5000m$bufferarea_m2 = pi * fieldsize_5000m$bufferradius_m^2
fieldsize_2500m$bufferarea_m2 = pi * fieldsize_2500m$bufferradius_m^2
fieldsize_1000m$bufferarea_m2 = pi * fieldsize_1000m$bufferradius_m^2

fieldsize <- 
  bind_rows(fieldsize_5000m, fieldsize_2500m,fieldsize_1000m)

###  Rename the classes 
fieldsize <- 
fieldsize %>% 
  mutate( class_description = case_when(
    class == 0 ~ "skipped",
    class == 3502 ~ "greater than 100 ha",
    class == 3503 ~ "between 16 ha and 100 ha",
    class == 3504 ~ "between 2.56 ha and 16 ha",
    class == 3505 ~ "between 0.64 ha and 2.56 ha",
    class == 3506 ~ "less than 0.64 ha",
    class == 3507 ~ "no fields"
  ),
  class = case_when(
    class == 0 ~ NA,
    class == 3502 ~ "very large",
    class == 3503 ~ "large",
    class == 3504 ~ "medium",
    class == 3505 ~ "small",
    class == 3506 ~ "very small",
    class == 3507 ~ "no fields"
  ),
  class = as.factor(class))

fieldsize$area_m2 <- as.numeric(fieldsize$area_m2)
fieldsize$area_m2 <- format(fieldsize$area_m2, scientific = FALSE)

summary(fieldsize)

###  Exploration & Visualisation
unique <- fieldsize %>%
  distinct(measurement_id, .keep_all = TRUE) ## all points are there

fieldsize_nozero <- fieldsize[which(fieldsize$class != NA), ]

