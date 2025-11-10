
# Literature Review

### Up to 50% of the negative effects of landscape simplification on ecosystem services was due to richness losses of service-providing organisms, with negative consequences for crop yields.

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

___

### Landscape configuration accounted for more variation in plant and arthropod species richness than landscape composition.

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

___

### The increase in cultivated areas had a negative effect on the visitation rate of both managed and native pollinators. Conversely, more diverse landscapes had a negative and significant effect on A. mellifera (honey bee) abundance within the plots.  

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

___

### Ecosystem services mediate the effects of landscape heterogeneity on epigaeic arthropods. 

<ins>Source:</ins> 

(Zhang et al., 2025)

```
Zhang, Y., Bian, Z., Guo, X., & Wang, C. (2025). Multiscale agrobiodiversity conservation: Modeling epigaeic arthropod diversity with landscape heterogeneity and ecosystem services. Journal of Environmental Management, 388, 126003. https://doi.org/10.1016/j.jenvman.2025.126003
```

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
* 


