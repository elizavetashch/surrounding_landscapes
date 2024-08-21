dat <- read.csv("data/data_with_landscape_metrics.csv")
colnames(dat)

# drop out some dodgy yield values
dat <- droplevels(subset(dat,No.!=3018)) 
dat <- droplevels(subset(dat,No.!=3019))
dat <- droplevels(subset(dat,No.!=4632))
dat <- droplevels(subset(dat,No.!=4633)) 
dat <- droplevels(subset(dat,No.!=3118)) 
dat <- droplevels(subset(dat,No.!=3119))

# look at whether these yield values could be just a miscalculation
subset(dat,No.==3018)
subset(dat,No.==3019)
subset(dat,No.==3118) 

# some of the values were incorrectly converted to kg/ha, we should fix them
dat$pr_yield_control_kgha[dat$yield_measure=="Mg/ha" & !is.na(dat$pr_yield_control_kgha)] <- 
  dat$pr_yield_control_kgha[dat$yield_measure=="Mg/ha" & !is.na(dat$pr_yield_control_kgha)]*1000000000
dat$pr_yield_control_kgha[dat$yield_measure=="Mg dry matter/ha" & !is.na(dat$pr_yield_control_kgha)] <- 
  dat$pr_yield_control_kgha[dat$yield_measure=="Mg dry matter/ha" & !is.na(dat$pr_yield_control_kgha)]*1000000000

# take a look at yield per yield measure to check - yes this is now correct
with(dat,boxplot(pr_yield_control_kgha~yield_measure))

# do we need to do the same for treatment yield?
with(dat,boxplot(pr_yield_treatm_kgha~yield_measure)) # yes, this needs to be changed too

dat$pr_yield_treatm_kgha[dat$yield_measure=="Mg/ha" & !is.na(dat$pr_yield_treatm_kgha)] <- 
  dat$pr_yield_treatm_kgha[dat$yield_measure=="Mg/ha" & !is.na(dat$pr_yield_treatm_kgha)]*1000000000
dat$pr_yield_treatm_kgha[dat$yield_measure=="Mg dry matter/ha" & !is.na(dat$pr_yield_treatm_kgha)] <- 
  dat$pr_yield_treatm_kgha[dat$yield_measure=="Mg dry matter/ha" & !is.na(dat$pr_yield_treatm_kgha)]*1000000000

# check if fixed
with(dat,boxplot(pr_yield_treatm_kgha~yield_measure))

# look at distribution of control yields
with(dat[!is.na(dat$pr_yield_control_kgha),],plot(density(pr_yield_control_kgha))) 
# same for treatment yields
with(dat[!is.na(dat$pr_yield_treatm_kgha),],plot(density(pr_yield_treatm_kgha))) 

# we have some repeat measurements here for the different radii and land cover types
# for now just get the mean per "No." which should be a unique measure of yield (we can check that)
# Source is the primary paper, No. is a measure of yield
dat_ag <- with(dat, aggregate(pr_yield_control_kgha,by=list(pr_Croptype,pr_Treatment,No.,Source,DatasetID,pr_Latitude,pr_Longitude),mean,na.rm=FALSE))
colnames(dat_ag) <- c("pr_Croptype","pr_Treatment","No.","Source","DatasetID","pr_Latitude","pr_Longitude","pr_yield_control_kgha")

# copy across the pr_Treatment yields
dat_ag$pr_yield_treatm_kgha <- with(dat, aggregate(pr_yield_treatm_kgha,by=list(pr_Croptype,pr_Treatment,No.,Source,DatasetID,pr_Latitude,pr_Longitude),mean,na.rm=FALSE))[,8]

# do the same but for SD - these should have SD of zero if all the numbers aggregated are the same
dat_ag$pr_yield_control_sd <- with(dat, aggregate(pr_yield_control_kgha,by=list(pr_Croptype,pr_Treatment,No.,Source,DatasetID,pr_Latitude,pr_Longitude),sd,na.rm=FALSE))[,8]
dat_ag$pr_yield_treatm_sd <- with(dat, aggregate(pr_yield_treatm_kgha,by=list(pr_Croptype,pr_Treatment,No.,Source,DatasetID,pr_Latitude,pr_Longitude),sd,na.rm=FALSE))[,8]

head(dat_ag)
summary(dat_ag$pr_yield_control_sd)
summary(dat_ag$pr_yield_treatm_sd)
# yes these are correct, the SD is zero for all of these

# So now we have correct 

# Now we can use lat and long combination to match up control and pr_Treatment yield
dat_ag$latlong <- paste(dat_ag$pr_Latitude,dat_ag$pr_Longitude,sep=" ")

# now we should replace NA's with a value, matched by the variable latlong
# need to do that for each latlong
# first mark those that get replaced, so we can remove duplicates (if they get created(??))
dat_ag$missing_control <- is.na(dat_ag$pr_yield_control_kgha)
dat_ag$missing_Treatment <- is.na(dat_ag$pr_yield_treatm_kgha)

# now we paste across values that were missing pr_Treatment
dat_ag$pr_yield_control_kgha[is.na(dat_ag$pr_yield_control_kgha)] <- 
  dat_ag$pr_yield_treatm_kgha[is.na(dat_ag$pr_yield_control_kgha)]

# now we paste across to pr_Treatment rows that were missing control
dat_ag$pr_yield_treatm_kgha[is.na(dat_ag$pr_yield_treatm_kgha)] <- 
  dat_ag$pr_yield_control_kgha[is.na(dat_ag$pr_yield_treatm_kgha)]

# if there were duplicates, how would we now identify them?
# this would be values sharing the same latlong and control/pr_Treatment lnrr
dat_ag$lnrr.yi <- log(dat_ag$pr_yield_treatm_kgha/dat_ag$pr_yield_control_kgha)

# remove duplicated lnrr.yi values in the same latlong combination
dat_ag$checkdup <- paste(dat_ag$latlong,dat_ag$lnrr.yi,sep=" ")
dat_ag <- dat_ag %>% distinct(checkdup, .keep_all = TRUE)

with(dat_ag, boxplot(lnrr.yi~pr_Treatment))
abline(h=0)

with(dat_ag, boxplot(lnrr.yi~pr_Croptype))
abline(h=0)

summary(dat_ag$lnrr.yi) # we still have 110 NA values

with(dat_ag, plot(lnrr.yi~pr_Latitude))
abline(h=0)

with(dat_ag, plot(lnrr.yi~pr_Longitude))
abline(h=0)

with(dat_ag, boxplot(pr_Latitude~pr_Treatment))
levels(factor(dat_ag$pr_Treatment))

colnames(dat_ag)

levels(factor(dat_ag$pr_Croptype))
length(subset(dat_ag, pr_Croptype=="Greenhouse_vegetable")) # only 16 datapoints

# what if we aggreate to lose these "No." values, so we get closer to only one yield control comparison per latlong
dat_ag2 <- with(dat_ag, aggregate(pr_yield_control_kgha,by=list(pr_Croptype,pr_Treatment,Source,DatasetID,pr_Latitude,pr_Longitude),mean,na.rm=FALSE))
colnames(dat_ag2) <- c("pr_Croptype","pr_Treatment","Source","DatasetID","pr_Latitude","pr_Longitude","pr_yield_control_kgha")

# separately, we can calculate land cover info and pull it across (only started...)
land_ag <- with(dat, aggregate(shannons,by=list(pr_Croptype,pr_Treatment,No.,Source,DatasetID,pr_Latitude,pr_Longitude),mean,na.rm=FALSE))


# some notes about the papers
# Ding et al 2018 - they tested 5 different "alternative fertilization options" in comparison to conventional fertilization
