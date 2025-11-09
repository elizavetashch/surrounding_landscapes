## Beyond the Field: Decoding the multi-level impact of surrounding landscapes on crop yields

```
documentation: Elizaveta Shcherbinina 
last update: 07.11.2025
current data: 20251107_data.csv 
```

**Documentation**
> [!NOTE]
> Variables which were not calculated but taken over from the corresponsing studies have a suffix `.orig`
> If a variable was averaged over a buffer, the radius of the buffer will stand as suffix at the end of teh variable's name `.1000`, `.2500`, `.5000`


Current version of the dataset containts the following: 

- [Metadata on each observaiton](#metadata-on-each-observation)
- [Land cover metrics](#land-cover-metrics)
- [Mycorrhiza data](#mycorrhiza-data)
- [Field size data](#field-size-data)
- [Soil data](#soil-data)
- [Mixed (pollination, species richness, temperature and precipitation)](#mixed-calculated-variables)

*(Press on the link to land to the corresponsing subsection)*


### metadata on each observation 

```
[1] "measurement.id"                         "ma.id"                                 
[3] "study.id"                               "control.id"                            
[5] "title"                                  "reference"                             
[7] "author.year"                            "study.pubyear"                         
[9] "harvest.year"                           "publication.to.harvest.year.difference"
[11] "harvest.year.by.median"                 "landcover.map.year"                    
[13] "lat.long"                               "latitude.decimal"                      
[15] "longitude.decimal"                      "country.new"                           
[17] "region.orig"                            "country.orig"                          
[19] "treatment"                              "crop.type.orig"                        
[21] "crop.type.orig.grouped.small"           "crop.type.orig.grouped.big"            
[23] "yield.unit"                             "mean.yield.control.kgha"               
[25] "mean.yield.treatment.kgha"              "yield.sd.control"                      
[27] "yield.sd.treatment"                     "replicates.control.summed"             
[29] "replicates.treatment.summed"            "n.aggregated"                          
[31] "soil.type.orig"                         "temperature.orig"                      
[33] "precipitation.orig"                     "climate.zone.orig"                     
[35] "lrr"                                    "lrr.vi"
```

> [!IMPORTANT]
> **NA values in the metadata**
> 
> 1.  big NA column is the harvest.year and publication.to.harvest.year.difference, indicating no information provided on year of harvest by the original study.
> 
> 2.  some NA in original country and region, indicating no information provided by the original study.
> 
> 3. NA in yield.sd.control and yield.sd.treatment, indicating no information provided on yield SD by the original study.
>
> 4. NA in temperature.orig and precipitation.orig, indicating no information provided by the original study.
> 
> 5. NA in lrr.vi


![NA's within the metadata variabes](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/05_Results/supporting_images/meta_na.png)

### land cover metrics
```
 [1] "nat.hab.1000"                          "nat.hab.2500"                         
 [3] "nat.hab.5000"                          "nat.hab.edgelength.1000"              
 [5] "nat.hab.edgelength.2500"               "nat.hab.edgelength.5000"              
 [7] "nat.hab.peri.area.ratio.1000"          "nat.hab.peri.area.ratio.2500"         
 [9] "nat.hab.peri.area.ratio.5000"          "nat.hab.wo.grass.1000"                
[11] "nat.hab.wo.grass.2500"                 "nat.hab.wo.grass.5000"                
[13] "nat.hab.wo.grass.edgelength.1000"      "nat.hab.wo.grass.edgelength.2500"     
[15] "nat.hab.wo.grass.edgelength.5000"      "nat.hab.wo.grass.peri.area.ratio.1000"
[17] "nat.hab.wo.grass.peri.area.ratio.2500" "nat.hab.wo.grass.peri.area.ratio.5000"
[19] "cropland.1000"                         "cropland.2500"                        
[21] "cropland.5000"                         "crop.peri.area.ratio.1000"            
[23] "crop.peri.area.ratio.2500"             "crop.peri.area.ratio.5000"            
[25] "crop.edgelength.1000"                  "crop.edgelength.2500"                 
[27] "crop.edgelength.5000"                  "inert.1000"                           
[29] "inert.2500"                            "inert.5000"                           
[31] "inert.edgelength.1000"                 "inert.edgelength.2500"                
[33] "inert.edgelength.5000"                 "inert.peri.area.ratio.1000"           
[35] "inert.peri.area.ratio.2500"            "inert.peri.area.ratio.5000"           
[37] "shannon.1000"                          "shannon.2500"                         
[39] "shannon.5000"                          "simpsonsevenness.1000"                
[41] "simpsonsevenness.2500"                 "simpsonsevenness.5000"              
```
![NA's within the mixed variabes](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/05_Results/supporting_images/nathab_na.png)

### mycorrhiza data

The mycorrhiza data was downloaded from the [Society for Protection of Underground Networks website](https://www.spun.earth/underground-atlas/mycorrhizal-biodiversity) and is based on the original publication by [Van Nuland et al. 2025](https://www.nature.com/articles/s41586-025-09277-4). 

:card_file_box: The column names are structured the following way: `mycorrhiza type`.`richness`.`statistical variable`.`buffer size`

- **mycorrhiza type**: am for arbuscular mycorrhiza, ecm for ectomycorrhiza
- **richness** indicates the metric that we exported from the SPUN project, namely the species richness in (species / 100 m2)
- **statistical variable**
  - centre: indicates the value that is located directly in the centre of the buffer (a value of one pixel right in the center of the buffer)
  - stddev: indicates the standard deviation of the species richness values within the buffer
  - variance: indicates the variance of the species richness values within the buffer
```
 [1] "am.richness.centre.1000"    "am.richness.centre.2500"    "am.richness.centre.5000"   
 [4] "am.richness.mean.1000"      "am.richness.mean.2500"      "am.richness.mean.5000"     
 [7] "am.richness.stddev.1000"    "am.richness.stddev.2500"    "am.richness.stddev.5000"   
[10] "am.richness.variance.1000"  "am.richness.variance.2500"  "am.richness.variance.5000" 
[13] "ecm.richness.centre.1000"   "ecm.richness.centre.2500"   "ecm.richness.centre.5000"  
[16] "ecm.richness.mean.1000"     "ecm.richness.mean.2500"     "ecm.richness.mean.5000"    
[19] "ecm.richness.stddev.1000"   "ecm.richness.stddev.2500"   "ecm.richness.stddev.5000"  
[22] "ecm.richness.variance.1000" "ecm.richness.variance.2500" "ecm.richness.variance.5000"

```

> [!IMPORTANT]
> **NA values in the mycorrhiza data**
> 
> 1.  NA repeating in equal intervals indicate the `.centre` variables in the data. Variables extracted from the centre have overall higher inaccuracy. 
> 
> 2. 30 points have NA almost in every column and those measurements come from city areas (28 observations) or land on sea (2 measurements)

![NA's within the mixed variabes](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/05_Results/supporting_images/mycorrhiza_na.png)

### field size data
```
 [1] "fieldsize.centre"      "nofield.area.m.5000"   "nofield.area.m.2500"  
 [4] "nofield.area.m.1000"   "small.area.m.5000"     "small.area.m.2500"    
 [7] "small.area.m.1000"     "verysmall.area.m.5000" "verysmall.area.m.2500"
[10] "verysmall.area.m.1000" "large.area.m.5000"     "large.area.m.2500"    
[13] "large.area.m.1000"     "verylarge.area.m.5000" "verylarge.area.m.2500"
[16] "verylarge.area.m.1000" "medium.area.m.5000"    "medium.area.m.2500"   
[19] "medium.area.m.1000" 
```

![NA's within the mixed variabes](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/05_Results/supporting_images/fieldsize_na.png)

### soil data

The soil variables were imported from the SoilGrids map 
- SoilGrids map: https://soilgrids.org/
- GEE code for value extraction: [https://code.earthengine.google.com/](https://code.earthengine.google.com/c20d523a9033e4f73df9d779df823134)

:card_file_box: The column names are structured the following way: `soil property`.`depth`.`statistical variable`.`buffer size`

- **soil property**:
  - bulk: Bulk density of the fine earth fraction (cg/cm³)
  - cec: Cation Exchange Capacity buffered at pH 7 (mmol©/kg)
  - clay:  Proportion of clay particles (< 0.002 mm) in the fine earth fraction (g/kg)
  - nitrogen: Total nitrogen (N) (cg/kg)
  - ocd: Organic carbon density (hg/dm³)
  - ocs: Organic carbon stocks (t/ha)
  - ph: Soil pH (pHx10)
  - sand:  Proportion of sand particles (> 0.05 mm) in the fine earth fraction (g/kg)
  - silt: Proportion of silt particles (≥ 0.002 mm and ≤ 0.05 mm) in the fine earth fraction (g/kg)
  - soc: Soil organic carbon content in the fine earth fraction (dg/kg)
- **depth** : is structured as A.B.cm , meaning from the depth A to the depth B in cm. (Example 0.5.cm indicates the soil layer from 0 to 5 cm depth) 
- **statistical variable**
  - centre: indicates the value that is located directly in the centre of the buffer (a value of one pixel right in the center of the buffer)
  - stddev: indicates the standard deviation of the species richness values within the buffer
  - variance: indicates the variance of the species richness values within the buffer

**Soil Texture**
Soil texture was calculated separately based either on the mean values of clay/silt/sand content in the 1000 m buffer (soiltexture.1000), and an additional soil texture variable was calcuated based on the centre value of the clay/silt/sand content.

> [!WARNING]
> Please note, that the soiltexture calculated based on the centre value has 264 NA value, while soil texture variable based on mean contents only 30 NAs. 

Here you can see the difference in those two ways of soil texture calculation within the soil triangle. 


soiltexture.centre            |  soiltexture.1000
:-------------------------:|:-------------------------:
![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/05_Results/supporting_images/solitexture_centre.png) |  ![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/05_Results/supporting_images/soiltexture_mean.png)

```
  [1] "bulk.0.5cm.centre.1000"           "bulk.0.5cm.centre.2500"           "bulk.0.5cm.centre.5000"          
  [4] "bulk.0.5cm.stddev.1000"           "bulk.0.5cm.stddev.2500"           "bulk.0.5cm.stddev.5000"          
  [7] "bulk.0.5cm.variance.1000"         "bulk.0.5cm.variance.2500"         "bulk.0.5cm.variance.5000"        
 [10] "bulk.100.200cm.centre.1000"       "bulk.100.200cm.centre.2500"       "bulk.100.200cm.centre.5000"      
 [13] "bulk.100.200cm.stddev.1000"       "bulk.100.200cm.stddev.2500"       "bulk.100.200cm.stddev.5000"      
 [16] "bulk.100.200cm.variance.1000"     "bulk.100.200cm.variance.2500"     "bulk.100.200cm.variance.5000"    
 [19] "bulk.15.30cm.centre.1000"         "bulk.15.30cm.centre.2500"         "bulk.15.30cm.centre.5000"        
 [22] "bulk.15.30cm.stddev.1000"         "bulk.15.30cm.stddev.2500"         "bulk.15.30cm.stddev.5000"        
 [25] "bulk.15.30cm.variance.1000"       "bulk.15.30cm.variance.2500"       "bulk.15.30cm.variance.5000"      
 [28] "bulk.30.60cm.centre.1000"         "bulk.30.60cm.centre.2500"         "bulk.30.60cm.centre.5000"        
 [31] "bulk.30.60cm.stddev.1000"         "bulk.30.60cm.stddev.2500"         "bulk.30.60cm.stddev.5000"        
 [34] "bulk.30.60cm.variance.1000"       "bulk.30.60cm.variance.2500"       "bulk.30.60cm.variance.5000"      
 [37] "bulk.5.15cm.centre.1000"          "bulk.5.15cm.centre.2500"          "bulk.5.15cm.centre.5000"         
 [40] "bulk.5.15cm.stddev.1000"          "bulk.5.15cm.stddev.2500"          "bulk.5.15cm.stddev.5000"         
 [43] "bulk.5.15cm.variance.1000"        "bulk.5.15cm.variance.2500"        "bulk.5.15cm.variance.5000"       
 [46] "bulk.60.100cm.centre.1000"        "bulk.60.100cm.centre.2500"        "bulk.60.100cm.centre.5000"       
 [49] "bulk.60.100cm.stddev.1000"        "bulk.60.100cm.stddev.2500"        "bulk.60.100cm.stddev.5000"       
 [52] "bulk.60.100cm.variance.1000"      "bulk.60.100cm.variance.2500"      "bulk.60.100cm.variance.5000"     
 [55] "cec.0.5cm.centre.1000"            "cec.0.5cm.centre.2500"            "cec.0.5cm.centre.5000"           
 [58] "cec.0.5cm.stddev.1000"            "cec.0.5cm.stddev.2500"            "cec.0.5cm.stddev.5000"           
 [61] "cec.0.5cm.variance.1000"          "cec.0.5cm.variance.2500"          "cec.0.5cm.variance.5000"         
 [64] "cec.100.200cm.centre.1000"        "cec.100.200cm.centre.2500"        "cec.100.200cm.centre.5000"       
 [67] "cec.100.200cm.stddev.1000"        "cec.100.200cm.stddev.2500"        "cec.100.200cm.stddev.5000"       
 [70] "cec.100.200cm.variance.1000"      "cec.100.200cm.variance.2500"      "cec.100.200cm.variance.5000"     
 [73] "cec.15.30cm.centre.1000"          "cec.15.30cm.centre.2500"          "cec.15.30cm.centre.5000"         
 [76] "cec.15.30cm.stddev.1000"          "cec.15.30cm.stddev.2500"          "cec.15.30cm.stddev.5000"         
 [79] "cec.15.30cm.variance.1000"        "cec.15.30cm.variance.2500"        "cec.15.30cm.variance.5000"       
 [82] "cec.30.60cm.centre.1000"          "cec.30.60cm.centre.2500"          "cec.30.60cm.centre.5000"         
 [85] "cec.30.60cm.stddev.1000"          "cec.30.60cm.stddev.2500"          "cec.30.60cm.stddev.5000"         
 [88] "cec.30.60cm.variance.1000"        "cec.30.60cm.variance.2500"        "cec.30.60cm.variance.5000"       
 [91] "cec.5.15cm.centre.1000"           "cec.5.15cm.centre.2500"           "cec.5.15cm.centre.5000"          
 [94] "cec.5.15cm.stddev.1000"           "cec.5.15cm.stddev.2500"           "cec.5.15cm.stddev.5000"          
 [97] "cec.5.15cm.variance.1000"         "cec.5.15cm.variance.2500"         "cec.5.15cm.variance.5000"        
[100] "cec.60.100cm.centre.1000"         "cec.60.100cm.centre.2500"         "cec.60.100cm.centre.5000"        
[103] "cec.60.100cm.stddev.1000"         "cec.60.100cm.stddev.2500"         "cec.60.100cm.stddev.5000"        
[106] "cec.60.100cm.variance.1000"       "cec.60.100cm.variance.2500"       "cec.60.100cm.variance.5000"      
[109] "clay.0.5cm.centre.1000"           "clay.0.5cm.centre.2500"           "clay.0.5cm.centre.5000"          
[112] "clay.0.5cm.stddev.1000"           "clay.0.5cm.stddev.2500"           "clay.0.5cm.stddev.5000"          
[115] "clay.0.5cm.variance.1000"         "clay.0.5cm.variance.2500"         "clay.0.5cm.variance.5000"        
[118] "clay.100.200cm.centre.1000"       "clay.100.200cm.centre.2500"       "clay.100.200cm.centre.5000"      
[121] "clay.100.200cm.stddev.1000"       "clay.100.200cm.stddev.2500"       "clay.100.200cm.stddev.5000"      
[124] "clay.100.200cm.variance.1000"     "clay.100.200cm.variance.2500"     "clay.100.200cm.variance.5000"    
[127] "clay.15.30cm.centre.1000"         "clay.15.30cm.centre.2500"         "clay.15.30cm.centre.5000"        
[130] "clay.15.30cm.stddev.1000"         "clay.15.30cm.stddev.2500"         "clay.15.30cm.stddev.5000"        
[133] "clay.15.30cm.variance.1000"       "clay.15.30cm.variance.2500"       "clay.15.30cm.variance.5000"      
[136] "clay.30.60cm.centre.1000"         "clay.30.60cm.centre.2500"         "clay.30.60cm.centre.5000"        
[139] "clay.30.60cm.stddev.1000"         "clay.30.60cm.stddev.2500"         "clay.30.60cm.stddev.5000"        
[142] "clay.30.60cm.variance.1000"       "clay.30.60cm.variance.2500"       "clay.30.60cm.variance.5000"      
[145] "clay.5.15cm.centre.1000"          "clay.5.15cm.centre.2500"          "clay.5.15cm.centre.5000"         
[148] "clay.5.15cm.stddev.1000"          "clay.5.15cm.stddev.2500"          "clay.5.15cm.stddev.5000"         
[151] "clay.5.15cm.variance.1000"        "clay.5.15cm.variance.2500"        "clay.5.15cm.variance.5000"       
[154] "clay.60.100cm.centre.1000"        "clay.60.100cm.centre.2500"        "clay.60.100cm.centre.5000"       
[157] "clay.60.100cm.stddev.1000"        "clay.60.100cm.stddev.2500"        "clay.60.100cm.stddev.5000"       
[160] "clay.60.100cm.variance.1000"      "clay.60.100cm.variance.2500"      "clay.60.100cm.variance.5000"     
[163] "nitrogen.0.5cm.centre.1000"       "nitrogen.0.5cm.centre.2500"       "nitrogen.0.5cm.centre.5000"      
[166] "nitrogen.0.5cm.stddev.1000"       "nitrogen.0.5cm.stddev.2500"       "nitrogen.0.5cm.stddev.5000"      
[169] "nitrogen.0.5cm.variance.1000"     "nitrogen.0.5cm.variance.2500"     "nitrogen.0.5cm.variance.5000"    
[172] "nitrogen.100.200cm.centre.1000"   "nitrogen.100.200cm.centre.2500"   "nitrogen.100.200cm.centre.5000"  
[175] "nitrogen.100.200cm.stddev.1000"   "nitrogen.100.200cm.stddev.2500"   "nitrogen.100.200cm.stddev.5000"  
[178] "nitrogen.100.200cm.variance.1000" "nitrogen.100.200cm.variance.2500" "nitrogen.100.200cm.variance.5000"
[181] "nitrogen.15.30cm.centre.1000"     "nitrogen.15.30cm.centre.2500"     "nitrogen.15.30cm.centre.5000"    
[184] "nitrogen.15.30cm.stddev.1000"     "nitrogen.15.30cm.stddev.2500"     "nitrogen.15.30cm.stddev.5000"    
[187] "nitrogen.15.30cm.variance.1000"   "nitrogen.15.30cm.variance.2500"   "nitrogen.15.30cm.variance.5000"  
[190] "nitrogen.30.60cm.centre.1000"     "nitrogen.30.60cm.centre.2500"     "nitrogen.30.60cm.centre.5000"    
[193] "nitrogen.30.60cm.stddev.1000"     "nitrogen.30.60cm.stddev.2500"     "nitrogen.30.60cm.stddev.5000"    
[196] "nitrogen.30.60cm.variance.1000"   "nitrogen.30.60cm.variance.2500"   "nitrogen.30.60cm.variance.5000"  
[199] "nitrogen.5.15cm.centre.1000"      "nitrogen.5.15cm.centre.2500"      "nitrogen.5.15cm.centre.5000"     
[202] "nitrogen.5.15cm.stddev.1000"      "nitrogen.5.15cm.stddev.2500"      "nitrogen.5.15cm.stddev.5000"     
[205] "nitrogen.5.15cm.variance.1000"    "nitrogen.5.15cm.variance.2500"    "nitrogen.5.15cm.variance.5000"   
[208] "nitrogen.60.100cm.centre.1000"    "nitrogen.60.100cm.centre.2500"    "nitrogen.60.100cm.centre.5000"   
[211] "nitrogen.60.100cm.stddev.1000"    "nitrogen.60.100cm.stddev.2500"    "nitrogen.60.100cm.stddev.5000"   
[214] "nitrogen.60.100cm.variance.1000"  "nitrogen.60.100cm.variance.2500"  "nitrogen.60.100cm.variance.5000" 
[217] "ocd.0.5cm.centre.1000"            "ocd.0.5cm.centre.2500"            "ocd.0.5cm.centre.5000"           
[220] "ocd.0.5cm.stddev.1000"            "ocd.0.5cm.stddev.2500"            "ocd.0.5cm.stddev.5000"           
[223] "ocd.0.5cm.variance.1000"          "ocd.0.5cm.variance.2500"          "ocd.0.5cm.variance.5000"         
[226] "ocd.100.200cm.centre.1000"        "ocd.100.200cm.centre.2500"        "ocd.100.200cm.centre.5000"       
[229] "ocd.100.200cm.stddev.1000"        "ocd.100.200cm.stddev.2500"        "ocd.100.200cm.stddev.5000"       
[232] "ocd.100.200cm.variance.1000"      "ocd.100.200cm.variance.2500"      "ocd.100.200cm.variance.5000"     
[235] "ocd.15.30cm.centre.1000"          "ocd.15.30cm.centre.2500"          "ocd.15.30cm.centre.5000"         
[238] "ocd.15.30cm.stddev.1000"          "ocd.15.30cm.stddev.2500"          "ocd.15.30cm.stddev.5000"         
[241] "ocd.15.30cm.variance.1000"        "ocd.15.30cm.variance.2500"        "ocd.15.30cm.variance.5000"       
[244] "ocd.30.60cm.centre.1000"          "ocd.30.60cm.centre.2500"          "ocd.30.60cm.centre.5000"         
[247] "ocd.30.60cm.stddev.1000"          "ocd.30.60cm.stddev.2500"          "ocd.30.60cm.stddev.5000"         
[250] "ocd.30.60cm.variance.1000"        "ocd.30.60cm.variance.2500"        "ocd.30.60cm.variance.5000"       
[253] "ocd.5.15cm.centre.1000"           "ocd.5.15cm.centre.2500"           "ocd.5.15cm.centre.5000"          
[256] "ocd.5.15cm.stddev.1000"           "ocd.5.15cm.stddev.2500"           "ocd.5.15cm.stddev.5000"          
[259] "ocd.5.15cm.variance.1000"         "ocd.5.15cm.variance.2500"         "ocd.5.15cm.variance.5000"        
[262] "ocd.60.100cm.centre.1000"         "ocd.60.100cm.centre.2500"         "ocd.60.100cm.centre.5000"        
[265] "ocd.60.100cm.stddev.1000"         "ocd.60.100cm.stddev.2500"         "ocd.60.100cm.stddev.5000"        
[268] "ocd.60.100cm.variance.1000"       "ocd.60.100cm.variance.2500"       "ocd.60.100cm.variance.5000"      
[271] "ocs.0.30cm.centre.1000"           "ocs.0.30cm.centre.2500"           "ocs.0.30cm.centre.5000"          
[274] "ocs.0.30cm.stddev.1000"           "ocs.0.30cm.stddev.2500"           "ocs.0.30cm.stddev.5000"          
[277] "ocs.0.30cm.variance.1000"         "ocs.0.30cm.variance.2500"         "ocs.0.30cm.variance.5000"        
[280] "ph.0.5cm.centre.1000"             "ph.0.5cm.centre.2500"             "ph.0.5cm.centre.5000"            
[283] "ph.0.5cm.stddev.1000"             "ph.0.5cm.stddev.2500"             "ph.0.5cm.stddev.5000"            
[286] "ph.0.5cm.variance.1000"           "ph.0.5cm.variance.2500"           "ph.0.5cm.variance.5000"          
[289] "ph.100.200cm.centre.1000"         "ph.100.200cm.centre.2500"         "ph.100.200cm.centre.5000"        
[292] "ph.100.200cm.stddev.1000"         "ph.100.200cm.stddev.2500"         "ph.100.200cm.stddev.5000"        
[295] "ph.100.200cm.variance.1000"       "ph.100.200cm.variance.2500"       "ph.100.200cm.variance.5000"      
[298] "ph.15.30cm.centre.1000"           "ph.15.30cm.centre.2500"           "ph.15.30cm.centre.5000"          
[301] "ph.15.30cm.stddev.1000"           "ph.15.30cm.stddev.2500"           "ph.15.30cm.stddev.5000"          
[304] "ph.15.30cm.variance.1000"         "ph.15.30cm.variance.2500"         "ph.15.30cm.variance.5000"        
[307] "ph.30.60cm.centre.1000"           "ph.30.60cm.centre.2500"           "ph.30.60cm.centre.5000"          
[310] "ph.30.60cm.stddev.1000"           "ph.30.60cm.stddev.2500"           "ph.30.60cm.stddev.5000"          
[313] "ph.30.60cm.variance.1000"         "ph.30.60cm.variance.2500"         "ph.30.60cm.variance.5000"        
[316] "ph.5.15cm.centre.1000"            "ph.5.15cm.centre.2500"            "ph.5.15cm.centre.5000"           
[319] "ph.5.15cm.stddev.1000"            "ph.5.15cm.stddev.2500"            "ph.5.15cm.stddev.5000"           
[322] "ph.5.15cm.variance.1000"          "ph.5.15cm.variance.2500"          "ph.5.15cm.variance.5000"         
[325] "ph.60.100cm.centre.1000"          "ph.60.100cm.centre.2500"          "ph.60.100cm.centre.5000"         
[328] "ph.60.100cm.stddev.1000"          "ph.60.100cm.stddev.2500"          "ph.60.100cm.stddev.5000"         
[331] "ph.60.100cm.variance.1000"        "ph.60.100cm.variance.2500"        "ph.60.100cm.variance.5000"       
[334] "sand.0.5cm.centre.1000"           "sand.0.5cm.centre.2500"           "sand.0.5cm.centre.5000"          
[337] "sand.0.5cm.stddev.1000"           "sand.0.5cm.stddev.2500"           "sand.0.5cm.stddev.5000"          
[340] "sand.0.5cm.variance.1000"         "sand.0.5cm.variance.2500"         "sand.0.5cm.variance.5000"        
[343] "sand.100.200cm.centre.1000"       "sand.100.200cm.centre.2500"       "sand.100.200cm.centre.5000"      
[346] "sand.100.200cm.stddev.1000"       "sand.100.200cm.stddev.2500"       "sand.100.200cm.stddev.5000"      
[349] "sand.100.200cm.variance.1000"     "sand.100.200cm.variance.2500"     "sand.100.200cm.variance.5000"    
[352] "sand.15.30cm.centre.1000"         "sand.15.30cm.centre.2500"         "sand.15.30cm.centre.5000"        
[355] "sand.15.30cm.stddev.1000"         "sand.15.30cm.stddev.2500"         "sand.15.30cm.stddev.5000"        
[358] "sand.15.30cm.variance.1000"       "sand.15.30cm.variance.2500"       "sand.15.30cm.variance.5000"      
[361] "sand.30.60cm.centre.1000"         "sand.30.60cm.centre.2500"         "sand.30.60cm.centre.5000"        
[364] "sand.30.60cm.stddev.1000"         "sand.30.60cm.stddev.2500"         "sand.30.60cm.stddev.5000"        
[367] "sand.30.60cm.variance.1000"       "sand.30.60cm.variance.2500"       "sand.30.60cm.variance.5000"      
[370] "sand.5.15cm.centre.1000"          "sand.5.15cm.centre.2500"          "sand.5.15cm.centre.5000"         
[373] "sand.5.15cm.stddev.1000"          "sand.5.15cm.stddev.2500"          "sand.5.15cm.stddev.5000"         
[376] "sand.5.15cm.variance.1000"        "sand.5.15cm.variance.2500"        "sand.5.15cm.variance.5000"       
[379] "sand.60.100cm.centre.1000"        "sand.60.100cm.centre.2500"        "sand.60.100cm.centre.5000"       
[382] "sand.60.100cm.stddev.1000"        "sand.60.100cm.stddev.2500"        "sand.60.100cm.stddev.5000"       
[385] "sand.60.100cm.variance.1000"      "sand.60.100cm.variance.2500"      "sand.60.100cm.variance.5000"     
[388] "silt.0.5cm.centre.1000"           "silt.0.5cm.centre.2500"           "silt.0.5cm.centre.5000"          
[391] "silt.0.5cm.stddev.1000"           "silt.0.5cm.stddev.2500"           "silt.0.5cm.stddev.5000"          
[394] "silt.0.5cm.variance.1000"         "silt.0.5cm.variance.2500"         "silt.0.5cm.variance.5000"        
[397] "silt.100.200cm.centre.1000"       "silt.100.200cm.centre.2500"       "silt.100.200cm.centre.5000"      
[400] "silt.100.200cm.stddev.1000"       "silt.100.200cm.stddev.2500"       "silt.100.200cm.stddev.5000"      
[403] "silt.100.200cm.variance.1000"     "silt.100.200cm.variance.2500"     "silt.100.200cm.variance.5000"    
[406] "silt.15.30cm.centre.1000"         "silt.15.30cm.centre.2500"         "silt.15.30cm.centre.5000"        
[409] "silt.15.30cm.stddev.1000"         "silt.15.30cm.stddev.2500"         "silt.15.30cm.stddev.5000"        
[412] "silt.15.30cm.variance.1000"       "silt.15.30cm.variance.2500"       "silt.15.30cm.variance.5000"      
[415] "silt.30.60cm.centre.1000"         "silt.30.60cm.centre.2500"         "silt.30.60cm.centre.5000"        
[418] "silt.30.60cm.stddev.1000"         "silt.30.60cm.stddev.2500"         "silt.30.60cm.stddev.5000"        
[421] "silt.30.60cm.variance.1000"       "silt.30.60cm.variance.2500"       "silt.30.60cm.variance.5000"      
[424] "silt.5.15cm.centre.1000"          "silt.5.15cm.centre.2500"          "silt.5.15cm.centre.5000"         
[427] "silt.5.15cm.stddev.1000"          "silt.5.15cm.stddev.2500"          "silt.5.15cm.stddev.5000"         
[430] "silt.5.15cm.variance.1000"        "silt.5.15cm.variance.2500"        "silt.5.15cm.variance.5000"       
[433] "silt.60.100cm.centre.1000"        "silt.60.100cm.centre.2500"        "silt.60.100cm.centre.5000"       
[436] "silt.60.100cm.stddev.1000"        "silt.60.100cm.stddev.2500"        "silt.60.100cm.stddev.5000"       
[439] "silt.60.100cm.variance.1000"      "silt.60.100cm.variance.2500"      "silt.60.100cm.variance.5000"     
[442] "soc.0.5cm.centre.1000"            "soc.0.5cm.centre.2500"            "soc.0.5cm.centre.5000"           
[445] "soc.0.5cm.stddev.1000"            "soc.0.5cm.stddev.2500"            "soc.0.5cm.stddev.5000"           
[448] "soc.0.5cm.variance.1000"          "soc.0.5cm.variance.2500"          "soc.0.5cm.variance.5000"         
[451] "soc.100.200cm.centre.1000"        "soc.100.200cm.centre.2500"        "soc.100.200cm.centre.5000"       
[454] "soc.100.200cm.stddev.1000"        "soc.100.200cm.stddev.2500"        "soc.100.200cm.stddev.5000"       
[457] "soc.100.200cm.variance.1000"      "soc.100.200cm.variance.2500"      "soc.100.200cm.variance.5000"     
[460] "soc.15.30cm.centre.1000"          "soc.15.30cm.centre.2500"          "soc.15.30cm.centre.5000"         
[463] "soc.15.30cm.stddev.1000"          "soc.15.30cm.stddev.2500"          "soc.15.30cm.stddev.5000"         
[466] "soc.15.30cm.variance.1000"        "soc.15.30cm.variance.2500"        "soc.15.30cm.variance.5000"       
[469] "soc.30.60cm.centre.1000"          "soc.30.60cm.centre.2500"          "soc.30.60cm.centre.5000"         
[472] "soc.30.60cm.stddev.1000"          "soc.30.60cm.stddev.2500"          "soc.30.60cm.stddev.5000"         
[475] "soc.30.60cm.variance.1000"        "soc.30.60cm.variance.2500"        "soc.30.60cm.variance.5000"       
[478] "soc.5.15cm.centre.1000"           "soc.5.15cm.centre.2500"           "soc.5.15cm.centre.5000"          
[481] "soc.5.15cm.stddev.1000"           "soc.5.15cm.stddev.2500"           "soc.5.15cm.stddev.5000"          
[484] "soc.5.15cm.variance.1000"         "soc.5.15cm.variance.2500"         "soc.5.15cm.variance.5000"        
[487] "soc.60.100cm.centre.1000"         "soc.60.100cm.centre.2500"         "soc.60.100cm.centre.5000"        
[490] "soc.60.100cm.stddev.1000"         "soc.60.100cm.stddev.2500"         "soc.60.100cm.stddev.5000"        
[493] "soc.60.100cm.variance.1000"       "soc.60.100cm.variance.2500"       "soc.60.100cm.variance.5000"      
             
```

Additionally calculated varibales such as soil texture. 

`sand/clay/silt`.percent.1000 indicates the percentage of sand/clay/silt in the 1000 buffer, calculated based on the mean values of those. 

```
[496] "sand.percent.1000"                "silt.percent.1000"                "clay.percent.1000"               
[499] "soiltexture.1000"                 "soiltexture.centre"          
```

> [!IMPORTANT]
> **NA values in the soil data**
> 
> 1.  NA repeating in equal intervals indicate the `.centre` variables in the data. Variables extracted from the centre have overall higher inaccuracy. 
> 
> 2. 30 points have NA almost in every column and those measurements come from city areas (28 observations) or land on sea (2 measurements)


![NA's within the mixed variabes](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/05_Results/supporting_images/soil_na.png)


### mixed calculated variables
```
[1] "sr"                 "temp.avg.1970.2000" "prec.avg.1970.2000" "poll.dependent"
```
Where 
1. "sr" stands for species richness added from the IUCN dataset,
2. temp_avg_1970.2000 is annual mean temperature was calculated in R,
3. prec_avg_1970.2000 is annual mean precipitation was calculated in R,
4. poll.dependant is pollinator dependance and was assigned 0 for no-pollinator-dependant crop and 1 for pollinator dependance.
![NA's within the mixed variabes](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/05_Results/supporting_images/species_na.png)


