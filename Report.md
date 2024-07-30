# Report 
## Introduciton 
With global food consumption projected to increase by 1.4% annually over the next decade, driven primarily by population growth, especially in low- and middle-income countries(OECD & Food and Agriculture Organization of the United Nations, 2022), securing sufficient food production is essential. Thus, agriculture must again meet higher goals. Although recent agricultural intensification through pesticide, fertilizer, and machine use has led to increased food production, it has also resulted in a series of environmental costs such as a decline in biodiversity (Köthe et al., 2023; Mamabolo et al., 2024; Zabel et al., 2019), landscape homogenization (Egli et al., 2021), and soil degradation (Mamabolo et al., 2024; Voltr et al., 2021), the latter being crucial for secure food production. These issues can be described as “intensification traps”—production declines triggered by the negative feedback of biodiversity loss at high input levels (Burian et al., 2024). Furthermore, further intensification practices make agricultural fields vulnerable to environmental changes and reduce food supply stability (Egli et al., 2021). Therefore, relying solely on intensified agriculture and expanded cultivation is unsustainable, as climate impacts exacerbate yield gaps and food supply inequities (Seppelt et al., 2024).

Several practices have been undertaken to maintain a more secure and sustainable path to meet rising food production goals. These include the restriction of mineral fertilizers and chemical pesticides, as implemented in organic farming practices, and mulching, crop rotation and reduced tillage, as implemented in conservation agriculture practices. Both practices can mitigate the negative effects of conventional farming while supporting ecosystem services crucial for agricultural productivity (Wittwer et al., 2021). For instance, substituting mineral fertilizers with manure has been demonstrated to reduce environmental pollution and enhance soil quality (Liang et al., 2022; Wang et al., 2023). Crop rotation can sequester atmospheric carbon and improve the resilience of corn production systems to climate change (Joshi et al., 2023). Additionally, practices such as straw return and straw addition have been shown to increase both crop yield and soil organic carbon (D. Liu et al., 2023). Moreover, conservation agriculture has proven to be more resilient to rising global temperatures and heat stress, ensuring stable food production even in a changing climate (Steward et al., 2018).

Recent studies suggest that the effectiveness of such measures is often mediated by the landscapes surrounding the agricultural field (Perrot et al., 2023), due to the positive effects of surrounding landscapes on biodiversity (Dominik et al., 2022; Estrada-Carmona et al., 2022) and agricultural production (Guo et al., 2022) by providing diverse ecosystem services. Contrary to the common observation of a negative correlation between yield and biodiversity (Jones et al., 2023), landscape diversification has been shown to positively affect crop yield with no negative effects for biodiversity (Galpern et al., 2020). DeClerck et al. (2023) even argues that there is no evidence that diversified production systems compromise food security, and many agricultural diversification practices provide multiple complementary benefits to multiple ecosystem services (Jones et al., 2023; Tamburini et al., 2020).

These complementary benefits often arise from spillover effects occurring both from natural to agricultural ecosystems and vice versa (Blitzer et al., 2012). Until recently, spillovers were viewed as obstacles to both agriculture and nature conservation, compromising their stability. For instance, intensive nutrient input and herbicide residues on agricultural lands are considered a threat to biodiversity and nature conservation due to their negative spillover effects on natural habitats (Larsen et al., 2024), with plant communities at the edges between these ecosystems being particularly endangered (Köthe et al., 2023). Older studies have focused on negative spillovers from natural to agricultural lands through the migration of herbivores, pests, and pathogens (Blitzer et al., 2012). However, recent research suggests that agriculture and nature conservation can complement rather than constrain each other through diversification practices and subsequent increases in biodiversity (Stein-Bachinger et al., 2021). 

Introducing semi-natural habitats would increase biodiversity in agricultural mosaics, as landscape diversity provides habitats for insects (Akter et al., 2023; Woltz & Landis, 2014) and birds (Fischer et al., 2011). Hence, increasing landscape complexity has a positive effect on the richness of service-providing organisms, such as pollinators (Bottero et al., 2023) and pest predators (B. Liu et al., 2018). In return, the richness of service-providing organisms positively influences the ecosystem services delivery such as pest control and pollination services (Dainese et al., 2019), resulting in increased crop productivity via ecological intensification (Bommarco et al., 2013) and higher yield stability (Bishop et al., 2022). Natural habitats often host a variety of beneficialinsects, birds, and other predators that can feed on agricultural pests (Tscharntke et al., 2005). These predators can migrate into crop fields and help control pest populations, reducing the need for chemical pesticides through biocontrol (Woltz & Landis, 2014; Yang et al., 2021).

Furthermore, natural habitats can provide pollination services, which benefit the yield of 75% of the world's agricultural crops (Klein et al., 2006). Pollinators that usually feed in natural habitats would fly over to the crop fields when they are flowering (Blitzer et al., 2012). Therefore, there would be a synergistic relationship between the crops, which get pollinated, and the pollinators, which feed on the nectar of the crops. This interaction supports both yield production and pollinator richness (Tscharntke et al., 2005; Yang et al., 2021), the latter being very important in times of recent massive pollinator declines (Janousek et al., 2023; Sritongchuay et al., 2022).
Soil health, carbon, nutrient, and water cycling are essential for supporting food production (De Deyn & Kooistra, 2021). Therefore, securing and rehabilitating soil is a primary concern for agricultural practices. Integrating natural habitats into agricultural mosaics has been found to increase agricultural productivity in adjacent lands by reducing erosion and improving soil biological activity and nutrient availability (Garibaldi et al., 2021). Additionally, forests and tree-based agricultural systems have been shown to contribute to hydrologic regulation (Galindo et al., 2022). However, it remains challenging to disentangle the pure effect of surrounding landscapes on yield, as the interactions and influence of other factors remain complex.

Multifunctionality is an important characteristic of agricultural mosaics (Burian et al., 2023), because they support water regulation, nutrient cycling, biodiversity, recreation and other important ecosystem services. With that in mind,it is crucially important to assess all possible ways of ecological intensification through increased  heterogeneity of land cover types at a regional scale. Several studies have already addressed therelationship between landscape heterogeneity and biodiversity through local field experiments or by calculating estimates on a larger scale using yield estimates or projections. The effects of surrounding landscapes on yield is context-dependent and differs among taxonomic groups and biogeographical regions (Zymaroieva et al., 2021; Martin et al., 2016). Therefore, looking into both class- and landscape-level patterns is crucial to better estimate the influence of surrounding landscapes on the cropfield productivity (Xin et al., 2024). This study will be the first to examine the effects of surrounding landscapes on crop yield globally by collecting data from previous field experiments, putting the data into spatial perspective by utilizing land cover data with 10m resolution on a temporal scale, and analyzing the yield in connection to landscape heterogeneity.

## Methods
Initially, the compiled dataset was evaluated and explored to understand its structure and content. We ensured that each data point included latitude and longitude, yield data, and the primary study source. Data points missing any of these properties were excluded.

All yield measurements were then standardized to the kg/ha metric for appropriate comparison. Some studies (three studies, 1561 observations) recorded both the publication year and the harvest year of the experiment. Using these studies, we calculated the time difference between publication and harvest and recorded the median of this distribution, chosen for its robustness to outliers. The median indicated a 7-year difference between publication and harvest. Consequently, for the entire dataset, the harvest year was calculated by subtracting 7 years from the publication date, including studies that directly indicated the harvest year to ensure consistency.

For land cover data, the GLC_FCS30D dataset developed by Zhang et al. (2024) was used. This dataset, developed using Landsat imagery, includes 35 land cover types at a 30-meter resolution, spanning the period from 1985 to 2022, with updates every five years before 2000 and annually thereafter.

Data points after 2000 were assigned to the corresponding land cover datasets. Points prior to 2000 were assigned to a 5-year range; for example, data points from 1988 to 1992 were assigned to the 1990 land cover dataset. For 1985, the range was from 1975 to 1987, and data points with a harvest year before 1975 were excluded.

The resulting data points were mapped onto corresponding maps in Google Earth Engine (GEE). Buffers of 1km, 2km and 5km radii were created around the data points.

Land cover metrics, including area, proportion, and edge length for each land cover type, were calculated in GEE. The 1km, 2km and 5km radii buffers were applied to all data points. The Canny Edge Detector algorithm (threshold = 0.7, sigma = 1) was used to detect edges in the images. Edge lengths for each land cover class were calculated within the buffered points, and the total edge length for each class within each buffer were recorded. The area for each land cover class was calculated using ee.Image.pixelArea() and grouped ee.Reducer.sum() for calculating the area for each land cover classes. The proportion for each land cover class was then calculated as the area of the class divided by the total area of the buffer. Shannon’s landscape diversity index was further used to evaluate landscape heterogeneity by calculating the negative sum of each area's proportion multiplied by the natural logarithm of that proportion.

## Results 

### Data Profile 
**In short words:** 
* **7959** data points with all complete landscape metrics
* **11** data sets
* **10** crop types
* **13** treatments
* **5** initial yield metrics

**Note:** the data is written in the long format, meaning that one harvest point will be represented by multiple rows. 

#### Datasets
The datasets were extracted from the supplementary data of the following metastudy papers: 

| DatasetID | Title of the Metastudy Paper                                    | Citation  |
|------------|-------------------------------------------------------------|-----------|
| D331         | Agricultural management strategies for balancing yield increase, carbon sequestration, and emission reduction after straw return for three major grain crops in China: A meta-analysis                                           | Liu, D., Song, C., Xin, Z., Fang, C., Liu, Z., & Xu, Y. (2023). Agricultural management strategies for balancing yield increase, carbon sequestration, and emission reduction after straw return for three major grain crops in China: A meta-analysis. Journal of Environmental Management, 340, 117965. https://doi.org/10.1016/j.jenvman.2023.117965   |
| D973         | Potential benefits of liming to acid soils on climate change mitigation and food security                                   | Wang, Y., Yao, Z., Zhan, Y., Zheng, X., Zhou, M., Yan, G., Wang, L., Werner, C., & Butterbach-Bahl, K. (2021). Potential benefits of liming to acid soils on climate change mitigation and food security. Global Change Biology, 27(12), 2807–2821. https://doi.org/10.1111/gcb.15607  |
| D1120         | The adaptive capacity of maize-based conservation agriculture systems to climate stress in tropical and subtropical environments: A meta-regression of yields                      | Steward, P. R., Dougill, A. J., Thierfelder, C., Pittelkow, C. M., Stringer, L. C., Kudzala, M., & Shackelford, G. E. (2018). The adaptive capacity of maize-based conservation agriculture systems to climate stress in tropical and subtropical environments: A meta-regression of yields. Agriculture, Ecosystems & Environment, 251, 194–202. https://doi.org/10.1016/j.agee.2017.09.019   |
| D921A & D921B        | Integrated biochar solutions can achieve carbon-neutral staple crop production                                        | Xia, L., Cao, L., Yang, Y., Ti, C., Liu, Y., Smith, P., van Groenigen, K. J., Lehmann, J., Lal, R., Butterbach-Bahl, K., Kiese, R., Zhuang, M., Lu, X., & Yan, X. (2023). Integrated biochar solutions can achieve carbon-neutral staple crop production. Nature Food, 4(3), 236–246. https://doi.org/10.1038/s43016-023-00694-0   |
| D309         | Improving yield and nitrogen use efficiency through alternative fertilization options for rice in China: A meta-analysis.                           | Ding, W., Xu, X., He, P., Ullah, S., Zhang, J., Cui, Z., & Zhou, W. (2018). Improving yield and nitrogen use efficiency through alternative fertilization options for rice in China: A meta-analysis. Field Crops Research, 227, 11–18. https://doi.org/10.1016/j.fcr.2018.08.001   |
| D669         | Effects of the Ratio of Substituting Mineral Fertilizers with Manure Nitrogen on Soil Properties and Vegetable Yields in China: A Meta-Analysis                         | Wang, S., Lv, R., Yin, X., Feng, P., & Hu, K. (2023). Effects of the Ratio of Substituting Mineral Fertilizers with Manure Nitrogen on Soil Properties and Vegetable Yields in China: A Meta-Analysis. Plants, 12(4), Article 4. https://doi.org/10.3390/plants12040964   |
| D473        | A global meta-analysis of cover crop response on soil carbon storage within a corn production system             | Joshi, D. R., Sieverding, H. L., Xu, H., Kwon, H., Wang, M., Clay, S. A., Johnson, J. M., Thapa, R., Westhoff, S., & Clay, D. E. (2023). A global meta-analysis of cover crop response on soil carbon storage within a corn production system. Agronomy Journal, 115(4), 1543–1556. https://doi.org/10.1002/agj2.21340   |
| D652         | Effects of super absorbent polymer on crop yield, water productivity and soil properties: A global meta-analysis                | Zheng, H., Mei, P., Wang, W., Yin, Y., Li, H., Zheng, M., Ou, X., & Cui, Z. (2023). Effects of super absorbent polymer on crop yield, water productivity and soil properties: A global meta-analysis. Agricultural Water Management, 282, 108290. https://doi.org/10.1016/j.agwat.2023.108290   |
| D906         | Assessment of drainage nitrogen losses on a yield-scaled basis           | Zhao, X., Christianson, L. E., Harmel, D., & Pittelkow, C. M. (2016). Assessment of drainage nitrogen losses on a yield-scaled basis. Field Crops Research, 199, 156–166. https://doi.org/10.1016/j.fcr.2016.07.015   |
| D352         | Effect of soil erosion depth on crop yield based on topsoil removal method: a meta‑analysis           | Zhang, L., Huang, Y., Rong, L., Duan, X., Zhang, R., Li, Y., & Guan, J. (2021). Effect of soil erosion depth on crop yield based on topsoil removal method: A meta-analysis. Agronomy for Sustainable Development, 41(5), 63. https://doi.org/10.1007/s13593-021-00718-8   |

The papers' main focus was on the effect of some treatment on the crop yield. Hence, different crops and treatments were included in different datasets: 
![frequencygrid](images/dataprofile/sankey_dataset_crop_treatment.png)


**Notes:**
* The Paper **D921** had two supplementary datasets, therefore they were gived D921A and D921B DatasetID's.
* Some crop types like "Grassland", "Cotton", "Oat", "Oilcrops" are represented by only one dataset.
* Some chinese papers were including not-peer-reviewed studies such as "Master thesis". Since I was looking up the primary sources for the datasets D331 and D652 to note the publication date, it turned out that they also included some sources marked as "Master Thesis" in the CKNI. To check what sources were tagged as "Master Thesis" check the "data" older for "d331_years.csv" and "d652_years.csv". 

#### Map: Locations of the points 
![map](images/dataprofile/map.png)

**Notes:** 
* The points are distributed across **all continents**.
* The current dataset is biased towards **chinese experiments**

#### Frequency charts 
![frequencygrid](images/dataprofile/frequencygrid.png)
![frequencygrid](images/dataprofile/country.png)

#### Distribution plots 
![frequencygrid](images/dataprofile/distribution.png)

Distribution of yield: 
**initial yield metric as filling color:**
![frequencygrid](images/dataprofile/yield.png)
**Crop type as filling color:**
![frequencygrid](images/dataprofile/yield_croptype.png)
**Treatment as filling color:**
![frequencygrid](images/dataprofile/yield_treatment.png)

### Landscape Metrics  

**What do the class codes stay for?**
| Class Code | Class Description by ESA                                    | HEX Code  |
|------------|-------------------------------------------------------------|-----------|
| 10         | Rainfed cropland                                            | #ffff64   |
| 11         | Herbaceous cover cropland                                   | #ffff64   |
| 12         | Tree or shrub cover (Orchard) cropland                      | #ffff00   |
| 20         | Irrigated cropland                                          | #aaf0f0   |
| 51         | Open evergreen broadleaved forest                           | #4c7300   |
| 52         | Closed evergreen broadleaved forest                         | #006400   |
| 61         | Open deciduous broadleaved forest (0.15<fc<0.4)             | #a8c800   |
| 62         | Closed deciduous broadleaved forest (fc>0.4)                | #00a000   |
| 71         | Open evergreen needle-leaved forest (0.15<fc<0.4)           | #005000   |
| 72         | Closed evergreen needle-leaved forest (fc>0.4)              | #003c00   |
| 81         | Open deciduous needle-leaved forest (0.15<fc<0.4)           | #286400   |
| 82         | Closed deciduous needle-leaved forest (fc>0.4)              | #285000   |
| 91         | Open mixed leaf forest (broadleaved and needle-leaved)      | #a0b432   |
| 92         | Closed mixed leaf forest (broadleaved and needle-leaved)    | #788200   |
| 120        | Shrubland                                                   | #966400   |
| 121        | Evergreen shrubland                                         | #964b00   |
| 122        | Deciduous shrubland                                         | #966400   |
| 130        | Grassland                                                   | #ffb432   |
| 140        | Lichens and mosses                                          | #ffdcd2   |
| 150        | Sparse vegetation (fc<0.15)                                 | #ffebaf   |
| 152        | Sparse shrubland (fc<0.15)                                  | #ffd278   |
| 153        | Sparse herbaceous (fc<0.15)                                 | #ffebaf   |
| 181        | Swamp                                                       | #00a884   |
| 182        | Marsh                                                       | #73ffdf   |
| 183        | Flooded flat                                                | #9ebb3b   |
| 184        | Saline                                                      | #828282   |
| 185        | Mangrove                                                    | #f57ab6   |
| 186        | Salt marsh                                                  | #66cdab   |
| 187        | Tidal flat                                                  | #444f89   |
| 190        | Impervious surfaces                                         | #c31400   |
| 200        | Bare areas                                                  | #fff5d7   |
| 201        | Consolidated bare areas                                     | #dcdcdc   |
| 202        | Unconsolidated bare areas                                   | #fff5d7   |
| 210        | Water body                                                  | #0046c8   |
| 220        | Permanent ice and snow                                      | #ffffff   |
| 0          | Filled value                                                | #ffffff   |

