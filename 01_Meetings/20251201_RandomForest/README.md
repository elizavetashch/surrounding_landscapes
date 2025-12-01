## Random Forest Applicaiton on the data set 

date: 01.12.2025

author: Elizaveta Shcherbinina 


Via a random forest decision tree we classify the data. In the following I tried predicting if the crop is pollinated or not pollinated based on the selected columns (prediction accuracy 65%) and on all columns (prediciton accuracy 80%). Also, I tried predicting the lrr (larger/smaller than zero) based on all columns. 

The jupiter notebook files can be found in the 20251201_RandomForest folder. 

The results are here. 


### Pollinated based on the selected columns

Selected columns are: 

```
selected_columns = [
    "nat.hab.1000",
    "cropland.1000",
    "shannon.1000",
    "simpsonsevenness.1000",
    "am.richness.mean.1000",
    "ecm.richness.mean.1000",
    "sr.birds",
    "sr.mammals",
    "temp.avg.1970.2000",
    "prec.avg.1970.2000",
    "latitude.decimal",
    "longitude.decimal",
    'poll.dependent'
]

```
#### Importance of variables
![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/01_Meetings/images/20251130_importance_poll_selected_columns.jpeg)


#### Decision tree
![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/01_Meetings/images/20251130_poll_selected_columns.jpeg)


### Pollinated based on all columns


#### Importance of variables
![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/01_Meetings/images/20251201_importance_poll_all_columns.jpeg)


#### Decision tree
![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/01_Meetings/images/20251201_poll_all_columns.jpeg)


### LRR classes based on all columns

I added a column named lrr.class with values 0 and 1, 0 being values =< 0 and 1 being > 0. 

This way I wanted to see if the dataset can predict the lrr based on teh columns present in the dataset. 


#### Importance of variables
![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/01_Meetings/images/20251201_importance_lrr_all_columns.jpeg)


#### Decision tree
![](https://github.com/elizavetashch/surrounding_landscapes/raw/current_main/01_Meetings/images/20251201_lrr_all_columns.jpeg)


### Multicollinearity 

According to ChatGPT you don't have to check for multicollinearity on Random Forest. 

**Why?**

Random Forests (and tree-based models in general) are **not affected by multicollinearity** in the same way that linear models are. Here’s why:

* Each decision tree splits on one feature at a time, so having correlated features doesn’t cause unstable coefficient estimates like in linear regression.
* The randomness in feature selection at each split means correlated variables will “compete,” but it **does not harm model performance**.
* At worst, collinear features may **dilute feature importance**, but the predictions remain robust.

