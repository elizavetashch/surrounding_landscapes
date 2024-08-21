# 210824
# I am running this after running the Yield_dat_2024-08-20 script
# reading in the processed file

data <- read.csv('data/data_processed.csv', sep = ',', dec = '.')
colnames(data)


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
# nested random effects for land-use radius, source paper, and meta-analysis
lme.1 <- lmer(logrr.yi~shannons_5000+(1|DatasetID/Source/No.),data)


with(data, boxplot(logrr.yi~pr_Treatment))
abline(h=0)
