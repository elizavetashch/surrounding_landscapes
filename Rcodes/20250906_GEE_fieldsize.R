
library(dplyr)
library(tidyr)

### What do the calsses mean 
# class == 0 ~ "skipped",
# class == 3502 ~ "greater than 100 ha",
# class == 3503 ~ "between 16 ha and 100 ha",
# class == 3504 ~ "between 2.56 ha and 16 ha",
# class == 3505 ~ "between 0.64 ha and 2.56 ha",
# class == 3506 ~ "less than 0.64 ha",
# class == 3507 ~ "no fields"

###  Merge the GEE outputs
fieldsize_5000m <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_fieldsize\\20250908_2_fieldsize_5000m.csv", colClasses = "character")
fieldsize_2500m <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_fieldsize\\20250908_2_fieldsize_2500m.csv", colClasses = "character")
fieldsize_1000m <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\GEE_fieldsize\\20250908_2_fieldsize_1000m.csv", colClasses = "character")

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

fieldsize_origin <- 
  bind_rows(fieldsize_5000m, fieldsize_2500m,fieldsize_1000m)

###  Rename the classes 
fieldsize <- 
  fieldsize_origin %>% 
  mutate( 
  class = case_when(
    class == 0 ~ "NAvalue",
    class == 3502 ~ "verylarge",
    class == 3503 ~ "large",
    class == 3504 ~ "medium",
    class == 3505 ~ "small",
    class == 3506 ~ "verysmall",
    class == 3507 ~ "nofields"
  ),
  class = as.factor(class),
  fieldsize = case_when(
    pixelvalue == 0 ~ "NAvalue",
    pixelvalue == 3502 ~ "verylarge",
    pixelvalue == 3503 ~ "large",
    pixelvalue == 3504 ~ "medium",
    pixelvalue == 3505 ~ "small",
    pixelvalue == 3506 ~ "verysmall",
    pixelvalue == 3507 ~ "nofields"
  ),
  fieldsize = as.factor(fieldsize)) %>% 
  select(-pixelvalue)

fieldsize$area_m2 <- as.numeric(fieldsize$area_m2)
fieldsize$study_id <- as.factor(fieldsize$study_id)
summary(fieldsize)

###  Organization

# check the sum of the area of the classes 
fieldsize_check <- 
fieldsize %>% 
  ungroup() %>%
  group_by(measurement_id, bufferarea_m2) %>% 
  mutate(sumarea = sum(area_m2),
         percentoverlap = sumarea/bufferarea_m2)

fieldsize_org <- 
  fieldsize %>% 
  ungroup() %>% 
  pivot_wider(names_from = class,
              values_from = area_m2) %>% 
  mutate(bufferradius_m = as.character(bufferradius_m)) %>% 
  select(-bufferarea_m2) %>%
  pivot_wider(names_from = bufferradius_m,
              values_from = c(NAvalue, small, verysmall, large, verylarge, medium))

# duplicates check
#d <- fieldsize_org$measurement_id[duplicated(fieldsize_org$measurement_id)]


### Merge with the original dataset 
data <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE/surrounding_landscapes_full_project/20250812_surrounding_landscapes/data/20250813_data.csv")
fieldsize_org$measurement_id <- as.numeric(fieldsize_org$measurement_id)
fieldsize_org$study_id <- as.numeric(fieldsize_org$study_id)

data_joined <- 
  left_join(data, fieldsize_org, 
            join_by("ma_id"=="ma_id", 
                    "measurement_id" == "measurement_id",
                    "study_id"=="study_id"))
data_joined <- data_joined[ ,-1]
write.csv(data_joined, "C:\\Users\\lisa7\\Documents\\UFZ_CLE/surrounding_landscapes_full_project/20250812_surrounding_landscapes/data/20250908_data.csv", row.names = FALSE )


### Analysis 

library(ggplot2)
ggplot(data_joined, aes(x = fieldsize, y = LRR)) +
  geom_boxplot(fill = "skyblue") +
  geom_jitter(width = 0.2, alpha = 0.6) + # show individual points
  theme_minimal() +
  labs(title = "LRR by Field Size",
       x = "Field Size",
       y = "LRR")

### Data Exploration 

counts <- table(data_joined$fieldsize)
barplot(counts,
        main = "Distribution of Field Size",
        xlab = "Field Size",
        ylab = "Count",
        col = "steelblue")
