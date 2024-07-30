# Contents

* **Report.md** is the final report of my internship, where you can find Introduction, Methods, Data Exploration and Results of the project. You can also check this file for better understanding of the dataset.  
* "All_yield_coords_decimals_20240417 - Copy.csv" is the original dataset given me in the beginning of May. This file is used in the R Markdown as input and is processed there (typos, mistakes, treatment assignments corrected).#
* "yield_points_in_wide_format.csv" is the result of processing of All_yield_coords_decimals_20240417 - Copy.csv in the R_data_processing.Rmd. ***Use it for your GEE assets.***
* R_data_processing.Rmd is the Markdown file you 1) process the original dataset (All_yield_coords_decimals_20240417 - Copy.csv), 2) save the processed dataset to use for your google earth engine asset, 3) then after making the calculations in google earth Engine you import the csv files generated in the GEE into this Markdown file, 4) and process them to get the shannon's index, area-to-proportion index and as a result one final table that you can later use for the analysis.
* *"gee_"* files contain the Google Earth Engine code, that you can directly copy into the GEE console and run it. You might need to download the data and upload it in your assets, and use your asset instead of mine for the feature collection.

# How to proceed 
## from the very beginning: 
1. download the All_yield_coords_decimals_20240417 - Copy.csv and the original data supplements (are not yet in github).
2. Use the data from the 1. step as the input for R_data_processing.Rmd
3. Get the yield_points_in_wide_format.csv, yield_points_in_wide_format_2009_part1.csv, yield_points_in_wide_format_2009_part2.csv
## start with GEE
4. Upload the yield_points_in_wide_format.csv, yield_points_in_wide_format_2009_part1.csv, yield_points_in_wide_format_2009_part2.csv on your GEE assets.
5. Run the *gee_area_proportion_calculation* for area proportion calculation. You will get 20 csv files on your google drive. Download them.
6. Run the *gee_edgelength_calculation* for edge length calculation. You will get 21 csv files on your google drive. Download them.
7. Use these csv files in the R_data_processing.Rmd to get the final data_with_landscape_metrics.csv.
## or just use the final data
8. You can also directly download the *data_with_landscape_metrics.csv*
