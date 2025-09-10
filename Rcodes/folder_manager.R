


# 12th august 2025

getwd()
df <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\20241216_data_processed.csv")

df_section <- df[, c("ma_id", "measurement_id", "study_id", "longitude_decimal", "latitude_decimal")]

write.csv(df_section, "C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\20250812_points_onlyID.csv", row.names = FALSE)
