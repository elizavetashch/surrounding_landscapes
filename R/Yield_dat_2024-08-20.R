library(tidyr)

data <- read.csv('data/data_with_landscape_metrics.csv', sep = ',', dec = '.') 
# variable description: DatasetID -> meta-data study

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

#hmmm - the issue is that for several unique data entries (i.e. unique treatment yield meassures), there are multiple times
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

# there is a major issue here - if you check the output, you will see that all the different land-cover data for the different
# radii of the sam unique yield measurement are identical - something went wrong!! 

####### (c) check for missing landscape data #######
x<-data[which(is.na(data$buffer_radius_m)), ]
# why are these data missing - here we have a lat and long?? And a land cover map (seemingly, as we have the year), but no land-cover
# data

# also, we have some places, where we have no 2 and 5km radii, but Elina says that is okay, because those places were close to the
# ocean and hence were not considered
table(data.mod$buffer_radius_m)

# I am not sure that this is the best approach - maybe it is better to still calculate 2 and 5km radii and then exclude water from 
# landcover indicies...?? Otherwise we would loose these data.

####### (D) check the latitude data #######
summary(data$pr_Latitude)
# wow! Why do we have latitude more than 90 degrees???

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

# get means
means<-aggregate(list(data.mod.2$pr_yield_control_kgha, data.mod.2$pr_yield_treatm_kgha, data.mod.2$No.), 
                 by = list(data.mod.2$pr_land_cover_Year , data.mod.2$Lat_long, data.mod.2$Treatment, data.mod.2$Croptype,  
                           data.mod.2$Source),
                 function(x){mean(x, na.rm = T)})
colnames(means)<-c('pr_land_cover_Year','Lat_long', 'Treatment', 'Croptype', 'Source', 'pr_yield_control_kgha',
                   'pr_yield_treatm_kgha', 'No.')

# get SDs and sample number
sds<-aggregate(list(data.mod.2$pr_yield_control_kgha, data.mod.2$pr_yield_treatm_kgha), 
                 by = list(data.mod.2$pr_land_cover_Year , data.mod.2$Lat_long, data.mod.2$Treatment, data.mod.2$Croptype,  
                           data.mod.2$Source),
                 function(x){sd(x, na.rm = T)})
means$pr_yield_control_kgha_sd<-sds[,6]; means$pr_yield_treatm_kgha_sd<-sds[,7]

n<-aggregate(list(data.mod.2$pr_yield_control_kgha, data.mod.2$pr_yield_treatm_kgha,  data.mod.2$No.), 
               by = list(data.mod.2$pr_land_cover_Year , data.mod.2$Lat_long, data.mod.2$Treatment, data.mod.2$Croptype,  
                         data.mod.2$Source),
               function(x){length(x[which(is.na(x)==F)])})
means$pr_yield_control_kgha_n<-n[,6]; means$pr_yield_treatm_kgha_n<-n[,7]

rm(sds, n)

# now pull in the remaining data variables
# it should be that we can pull in things that have the same latidude-longitude combination and the same land-cover map-year


means<-cbind(means, data.mod.2[match(paste0(means$Lat_long, means$pr_land_cover_Year), 
                                     paste0(data.mod.2$Lat_long, data.mod.2$pr_land_cover_Year)), 
                               c(3:7,13,18,20,21,27:ncol(data.mod.2))])
# compute the log-response ratio
means$logrr.yi <- log10(means$pr_yield_treatm_kgha/means$pr_yield_control_kgha)

# remove NANs
means<-means[-which(is.nan(means$pr_yield_treatm_kgha)),]


