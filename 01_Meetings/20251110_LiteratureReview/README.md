
# Literature Review

### Up to 50% of the negative effects of landscape simplification on ecosystem services was due to richness losses of service-providing organisms, with negative consequences for crop yields.

<details>
<ins>Source:</ins> 


```
Dainese, M., Martin, E. A., Aizen, M. A., Albrecht, M., Bartomeus, I., Bommarco, R., Carvalheiro, L. G., Chaplin-Kramer, R., Gagic, V., Garibaldi, L. A., Ghazoul, J., Grab, H., Jonsson, M., Karp, D. S., Kennedy, C. M., Kleijn, D., Kremen, C., Landis, D. A., Letourneau, D. K., … Steffan-Dewenter, I. (2019). A global synthesis reveals biodiversity-mediated benefits for crop production. Science Advances, 5(10), eaax0121. https://doi.org/10.1126/sciadv.aax0121
```

(Dainese et al., 2019)

<ins>Landscape Indices:</ins>

Landscapes were characterized by calculating the percentage of cropland (annual and perennial) within a radius of 1 km around the center of each crop field.

<ins>Buffer Size:</ins>

The 1-km spatial  extent was chosen to reflect the typical flight and foraging distances of many insects including pollinators and natural enemies. 

<ins>Method used:</ins>

* Bayesian multivariate response model
* Partioned the relative importance of richness and total and relative abundance in driving biodiversity-ecosystem relationships.
* The model included the ecosystem service index as response, landscape simplification as predictor, and richness as mediator.

| --- | ---  |
:-------------------------:|:-------------------------:
![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/01_Meetings/images/litrev_dainese1.jpeg) |  ![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/01_Meetings/images/litrev_dainese2.jpeg)

</details> 
___

### Landscape configuration accounted for more variation in plant and arthropod species richness than landscape composition.
<details>
<ins>Source:</ins> 


```
Duff, H., Debinski, D., & Maxwell, B. D. (2024). Landscape context affects patch habitat contributions to biodiversity in agroecosystems. Ecosphere, 15(6), e4879. https://doi.org/10.1002/ecs2.4879
```

(Duff et al., 2024)

<ins>Landscape Indices:</ins>

* Landscape composition variables such as land cover type diversity, land cover type richness, and land use type
* Landscape configuration variables included patch cohesion as a metric of connectedness within each spatial extent, patch division as a metric of patchiness within each spatial extent, total edge amount as a metric of fragmentation within each spatial extent, total number of patches as a metric of patchiness within each spatial extent, and Large Patch Index as a measure of the percentage of landscape covered by the dominant patch type within each spatial extent (McGarigal et al., 2012) (Table 3). All landscape configuration metrics were calculated from the Cropland Data Layer using the LandscapeMetric package in R (McGarigal et al., 2012) (Appendix S1: Table S4) at 30-m (0.09-ha pixel) resolution for each landscape extent buffer (Figure 1F).

<ins>Buffer Size:</ins>

* 0.1-, 0.5-, 1-, 2-, and 5-km radii
* Biodiversity responses to landscape variables were largely scale-dependent, as pairwise comparisons were significantly different between all spatial extents except between 1- and 2-km extents, and correlations were lowest at the 
5-km extent. 

<ins>Method used:</ins>

* PLS-analysis (Partial least-squares regression)
* Models performed best when composition and configuration were considered together rather than alone, suggesting that both components of landscape complexity should be considered for identifying and managing conservation areas in crop fields. 

![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/01_Meetings/images/litrev_duff.jpg)
</details>
___

### The increase in cultivated areas had a negative effect on the visitation rate of both managed and native pollinators. Conversely, more diverse landscapes had a negative and significant effect on A. mellifera (honey bee) abundance within the plots.  

<details>
 
<ins>Source:</ins> 


```
Cavigliasso, P., Maza, N., Barreto, C. G., Maina, M. E., Gennari, G. P., & Chacoff, N. P. (2025). Multi-Scale Factors Promote Entomophilous Pollination: Productive Blueberry Agroecosystems as a Study Model. Journal of Applied Entomology, 149(6), 1010–1022. https://doi.org/10.1111/jen.13428
```

(Cavigliasso et al., 2025)

<ins>Landscape Indices:</ins>

* Landscapes compositional heterogeneity: The percentage of coverage of each of the LUs
* Landscapes configurational heterogeneity: the average “Perimeter/Area (PE/AR)” ratio of the 
patches that make up each site and the “Habitat Diversity (HD)” index calculated as the exponential of the Shannon 
index (the level of entropy of a system) calculated from the proportional occupation of LUs in each particular site (Omayio et al. 2019).

<ins>Buffer Size:</ins>

* 1000 m radius 

<ins>Method used:</ins>

* Generalized linear mixed effects model
* To assess the effects of landscape components, we used the abundance and richness of pollinator communities (Abundance: Wild pollinators and A. mellifera; Richness: Wild pollinators) and the frequency of visits (A. mellifera/flower, wild pollinators/flower, as well as the richness of floral visitor species) as the response variables. The percentage of land use types (BL, CI, FO, SN) and the PE/AR and HD indices were considered as fixed factors. The random structure of the model consisted of “Year/Site” with a Gamma (link = log) error distribution.
</details>
___

### Ecosystem services mediate the effects of landscape heterogeneity on epigaeic arthropods. 

<details>
 
<ins>Source:</ins> 

```
Zhang, Y., Bian, Z., Guo, X., & Wang, C. (2025). Multiscale agrobiodiversity conservation: Modeling epigaeic arthropod diversity with landscape heterogeneity and ecosystem services. Journal of Environmental Management, 388, 126003. https://doi.org/10.1016/j.jenvman.2025.126003
```
(Zhang et al., 2025)

<ins>Result Notes:</ins>

* The parameter estimates for SHDI, SNH, and CP were all significant and positive, with CP having the strongest effect (Fig. 5c). Specifically, landscape composition (SNH) contributed 24.68 %, landscape configuration (SHDI) 31.99 %, and ESs (CP) 43.32 % to the model's explanatory power.

<ins>Landscape Indices:</ins>

* Landscape heterogeneity: Rao quadratic entropy index
* Landscape configuration heterogeneity: Landscape Shape Index (LSI), Contagion Index (CONTAGE), Shannon Diversity Index (SHDI), and Landscape Division Index (DIVISION)


<ins>Buffer Size:</ins>

* not applicable. Analysis done within one study area. 

<ins>Method used:</ins>

* Geographically weighted regression models (GWR)
* Model selection via "MuMln" package; The best model was chosen by comparing the differences in AIC values (ΔAIC) between models, following the Akaike Information Criterion
* Additionally, the variance explained by the explanatory variables in the linear model was computed using the hierarchical partitioning method in the “rdacca.hp” package.
* Structural equation modelling (SEM) to examine direct and indirect interactions between variables. This was
 used to analyze the influence pathways through which landscape composition and configuration affect epigaeic arthropod diversity at field, watershed, and county scales, as well as the role of ESs within these pathways
</details>

___

### (1) Increasing land-use diversity was associated with a reduction in the magnitude of yield decline at field edges, particularly when small woody features (SWF) were present nearby; (2) Crop types react differently to yield decline at the field edge; (3) Grassland can act as an indicator for the types of farming systems that operate within the landscape;

<details>
 
<ins>Source:</ins> 


```
Metcalfe, H., Cook, S. M., & Milne, A. E. (2025). Agricultural landscape features can mitigate field-edge yield declines: Insights from yield monitor and remote sensing data. Agriculture, Ecosystems & Environment, 394, 109891. https://doi.org/10.1016/j.agee.2025.109891
```
(Metcalfe et al., 2025)

<ins>Result Notes:</ins>

- Significant effects of various measures of topography on field-edge yield decline
   - Field edges with open topography that increases wind exposure may lead to crop lodging
- Specifically, increasing land-use diversity was associated with a reduction in the magnitude of yield decline at field edges, particularly when small woody features (SWF) were present nearby. 
 - Woody features exacerbate yield decline associated with wetness
 - Yield breakdown until 25m from the field edge
 - In diverse landscapes woody feature may contribute to the provision of ecosystem services (ES), while in homogenous landscapes, where wild organisms population sizes are reduced, those may act as barriers simultaneously serving as a habitat for more generalist or mobile pests, weeds or pathogens
 - As all our data were from combinable crops, the amount of grassland in the landscape indicates a distinction between
intensive arable production systems and mixed farming systems, where crops and livestock are produced on the same farm.
 - The shorter growing season for spring crops means that there is less potential for natural processes such as environmental effects and the delivery of ecosystem services from the surrounding landscape to take a sufficiently large effect as to be observable in the yield data.

![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/01_Meetings/images/litrev_metcalfe.png)

<ins>Landscape Indices:</ins>

- Landscape features:
    - local influences  (e.g., adjacent hedgerows)
        - the local scale, defined as immediately adjacent to the field boundary, the farm scale (≤1000 m)
    - broader landscape context (e.g., land-use diversity at the farm or landscape scale)
        - the landscape scale (≤2500 m)

<ins>Buffer Size:</ins>

- 1000m, 2500m 

<ins>Method used:</ins>

- "We aimed to fit a GLMM to express the magnitude () and the extent () of field-edge yield decline in terms of our explanatory variables for each of our five crops. We used a Least Absolute Shrinkage and Selection Operator (LASSO) approach (Tibshirani, 1996) to screen the large number of explanatory variables and all second-order interactions and estimate a smaller set of important variables. The inclusion of interaction terms between local boundary features and broader-scale landscape and farm context variables permits boundary-specific environmental effects to vary depending on landscape composition and farming system, reflecting realistic spatial heterogeneity rather than assuming uniform effects across all field boundaries."


</details>

___

### (1) The crop yield in the landscape with forest cover (>27%) was increased by 169%. (2) Land shape complexity (6%) and area (7%) contributed more to the variation of crop yield than landscape diversity (∼2%).

<details>
 
<ins>Source:</ins> 


```
Xin, J., Peng, Y., Peng, N., Yang, L., Huang, J., Yuan, J., Wei, B., & Ren, Y. (2024). Both class- and landscape-level patterns influence crop yield. European Journal of Agronomy, 153, 127057. https://doi.org/10.1016/j.eja.2023.127057

```
(Xin et al., 2024)

<ins>Result Notes:</ins>

- Key climate, landscape, and fertilizer drivers were identified. Among these drivers, the following landscape metrics showed the highest frequency in the GLMMs: patch shape complexity (SHAPE, 42; PARA, 34 TE, 33, LSI, 30), area metric (PLAND, 34; LPI 14), fragmentation metrics (PD, 27), and aggregation metrics (CONTAG, 7). Landscape diversity and landscape heterogeneity indices only appeared eight in the GLMMs.
- The factors that infiuenced yield of a crop (rice, maize or wheat) were different not only between crops but also between climatic zones. Meaning that the factor influencing the yield of a crop will depend on the crop and on the location of the measurement.
  
<ins>Landscape Indices:</ins>

- To assess the degree of **landscape fragmentation**, we used landscape connection (CONNECT), landscape contagion (CONTAG), landscape contiguity index (CONTIG), number of patches (NP), Euclidean nearest neighbor distance (ENN, m), and patch density (PD), which together reflect the connectivity and fragmentation of a landscape (Kupfer, 2012).
-  For **landscape heterogeneity** which indicating the land use diversity within a landscape, we used land use Shannon-Wiener diversity index (SHDI), Simpson Diversity index (SIDI), and interspersion &juxtaposition index (IJI).
-  For **landscape aggregation**, we used aggregation index (AI), patch cohesion index (COHISION), and proximity index (PROX). 
  
<ins>Buffer Size:</ins>

<ins>Method used:</ins>

- This study focused on the main cultivation areas of maize, wheat, and rice in China.
- The data of crop yield are from the global dataset of historical yields for major crops (Iizumi and Sakai, 2020) (Elizaveta's side note: we have requested this dataset and we haev it)
- Fertilizer data are extracted from the National Bureau of Statistics of China and the statistical bureaus of the Chinese provinces at county scale. 
- Generalized linear mixed model
  -  The following variables were used in the GLMM: climate, fertilizer and landscape pattern, and climate and landscape interactions (climate × landscape).
  -  Response variables were yield of wheat, rice, maize, and their total.
  -  Climate, landscape metrics, and fertilizer were included in the model as fixed factors, and location and time were random factors.
- Gradient analysis
  -  To investigate the potential mediating effect of landscape factors on climate factors, we used a gradient analysis approach.
  -  The difference in crop average yield across three landscape gradients were compared with Duncan's new multiple range test (DNMRT). 
</details>

___

###  The mechanisms stabilizing ecosystem functioning change with community age

<details>
 
<ins>Source:</ins> 


```
Wagg, C., Roscher, C., Weigelt, A., Vogel, A., Ebeling, A., de Luca, E., Roeder, A., Kleinspehn, C., Temperton, V. M., Meyer, S. T., Scherer-Lorenzen, M., Buchmann, N., Fischer, M., Weisser, W. W., Eisenhauer, N., & Schmid, B. (2022). Biodiversity–stability relationships strengthen over time in a long-term grassland experiment. Nature Communications, 13(1), 7752. https://doi.org/10.1038/s41467-022-35189-2

```
(Wagg et al., 2022)

<ins>Result Notes:</ins>

- Productivity declined more rapidly in less diverse communities resulting in temporally strengthening positive effects of richness on productivity, complementarity, and stability.

  
<ins>Landscape Indices:</ins>

Not applicable 

<ins>Buffer Size:</ins>

Not applicable 

<ins>Method used:</ins>

17 years of a controlled grassland biodiversity experiment

</details>


___
