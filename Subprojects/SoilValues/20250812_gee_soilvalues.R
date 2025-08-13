

df <- read.csv("C:\\Users\\lisa7\\Documents\\UFZ_CLE\\surrounding_landscapes_full_project\\20250812_surrounding_landscapes\\data\\20250812_2_soilvalues.csv")

summary(df)

na <- df[ rowSums(is.na(df)) > 0, ]

full_join