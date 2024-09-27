library(tidyr)

data <- read.csv('data/data_yield_24092024_v2.csv', sep = ',', dec = '.') 
# variable description: DatasetID -> meta-data study
# No. -> an indiviudal measurement of yield treatment

landcover.meta<-read.csv('data/legend_classcode_landcovertypes.csv', sep = ',', dec = '.') 

# changes some colnume names to make it more understandable 
colnames(data)[c(2,4)]<- c('measurement_ID', "control_ID")
# the four ID columns are (i) meta-analysis ID, (ii) unique treatment ID, (iii) study ID (starts at 1 with every meta-analysis) 
# and (iv) unique control ID (starts in each study with 1 again)

# Note: To do/ issues:
# (i) The countries need to be still updated and that will help us to clean up some mistakes with long and lat data - Elizabetha will do that
# (ii) check out the yield data, why do we have so high values and why sometimes so high rates of change?
# (iii) do we need really a standardised yield measure? Or, if we work with effect sizes - then it could be anyhow not important whether we
# we have different units among different studies?? I would vote for the latter. If others agree, we have to change II B in the code
# (iv) if we compute means for the data that share the same location, study year, crop type and treatment, I noticed that we combine data points that
# already have some replicates (we compute an average of averages). That might be okay, but that means that we probably sum some things that have
#  were first kept separate on purpose (for whatever reason, maybe because they have different coordinates in reality, etc, we don't know)
# (v) treatment of temporal and spatial replicates: as a note - I tried now to treat spatial and replicates in the same way. Always when we have
# different land-cover maps, we consider the data point separately.
# (vi) why are there NAs in the study ID column??
# (vii) we have a lot of columns where the treatment yield is exactly as the control yield! Is that not very odd and unlikely 
# (almost 10% of the data) See II C
# (viii) we need to calculate also converted standard deviations for yield treatment and yield control data. If you do so, we have to adjust 
# the column numbers in II A!!! And update in II E the column that is used!!! And in II F the columns as well!
# (ix) the code for the creation of the 2500m radius data is silenced right now - needs to be updated once the data is there...
# (x) we have about 30 data points where both the area and the edgelength of agricultural land is 0 - that seems odd, can we look into this
# the IDs of the samples can be found in III D
# (xi) what is the resolution of the land-use raster? I am irritated that we have so high edgeland to area ratios. They seem to be frequently 
# above 1.2m/m2. If we have a resolution of 10m, then the highest possible ratio should be 0.4 (100m2 area and 40m perimeter). How can we explain 
# these data?
# (xii) Some data points have very high proportion of inert data (up to 100%) - this is very likely due to wrong coordinates. Look into III F
# to identify these data points.
  
####### (I) check and clean the data #######
####### (A) check frequency of class entries per unique treatment yield measurement (i.e. No.) #######
# check whether we have each land-cover class only one time for each unique measurement
check<-as.data.frame(table(data$class, data$buffer_radius_m, data$measurement_ID))
colnames(check)<- c('class', 'radius', 'number','Freq')

# Good that seems right now!
unique(check$number [which(check$Freq>1)]) 

# clean up
rm(check)

####### (B) check for missing landscape data #######
unique(data$buffer_radius_m)
x<-data[which(is.na(data$buffer_radius_m)), ]
# The issue is that we have some data where we do not know the publication year of the study and hence we cannot assign a landcover map.
# These data points are removed

data<-data[-which(is.na(data$buffer_radius_m)),]

####### (C) check the latitude data #######
summary(data$latitude_decimal)
# check whether the values seem to be realistic - yes that looks fine

####### (D) Fix 0 radius issues #######
# there is an issue that some land-cover specifications have 0 edge length
# this is because the area is very small and the algorithm has failed to associated an edge to that. 
# the fix is that we assume a circular area of that land-cover class and that it is to 100% in the radius

selection<-which(data$edgelength_m==0) 
# calculates from the area the radius of a circle with that area and then computes from the radius the perimeter
data$edgelength_m[selection]<-(sqrt(data$area_m2[selection])) * 2 

rm(selection)

####### (E) check whether yield data is realistic ##########
hist(data$yield_treatment_kgha)
summary(data$yield_treatment_kgha)

# this seems to be a bit odd - a very good corn yield per ha is e.g. 13 tons. So, that fits with the median (6000 kg). However,
# we have here a lot of yields that are 10000 tons and higher. That cannot be right. We should look into this closer!
# one possibility could be that this is the whole biomass and not the corn yield, but that would still weird somehow to report this
unique(data$crop_type_grouped_small[which(data$yield_treatment_kgha>10^7)])
unique(data$crop_type_grouped_big[which(data$yield_treatment_kgha>10^7)])

x<-data$yield_treatment_kgha/ data$yield_control_kgha
x[which(x> 2.5 | x<0.25)]
# there are some data that show a quite high change in values - so either an increase by more than 150% or a shrinkage of the yield
# in the treatment to less than a quarter of what the original yield was. This seems extreme - can we trust this? We should probably
# also double check? 

####### (F) Sort out proportion data so that land cover classes always add up to 1 ##########
ID<-paste0(data$ma_id, '_',data$measurement_ID, '_',data$buffer_radius_m)
unique_ID<-unique(ID)

# takes a bit because it is a slow loop... but is okay :)
for(i in 1:length(unique_ID)){x<-which(ID==unique_ID[i])
  data$proportion[x]<-data$proportion[x]/sum(data$proportion[x])}

####### (II) transform the data #######

##### (A) Change the format ##########
# create the longer data format
data.mod<- pivot_wider(data[,1:50], names_from = class, values_from = c(41,45,50))

x<-as.data.frame(table(data.mod$measurement_ID))
table(x$Freq) # that worked nicely - each unique measurement has now exactly two entries (for each of the two radii)

# second step here - we have still three 
data.mod.2<- pivot_wider(data.mod[,-c(42:46)], names_from = buffer_radius_m, values_from = c(42:(ncol(data.mod)-5)))
x<-as.data.frame(table(data.mod.2$measurement_ID))
table(x$Freq) # that worked nicely again!

##### (B) Handle missing data in the control column ##########
# there are some yield data which could not be transformed (because they were weird units - these ones we have to eliminate
data.mod.2<- data.mod.2[-which(is.na(data.mod.2$yield_control_kgha)),]

##### (C) check differences between control and treatment yield data ##########
x<-data.mod.2[which(data.mod.2$yield_control_kgha == data.mod.2$yield_treatment_kgha),]
which(data$yield_control_kgha == data$yield_treatment_kgha)

#something major has gone wrong here because many of the original yield data in x do not have that problem... 

##### (D) erase double data entries ##########
# here I use an aggregate function to compute average for all data that has the same publication year, treatment, location and corp type.
# if I do add study ID (different for each meta-analysis), then I get suddenly 9 additional data points. These should be 9 studies that 
# are twice in our data set and we probably better remove them.
data.mod.2$Lat_long<- paste0(data.mod.2$latitude_decimal, data.mod.2$longitude_decimal)

means.check<-aggregate(list(data.mod.2$yield_control_kgha, data.mod.2$yield_treatment_kgha, data.mod.2$measurement_ID),
                       by = list(data.mod.2$study_pubyear, data.mod.2$treatment, data.mod.2$Lat_long,
                                 data.mod.2$crop_type),   function(x){mean(x, na.rm = T)})
colnames(means.check)<-c('study_pubyear', 'treatment', 'Lat_long', 'crop_type','yield_control_kgha',
                         'yield_treatment_kgha', 'measurement_ID')
means.check.2<-aggregate(list(data.mod.2$yield_control_kgha, data.mod.2$yield_treatment_kgha, data.mod.2$measurement_ID),
                       by = list(data.mod.2$ma_id, data.mod.2$study_id, data.mod.2$study_pubyear, data.mod.2$treatment, data.mod.2$Lat_long,
                                 data.mod.2$crop_type),   function(x){mean(x, na.rm = T)})
colnames(means.check.2)<-c('ma_id','study_id','study_pubyear', 'treatment', 'Lat_long', 'crop_type','yield_control_kgha',
                         'yield_treatment_kgha', 'measurement_ID')

means.check.2$ID<-paste0(means.check.2$study_pubyear, means.check.2$treatment, means.check.2$Lat_long,means.check.2$crop_type)
means.check$ID<-  paste0(means.check$study_pubyear, means.check$treatment, means.check$Lat_long,means.check$crop_type)

# super odd - for some reason the treatment "control conventional tillage-treatm no tillage" is not in means.check.2. ???
means.check<-means.check[which(means.check$treatment!="control conventional tillage-treatm no tillage"),]

x<-as.data.frame(table(means.check.2$ID))
y<-which(x$Freq>1) #some of those are more than two times in the data

# identify the double entries - where the everything is the same ('study_pubyear', 'treatment', 'Lat_long', 'crop_type' and there are still
# two entries)
problem<-means.check.2[(match(x$Var1[y],means.check.2$ID)),]

# check whether the treatment yield is also the same. If yes, we should remove the data, because they are likely double counted... 
remove<-c()
for(i in 1:nrow(problem)){x<-data.mod.2[which(data.mod.2$study_pubyear==problem$study_pubyear[i] &
                                         data.mod.2$treatment==problem$treatment[i] &
                                         data.mod.2$crop_type==problem$crop_type[i] &
                                         data.mod.2$Lat_long==problem$Lat_long[i]),]
y<-as.data.frame(table(x$yield_treatment_kgha))
y<-y$Var1[which(y$Freq>1)]
for(j in 1:length(y)){z<-which(data.mod.2$study_pubyear==problem$study_pubyear[i] &
                                          data.mod.2$treatment==problem$treatment[i] &
                                          data.mod.2$crop_type==problem$crop_type[i] &
                                          data.mod.2$Lat_long==problem$Lat_long[i] & 
                                          data.mod.2$yield_treatment_kgha==y[j])
  remove<-c(remove, z[-1])}}

# remove the spurious data
data.mod.2<-data.mod.2[-remove,]

# clean up
rm(x,y, means.check, means.check.2, problem,remove,z)

##### (E) Average replicates that use the same location and the same land-cover map ##########
# we need (i) the mean of the two yields, (ii) the combination of the standard deviation, (iii) the sum of the sample sizes, (iv) the 
# number of aggregated unique measurement IDs

means<-aggregate(list(data.mod.2$yield_control_kgha, data.mod.2$yield_treatment_kgha),
                       by = list(data.mod.2$landcover_map_year, data.mod.2$treatment, data.mod.2$Lat_long,
                                 data.mod.2$crop_type),   function(x){mean(x, na.rm = T)})
colnames(means)<-c('landcover_map_year','treatment', 'Lat_long', 'crop_type', 'yield_control_kgha', 'yield_treatment_kgha')

# add sds of yield
sds.yield<-aggregate(list(data.mod.2$yield_SD_control, data.mod.2$yield_treatment),
                       by = list(data.mod.2$landcover_map_year, data.mod.2$treatment, data.mod.2$Lat_long,
                                 data.mod.2$crop_type),   function(x){ sqrt(sum(x^2))})
colnames(sds.yield)<-c('landcover_map_year','treatment', 'Lat_long', 'crop_type', 'yield_SD_control', 'yield_treatment')

means$yield_SD_control<- sds.yield$yield_SD_control
means$yield_SD_treatment<- sds.yield$yield_treatment

# sum sample size of yield
n.yield<-aggregate(list(data.mod.2$control_replicates, data.mod.2$treatment_replicates),
                     by = list(data.mod.2$landcover_map_year, data.mod.2$treatment, data.mod.2$Lat_long,
                               data.mod.2$crop_type),   function(x){sum(x)})
colnames(n.yield)<-c('landcover_map_year','treatment', 'Lat_long', 'crop_type', 'replicates_control_summed', 'replicates_treatment_summed')

means$replicates_control_summed<- n.yield$replicates_control_summed
means$replicates_treatment_summed<- n.yield$replicates_treatment_summed

# sum sample size of yield
n.aggregated<-aggregate(list(data.mod.2$control_replicates),
                   by = list(data.mod.2$landcover_map_year, data.mod.2$treatment, data.mod.2$Lat_long,
                             data.mod.2$crop_type),   function(x){length(x)})
colnames(n.aggregated)<-c('landcover_map_year','treatment', 'Lat_long', 'crop_type', 'n_aggregated')

means$n_aggregated<- n.aggregated$n_aggregated

# clean up:
rm(sds.yield, n.yield, n.aggregated)

##### (F) Add additional columns to aggregated data ##########

# add remaining data to the average data
# it should be okay to pull in things that have the same latidude-longitude combination and the same land-cover map-year
means<-cbind(means, data.mod.2[match(paste0(means$Lat_long, means$landcover_map_year, means$treatment, 
                                            means$crop_type), 
                                     paste0(data.mod.2$Lat_long, data.mod.2$landcover_map_year, data.mod.2$treatment,
                                            data.mod.2$crop_type)), 
                               c(1:8,11:12,29:37,41:ncol(data.mod.2))])

# watch out - study ID might not be 100% correct anymore because if there are two studies from the same place and the same year, they will be 
# combined. It can happen, but is relatively rare... 

# note - "soil_type","temperature","precipitation",'climate_zone',LRR, LRR_vi,reference,    are left out because of the large NA count 

data.mod.2$reference[data.mod.2$reference=='']<-NA
length(which(is.na(data.mod.2$reference)))/nrow(data.mod.2)

# compute the log-response ratio
means$logrr.yi <- log10(means$yield_treatment_kgha/means$yield_control_kgha)

##### (III) Prepare predictors ##########
reg.data<-means[,c(1:30)]
col.names<-colnames(means)

##### (A) create the semi natural habitat proportion (including grassland) #####

# (i) get the classes which need to be included
nat.hab.class.code<-landcover.meta$Class.Code[-which(
  landcover.meta$Bigger.CLass=='Bare Surfaces'| 
  landcover.meta$Class.Description.by.ESA=='Permanent ice and snow'|
  landcover.meta$Bigger.CLass=='Cropland' )]

# (ii) natural habitat for the three different radii: get the column names for the 1000 radius
# create the column names that should be included
nat.hab.col.names<-c(paste0('proportion_',nat.hab.class.code,'_1000'))

# create the nat. habitat variable
reg.data$nat.hab.1000<-rowSums(means[,which(is.element(col.names,nat.hab.col.names))], na.rm = T)

# (iii) now for the other two radii
# nat.hab.col.names<-c(paste0('proportion_',nat.hab.class.code,'_2000'))
# reg.data$nat.hab.2000<-rowSums(means[,which(is.element(col.names,nat.hab.col.names))], na.rm = T)

nat.hab.col.names<-c(paste0('proportion_',nat.hab.class.code,'_5000'))
reg.data$nat.hab.5000<-rowSums(means[,which(is.element(col.names,nat.hab.col.names))], na.rm = T)

plot(reg.data$nat.hab.5000, reg.data$nat.hab.1000) # looks right


##### (B) create the semi natural habitat proportion (now without grassland) #####

# (i) get the classes which need to be included
nat.hab.class.code<-landcover.meta$Class.Code[-which(
  landcover.meta$Bigger.CLass=='Bare Surfaces'| 
    landcover.meta$Class.Description.by.ESA=='Permanent ice and snow'|
    landcover.meta$Bigger.CLass=='Grassland' |
    landcover.meta$Bigger.CLass=='Cropland' )]

# (ii) natural habitat for the three different radii: 
# create the column names that should be included
nat.hab.col.names<-c(paste0('proportion_',nat.hab.class.code,'_1000'))
reg.data$nat.hab.wo.grass.1000<-rowSums(means[,which(is.element(col.names,nat.hab.col.names))], na.rm = T)

# now for the other two radii
# nat.hab.col.names<-c(paste0('proportion_',nat.hab.class.code,'_2000'))
# reg.data$nat.hab.wo.grass.2000<-rowSums(means[,which(is.element(col.names,nat.hab.col.names))], na.rm = T)

nat.hab.col.names<-c(paste0('proportion_',nat.hab.class.code,'_5000'))
reg.data$nat.hab.wo.grass.5000<-rowSums(means[,which(is.element(col.names,nat.hab.col.names))], na.rm = T)
# not that there is still this coding mistake and the radii data are still identical...

plot(reg.data$nat.hab.wo.grass.5000, reg.data$nat.hab.5000) # looks nice and right on the first glance

##### (C) create the cropland proportion data #####

# (i) get the classes which need to be included and create their col-names
cropland.class.code<-landcover.meta$Class.Code[which(landcover.meta$Bigger.CLass=='Cropland')]
names<-c(paste0('proportion_',cropland.class.code,'_1000'))

# (ii) create the data for the 1km radius
reg.data$cropland.1000<-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

# (iii) repeat that for the 2 and 5km radii
# names<-c(paste0('proportion_',cropland.class.code,'_2000'))
# reg.data$cropland.2000<-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

names<-c(paste0('proportion_',cropland.class.code,'_5000'))
reg.data$cropland.5000<-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

plot(reg.data$nat.hab.wo.grass.5000, reg.data$cropland.5000) 
hist(reg.data$nat.hab.5000 + reg.data$cropland.5000)
summary(reg.data$nat.hab.5000 + reg.data$cropland.5000)
summary(reg.data$nat.hab.1000 + reg.data$cropland.1000)
# all looks nice and right on the first glance

##### (D) create the cropland area vs perimeter data #####

colnames(means)

# (i) create the column names
names<-c(paste0('area_m2_',cropland.class.code,'_1000'))
names.per<-c(paste0('edgelength_m_',cropland.class.code,'_1000'))

# (ii) create the variable
reg.data$crop.peri.area.ratio.1000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T) /
  rowSums(means[,which(is.element(col.names,names))], na.rm = T) # unit: m/m2

# we have some data points where both area and edgelength of agricultural land is 0 
x<-rowSums(means[,which(is.element(col.names,names))], na.rm = T)
y<-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T)

which(x==0); which(y==0) 

# for now, we can exclude these points? But maybe we can look into this problem?
# we do the exclusion at the end...

# check whether the proportion data matches with the area data 
plot(means$area_m2_72_5000 , means$proportion_72_5000)
# yes - it does, good nicely!

# (iii) repeat that for the 2 and 5km radii
# names<-c(paste0('area_m2_',cropland.class.code,'_2000'))
# names.per<-c(paste0('edgelength_m_',cropland.class.code,'_2000'))
# reg.data$crop.peri.area.ratio.2000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T) /
#   rowSums(means[,which(is.element(col.names,names))], na.rm = T) # unit: m/m2

names<-c(paste0('area_m2_',cropland.class.code,'_5000'))
names.per<-c(paste0('edgelength_m_',cropland.class.code,'_5000'))
reg.data$crop.peri.area.ratio.5000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T) /
  rowSums(means[,which(is.element(col.names,names))], na.rm = T) # unit: m/m2

##### (E) create the agricultural edge-length #####
names.per<-c(paste0('edgelength_m_',cropland.class.code,'_1000'))
reg.data$crop.edgelength.1000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T) 

# names.per<-c(paste0('edgelength_m_',cropland.class.code,'_2000'))
# reg.data$crop.edgelength.2000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T) 

names.per<-c(paste0('edgelength_m_',cropland.class.code,'_5000'))
reg.data$crop.edgelength.5000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T)

##### (F) create the inert land-cover #####
# (i) get the classes which need to be included and create their col-names
inert.land.class.code<-landcover.meta$Class.Code[-which(
  landcover.meta$Bigger.CLass=='Bare Surfaces'| 
  landcover.meta$Class.Description.by.ESA=='Permanent ice and snow')]
names<-c(paste0('proportion_',inert.land.class.code,'_1000'))

# (ii) create the data for the 1km radius - here we also have urban areas and other built environments, which are
# not included in our land-cover classes, so we have to use the not inert area and subtract it from 1 to get the 
# right value.
reg.data$inert.1000<- 1-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

# (iii) repeat that for the 2 and 5km radii
# names<-c(paste0('proportion_',inert.land.class.code,'_2000'))
# reg.data$inert.2000<- 1-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

names<-c(paste0('proportion_',inert.land.class.code,'_5000'))
reg.data$inert.5000<- 1-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

# looks good, but we have some very high inert values...
plot(reg.data$inert.1000, reg.data$inert.5000)

which(reg.data$inert.1000>0.8) # maybe check these points once more? 


##### (H) create the shannon index #####
# (i) define the variables that need to be included
names<-c(paste0('area_m2_',inert.land.class.code,'_1000')) # inert.land.class.code - contains all non inert land-cover types

# (ii) create the data frame for the analysis
shannon.df<-means[,which(is.element(col.names,names))]
shannon.df$inert<- reg.data$inert.1000

# (iii) replace NAs with 0s
for(i in 1:ncol(shannon.df)){shannon.df[which(is.na(shannon.df[,i])) , i]<-0}
  
# (iv) calculate the shannon diversity
library(vegan) # 'species' need to be the columns
reg.data$shannon.1000<-diversity(shannon.df, index = "shannon")

# (v) repeat for the other two radii
# names<-c(paste0('area_m2_',inert.land.class.code,'_2000'))
# shannon.df<-means[,which(is.element(col.names,names))]
# shannon.df$inert<- reg.data$inert.2000
# for(i in 1:ncol(shannon.df)){shannon.df[which(is.na(shannon.df[,i])) , i]<-0}
# reg.data$shannon.2000<-diversity(shannon.df, index = "shannon")

names<-c(paste0('area_m2_',inert.land.class.code,'_5000'))
shannon.df<-means[,which(is.element(col.names,names))]
shannon.df$inert<- reg.data$inert.5000
for(i in 1:ncol(shannon.df)){shannon.df[which(is.na(shannon.df[,i])) , i]<-0}
reg.data$shannon.5000<-diversity(shannon.df, index = "shannon")

# Diagnostic check whether we have NAs - we should not have them
which(is.na(reg.data$inert.1000))
which(is.na(reg.data$cropland.1000))
which(is.na(reg.data$crop.edgelength.1000))
which(is.na(reg.data$nat.hab.1000))
which(is.na(reg.data$nat.hab.wo.grass.1000))
# that all looks good

# clean up some objects that are not needed anymore
rm(nat.hab.col.names, nat.hab.class.code, cropland.class.code,names, names.per, inert.land.class.code, shannon.df)

# save the file
write.csv(reg.data, file = 'data/data_processed.csv',row.names = TRUE)

plot(reg.data$shannon.1000~reg.data$cropland.1000)
plot(reg.data$shannon.1000~reg.data$nat.hab.1000)
plot(reg.data$shannon.1000~reg.data$nat.hab.wo.grass.1000)

# check how many data points we have per study now...
summary(as.vector(table(paste0(reg.data$study_id,reg.data$ma_id))))

