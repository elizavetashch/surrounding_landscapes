# 210824
# I am running this after running the Yield_dat_2024-08-20 script
# reading in the processed file

###
data <- read.csv('data/data_processed.csv', sep = ',', dec = '.') #1739 obs
data <- read.csv('data/data_yield_24092024_v2.csv', sep = ',', dec = '.') # 233155 obs
colnames(data)

# some datasets included mean annual T and P
# we should now use latitude_decimal rather than pr_latitude and same for 

# dataset description from Elizaveta Shcherbinina:

# ma_id - original meta-analysis publication
# row_id - this should be unique for each row, but this is a processed dataset with multiple rows, because there are multiple land cover
# study_id - original publication
# comparison_id - experiment ID, same as 'shared control cluster ID'
# long and lat, as reported from original study

# control_replicates - sample size for controls. this is *within* the same lat and long values.
# treatment_replicates - as above
## same site, 
## we can't tell difference between within site spatial and/or temporal variation
## depends upon whether harvest year is reported

# crop_type_grouped_small - tiny groups of crops
# crop_type_grouped_big - 6 groupings of crops
# yield_SD_control - SD *within* the same lat and long, this could be variation in time *or* space within lat long (e.g. between smaller plots in same field)
# reference - citation 
# longitude_decimal - this is processed, including switching if latitude was bigger (90) than can exist etc 
# country.new - country assigned based on processed lat long, there are c.16 values that don't have a country assigned.
# country_match - this is a direct text match, e.g. USA and United States are identified as false. some of these are really wrong, e.g. USA vs Mongolia, this could be because lat and long are reversed, or lat and long are minus
# harvest_year_by_median - when we don't know harvest...
# yield_control_kgha - this is yield converted to kg/ha, same for treatment
# city is classed as impervious services
# class - 
# nb. land cover is based on harvest_year_by_median
# buffer_radius_m - this is either 1000 or 5000
# proportion - proportion of each land cover class within an area
# simpsons_index
# species_richness - number of land cover classes within a radius

library(lme4)
library(ggplot2)

#################  
### add in some climate info
### optional for now
#################

# save the lat and long to paste back
latlongs <- data

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
points <- st_as_sf(data, coords = c("longitude_decimal", "latitude_decimal"), crs = st_crs(ecoregions))

# Step 3: Perform a spatial join to extract the Köppen-Geiger ecoregions
# This joins the points with the ecoregions based on spatial overlap.
data <- st_join(points, ecoregions, join = st_intersects)

# Step 4: Optional - Convert back to a regular dataframe (if needed)
# You can drop the geometry column to get back to a standard dataframe if the spatial attributes are no longer needed.
data <- st_drop_geometry(data)

# we got 20 new rows - remove these by getting rid of rows with decimal
data$rownames <- as.numeric(rownames(data))
data <- data[data$rownames %% 1 == 0, ]

# add back in the latlongs
data$latitude_decimal <- latlongs$latitude_decimal
data$longitude_decimal <- latlongs$longitude_decimal

# finish climate processing stuff
colnames(data)

levels(factor(data$main_climate))


##################
##################

# also remove the topsoil removal dataset - this wasn't a yield benefiting treatment
str(data$treatment)
levels(factor(data$treatment))
data <- droplevels(data[data$treatment!="Erosion simulation",])
data <- droplevels(data[data$treatment!="simplified vs diversified",])

# we also have the same for the treatment 'simplified vs diversified' - this shows a negative effect of treatment
# we could get around that by switching the labels for that one

# create lnrr variable
data$lnrr.yi <- log(data$yield_treatment_kgha/data$yield_control_kgha)
hist(data$lnrr.yi)

# lets do a basic thing where we aggregate by row_id
data2 <- aggregate(data$lnrr.yi,by=list(data$row_id),mean)
colnames(data2) <- c("row_id","lnrr.yi")
data2$shannons_index <- aggregate(data$shannons_index,by=list(data$row_id),mean)[,2]

with(data2, plot(lnrr.yi~shannons_index,pch=16,col=rgb(0,0,0,0.05)))
with(data2, abline(lm(lnrr.yi~shannons_index),col="blue"))
abline(h=0,col="gray95",lty=2)

# do with other land cover metrics
data2$simpsons_index <- aggregate(data$simpsons_index,by=list(data$row_id),mean)[,2]
data2$simpsons_evenness <- aggregate(data$simpsons_evenness,by=list(data$row_id),mean)[,2]
data2$species_richness <- aggregate(data$species_richness,by=list(data$row_id),mean)[,2]
data2$perimeter_to_area <- aggregate(data$perimeter_to_area,by=list(data$row_id),mean)[,2]

with(data2, plot(lnrr.yi~simpsons_index,pch=16,col=rgb(0,0,0,0.05)))
with(data2, abline(lm(lnrr.yi~simpsons_index),col="blue"))
abline(h=0,col="gray95",lty=2)

with(data2, plot(lnrr.yi~simpsons_evenness,pch=16,col=rgb(0,0,0,0.05)))
with(data2, abline(lm(lnrr.yi~simpsons_evenness),col="blue"))
abline(h=0,col="gray95",lty=2)

with(data2, plot(lnrr.yi~species_richness,pch=16,col=rgb(0,0,0,0.05)))
with(data2, abline(lm(lnrr.yi~species_richness),col="blue"))
abline(h=0,col="gray95",lty=2)

with(data2, plot(lnrr.yi~perimeter_to_area,pch=16,col=rgb(0,0,0,0.05)))
with(data2, abline(lm(lnrr.yi~perimeter_to_area),col="blue"))
abline(h=0,col="gray95",lty=2)

# nb this isn't great because I am currently averaging across both 1000 and 5000 buffers

# some simple questions that we could ask:
# - are control yields higher in places with greater % of cropland
# crop land covers are 10, 11, 12 and 20
colnames(data)

# some intitial exploratory analyses
with(data, boxplot(lnrr.yi~treatment))
abline(h=0)

# look at lnrr vs amount of natural habitat without grassland
#with(data, plot(lnrr.yi~nat.hab.wo.grass.5000,
#                pch=16,
#                col=rgb(0,0,0,0.1)))
#abline(h=0)
#with(data, abline(lm(lnrr.yi~nat.hab.5000),col="blue",lwd=2))

# we can try now and run a first mixed model
library(lme4)
# nested random effects for primary source paper, and meta-analysis paper
# also random effects for country, croptype and treatment
lme.1 <- lmer(lnrr.yi~nat.hab.wo.grass.5000+I(nat.hab.wo.grass.5000^2)+(1|Source)+(1|Country)+(1|pr_Croptype)+(1|pr_Treatment),data)
summary(lme.1)

# test vs null model
lme.null <- lmer(lnrr.yi~1+(1|Source)+(1|Country)+(1|pr_Croptype)+(1|pr_Treatment),data)
summary(lme.null)
AIC(lme.null) #-3592.374 with main_climate, -3594.252 without -> less than 1.878

anova(lme.1,lme.null)
# no difference in model fit from including proportion natural habitat

# can we look whether logrr.yi varies between crops?
# the estimate per crop is quite similar
lme.crop <- lmer(lnrr.yi~pr_Croptype-1+(1|Source)+(1|Country)+(1|pr_Treatment),data)
summary(lme.crop)

# we have some inaccuracy in the latitude and longitude values
# can we count then number of decimal places, and then weight according to that?

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
data$pr_Latitude_acc <- sapply(data$pr_Latitude,count_nonzero_decimal_places)
data$pr_Longitude_acc <- sapply(data$pr_Longitude,count_nonzero_decimal_places)
summary(data$pr_Latitude_acc) 
# take a look at some with only 2 decimal places
subset(data,pr_Latitude_acc==2)

# for now, drop the zero value
data <- subset(data,pr_Latitude_acc!=0) # lose 30 points: 1678 to 

# so, we want to treat points with 2-5 decimal places the same
# 2 decimal places (3 trailing zeros) is to the nearest 1km - give this 1/2 of 2 trailing zero group
# 1 decimal places (4 trailing zeros) is to the nearest 10km - give this 1/10 of 2 trailing zero group
# all others are equivalent
data$weights <- data$pr_Latitude_acc
data$weights[data$pr_Latitude_acc>2] <- 10
data$weights[data$pr_Latitude_acc==2] <- 5
data$weights[data$pr_Latitude_acc==1] <- 1
hist(data$weights)

# the trouble is that some of these are actually none rounded

lme.2 <- lmer(lnrr.yi~nat.hab.wo.grass.5000+(1|DatasetID/Source)+(1|Country)+(1|pr_Croptype)+(1|pr_Treatment),
              weights=weights,data)
summary(lme.2)

# make new null model with these same weights
lme.2.null <- lmer(lnrr.yi~1+(1|DatasetID/Source)+(1|Country)+(1|pr_Croptype)+(1|pr_Treatment),
                   weights=weights,data)

# compare this to null model with LRT
anova(lme.2,lme.2.null) # with this weighting, we still don't have a significant effect 

colnames(data)

# crop.peri.area.ratio.5000
sub <- data[!is.na(data$crop.peri.area.ratio.5000),]

lme.3 <- lmer(lnrr.yi~crop.peri.area.ratio.5000+
                (1|DatasetID/Source)+(1|pr_Croptype)+(1|pr_Treatment),
              weights=weights,
              sub)
summary(lme.3)

lme.3.null <- lmer(lnrr.yi~
                (1|DatasetID/Source)+(1|pr_Croptype)+(1|pr_Treatment),
                   weights=weights,
                data=sub)
summary(lme.3.null)

anova(lme.3,lme.3.null)

with(data, plot(lnrr.yi~crop.peri.area.ratio.5000))
abline(1.315e-01,-4.200e-05)
abline(h=0)

# so we have a negative effect of crop.peri.area.ratio.5000
# a high ratio means that small fields (fields with many boundaries)

# try it with edge length
# the weights don't make a big difference
sub <- data[!is.na(data$crop.edgelength.5000),]
lme.4 <- lmer(lnrr.yi~crop.edgelength.5000+
                (1|DatasetID/Source)+(1|pr_Croptype)+(1|pr_Treatment),
              weights=weights,
              sub)
lme.4.null <- lmer(lnrr.yi~1+
                     (1|DatasetID/Source)+(1|pr_Croptype)+(1|pr_Treatment),
                   weights=weights,
                   sub)
anova(lme.4,lme.4.null)
summary(lme.4)

# what other variables do we have?
# so crop peri area ratio was significant - what might that be measuring? field size? what else..
colnames(data)

# area of crop land
sub <- data[!is.na(data$cropland.5000),]
lme.5 <- lmer(lnrr.yi~cropland.5000+
                (1|DatasetID/Source)+(1|pr_Croptype)+(1|pr_Treatment),
              weights=weights,
              sub)
lme.5.null <- lmer(lnrr.yi~1+
                     (1|DatasetID/Source)+(1|pr_Croptype)+(1|pr_Treatment),
                   weights=weights,
                   sub)
anova(lme.5,lme.5.null)
summary(lme.5)

with(data, plot(lnrr.yi~cropland.5000))
abline(h=0)

# what about not looking at the lnrr.yi but at the actual control yield
with(data, plot(pr_yield_control_kgha~cropland.5000))
sub <- data[!is.na(data$pr_yield_control_kgha),]
lme.6 <- lmer(pr_yield_control_kgha~cropland.5000+
                (1|DatasetID/Source)+(1|pr_Croptype)+(1|pr_Treatment),
              weights=weights,
              sub)
lme.6.null <- lmer(pr_yield_control_kgha~1+
                (1|DatasetID/Source)+(1|pr_Croptype)+(1|pr_Treatment),
              weights=weights,
              sub)
anova(lme.6,lme.6.null)
summary(lme.6)
abline(4272.5,835.9)

# what about some relationships between our lnrr.yi (the benefit of the treatments) and control or treatment yield
with(data,plot(lnrr.yi~pr_yield_treatm_kgha))
with(data,abline(lm(lnrr.yi~pr_yield_treatm_kgha)))

with(data,plot(lnrr.yi~pr_yield_control_kgha))
with(data,abline(lm(lnrr.yi~pr_yield_control_kgha)))

### lets try using our variables as a random effect instead
# this is basically to explain some "noise" while trying to find treatment effects rather than anything more
# more like the original idea
lme.7 <- lmer(lnrr.yi~pr_Treatment-1 + 
                (1|DatasetID/Source)+(1|pr_Croptype)+
                (1|nat.hab.wo.grass.1000)+(1|crop.peri.area.ratio.1000)+(1|crop.edgelength.1000),
              weights=weights,
              sub)
summary(lme.7)
AIC(lme.7)

# Extract fixed effects estimates
estimates <- fixef(lme.7)

# Extract standard errors
std_errors <- sqrt(diag(vcov(lme.7)))

# Calculate 95% Wald confidence intervals
z_value <- qnorm(0.975)  # 1.96 for 95% CI

CI_Lower <- estimates - z_value * std_errors
CI_Upper <- estimates + z_value * std_errors

# Combine into a data frame
results_df_with <- data.frame(
  Term = names(estimates),
  Estimate = estimates,
  Std_Error = std_errors,
  CI_Lower = CI_Lower,
  CI_Upper = CI_Upper
)

# Print the results
print(results_df_with)

with_land <- ggplot(results_df_with, aes(x = Estimate, y = Term)) +
  geom_point() +
  geom_errorbarh(aes(xmin = CI_Lower, xmax = CI_Upper), height = 0.2) +
  labs(title = "Fixed Effects Estimates with 95% Confidence Intervals",
       x = "Estimate",
       y = "Term") +
  theme_minimal()
with_land

# redo without land cover as a random effect

lme.8 <- lmer(lnrr.yi~pr_Treatment-1 + 
                (1|DatasetID/Source)+(1|pr_Croptype),
              weights=weights,
              sub)
summary(lme.8)
AIC(lme.8)

# Extract fixed effects estimates
estimates <- fixef(lme.8)

# Extract standard errors
std_errors <- sqrt(diag(vcov(lme.8)))

# Calculate 95% Wald confidence intervals
z_value <- qnorm(0.975)  # 1.96 for 95% CI

CI_Lower <- estimates - z_value * std_errors
CI_Upper <- estimates + z_value * std_errors

# Combine into a data frame
results_df_without <- data.frame(
  Term = names(estimates),
  Estimate = estimates,
  Std_Error = std_errors,
  CI_Lower = CI_Lower,
  CI_Upper = CI_Upper
)

without_land <- ggplot(results_df_without, aes(x = Estimate, y = Term)) +
  geom_point() +
  geom_errorbarh(aes(xmin = CI_Lower, xmax = CI_Upper), height = 0.2) +
  labs(title = "Fixed Effects Estimates with 95% Confidence Intervals",
       x = "Estimate",
       y = "Term") +
  theme_minimal()
without_land

# some more chatgpt fun

# Add a column indicating the model
results_df_with$Model <- "With Land"
results_df_without$Model <- "Without Land"

# Combine the two data frames
combined_results_df <- rbind(results_df_with, results_df_without)

# Create the plot
ggplot(combined_results_df, aes(x = Estimate, y = Term, color = Model)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbarh(aes(xmin = CI_Lower, xmax = CI_Upper), 
                 position = position_dodge(width = 0.5), height = 0.2) +
  labs(title = "Comparison of Fixed Effects Estimates with and without Land Cover",
       x = "Estimate",
       y = "Term") +
  theme_minimal() +
  theme(legend.position = "top", 
        axis.text.y = element_text(size = 10), 
        axis.title.x = element_text(size = 12),
        plot.title = element_text(hjust = 0.5)) +
  scale_color_manual(values = c("With Land" = "blue", "Without Land" = "red"))

# note, this is currently random intercepts

# we should actuallly look at how our variables are correlated

# make a correlation matrix
corr_matrix <- cor(data[, 19:36], use = "complete.obs")
corrplot(corr_matrix)

# there are highly correlated values, so we should only pick some
# - nat.hab.wo.grass - any radius is ok, these are all the same for now (until an error with extraction)
# - crop.peri.area.ratio - only go with 1000, area is incorrect for other sizes but edge is correct across sizes so we divide area by different numbers
# - crop.edgelength - this is correct at different buffers
# - shannon

# run scatter plot matrix instead
tiff(file = "images/regmatrix.tiff",
     width=500,height=500,res=600,units="mm",compression="lzw")
plot(data[, 19:36],pch=16,col=rgb(0,0,0,0.1))
dev.off()

# put them all in a mixed model for now
lme.9 <- lmer(lnrr.yi~1 + scale(nat.hab.wo.grass.1000)
              +scale(crop.peri.area.ratio.1000)
              +scale(crop.edgelength.1000)+
                +(1|DatasetID/Source)+(1|pr_Croptype),
              weights=weights,
              data)
summary(lme.9)
AIC(lme.9)

# quadratic terms -2101.854
# without quadratics -2135.895


# and a corresponding null
lme.9.null <- lmer(lnrr.yi~1 +
                (1|DatasetID/Source)+(1|pr_Croptype),
              weights=weights,
              data)
summary(lme.9.null)
AIC(lme.9.null) # -2178.621
anova(lme.9,lme.9.null)

##################################
### a different option - can we instead look at treatment yield and include control yield as a predictor?
##################################

# how would that differ from the lnrr approach?
# we have some non-independence
lme.10 <- lmer(pr_yield_treatm_kgha ~  
                pr_yield_control_kgha*scale(nat.hab.wo.grass.1000)
               +pr_yield_control_kgha*scale(crop.peri.area.ratio.1000)
               +pr_yield_control_kgha*scale(crop.edgelength.1000)
               +pr_Latitude
               +pr_Longitude
               +(1|DatasetID/Source)
               +(1|pr_Croptype),
               weights=weights,
               data)
summary(lme.10)
AIC(lme.10) # 27739.03, with interactions 27615.78

# get blups estimates from this model
blups <- ranef(lme.10)
t.Source <- blups$Source
library(tibble)
t.Source <- rownames_to_column(t.Source, var = "Source")

# this is deviation from the meta-analytic mean -ve values mean more pollinator dependence and +ve means less than the average cultivar

# Create a dataframe from the BLUPs
t.Source <- blups$Source %>% 
  rownames_to_column(var = "Source")

# Abbreviate the Source names to the first 5 characters
t.Source$ShortSource <- substr(t.Source$Source, 1, 5)

# Plot the BLUPs with short labels
ggplot(t.Source, aes(x = reorder(ShortSource, `(Intercept)`), y = `(Intercept)`)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "BLUPs for Source Random Effects",
       x = "Source (Abbreviated)",
       y = "BLUPs (Intercept)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# make null model
lme.10.noint <- lmer(pr_yield_treatm_kgha ~  
pr_yield_control_kgha
+scale(nat.hab.wo.grass.1000)
+scale(crop.peri.area.ratio.1000)
+scale(crop.edgelength.1000)
+pr_Latitude
+pr_Longitude
+(1|DatasetID/Source)
+(1|pr_Croptype),
weights=weights,
data)
summary(lme.10.noint)
anova(lme.10.noint,lme.10) # significnat effect of interactions between control yield and natural habitats

with(data,plot(pr_yield_treatm_kgha~pr_yield_control_kgha,pch=16,col=rgb(0,0,0,0.1)))
with(data,plot(log(pr_yield_treatm_kgha)~log(pr_yield_control_kgha),pch=16,col=rgb(0,0,0,0.1)))
with(data,plot(pr_yield_treatm_kgha~scale(nat.hab.wo.grass.1000),pch=16,col=rgb(0,0,0,0.1)))
with(data,plot(pr_yield_treatm_kgha~scale(crop.peri.area.ratio.1000),pch=16,col=rgb(0,0,0,0.1)))
with(data,plot(pr_yield_treatm_kgha~scale(crop.edgelength.1000),pch=16,col=rgb(0,0,0,0.1)))
