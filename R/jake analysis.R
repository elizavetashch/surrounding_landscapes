# 210824
# I am running this after running the Yield_dat_2024-08-20 script
# reading in the processed file

###
data <- read.csv('data/data_processed.csv', sep = ',', dec = '.') #1777 obs
colnames(data)

### add in some climate info

# Load necessary libraries
library(sf)  # for handling spatial data
library(dplyr)  # for data manipulation

# Step 1: Read the Köppen-Geiger ecoregions shapefile
if (file.exists("1976-2000_GIS.zip")==FALSE){
  download.file("http://koeppen-geiger.vu-wien.ac.at/data/1976-2000_GIS.zip","1976-2000_GIS.zip", mode="wb")
  unzip("1976-2000_GIS.zip")
} else {unzip("1976-2000_GIS.zip")}

ecoregions <- st_read(dsn=".",layer="1976-2000")
sf_use_s2(FALSE)
ecoregions$main_climate <- cut(ecoregions$GRIDCODE, breaks=c(10,20,30,40,60,70), labels=c("Tropical","Arid","Temperate","Cold (Continental)","Polar"))

# Step 2: Convert the latitude and longitude columns into a 'sf' object (spatial points)
# First, create the points using the longitude and latitude values.
points <- st_as_sf(data, coords = c("pr_Longitude", "pr_Latitude"), crs = st_crs(ecoregions))

# Step 3: Perform a spatial join to extract the Köppen-Geiger ecoregions
# This joins the points with the ecoregions based on spatial overlap.
data <- st_join(points, ecoregions, join = st_intersects)

# Step 4: Optional - Convert back to a regular dataframe (if needed)
# You can drop the geometry column to get back to a standard dataframe if the spatial attributes are no longer needed.
data <- st_drop_geometry(data)

# finish climate processing stuff
colnames(data)

# first remove some NA values
data <- data[!is.na(data$shannons_5000),] # lose 10 vals

# also remove greenhouse vegetables as a crop type
levels(factor(data$pr_Croptype))
data <- data[data$pr_Croptype!="Greenhouse_vegetable",]

# also remove the topsoil removal dataset - this wasn't a yield benefitting treatment
str(data$pr_Treatment)
levels(factor(data$pr_Treatment))
data <- droplevels(data[data$pr_Treatment!="Topsoil removal experiment",])

# look at lnrr vs shannon at 5000
with(data, plot(logrr.yi~shannons_5000,
                pch=16,
                col=rgb(0,0,0,0.1)))
abline(h=0)
with(data, abline(lm(logrr.yi~shannons_5000),col="blue",lwd=2))

# look at lnrr vs shannon at 2000
with(data, plot(logrr.yi~shannons_2000,
                pch=16,
                col=rgb(0,0,0,0.1)))
abline(h=0)
with(data, abline(lm(logrr.yi~shannons_2000),col="blue",lwd=2))

# look at lnrr vs shannon at 1000
with(data, plot(logrr.yi~shannons_1000,
                pch=16,
                col=rgb(0,0,0,0.1)))
abline(h=0)
with(data, abline(lm(logrr.yi~shannons_1000),col="blue",lwd=2))

# we can try now and run a first mixed model
library(lme4)
# nested random effects for primary source paper, and meta-analysis paper
# also random effects for country, croptype and treatment
#lme.1 <- lmer(logrr.yi~shannons_5000+(1|DatasetID/Source)+(1|Country)+(1|pr_Croptype)+(1|pr_Treatment),data)
lme.1 <- lmer(logrr.yi~shannons_5000+(1|Source)+(1|Country)+(1|main_climate)+(1|pr_Croptype)+(1|pr_Treatment),data)
summary(lme.1)

# test vs null model
lme.null <- lmer(logrr.yi~1+(1|Source)+(1|Country)+(1|pr_Treatment),data)
summary(lme.null)
AIC(lme.null) #-3592.374 with main_climate, -3594.252 without -> less than 1.878

anova(lme.1,lme.null)
# no difference in model fit from including shannons_5000

# what else might we want to look at as a random effect?
levels(factor(data$Country))

levels(factor(data$pr_Croptype))

# we have some inaccuracy in the latitude and longitude
# can we count then number of decimal places, and then weight according to that?

data$pr_Latitude
round(data$pr_Latitude,2)[997]
round(data$pr_Latitude,4)

# chatgpt function to count non-zero

count_nonzero_decimal_places <- function(x) {
  # Convert the number to a string with full precision
  x_str <- format(x, scientific = FALSE, trim = TRUE)
  
  # Split the string at the decimal point
  parts <- strsplit(x_str, "\\.")[[1]]
  
  # If there's a decimal point, process the decimal part
  if(length(parts) > 1) {
    decimal_part <- parts[2]
    
    # Remove trailing zeros
    decimal_part <- gsub("0+$", "", decimal_part)
    
    # Count the number of remaining digits
    return(nchar(decimal_part))
  } else {
    return(0)
  }
}

# these variables count the number of trailing zeros
# values with more trailing zeros are less accurate
# so I think we want to invert it, or similar
data$pr_Latitude_acc <- sapply(data$pr_Latitude,count_nonzero_decimal_places)
data$pr_Longitude_acc <- sapply(data$pr_Longitude,count_nonzero_decimal_places)
summary(data$pr_Longitude_acc)
# for now, drop the zero value
data <- subset(data,pr_Longitude_acc!=0)
badvals <- subset(data,pr_Longitude_acc==5)

# use inverse number of zeros as weighting in the mixed model - so this means we give a higher weighting
# to the value where we have 'more accurate' longitude coordinates
# but what value do we give
# 5 decimal places is to the nearest metre, 4 decimal is to the nearest 10 metre - this is basically equivalent
# 3 decimal places (2 trailing zeros) is to the nearest 100m so shouldn't be penalised either
# so we give 3 and 4 decimals (1 and 2 trailing zeros) the same weighting

data$pr_Longitude_acc[data$pr_Longitude_acc==2] <- "good"
# 2 decimal places (3 trailing zeros) is to the nearest 1km - give this 1/2 of 2 trailing zero group
# 1 decimal places (4 trailing zeros) is to the nearest 10km - give this 1/10 of 2 trailing zero group


lme.2 <- lmer(logrr.yi~shannons_5000+(1|DatasetID/Source)+(1|Country)+(1|pr_Croptype)+(1|pr_Treatment),
              weights=1/data$pr_Longitude_acc,data)
summary(lme.2)

# make new null model with these same weights
lme.2.null <- lmer(logrr.yi~1+(1|DatasetID/Source)+(1|Country)+(1|pr_Croptype)+(1|pr_Treatment),
              weights=1/data$pr_Longitude_acc,data)

# compare this to null model with LRT
anova(lme.2,lme.2.null)

