
######

# Author: Elizaveta Shcherbinina 
# Topic: Visualisation of whittaker biomes and the map 

######

library(ggplot2)
library(plotbiomes)
library("rnaturalearth")
library("rnaturalearthdata")
library(patchwork)


df <- read.csv("data/20251006_df_soiltype_unscaled.csv", header = TRUE, sep = ",") # import 20250908_surroundland_landindex_SR_clim_soil_fsize
world <- ne_countries(scale = "medium", returnclass = "sf")



# Plot 1: Whittaker biokmes -----------------------------------------------

my_palette <- (c("#BFBFBF", "#332288", "#1C8A41", "#4CC7B4",
               "#88CCEE", "#DDCC77", "#CC6677",
               "#AA4499", "#882255"))

plot1 <- whittaker_base_plot(
  color_palette =  my_palette
) +
  # add the temperature - precipitation data points
  geom_point(data = df, 
             aes(x = temp_avg_1970.2000, 
                 y = prec_avg_1970.2000), 
             size   = 3,
             shape  = 21,
             colour = "#71869A", 
             fill   = "#141F33",
             stroke = 1,
             alpha  = 0.5) +
  theme_classic() +
  scale_y_continuous(name = 'Mean Annual Precipitation (cm)',
                   limits = c(min = -5, max = ceiling(max(460, df$prec_avg_1970.2000)/10)*10) ,
                   expand = c(0, 0)) +
  # - set range on OX axes and adjust the distance (gap) from OY axes
  scale_x_continuous(name = expression("Mean Annual Temperature " ( degree*C)),
                     limits = c(min = floor(min(-20, df$temp_avg_1970.2000)/5)*5, max = 30.5),
                     expand = c(0, 0)) +
  coord_fixed(ratio = 1/10) + # aspect ratio, expressed as y / x
  theme_classic() +
  theme(
    legend.justification = c(0, 1), # pick the upper left corner of the legend box and
    legend.position = c(0, 1), # adjust the position of the corner as relative to axis
    legend.background = element_rect(fill = NA), # transparent legend background
    legend.box = "horizontal", # horizontal arrangement of multiple legends
    legend.spacing.x = unit(0.5, units = "cm"), # horizontal spacing between legends
    panel.grid = element_blank(), # eliminate grids
    axis.title = element_text(size = 14),
    axis.text  = element_text(size = 14),
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 14)
  )


# Plot 2: Map -------------------------------------------------------------

plot2 <- ggplot(data = world) +
  geom_sf(fill = "#E1E2E4",
          color = "#E1E2E4") +
  geom_point(data = df, 
             aes(x = longitude_decimal, 
                 y = latitude_decimal), 
             size   = 2,
             shape  = 21,
             colour = "#71869A", 
             fill   = "#141F33",
             stroke = 1,
             alpha  = 0.5) + 
  scale_x_continuous(name = expression("Longitude")) +
  scale_y_continuous(name = 'Latitude') +
  theme_classic() +
  theme(
    axis.title = element_text(size = 14),
    axis.text  = element_text(size = 14)
  )


# Combine two plots -------------------------------------------------------
combined_plot <-  plot2 + plot1 + plot_layout(widths = c(3, 2))
combined_plot

# Plot 3: Map with ma_id -------------------------------------------------------------

ggplot(data = world) +
  geom_sf(fill = "#E1E2E4",
          color = "#E1E2E4") +
  geom_point(data = df, 
             aes(x = longitude_decimal, 
                 y = latitude_decimal,
                 fill   = as.factor(df$ma_id)), 
             size   = 2,
             shape  = 21,
             stroke = 1,
             alpha  = 0.5) + 
  scale_x_continuous(name = expression("Longitude")) +
  scale_y_continuous(name = 'Latitude') +
  theme_classic() +
  theme(
    axis.title = element_text(size = 16),
    axis.text  = element_text(size = 16)
  ) +
  guides(fill = "none")


# Plot 4 whittaker ma_id ------------------------------------------------------------------

whittaker_base_plot(
  color_palette = my_palette
) +
  geom_point(data = df, 
             aes(x = temp_avg_1970.2000, 
                 y = prec_avg_1970.2000,
                 color = as.factor(ma_id)),  # no need for df$ inside aes
             size   = 3,
             shape  = 20, 
             stroke = 1,
             alpha  = 0.5) +
  scale_y_continuous(
    name = 'Mean Annual Precipitation (cm)',
    limits = c(-5, ceiling(max(460, df$prec_avg_1970.2000) / 10) * 10),
    expand = c(0, 0)
  ) +
  scale_x_continuous(
    name = expression("Mean Annual Temperature " * (degree * C)),
    limits = c(floor(min(-20, df$temp_avg_1970.2000) / 5) * 5, 30.5),
    expand = c(0, 0)
  ) +
  coord_fixed(ratio = 1 / 10) +
  scale_color_manual(name = "Meta-study ID", values = my_palette) +
  theme_classic() +
  theme(
    panel.grid    = element_blank(),
    axis.title    = element_text(size = 16),
    axis.text     = element_text(size = 16),
    legend.text   = element_text(size = 16),
    legend.title  = element_text(size = 16)
  )

