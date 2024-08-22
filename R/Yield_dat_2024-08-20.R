library(tidyr)

data <- read.csv('data/data_with_landscape_metrics.csv', sep = ',', dec = '.') 
# variable description: DatasetID -> meta-data study
# No. -> an indiviudal measurement of yield treatment

landcover.meta<-read.csv('data/legend_classcode_landcovertypes.csv', sep = ',', dec = '.') 
  
####### (I) check data #######
####### (A) check frequency of class entries per unique treatment yield measurement (i.e. No.) #######
check<-as.data.frame(table(data$class, data$buffer_radius_m, data$No.))
colnames(check)<- c('class', 'radius', 'number','Freq')

# It seems that we have a problem here! There are several times the same land-cover class for unique yield data
problems<- unique(check$number [which(check$Freq>1)]) 
x<-data[which(is.element(data$No., problems)),]


# class values match at the beginning but later on there is really an issue here!
plot(x$areaM2[1:15],x$areaM2[16:30])
plot(x$areaM2[1:15],x$areaM2[46:60])

# PROBLEM:the issue is that for several unique data entries (i.e. unique treatment yield measures), there are multiple times
# values for different land-cover classes provided. to get rid of that, I would suggest to just take the first data entries.
# But we need to look into that!

# # (old) get means per unique data entry
# means<-aggregate(list(x$areaM2, x$proportion, x$edgelength_m, x$areatoperimeterratio), by = list(x$class,x$No.), 
#                  function(x){mean(x)})

# (i) take the first data entry that comes up for a unique No.-class combination
x$combi_var<-paste0(x$No., x$class)
maintain<- unique(x$combi_var)

# (ii) select the data
x<-x[match(maintain, x$combi_var),]

# (iii) get rid of the flawed data in the main dataframe
data<- data[-which(is.element(data$No. , problems)),]

# (iv) add the fixed data to the main data frame
data<-rbind(data, x[,1:33])

# clean up
rm(x, maintain, problems)

####### (B) check the radii data #######
means<-aggregate(list(data$areaM2), 
                 by = list(data$buffer_radius_m,  data$No.),
                 function(x){sum(x)})

# PROBLEM - if you check the output, you will see that all the different land-cover data for the different
# radii of the sam unique yield measurement are identical - something went wrong!! 

####### (c) check for missing landscape data #######
x<-data[which(is.na(data$buffer_radius_m)), ]
# PROBLEM: why are these data missing - here we have a lat and long?? And a land cover map (seemingly, as we have the year),
# but no land-cover data

# PROBLEM: also, we have some places, where we have no 2 and 5km radii, but Elina says that is okay, because those places 
# were close to the ocean and hence were not considered
table(data.mod$buffer_radius_m)

# I am not sure that this is the best approach - maybe it is better to still calculate 2 and 5km radii and then exclude 
# water from landcover indicies...?? Otherwise we would loose these data.

####### (D) check the latitude data #######
summary(data$pr_Latitude)
# wow! Why do we have latitude more than 90 degrees??? - this issues is resolved when the pr_Latidue is used : )

# there are 184 data points (at least where this is an issue!!)
#length(which(abs(data.mod.2$Latitude)>90))
#length(which(abs(data.mod.2$pr_Latitude)>90))
# with the pr_latitude this seems to be fixed...

####### (II) clean and transform the data #######

##### (A) Deal with some simple issues ##########
# (i) drop out some dodgy yield values
data<-data[-which(is.element(data$No., c(3018, 3019, 3118, 3119, 4632, 4633))), ]

# (ii) some of the values were incorrectly converted to kg/ha, we should fix them: First take care of the control values
data$pr_yield_control_kgha[data$yield_measure=="Mg/ha" & !is.na(data$pr_yield_control_kgha)] <- 
  data$pr_yield_control_kgha[data$yield_measure=="Mg/ha" & !is.na(data$pr_yield_control_kgha)]*1000000000
data$pr_yield_control_kgha[data$yield_measure=="Mg dry matter/ha" & !is.na(data$pr_yield_control_kgha)] <- 
  data$pr_yield_control_kgha[data$yield_measure=="Mg dry matter/ha" & !is.na(data$pr_yield_control_kgha)]*1000000000

# and then the treatment values
data$pr_yield_treatm_kgha[data$yield_measure=="Mg/ha" & !is.na(data$pr_yield_treatm_kgha)] <- 
  data$pr_yield_treatm_kgha[data$yield_measure=="Mg/ha" & !is.na(data$pr_yield_treatm_kgha)]*1000000000
data$pr_yield_treatm_kgha[data$yield_measure=="Mg dry matter/ha" & !is.na(data$pr_yield_treatm_kgha)] <- 
  data$pr_yield_treatm_kgha[data$yield_measure=="Mg dry matter/ha" & !is.na(data$pr_yield_treatm_kgha)]*1000000000

# (iii) get rid of data that has no land-cover information (we might need to fix this and get this data, 
# but for now, we just remove it)
data<-data[-which(is.na(data$buffer_radius_m)), ]

##### (B) Change the format ##########
# create the longer data format
data.mod<- pivot_wider(data, names_from = class, values_from = c(30:33))

# second step here - we have still three 
data.mod.2<- pivot_wider(data.mod, names_from = buffer_radius_m, values_from = c(28:ncol(data.mod)))

##### (c) Handle missing data in the control column ##########
# the issue is that some of the meta-analyses that we use have already averaged within study, others do provide the raw data
# For consistency, we decided that we should also average for those that provide raw data.
data.mod.2$Lat_long<- paste0(data.mod.2$pr_Latitude, data.mod.2$pr_Longitude)

# additional check
means.check<-aggregate(list(data.mod.2$pr_yield_control_kgha, data.mod.2$pr_yield_treatm_kgha, data.mod.2$No.),
                 by = list(data.mod.2$pr_land_cover_Year , data.mod.2$Lat_long, data.mod.2$pr_Treatment,
                           data.mod.2$pr_Croptype,  data.mod.2$Source),   function(x){mean(x, na.rm = T)})
colnames(means.check)<-c('pr_land_cover_Year','Lat_long', 'pr_Treatment', 'pr_Croptype', 'Source_A','pr_yield_control_kgha',
                   'pr_yield_treatm_kgha', 'No.')
means.check.2<-aggregate(list(means.check$pr_yield_control_kgha, means.check$pr_yield_treatm_kgha, means.check$No.),
                 by = list(means.check$pr_land_cover_Year , means.check$Lat_long, means.check$pr_Treatment,
                           means.check$pr_Croptype),   function(x){sd(x,  na.rm = T)})
# PROBLEM: there are multiple entries, which share location, year, treatment and croptype, but they do have not the same
# yield values

# for now, we just deal with the issue by maintaining them
means<-aggregate(list(data.mod.2$pr_yield_control_kgha, data.mod.2$pr_yield_treatm_kgha, data.mod.2$No.),
                 by = list(data.mod.2$pr_land_cover_Year , data.mod.2$Lat_long, data.mod.2$pr_Treatment,
                           data.mod.2$pr_Croptype,  data.mod.2$Source),   function(x){mean(x, na.rm = T)})
colnames(means)<-c('pr_land_cover_Year','Lat_long', 'pr_Treatment', 'pr_Croptype', 'Source_A','pr_yield_control_kgha',
                   'pr_yield_treatm_kgha', 'No.')

# get SDs and sample number
sds<-aggregate(list(data.mod.2$pr_yield_control_kgha, data.mod.2$pr_yield_treatm_kgha), 
                 by = list(data.mod.2$pr_land_cover_Year , data.mod.2$Lat_long, data.mod.2$pr_Treatment, 
                           data.mod.2$pr_Croptype,  data.mod.2$Source),
                 function(x){sd(x, na.rm = T)})
means$pr_yield_control_kgha_sd<-sds[,6]; means$pr_yield_treatm_kgha_sd<-sds[,7]

n<-aggregate(list(data.mod.2$pr_yield_control_kgha, data.mod.2$pr_yield_treatm_kgha,  data.mod.2$No.), 
               by = list(data.mod.2$pr_land_cover_Year , data.mod.2$Lat_long, data.mod.2$pr_Treatment, 
                         data.mod.2$pr_Croptype, data.mod.2$Source),
               function(x){length(x[which(is.na(x)==F)])})
means$pr_yield_control_kgha_n<-n[,6]; means$pr_yield_treatm_kgha_n<-n[,7]

rm(sds, n, x, check)

# now pull in the remaining data variables
# it should be that we can pull in things that have the same latidude-longitude combination and the same land-cover map-year

# diagnostic check: no the assumption above is not true - but that is already addressed in PROBLEM above...
means.check<-cbind(means, data.mod.2[match(paste0(means$Lat_long, means$pr_land_cover_Year, means$pr_Treatment, 
                                            means$pr_Croptype), 
                                     paste0(data.mod.2$Lat_long, data.mod.2$pr_land_cover_Year, data.mod.2$pr_Treatment,
                                            data.mod.2$pr_Croptype)), 
                               c(2:7,13,18,20,21,27:ncol(data.mod.2))])

check<-data.frame(means.check$Source, means.check$Source_A)
which((check$means.check.Source == check$means.check.Source_A)==F)
# here you can identify where the problem occurs...

rm(check, means.check, means.check.2)

means<-cbind(means, data.mod.2[match(paste0(means$Lat_long, means$pr_land_cover_Year, means$pr_Treatment, 
                                            means$pr_Croptype,  means$Source), 
                                     paste0(data.mod.2$Lat_long, data.mod.2$pr_land_cover_Year, data.mod.2$pr_Treatment,
                                            data.mod.2$pr_Croptype,  data.mod.2$Source)), 
                               c(2:7,13,18,20,21,27:ncol(data.mod.2))])

# compute the log-response ratio
means$logrr.yi <- log10(means$pr_yield_treatm_kgha/means$pr_yield_control_kgha)

# remove NANs in the data set (the data that had no treatment yield data...)
means<-means[-which(is.nan(means$pr_yield_treatm_kgha)),]

##### (III) Prepare predictors ##########
reg.data<-means[,c(1,3,4, 6:7,9:16, 19:22)]
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
nat.hab.col.names<-c(paste0('proportion_',nat.hab.class.code,'_2000'))
reg.data$nat.hab.2000<-rowSums(means[,which(is.element(col.names,nat.hab.col.names))], na.rm = T)

nat.hab.col.names<-c(paste0('proportion_',nat.hab.class.code,'_5000'))
reg.data$nat.hab.5000<-rowSums(means[,which(is.element(col.names,nat.hab.col.names))], na.rm = T)
# not that there is still this coding mistake and the radii data are still identical...

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
nat.hab.col.names<-c(paste0('proportion_',nat.hab.class.code,'_2000'))
reg.data$nat.hab.wo.grass.2000<-rowSums(means[,which(is.element(col.names,nat.hab.col.names))], na.rm = T)

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
names<-c(paste0('proportion_',cropland.class.code,'_2000'))
reg.data$cropland.2000<-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

names<-c(paste0('proportion_',cropland.class.code,'_5000'))
reg.data$cropland.5000<-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

##### (D) create the cropland area vs perimeter data #####

# (i) create the column names
names<-c(paste0('areaM2_',cropland.class.code,'_1000'))
names.per<-c(paste0('edgelength_m_',cropland.class.code,'_1000'))

# (ii) create the variable
reg.data$crop.peri.area.ratio.1000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T) /
  rowSums(means[,which(is.element(col.names,names))], na.rm = T)*10000 # unit: m/ha

colnames(means)[which(is.element(col.names,names.per))]
colnames(means)[which(is.element(col.names,names))]

# some diagnostic check - can that be, that the values are so low?
check<-data$edgelength_m[is.element(data$class, cropland.class.code)]/
  data$areaM2[is.element(data$class, cropland.class.code)]*10000

summary(check)
summary(reg.data$crop.peri.area.ratio.1000)

# okay, we have a difference in median edge length per ha. but that difference seems rather low
# potential PROBLEM - quite low value, but maybe still realistic?

# check whether the proportion data matches with the area data 
plot(means$areaM2_72_1000 , means$proportion_72_1000)
# yes - it does, good!

# (iii) repeat that for the 2 and 5km radii
names<-c(paste0('areaM2_',cropland.class.code,'_2000'))
names.per<-c(paste0('edgelength_m_',cropland.class.code,'_2000'))
reg.data$crop.peri.area.ratio.2000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T) /
  rowSums(means[,which(is.element(col.names,names))], na.rm = T)*10000 # unit: m/ha

names<-c(paste0('areaM2_',cropland.class.code,'_5000'))
names.per<-c(paste0('edgelength_m_',cropland.class.code,'_5000'))
reg.data$crop.peri.area.ratio.5000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T) /
  rowSums(means[,which(is.element(col.names,names))], na.rm = T)*10000 # unit: m/ha

##### (E) create the agricultural edge-length #####
names.per<-c(paste0('edgelength_m_',cropland.class.code,'_1000'))
reg.data$crop.edgelength.1000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T) 

names.per<-c(paste0('edgelength_m_',cropland.class.code,'_2000'))
reg.data$crop.edgelength.2000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T) 

names.per<-c(paste0('edgelength_m_',cropland.class.code,'_5000'))
reg.data$crop.edgelength.5000 <-rowSums(means[,which(is.element(col.names,names.per))], na.rm = T)

##### (F) create the inert land-cover #####
# (i) get the classes which need to be included and create their col-names
inert.land.class.code<-landcover.meta$Class.Code[-which(
  landcover.meta$Bigger.CLass=='Bare Surfaces'| 
  landcover.meta$Class.Description.by.ESA=='Permanent ice and snow')]
names<-c(paste0('proportion_',inert.land.class.code,'_1000'))

# (ii) create the data for the 1km radius - here we also have urban areas and other built environments, which are
# not included in our land-cover classes, so we have to use the not inert area and substract it from 1 to get the 
# right value.
reg.data$inert.1000<- 1-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

# (iii) repeat that for the 2 and 5km radii
names<-c(paste0('proportion_',inert.land.class.code,'_2000'))
reg.data$inert.2000<- 1-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

names<-c(paste0('proportion_',inert.land.class.code,'_5000'))
reg.data$inert.5000<- 1-rowSums(means[,which(is.element(col.names,names))], na.rm = T)

# PROBLEM: there is something wrong with this one data point here - it should not be allowed to be negative...
which(reg.data$inert.1000<0)
reg.data$nat.hab.1000[which(reg.data$inert.1000<0)]
reg.data$cropland.1000[which(reg.data$inert.1000<0)] # hmm the agricultural proportion is very high...

#for now I can set that value to 0
reg.data$inert.1000[which(reg.data$inert.1000<0)]<-0

# once the radius stuff is fixed, one can have a look at these plots...
plot(reg.data$inert.1000, reg.data$inert.5000)
plot(reg.data$inert.2000, reg.data$inert.5000)


##### (H) create the shannon index #####
# (i) define the variables that need to be included
names<-c(paste0('areaM2_',inert.land.class.code,'_1000'))

# (ii) create the data frame for the analysis
shannon.df<-means[,which(is.element(col.names,names))]
shannon.df$inert<- reg.data$inert.1000

# (iii) replace NAs with 0s
for(i in 1:ncol(shannon.df)){shannon.df[which(is.na(shannon.df[,i])) , i]<-0}
  
# (iv) calculate the shannon diversity
library(vegan) # 'species' need to be the columns
reg.data$shannon.1000<-diversity(shannon.df, index = "shannon")

# (v) repeat for the other two radii
names<-c(paste0('areaM2_',inert.land.class.code,'_2000'))
shannon.df<-means[,which(is.element(col.names,names))]
shannon.df$inert<- reg.data$inert.2000
for(i in 1:ncol(shannon.df)){shannon.df[which(is.na(shannon.df[,i])) , i]<-0}
reg.data$shannon.2000<-diversity(shannon.df, index = "shannon")

names<-c(paste0('areaM2_',inert.land.class.code,'_5000'))
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

# here we have PROBLEMs: we have both - 0s in the cropland area but we have an edgelength above 0 and we have values 
# where the edgelength is 0 and the area is above 0 (the one results in NAs, the other creates INF values)
which(is.na(reg.data$crop.peri.area.ratio.1000))

# temporal fix: we set the NAs to 0 and the Inf to the max value
reg.data$crop.peri.area.ratio.1000[which(is.nan(reg.data$crop.peri.area.ratio.1000))]<-
  max(reg.data$crop.peri.area.ratio.1000,na.rm = T)

# clean up some objects that are not needed anymore
rm(nat.hab.col.names,nat.hab.class.code,cropland.class.code,names, names.per, inert.land.class.code, shannon.df)

# save the file
write.csv(reg.data, file = 'data/data_processed.csv',row.names = TRUE)

plot(reg.data$shannon.1000~reg.data$cropland.1000)
plot(reg.data$shannon.1000~reg.data$nat.hab.1000)
plot(reg.data$shannon.1000~reg.data$nat.hab.wo.grass.1000)

# check how many data points we have per study now...
summary(as.vector(table(reg.data$Source)))

