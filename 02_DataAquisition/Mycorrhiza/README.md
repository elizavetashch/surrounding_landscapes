The mycorrhiza dataset was downloaded from the [Society for Protection of Underground Networks website](https://www.spun.earth/underground-atlas/mycorrhizal-biodiversity) and is based on the original publication by [Van Nuland et al. 2025](https://www.nature.com/articles/s41586-025-09277-4). This work is licensed under a Creative Commons Attribution 4.0 International License. 


**Methods Explanation: How the map was built:**

<details>
  <summary>Open here to see relevant method sections from the original paper</summary>

- Motivation of Use:
"Plants can get up to 80% of their phosphorus from mycorrhizal fungi. Underground fungal networks help build productive soils by increasing water and nutrient retention, preventing erosion, and decreasing the amount of nutrients leached out of the soil by more than 50%." https://www.spun.earth/underground-atlas/explainer-article"

- Training data:
First, we explored the distribution and range of the training data (Fig. 1). This dataset consisted of a globally distributed collection of nearly 25,000 soil samples containing >2.8 billion fungal DNA sequences from 130 countries compiled in the GlobalFungi, GlobalAMFungi and Global Soil Mycobiome consortium databases6,7,8.
These sequences were analysed using virtual taxa (VT) for AM fungi and 97% similar operational taxonomic units (OTUs) for EcM fungi. With these data, we estimated AM and EcM fungal richness using a rarefaction and extrapolation approach, and rarity-weighted richness (hereafter ‘rarity’; Extended Data Fig. 1), which is a metric of relative endemism used to guide conservation priorities.


![Figure 1 from the original Paper](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/Subprojects/Mycorrhiza/Publication_Figure1.webp)

</details>

**Download data**
- If you request the data download here: https://www.spun.earth/underground-atlas/data-request
- Then you would recieve two fodlers: AM and EcM fungi
- The folders will contain `.tif` files, namely Distribution of sites and 
  - _Richness_CoefVar
  - _Richness_Extrapolation
  - _Richness_Predicted 
  - _RWR_Empirical_CoefVar
  - _RWR_Empirical_Extrapolation 
  - _RWR_Empirical_Predicted 
  - _RWR_HighSampling_CoefVar 
  - _RWR_HighSampling_Extrapolation
  - _RWR_HighSampling_Predicted

Richness for the AM or EcM richness map and RWR stands for rarity-weighted richness (RWR) estimates.

On the SPUN online map the predicted values are shown, hence we use the
→ `_Richness_Predicted.tif` files 

**Write the GEE code**

The GEE code calculates the 
- point pixel (the value of the mycorrhiza richness map at the exact location)
- the mean richness value in the buffer
- the standard deviations
- and the variance of the richness

and produces an ouput of two files: one for Arbuscular Mycorrhiza (AM) and one for Ectomycorrhiza. 

Link to the code: [GEE Mycorrhiza Code](https://code.earthengine.google.com/27fa943deba3c3ef2d470f40498abf65)
