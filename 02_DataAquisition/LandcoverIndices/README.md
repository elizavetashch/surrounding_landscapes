

**Shannon's Index Calculation**

In the 20241213_data_processing.Rmd the following lines were used to calculate shannon's index : 

<details>
  <summary>Click here to see the code</summary>
```
## (H) create the shannon index

```{r IIIH create shannon index}
# (i) define the variables that need to be included
names<-c(paste0('area_m2_',noninert.land.class.code,'_1000')) 
# noninert.land.class.code - contains all non inert land-cover types - non built and non snow

# (ii) create the data frame for the analysis
shannon.df<-means[,which(is.element(col.names,names))]
shannon.df$inert<- reg.data$inert.1000

# (iii) replace NAs with 0s
for(i in 1:ncol(shannon.df)){shannon.df[which(is.na(shannon.df[,i])) , i]<-0}
  
# (iv) calculate the shannon diversity
library(vegan) # 'species' need to be the columns
reg.data$shannon.1000<-diversity(shannon.df, index = "shannon")

# (v) repeat for the other two radii
names<-c(paste0('area_m2_',noninert.land.class.code,'_2500'))
shannon.df<-means[,which(is.element(col.names,names))]
shannon.df$inert<- reg.data$inert.2500
for(i in 1:ncol(shannon.df)){shannon.df[which(is.na(shannon.df[,i])) , i]<-0}
reg.data$shannon.2500<-diversity(shannon.df, index = "shannon")

names<-c(paste0('area_m2_',noninert.land.class.code,'_5000'))
shannon.df<-means[,which(is.element(col.names,names))]
shannon.df$inert<- reg.data$inert.5000
for(i in 1:ncol(shannon.df)){shannon.df[which(is.na(shannon.df[,i])) , i]<-0}
reg.data$shannon.5000<-diversity(shannon.df, index = "shannon")

```
</details>

The `noninert.land.class.code` contains class codes  

```
10  11  12  20  51  52  61  62  71  72  81  82  91  92 120 121 122
130 140 150 152 153 181 182 183 184 185 186 187 210   0
```

These are all class codes without the Bare Surfaces and Permanent Ice Covers. 

The shannon's index calculation happens in this line: 

```
reg.data$shannon.1000<-diversity(shannon.df, index = "shannon")
```

where every class is used to calculate the final heterogeneity metric for the buffer. 

