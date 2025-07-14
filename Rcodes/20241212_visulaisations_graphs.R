

# read and correct data #####
df <- X20241027_data_yield

df <- 
  df %>% 
  mutate(country_new = if_else(country_new == "United States of America", "USA", country_new))

df$measurement_id <- as.factor(df$measurement_id)
length(levels(df$measurement_id))

df$country_new <- as.factor(df$country_new)
length(levels(df$country_new))

df$treatment <- as.factor(df$treatment)
length(levels(df$treatment))
summary(df$landcover_map_year)



##### map graph ############
df_map <- 
  df %>% 
  select(measurement_id, country_new) %>% 
  unique()

# Summarize the number of points per country
country_counts <- df_map %>%
  group_by(country_new) %>%
  summarise(count = n())

# Get world map data
world_map <- map_data("world")

# Merge the country counts with the map data
map_data <- world_map %>%
  left_join(country_counts, by = c("region" = "country_new"))

# Calculate centroids for label placement
centroids <- map_data %>%
  group_by(region) %>%
  summarise(long = mean(range(long)), lat = mean(range(lat))) %>%
  left_join(country_counts, by = c("region" = "country_new"))

# Plot the map with the number of points per country and add labels
ggplot(map_data, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = count), color = "white") +
  #geom_text_repel(data = centroids, aes(label = count, x = long, y = lat),
  #                size = 3, color = "black", inherit.aes = FALSE, na.rm = TRUE) +
  scale_fill_gradient(low = "lightblue", high = "darkblue", na.value = "grey50") +
  theme_void() +
  labs(fill = "Number of articles \nper country")



##### buffer selection #########


data_buffer1000 <- 
  X20241027_data_yield %>% 
  filter(buffer_radius_m == 1000)

data_buffer1000$class <- as.factor(data_buffer1000$class)

data_buffer1000_selected <- 
  data_buffer1000 %>% 
  group_by(measurement_id) %>% 
  mutate(croparea = sum(area_m2[class %in% c(10, 11, 12, 20)], na.rm = TRUE)) %>%
  ungroup() %>% 
  select(ma_id, measurement_id, control_id, study_id, yield_control_kgha, yield_treatment_kgha, shannons_index, treatment, crop_type_grouped_small,crop_type_grouped_big, croparea) %>% 
  unique()

data_buffer1000_selected <- 
  data_buffer1000_selected %>% 
  group_by(ma_id, study_id, shannons_index, treatment, crop_type_grouped_small, crop_type_grouped_big, croparea) %>% 
  summarise(mean_yield_control = mean(yield_control_kgha),
            mean_yield_treat = mean(yield_treatment_kgha)) %>% 
  mutate(   mean_yield_control_scaled = mean_yield_control / (croparea),
            mean_yield_treatment_scaled = mean_yield_treat / (croparea)) %>% 
  filter(is.finite(mean_yield_control_scaled), is.finite(mean_yield_treatment_scaled)) %>% 
  ungroup()

df <- data_buffer1000_selected


df_long <- df %>%
  pivot_longer(cols = c(mean_yield_control_scaled, mean_yield_treatment_scaled), 
               names_to = "controltreatment", 
               values_to = "values")

### graph 1 ####

# Filter for crop_type_grouped_small = "Maize"
df_maize <- df %>%
  filter(crop_type_grouped_small == "Maize")

# Fit linear models and extract slope, R-squared, p-value, and number of observations
model_stats <- df_maize %>%
  group_by(treatment) %>%
  do({
    model <- lm(mean_yield_control_scaled ~ shannons_index, data = .)
    summary_model <- summary(model)
    data.frame(
      estimate = coef(model)[2],
      r.squared = summary_model$r.squared,
      p.value = coef(summary_model)[2, 4],
      n = nrow(.)
    )
  })

# Plot scatterplot with linear regression model
ggplot(df_maize, aes(x = shannons_index, y = mean_yield_control_scaled)) +
  geom_point(color = "darkgray", alpha = 0.5) +  # Set points to gray with transparency
  geom_smooth(method = "lm", se = FALSE, color = "#003049") +
  facet_wrap(~ treatment, scales = "free_y", ncol = 2) +  # Use facet_wrap with ncol = 1 for single column
  labs(
    title = "Maize: Yield Control Scaled vs Shannon's Index",
    x = "Shannon's Index",
    y = "Mean Yield Control Scaled kg/ha"
  ) +
  geom_text(
    data = model_stats,
    aes(
      label = paste(
        "Slope:", round(estimate, 3), 
        "\nR²:", round(r.squared, 3),
        "\nP:", format.pval(p.value, digits = 3),
        "\nN:", n
      )
    ),
    x = Inf, y = Inf, hjust = 1.1, vjust = 1.1, size = 3, color = "black"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16),  # Title size
    axis.title.x = element_text(size = 14),              # X-axis label size
    axis.title.y = element_text(size = 14),              # Y-axis label size
    axis.text = element_text(size = 12),                 # Tick labels size
    legend.title = element_text(size = 14),              # Legend title size
    legend.text = element_text(size = 12),               # Legend labels size
    strip.text = element_text(size = 14, face = "bold"), # Facet titles size
    strip.background = element_blank()                   # Remove background for facet titles
  )


### graph 2 ####

# Filter Maize from crop_type_grouped_big
df_long_maize <- df_long %>%
  filter(crop_type_grouped_small == "Maize")



# Plot with linear regression lines and annotations
ggplot(df_long_maize, aes(y = values, x = shannons_index, color = controltreatment)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~ treatment, scales = "free", ncol = 2) +
  theme_minimal() +
  labs(title = "Maize: Yield kg/ha vs Shannon's Index across Treatments",
       x = "Shannon's Index", y = "Yield Scaled kg/ha", color = "Control/Treatment") +
  scale_color_manual(
    values = c("mean_yield_control_scaled" = "gray", 
               "mean_yield_treatment_scaled" = "#7192BE"),  # Set colors if desired
    labels = c("mean_yield_control_scaled" = "Control", 
               "mean_yield_treatment_scaled" = "Treatment")
  )+
  theme(
    plot.title = element_text(size = 16),  # Title size
    axis.title.x = element_text(size = 14),              # X-axis label size
    axis.title.y = element_text(size = 14),              # Y-axis label size
    axis.text = element_text(size = 12),                 # Tick labels size
    legend.title = element_text(size = 14),              # Legend title size
    legend.text = element_text(size = 12),               # Legend labels size
    strip.text = element_text(size = 14, face = "bold")  # Facet titles size
  )




##### graph 1 rice ############
# Filter for crop_type_grouped_small = "Maize"
df_rice <- df %>%
  filter(crop_type_grouped_small == "Rice")

# Fit linear models and extract slope, R-squared, p-value, and number of observations
model_stats <- df_rice %>%
  group_by(treatment) %>%
  do({
    model <- lm(mean_yield_control_scaled ~ shannons_index, data = .)
    summary_model <- summary(model)
    data.frame(
      estimate = coef(model)[2],
      r.squared = summary_model$r.squared,
      p.value = coef(summary_model)[2, 4],
      n = nrow(.)
    )
  })


# Plot scatterplot with linear regression model
ggplot(df_rice, aes(x = shannons_index, y = mean_yield_control_scaled)) +
  geom_point(color = "darkgray", alpha = 0.5) +  # Set points to gray with transparency
  geom_smooth(method = "lm", se = FALSE, color = "#003049") +
  facet_wrap(~ treatment, scales = "free_y", ncol = 2) +  # Use facet_wrap with ncol = 1 for single column
  labs(
    title = "Rice: Yield Control Scaled vs Shannon's Index",
    x = "Shannon's Index",
    y = "Mean Yield Control Scaled kg/ha"
  ) +
  geom_text(
    data = model_stats,
    aes(
      label = paste(
        "Slope:", round(estimate, 3), 
        "\nR²:", round(r.squared, 3),
        "\nP:", format.pval(p.value, digits = 3),
        "\nN:", n
      )
    ),
    x = Inf, y = Inf, hjust = 1.1, vjust = 1.1, size = 3, color = "black"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16),  # Title size
    axis.title.x = element_text(size = 14),              # X-axis label size
    axis.title.y = element_text(size = 14),              # Y-axis label size
    axis.text = element_text(size = 12),                 # Tick labels size
    legend.title = element_text(size = 14),              # Legend title size
    legend.text = element_text(size = 12),               # Legend labels size
    strip.text = element_text(size = 14, face = "bold"), # Facet titles size
    strip.background = element_blank()                   # Remove background for facet titles
  )



### graph 2 rice ####

# Filter Maize from crop_type_grouped_big
df_long_rice <- df_long %>%
  filter(crop_type_grouped_small == "Rice")



# Plot with linear regression lines and annotations
ggplot(df_long_rice, aes(y = values, x = shannons_index, color = controltreatment)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~ treatment, scales = "free", ncol = 2) +
  theme_minimal() +
  labs(title = "Rice: Yield kg/ha vs Shannon's Index across Treatments",
       x = "Shannon's Index", y = "Yield Scaled kg/ha", color = "Control/Treatment") +
  scale_color_manual(
    values = c("mean_yield_control_scaled" = "gray", 
               "mean_yield_treatment_scaled" = "#7192BE"),  # Set colors if desired
    labels = c("mean_yield_control_scaled" = "Control", 
               "mean_yield_treatment_scaled" = "Treatment")
  )+
  theme(
    plot.title = element_text(size = 16),  # Title size
    axis.title.x = element_text(size = 14),              # X-axis label size
    axis.title.y = element_text(size = 14),              # Y-axis label size
    axis.text = element_text(size = 12),                 # Tick labels size
    legend.title = element_text(size = 14),              # Legend title size
    legend.text = element_text(size = 12),               # Legend labels size
    strip.text = element_text(size = 14, face = "bold")  # Facet titles size
  )
