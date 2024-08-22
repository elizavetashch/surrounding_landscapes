# 210824
# I am running this after running the Yield_dat_2024-08-20 script
# reading in the processed file

###
reg.data <- read.csv('data/data_processed.csv', sep = ',', dec = '.') #1739 obs
colnames(reg.data)

#################  
### add in some climate info
### optional for now
#################

# # Load necessary libraries
# library(sf)  # for handling spatial data
# library(dplyr)  # for data manipulation
# 
# # Step 1: Read the Köppen-Geiger ecoregions shapefile
# if (file.exists("1976-2000_GIS.zip")==FALSE){
#   download.file("http://koeppen-geiger.vu-wien.ac.at/data/1976-2000_GIS.zip","1976-2000_GIS.zip", mode="wb")
#   unzip("1976-2000_GIS.zip")
# } else {unzip("1976-2000_GIS.zip")}
# 
# ecoregions <- st_read(dsn=".",layer="1976-2000")
# sf_use_s2(FALSE)
# ecoregions$main_climate <- cut(ecoregions$GRIDCODE, breaks=c(10,20,30,40,60,70), labels=c("Tropical","Arid","Temperate","Cold (Continental)","Polar"))
# 
# # Step 2: Convert the latitude and longitude columns into a 'sf' object (spatial points)
# # First, create the points using the longitude and latitude values.
# points <- st_as_sf(data, coords = c("pr_Longitude", "pr_Latitude"), crs = st_crs(ecoregions))
# 
# # Step 3: Perform a spatial join to extract the Köppen-Geiger ecoregions
# # This joins the points with the ecoregions based on spatial overlap.
# data <- st_join(points, ecoregions, join = st_intersects)
# 
# # Step 4: Optional - Convert back to a regular dataframe (if needed)
# # You can drop the geometry column to get back to a standard dataframe if the spatial attributes are no longer needed.
# data <- st_drop_geometry(data)
# 
# # finish climate processing stuff
# colnames(data)
# # we got 20 new rows - lets check these
# dataextra <- read.csv('data/data_processed.csv', sep = ',', dec = '.')
# dataextra$pr_yield_treatm_kgha==data$pr_yield_treatm_kgha
# # the problem here is that some coordinates have two climate types 

##################
##################
reg.data$lnrr.yi <- log(reg.data$pr_yield_treatm_kgha/reg.data$pr_yield_control_kgha)

# range transform the predictors
range.std<-function(x){(x-min(x, na.rm = T))/(max(x, na.rm = T)-min(x, na.rm = T))}
for(i in c(5,6,19:ncol(reg.data))) {reg.data[,i]<-range.std(reg.data[,i])}

##### (A) Mix-model approach ######
# (1) Select predictors:
# some diagnostic plots
library(car)
plot(reg.data$nat.hab.wo.grass.1000 ~ reg.data$inert.1000)
plot(reg.data$nat.hab.wo.grass.1000 ~ reg.data$inert.1000)

cor.test(reg.data$nat.hab.wo.grass.1000 , reg.data$cropland.1000)

library(Hmisc)
cor.matrix<- rcorr(as.matrix(reg.data[,c(5,6,19:ncol(reg.data))]), type = "spearman")
matrix.r<-cor.matrix$r

# we have agreed on the following predictors:
# shannon.1000, inert.1000, crop.edgelength.1000, crop.peri.area.ratio.1000, nat.hab.wo.grass.1000

# (2) Create weights for accounting for inaccuracy in the latitude and longitude values

# chatgpt function to count non-zeros

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
    return(0)}}

# now count the number of trailing zeros for lat and long
reg.data$pr_Latitude_acc <- sapply(reg.data$pr_Latitude, count_nonzero_decimal_places)
reg.data$pr_Longitude_acc <- sapply(reg.data$pr_Longitude, count_nonzero_decimal_places)
summary(reg.data$pr_Latitude_acc)

# for now, drop the zero value
reg.data <- subset(reg.data,pr_Latitude_acc!=0) # lose 30 points: 1663

# so, we want to treat points with 2-5 decimal places the same
# 2 decimal places (3 trailing zeros) is to the nearest 1km - give this 1/2 of 2 trailing zero group
# 1 decimal places (4 trailing zeros) is to the nearest 10km - give this 1/10 of 2 trailing zero group
# all others are equivalent
reg.data$weights <- reg.data$pr_Latitude_acc
reg.data$weights[reg.data$pr_Latitude_acc>2] <- 10
reg.data$weights[reg.data$pr_Latitude_acc==2] <- 5
reg.data$weights[reg.data$pr_Latitude_acc==1] <- 1
hist(reg.data$weights)

# (3) Select radii for predictors and see what kind of transformations we need to implement
library(lme4); library(lmerTest)

# include country as random effect:
lme.non.tr <- lmer(lnrr.yi ~ nat.hab.wo.grass.1000 + shannon.1000 + inert.1000 + crop.edgelength.1000 +
                  crop.peri.area.ratio.1000 + nat.hab.wo.grass.1000 + 
                  (1|DatasetID/Source) + (1|pr_Croptype) + (1|pr_Treatment),
                weights=weights,reg.data)
lme.exp <- lmer(lnrr.yi ~ I(nat.hab.wo.grass.1000^2) + shannon.1000 + inert.1000 + crop.edgelength.1000 +
                  crop.peri.area.ratio.1000 + nat.hab.wo.grass.1000 + pr_Treatment+
                  (1|DatasetID/Source) + (1|pr_Croptype) ,
                weights=weights,reg.data)
summary(lme.exp)

which(is.na(reg.data$nat.hab.wo.grass.1000))

r<-residuals(lme.non.tr)
resid.mod<-lm(r ~ reg.data$lnrr.yi[which(is.na(reg.data$lnrr.yi)==F)])
summary(resid.mod)

plot(reg.data$lnrr.yi~ reg.data$inert.1000)
plot(lme.non.tr)

# also remove greenhouse vegetables as a crop type
levels(factor(data$pr_Croptype))
data <- data[data$pr_Croptype!="Greenhouse_vegetable",]

## also remove the topsoil removal dataset - this wasn't a yield benefitting treatment
# str(data$pr_Treatment)
# levels(factor(data$pr_Treatment))
# data <- droplevels(data[data$pr_Treatment!="Topsoil removal experiment",])

# create lnrr variable
data$lnrr.yi <- log(data$pr_yield_treatm_kgha/data$pr_yield_control_kgha)
hist(data$lnrr.yi)

# look at lnrr vs amount of natural habitat without grassland
with(data, plot(lnrr.yi~nat.hab.wo.grass.5000,
                pch=16,
                col=rgb(0,0,0,0.1)))
abline(h=0)
with(data, abline(lm(lnrr.yi~nat.hab.5000),col="blue",lwd=2))

# some diagnostic plots
library(car)
plot(data$nat.hab.wo.grass.1000 ~ data$inert.1000)
plot(data$nat.hab.wo.grass.1000 ~ data$inert.1000)

cor.test(data$nat.hab.wo.grass.1000 , data$cropland.1000)

library(Hmisc)
cor.matrix<- rcorr(as.matrix(data[,c(5,6,19:ncol(data))]), type = "spearman")
matrix.r<-cor.matrix$r

library(corrplot)
png(file="corr.png", res=300, width=4500, height=4500)
corrplot(as.matrix(matrix.r))
dev.off()

# predictor selection - (i) nat. habitat without grass, (ii) 


plot(data[,c(5,6,19:ncol(data))])

# we can try now and run a first mixed model
library(lme4)
# nested random effects for primary source paper, and meta-analysis paper
# also random effects for country, croptype and treatment
lme.1 <- lmer(lnrr.yi ~ nat.hab.wo.grass.5000 + I(nat.hab.wo.grass.5000^2)+(1|Source)+
                (1|Country)+(1|pr_Croptype)+(1|pr_Treatment),data)
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
cropland.5000

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
                (1|DatasetID/Source)+(1|pr_Croptype)+(1|crop.edgelength.5000),
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