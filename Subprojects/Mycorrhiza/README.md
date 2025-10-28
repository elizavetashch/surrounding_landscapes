The mycorrhiza dataset was downloaded from the [Society for Protection of Underground Networks website](https://www.spun.earth/underground-atlas/mycorrhizal-biodiversity) and is based on the original publication by [Van Nuland et al. 2025](https://www.nature.com/articles/s41586-025-09277-4). This work is licensed under a Creative Commons Attribution 4.0 International License. 

Motivation of USe: 
"Plants can get up to 80% of their phosphorus from mycorrhizal fungi. Underground fungal networks help build productive soils by increasing water and nutrient retention, preventing erosion, and decreasing the amount of nutrients leached out of the soil by more than 50%." https://www.spun.earth/underground-atlas/explainer-article"

Methods Explanation - How th e map was built:

- Training data:
First, we explored the distribution and range of the training data (Fig. 1). This dataset consisted of a globally distributed collection of nearly 25,000 soil samples containing >2.8 billion fungal DNA sequences from 130 countries compiled in the GlobalFungi, GlobalAMFungi and Global Soil Mycobiome consortium databases6,7,8.
These sequences were analysed using virtual taxa (VT) for AM fungi and 97% similar operational taxonomic units (OTUs) for EcM fungi. With these data, we estimated AM and EcM fungal richness using a rarefaction and extrapolation approach, and rarity-weighted richness (hereafter ‘rarity’; Extended Data Fig. 1), which is a metric of relative endemism used to guide conservation priorities23.
