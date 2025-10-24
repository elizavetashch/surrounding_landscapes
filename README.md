## Surrounding Landscapes Affect the Productivity of Crop Yields:
data organization and cleaning: Elizaveta Shcherbinina 
las update on 24.10.2025

## Description
description of the 20251006_df_soiltype_unscaled.csv file ([file link](surrounding_landscapes/tree/current_main/data/20251006_df_soiltype_unscaled.csv))

20251006_df_soiltype_unscaled was merged from 
- 20241216_data_processed.csv, 
- 20250812_soilvalues_1000m.csv, 
- 20250812_soilvalues_2500m.csv and 
- 20250812_soilvalues_5000m.csv
- 20250908_2_fieldsize_1000m.csv
- 20250908_2_fieldsize_2500m.csv
- 20250908_2_fieldsize_5000m.csv


## Statistics 
It has 1384 observations and 272 variables. Out of 272 varibales, 54 are soil variables. 38 observations have NA in soil variables, because there are no values available for the buffer region (often within a city area). 

The name of the soil variable is structured like `bdod_bdod_0.5cm_mean`. First goes the name of the variable (`bdod` for bulk density) and then the depth layer name (`bdod_0.5cm_mean` for the bulk density mean at the 0.5 cm depth).

## Data Repository 

### Original Variables 
from the 20241216_data_processed.csv file 

**For the summary statistics please unroll the following section** ⬇️
<details>
  <summary>Original variables table description</summary>

| Column Name                            | Data Type  | Example                              |
|----------------------------------------|------------|-------------------------------------|
| landcover_map_year                     | int        | 1985                                |
| treatment                              | chr        | "Cover crops"                       |
| Lat_long                               | chr        | "40.8-82"                           |
| crop_type                              | chr        | "Maize"                             |
| mean_yield_control_kgha                | num        | 10100                               |
| mean_yield_treatment_kgha              | num        | 9677                                |
| yield_SD_control                       | num        | NA                                  |
| yield_SD_treatment                     | num        | NA                                  |
| replicates_control_summed              | int        | 9                                   |
| replicates_treatment_summed            | int        | 9                                   |
| n_aggregated                           | int        | 3                                   |
| ma_id                                  | chr        | "D473"                              |
| measurement_id                         | int        | 1451                                |
| study_id                               | int        | 1                                   |
| control_id                             | int        | 1                                   |
| author_year                            | chr        | ""                                  |
| title                                  | chr        | ""                                  |
| study_pubyear                          | int        | 1991                                |
| harvest_year                           | int        | NA                                  |
| region                                 | chr        | ""                                  |
| country                                | chr        | "USA"                               |
| yield_unit                             | chr        | "Mg/ha"                             |
| soil_type                              | chr        | ""                                  |
| temperature                            | chr        | "9.5"                               |
| precipitation                          | chr        | "965"                               |
| climate_zone                           | chr        | "Cold"                              |
| LRR                                    | num        | NA                                  |
| LRR_vi                                 | num        | NA                                  |
| reference                              | chr        | ""                                  |
| longitude_decimal                      | num        | -82                                 |
| latitude_decimal                       | num        | 40.8                                |
| country_new                            | chr        | "United States of America"          |
| crop_type_grouped_small                | chr        | "Maize"                             |
| crop_type_grouped_big                  | chr        | "Grains"                            |
| publication_to_harvest_year_difference | int        | NA                                  |
| harvest_year_by_median                 | int        | 1984                                |
| nat.hab.1000                           | num        | 0.4319                              |
| nat.hab.2500                           | num        | 0.364                               |
| nat.hab.5000                           | num        | 0.413                               |
| nat.hab.edgelength.1000                | num        | 1525475                             |
| nat.hab.edgelength.2500                | num        | 6690469                             |
| nat.hab.edgelength.5000                | num        | 26643136                            |
| nat.hab.peri.area.ratio.1000           | num        | 1.136                               |
| nat.hab.peri.area.ratio.2500           | num        | 0.947                               |
| nat.hab.peri.area.ratio.5000           | num        | 0.83                                |
| nat.hab.wo.grass.1000                  | num        | 0.2779                              |
| nat.hab.wo.grass.2500                  | num        | 0.2396                              |
| nat.hab.wo.grass.5000                  | num        | 0.27138                             |
| nat.hab.wo.grass.edgelength.1000       | num        | 480264                              |
| nat.hab.wo.grass.edgelength.2500       | num        | 1568100                             |
| nat.hab.wo.grass.edgelength.5000       | num        | 6701681                             |
| nat.hab.wo.grass.peri.area.ratio.1000  | num        | 0.556                               |
| nat.hab.wo.grass.peri.area.ratio.2500  | num        | 0.337                               |
| nat.hab.wo.grass.peri.area.ratio.5000  | num        | 0.318                               |
| cropland.1000                          | num        | 0.451                               |
| cropland.2500                          | num        | 0.595                               |
| cropland.5000                          | num        | 0.51                                |
| crop.peri.area.ratio.1000              | num        | 0.84                                |
| crop.peri.area.ratio.2500              | num        | 0.398                               |
| crop.peri.area.ratio.5000              | num        | 0.4882                              |
| crop.edgelength.1000                   | num        | 1176533                             |
| crop.edgelength.2500                   | num        | 4597396                             |
| crop.edgelength.5000                   | num        | 19355417                            |
| inert.1000                             | num        | 0.1172                              |
| inert.2500                             | num        | 0.04124                             |
| inert.5000                             | num        | 0.0767                              |
| inert.edgelength.1000                  | num        | 613371                              |
| inert.edgelength.2500                  | num        | 2250027                             |
| inert.edgelength.5000                  | num        | 8169165                             |
| inert.peri.area.ratio.1000             | num        | 1.684                               |
| inert.peri.area.ratio.2500             | num        | 2.809                               |
| inert.peri.area.ratio.5000             | num        | 1.37                                |
| shannon.1000                           | num        | 1.173                               |
| shannon.2500                           | num        | 0.965                               |
| shannon.5000                           | num        | 1.054                               |
| simpsonsevenness.1000                  | num        | 2.72                                |
| simpsonsevenness.2500                  | num        | 2.18                                |
| simpsonsevenness.5000                  | num        | 2.45                                |

</details>

### Soil variables 
The soil variables were imported from the SoilGrids map 
- SoilGrids map: https://soilgrids.org/
- GEE code for value extraction: [https://code.earthengine.google.com/](https://code.earthengine.google.com/c20d523a9033e4f73df9d779df823134)

**For the summary statistics please unroll the following section** ⬇️

<details>
  <summary>Soil variables description</summary>
  
| Column Name                          | Description                                                               | Unit       | Min      | 1st Qu  | Median   | Mean     | 3rd Qu  | Max       |
|--------------------------------------|----------------------------------------------------------------------------|------------|----------|---------|----------|----------|---------|-----------|
| bdod_bdod_0.5cm_mean_mean             | Bulk density of the fine earth fraction                                   | cg/cm³     | 65.18    | 119.60  | 125.24   | 125.25   | 131.43  | 162.41    |
| bdod_bdod_100.200cm_mean_mean         | Bulk density of the fine earth fraction                                   | cg/cm³     | 102.8    | 141.8   | 145.8    | 145.7    | 150.4   | 180.1     |
| bdod_bdod_15.30cm_mean_mean           | Bulk density of the fine earth fraction                                   | cg/cm³     | 90.49    | 132.76  | 139.08   | 138.04   | 142.89  | 171.85    |
| bdod_bdod_30.60cm_mean_mean           | Bulk density of the fine earth fraction                                   | cg/cm³     | 97.79    | 137.83  | 143.32   | 142.40   | 147.78  | 177.32    |
| bdod_bdod_5.15cm_mean_mean            | Bulk density of the fine earth fraction                                   | cg/cm³     | 86.67    | 123.36  | 128.56   | 129.23   | 134.22  | 168.97    |
| bdod_bdod_60.100cm_mean_mean          | Bulk density of the fine earth fraction                                   | cg/cm³     | 99.56    | 140.17  | 145.35   | 144.77   | 149.81  | 179.54    |
| cec_cec_0.5cm_mean_mean               | Cation Exchange Capacity of the soil                                      | mmol(c)/kg | 75.78    | 182.00  | 204.48   | 213.34   | 237.28  | 481.67    |
| cec_cec_100.200cm_mean_mean           | Cation Exchange Capacity of the soil                                      | mmol(c)/kg | 42.88    | 146.38  | 164.83   | 170.47   | 190.50  | 517.52    |
| cec_cec_15.30cm_mean_mean             | Cation Exchange Capacity of the soil                                      | mmol(c)/kg | 47.15    | 151.16  | 174.00   | 181.98   | 206.75  | 507.84    |
| cec_cec_30.60cm_mean_mean             | Cation Exchange Capacity of the soil                                      | mmol(c)/kg | 42.86    | 150.22  | 169.74   | 177.25   | 197.65  | 508.40    |
| cec_cec_5.15cm_mean_mean              | Cation Exchange Capacity of the soil                                      | mmol(c)/kg | 49.21    | 155.79  | 179.92   | 187.88   | 214.08  | 507.26    |
| cec_cec_60.100cm_mean_mean            | Cation Exchange Capacity of the soil                                      | mmol(c)/kg | 41.19    | 151.04  | 169.31   | 175.49   | 194.44  | 511.61    |
| clay_clay_0.5cm_mean_mean             | Proportion of clay particles (< 0.002 mm) in the fine earth fraction      | g/kg       | 34.55    | 230.67  | 272.38   | 270.35   | 303.30  | 593.77    |
| clay_clay_100.200cm_mean_mean         | Proportion of clay particles (< 0.002 mm) in the fine earth fraction      | g/kg       | 66.28    | 260.90  | 307.06   | 309.23   | 347.72  | 703.58    |
| clay_clay_15.30cm_mean_mean           | Proportion of clay particles (< 0.002 mm) in the fine earth fraction      | g/kg       | 31.99    | 250.14  | 287.94   | 289.55   | 322.69  | 635.95    |
| clay_clay_30.60cm_mean_mean           | Proportion of clay particles (< 0.002 mm) in the fine earth fraction      | g/kg       | 45.52    | 262.92  | 301.01   | 305.91   | 340.73  | 701.44    |
| clay_clay_5.15cm_mean_mean            | Proportion of clay particles (< 0.002 mm) in the fine earth fraction      | g/kg       | 32.07    | 234.74  | 276.79   | 274.86   | 308.28  | 595.60    |
| clay_clay_60.100cm_mean_mean          | Proportion of clay particles (< 0.002 mm) in the fine earth fraction      | g/kg       | 62.66    | 264.76  | 304.18   | 309.01   | 346.05  | 708.06    |
| nitrogen_nitrogen_0.5cm_mean_mean     | Total nitrogen (N)                                                        | cg/kg      | 717      | 1838    | 2737     | 3057     | 3777    | 18198     |
| nitrogen_nitrogen_100.200cm_mean_mean | Total nitrogen (N)                                                        | cg/kg      | 194.0    | 458.4   | 557.3    | 677.9    | 718.0   | 9553.8    |
| nitrogen_nitrogen_15.30cm_mean_mean   | Total nitrogen (N)                                                        | cg/kg      | 423.0    | 918.3   | 1097.5   | 1252.8   | 1375.6  | 11151.4   |
| nitrogen_nitrogen_30.60cm_mean_mean   | Total nitrogen (N)                                                        | cg/kg      | 281.8    | 639.1   | 767.1    | 910.1    | 983.4   | 12259.9   |
| nitrogen_nitrogen_5.15cm_mean_mean    | Total nitrogen (N)                                                        | cg/kg      | 511.5    | 1137.6  | 1426.2   | 1582.5   | 1770.4  | 11475.4   |
| nitrogen_nitrogen_60.100cm_mean_mean  | Total nitrogen (N)                                                        | cg/kg      | 219.4    | 510.3   | 610.7    | 738.4    | 792.0   | 10863.1   |
| phh2o_phh2o_0.5cm_mean_mean           | Soil pH                                                                    | pHx10      | 46.62    | 59.03   | 64.84    | 66.32    | 74.10   | 87.48     |
| phh2o_phh2o_100.200cm_mean_mean       | Soil pH                                                                    | pHx10      | 49.65    | 60.40   | 66.97    | 68.29    | 77.11   | 90.27     |
| phh2o_phh2o_15.30cm_mean_mean         | Soil pH                                                                    | pHx10      | 49.10    | 59.55   | 65.64    | 67.22    | 75.80   | 87.95     |
| phh2o_phh2o_30.60cm_mean_mean         | Soil pH                                                                    | pHx10      | 49.22    | 59.97   | 66.00    | 67.81    | 76.87   | 88.72     |
| phh2o_phh2o_5.15cm_mean_mean          | Soil pH                                                                    | pHx10      | 47.14    | 59.31   | 65.42    | 66.80    | 74.91   | 88.12     |
| phh2o_phh2o_60.100cm_mean_mean        | Soil pH                                                                    | pHx10      | 49.77    | 60.40   | 66.60    | 68.26    | 77.31   | 91.75     |
| sand_sand_0.5cm_mean_mean             | Proportion of sand particles (> 0.05 mm) in the fine earth fraction       | g/kg       | 39.21    | 229.29  | 288.28   | 308.72   | 363.89  | 926.30    |
| sand_sand_100.200cm_mean_mean         | Proportion of sand particles (> 0.05 mm) in the fine earth fraction       | g/kg       | 35.6     | 215.8   | 276.3    | 291.4    | 353.0   | 878.4     |
| sand_sand_15.30cm_mean_mean           | Proportion of sand particles (> 0.05 mm) in the fine earth fraction       | g/kg       | 34.36    | 221.78  | 278.81   | 297.58   | 356.20  | 929.91    |
| sand_sand_30.60cm_mean_mean           | Proportion of sand particles (> 0.05 mm) in the fine earth fraction       | g/kg       | 26.61    | 212.45  | 272.72   | 287.72   | 347.81  | 916.92    |
| sand_sand_5.15cm_mean_mean            | Proportion of sand particles (> 0.05 mm) in the fine earth fraction       | g/kg       | 38.08    | 225.18  | 284.44   | 305.79   | 360.40  | 928.96    |
| sand_sand_60.100cm_mean_mean          | Proportion of sand particles (> 0.05 mm) in the fine earth fraction       | g/kg       | 28.41    | 213.09  | 274.07   | 287.49   | 347.17  | 899.14    |
| silt_silt_0.5cm_mean_mean             | Proportion of silt particles (≥ 0.002 mm and ≤ 0.05 mm) in the fine earth fraction | g/kg | 36.82 | 374.91  | 433.28   | 420.92   | 486.89  | 727.41    |
| silt_silt_100.200cm_mean_mean         | Proportion of silt particles (≥ 0.002 mm and ≤ 0.05 mm) in the fine earth fraction | g/kg | 41.0  | 356.8   | 409.2    | 399.3    | 468.8   | 666.4     |
| silt_silt_15.30cm_mean_mean           | Proportion of silt particles (≥ 0.002 mm and ≤ 0.05 mm) in the fine earth fraction | g/kg | 37.35 | 365.74  | 425.09   | 412.87   | 479.26  | 697.67    |
| silt_silt_30.60cm_mean_mean           | Proportion of silt particles (≥ 0.002 mm and ≤ 0.05 mm) in the fine earth fraction | g/kg | 35.28 | 360.11  | 419.98   | 406.37   | 475.39  | 664.51    |
| silt_silt_5.15cm_mean_mean            | Proportion of silt particles (≥ 0.002 mm and ≤ 0.05 mm) in the fine earth fraction | g/kg | 38.01 | 372.75  | 432.97   | 419.36   | 485.08  | 725.56    |
| silt_silt_60.100cm_mean_mean          | Proportion of silt particles (≥ 0.002 mm and ≤ 0.05 mm) in the fine earth fraction | g/kg | 36.16 | 360.91  | 415.71   | 403.49   | 473.70  | 656.05    |
| soc_soc_0.5cm_mean_mean               | Soil organic carbon content in the fine earth fraction                    | dg/kg     | 58.21    | 182.88  | 265.14   | 300.09   | 386.04  | 1937.58   |
| soc_soc_100.200cm_mean_mean           | Soil organic carbon content in the fine earth fraction                    | dg/kg     | 7.943    | 33.450  | 43.567   | 61.200   | 63.615  | 849.000   |
| soc_soc_15.30cm_mean_mean             | Soil organic carbon content in the fine earth fraction                    | dg/kg     | 38.41    | 89.25   | 115.13   | 130.52   | 148.22  | 902.69    |
| soc_soc_30.60cm_mean_mean             | Soil organic carbon content in the fine earth fraction                    | dg/kg     | 18.13    | 58.58   | 72.13    | 89.01    | 98.94   | 870.00    |
| soc_soc_5.15cm_mean_mean              | Soil organic carbon content in the fine earth fraction                    | dg/kg     | 35.83    | 115.91  | 149.90   | 172.94   | 199.85  | 1181.80   |
| soc_soc_60.100cm_mean_mean            | Soil organic carbon content in the fine earth fraction                    | dg/kg     | 13.45    | 41.69   | 52.27    | 66.52    | 70.65   | 880.00    |

</details>

### Soil Texture 

- Additionally, soil texture was derived via soiltexture::TT.points.in.classes() function in R using the values from the SoilGrids (silt_15.30cm_mean.1000+sand_15.30cm_mean.1000+clay_15.30cm_mean.1000)
- Soil texture is preliminray called soiltype and will be changed to "soiltexture" asap

**For the summary statistics please unroll the following section** ⬇️

<details>
  <summary>Added variables description</summary>
  
| **Column Name**           | **Min.**  | **1st Qu.** | **Median** | **Mean**   | **3rd Qu.** | **Max.**   | **NA’s** |
| ------------------------- | --------- | ----------- | ---------- | ---------- | ----------- | ---------- | -------- |
| SAND                  | 3.436     | 21.713      | 27.538     | 29.715     | 35.805      | 92.122     | 30       |
| SILT                  | 3.734     | 36.456      | 42.472     | 41.336     | 48.019      | 69.762     | 30       |
| CLAY                  | 4.145     | 24.713      | 28.690     | 28.949     | 32.602      | 61.827     | 30       |
| soiltype              | factor (11 levels)          | Cl: 59, ClLo: 523, Lo: 374, LoSa: 1, Sa: 1, SaCl: 2, SaClLo: 64, SaLo: 25, SiCl: 16, SiClLo: 164, SiLo: 125, NAs: 30| —          |  —  | —           | —          | —        |

</details>

### Fieldsize variables 
 
The field size variables were imported from the field size map 
- Fied size map : [publication link](https://pure.iiasa.ac.at/id/eprint/15526/)
- GEE code for value extraction: [https://code.earthengine.google.com/](https://code.earthengine.google.com/2080466c0f5ebddb65ff7392ae4b0064)
- Link to the description file: [here](surrounding_landscapes/tree/current_main/Subprojects/FieldSize/README.md)

<details>
  <summary>Fied size variables description</summary>

**For the summary statistics please unroll the following section** ⬇️

| **Column Name**           | **Min.**  | **1st Qu.** | **Median** | **Mean**   | **3rd Qu.** | **Max.**   | **NA’s** |
| ------------------------- | --------- | ----------- | ---------- | ---------- | ----------- | ---------- | -------- |
| fieldsize  | factor   (6 levels)    | large_area_m: 52; medium_area_m: 68; nofield_area_m: 217; small_area_m: 48; verylarge_area_m: 3; verysmall_area_m : 996 |X  | X | X  | X | X      |
| nofield_area_m.5000   | 1597      | 1,757,059   | 6,201,059  | 16,788,854 | 22,801,944  | 77,836,797 | 280      |
| nofield_area_m.2500   | 1030      | 681,484     | 2,310,377  | 5,309,190  | 8,218,220   | 19,474,536 | 548      |
| nofield_area_m.1000  | 1100      | 249,337     | 903,048    | 1,285,665  | 2,327,115   | 3,123,431  | 852      |
| small_area_m.5000     | 25,534    | 8,868,164   | 30,777,799 | 37,251,405 | 67,877,414  | 77,808,877 | 1,272    |
| small_area_m.2500    | 50,544    | 5,288,125   | 12,686,828 | 11,618,757 | 19,343,132  | 19,452,199 | 1,297    |
| small_area_m.1000     | 54,159    | 1,560,370   | 2,622,726  | 2,273,812  | 3,106,700   | 3,113,476  | 1,316    |
| verysmall_area_m.5000 | 18,716    | 62,239,129  | 74,201,670 | 64,960,173 | 77,198,244  | 77,792,226 | 231      |
| verysmall_area_m.2500 | 17,510    | 16,695,910  | 19,063,133 | 16,881,700 | 19,371,642  | 19,452,239 | 260      |
| verysmall_area_m.1000 | 15,430    | 2,886,050   | 3,094,196  | 2,768,683  | 3,099,562   | 3,113,627  | 277      |
| large_area_m.5000    | 3,389     | 14,517,357  | 47,493,754 | 45,349,678 | 76,840,867  | 77,771,886 | 1,291    |
| large_area_m.2500     | 1,110     | 9,978,321   | 18,338,982 | 14,249,395 | 19,133,671  | 19,440,562 | 1,311    |
| large_area_m.1000     | 9,202     | 2,446,260   | 3,097,006  | 2,576,479  | 3,105,596   | 3,120,552  | 1,320    |
| verylarge_area_m.5000 | 6,888,078 | 30,518,906  | 38,395,849 | 30,518,906 | 38,395,849  | 38,395,849 | 1,380    |
| verylarge_area_m.2500 | 2,086,799 | 6,429,288   | 7,876,784  | 6,429,288  | 7,876,784   | 7,876,784  | 1,380    |
| verylarge_area_m.1000 | 932,045   | 932,045     | 932,045    | 965,734    | 965,734     | 1,066,802  | 1,380    |
| medium_area_m.5000    | 27,013    | 10,855,177  | 43,728,929 | 41,730,331 | 73,409,561  | 77,886,900 | 1,255    |
| medium_area_m.2500   | 17,887    | 6,072,694   | 14,222,247 | 12,615,087 | 19,260,432  | 19,487,852 | 1,278    |
| medium_area_m.1000    | 15,038    | 1,472,534   | 3,079,211  | 2,267,156  | 3,107,051   | 3,118,733  | 1,288    |

</details>


### Other variabels 
- Species Richness was added from the IUCN dataset
- Annual mean temperature was calculated in R: temp_avg_1970.2000
- Annual mean precipitation was calculated in R: prec_avg_1970.2000
- Pollinator dependance was assigned 0 for no-pollinator-dependant crop and 1 for pollinator dependance

  **For the summary statistics please unroll the following section** ⬇️

<details>
  <summary>Added variables description</summary>
  
| **Column Name**           | **Min.**  | **1st Qu.** | **Median** | **Mean**   | **3rd Qu.** | **Max.**   | **NA’s** |
| ------------------------- | --------- | ----------- | ---------- | ---------- | ----------- | ---------- | -------- |
| SR                    | 82.8      | 237.4       | 320.3      | 344.3      | 402.3       | 954.7      | 4        |
| temp_avg_1970.2000    | -2.07     | 9.86        | 15.68      | 14.12      | 17.49       | 27.52      | —        |
| prec_avg_1970.2000    | 3.08      | 50.33       | 85.42      | 83.57      | 113.67      | 262.17     | —        |
| poll_dependent        | 0.00000   | 0.00000     | 0.00000    | 0.00000    | 0.00000     | 1.00000    | —        |

</details>



