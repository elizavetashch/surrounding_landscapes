The SoilGrids dataset was downloaded from the [SoilGrids webpage](https://soilgrids.org/).

LICENSE INFORMATION: This version of SoilGrids is available to you by ISRIC — World Soil Information under the CC-BY 4.0 License. Alternatively, the CC BY licence for individual profiles/properties is indicated in 'wosis_latest'. By using the ISRIC website and web services the user accepts those licenses and the ISRIC data policy in full. 

### Map/Dataset Information 
The dataset was built in the project described in the [ESSD paper](https://essd.copernicus.org/articles/12/299/2020/)
The dataset release: [SoilGrids250m](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0169748)
The GEE community Catalog GEE Datset link: [gee-dataset description](https://gee-community-catalog.org/projects/isric/)

<details>
  <summary>Open here to see relevant method sections from the original paper</summary>
  
  - **Predicitons** were based on ca. 150,000 soil profiles used for training and a stack of 158 remote sensing-based soil covariates (primarily derived from MODIS land products, SRTM DEM derivatives, climatic images and global landform and lithology maps), which were used to fit an ensemble of machine learning methods—random forest and gradient boosting and/or multinomial logistic regression—as implemented in the R packages ranger, xgboost, nnet and caret. 

- **Cross-validation**: The results of 10–fold cross-validation show that the ensemble models explain between 56% (coarse fragments) and 83% (pH) of variation with an overall average of 61%.


![Table A1Coding conventions and soil property names and their description, units of measurement, inferred accuracy, and number of profiles and layers provided in the “WoSIS September 2019” snapshot. Soil properties are listed in alphabetical order using the property code.](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/Subprojects/SoilValues/TableA1_SoilGrids_Variable_Description.png)


![Fig 2. Example of soil variable-depth curves: Original sampled soil profiles (black rectangles) vs predicted SoilGrids values at seven standard depths (broken red line), and predicted soil organic carbon stock for depth intervals 0–100 and 100–200 cm. ](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/Subprojects/SoilValues/Fig2soildepths.png)
Locations of points from the USDA National Cooperative Soil Survey Soil Characterization database: mineral soil S1991CA055001 (-122.37°W, 38.25°N), and an organic soil profile S2012CA067002 (-121.62°W, 38.13°N).

![Fig 7. Examples of relationships for target variables and the most important covariates: (top row) bulk density in kg m−3, (middle row) soil pH, and (bottom row) soil organic carbon in permilles (on log scale).
](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/Subprojects/SoilValues/Fig7_targetvariables_covariates.png)

Plots show target variables and the top three most important covariates as reported by the random forest model. DEPTH.f is the observed depth from soil surface, T09MOD3 is mean monthly temperature for September, TMDMOD3 is mean annual temperature, PRSMRG3 is total annual precipitation, M04MOD4 is mean monthly MODIS NIR band reflectance for April, P07MRG3 is mean monthly precipitation for July, T01MOD3 is mean monthly temperature for January, and T02MOD3 is mean monthly temperature for February. 

</details>

### Write the GEE Code 
- I rewrote the soilgrids code in the same format my other codes are written (first define the addPixelValue function, then apply it)
- you will see that in the code the asset _mean was used. mean is the name of the asset, but it contains all the depths as bands

Link to the code: [GEE SoilGrids 2.0](https://code.earthengine.google.com/1154d785c765ef082d22e69140981b9e)
