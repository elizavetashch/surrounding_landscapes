# Author: Elizaveta Shcherbinina
# Date: 28.09.2025
library(metafor)
library(lme4)
library(Matrix)
library(ggplot2)
library(dplyr)
library(tidyr)
library(MuMIn)
library(broom.mixed)
library(plotly)
library(ggeffects)
library(sjPlot)
library(splines)

# BELOW code originally from Dr. Elina Takola 

options(scipen = 999) # disable scientific notation

df <- read.csv("data/20251006_df_soiltype_scaled.csv", header = TRUE, sep = ",") # import 20250908_surroundland_landindex_SR_clim_soil_fsize
#df1 <- df
# Round everything to 2 decimals
df <- as.data.frame(lapply(df, function(x) if(is.numeric(x)) round(x, 2) else x))
str(df)

plot(df$nat.hab.1000)
plot(df$nat.hab.2500)
plot(df$nat.hab.5000)

############ 
# Data exploration
############ 
# Let's check collinearity first, before scaling 
library(corrplot)
num_vars <- df[, sapply(df, is.numeric)]  # select numeric columns
cor_matrix <- cor(num_vars, use = "pairwise.complete.obs")
corrplot(cor_matrix, method = "color", tl.cex = 0.7, tl.col = "black")

# Distribution of the response variable
ggplot(df, aes(x = LRR)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "lightblue", color = "black") +
  geom_density(alpha = 0.2, fill = "blue") +
  labs(title = "Distribution of LRR", x = "LRR", y = "Density")

# LRR per harvest year
ggplot(df, aes(x = harvest_year_by_median, y = LRR)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", color = "red", se = TRUE) +
  labs(title = "LRR over Harvest Year", x = "Harvest Year", y = "LRR")

# Facet by crop_type and treatment (trend line per facet, x = harvest_year)
ggplot(df, aes(x = harvest_year_by_median, y = LRR)) +
  geom_point(alpha = 0.5, aes(color = as.factor(treatment))) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_grid(crop_type_grouped_big ~ treatment,
             labeller = labeller(.rows = label_wrap_gen(width = 15),
                                 .cols = label_wrap_gen(width = 15))) +
  labs(title = "LRR by Crop Type and Treatment over Harvest Year",
       x = "Harvest Year", y = "LRR") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

# Now let's scale 
# columns to exclude from scaling
exclude_vars <- c(
  "LRR", "LRR_vi", "ma_id", "measurement_id", "study_id", "control_id",
  "author_year", "study_pubyear", "harvest_year", "longitude_decimal",
  "latitude_decimal", "harvest_year_by_median", "poll_dependent"
)

df <- df %>%
  mutate(across(
    .cols = where(is.numeric) & !all_of(exclude_vars),
    .fns  = scale
  ))

crop_table <- table(df$crop_type, df$poll_dependent)
colnames(crop_table) <- c("Pollinator_Independent", "Pollinator_Dependent")
write.csv(crop_table, "crop_pollinator_table.csv", row.names = TRUE)

############ 
# H1: ---------------------------------------------------------------------
# H1:	Land cover diversity (measured with the Shannon index) correlates positively with yield treatment effectiveness.
############ 
shannon1000 <- lmer(LRR ~ shannon.1000 + (1|ma_id/study_id), data = df)  
shannon2500 <- lmer(LRR ~ shannon.2500 + (1|ma_id/study_id), data = df)  
shannon5000 <- lmer(LRR ~ shannon.5000 + (1|ma_id/study_id), data = df)  
summary(shannon1000)
summary(shannon2500)
summary(shannon5000)


# AIC
AIC(shannon1000)
AIC(shannon2500)
AIC(shannon5000)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(shannon1000)
r2_2500 <- r.squaredGLMM(shannon2500)
r2_5000 <- r.squaredGLMM(shannon5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by Shannon diversity models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

# Extract fixed effect estimates and CIs
shannon_results <- bind_rows(
  broom.mixed::tidy(shannon1000, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "1000 m"),
  broom.mixed::tidy(shannon2500, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "2500 m"),
  broom.mixed::tidy(shannon5000, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "5000 m")
)

# Keep only the slope for Shannon index (not the intercept)
shannon_results <- shannon_results %>%
  filter(term %in% c("shannon.1000", "shannon.2500", "shannon.5000"))

# Clean term labels
shannon_results$Scale <- factor(shannon_results$Scale, 
                                levels = c("1000 m", "2500 m", "5000 m"))

# Plot
ggplot(shannon_results, aes(x = Scale, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange(color = "steelblue", size = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "Effect of Shannon diversity on yield response (LRR)",
       x = "Buffer scale",
       y = "Estimated effect (slope ± 95% CI)") +
  coord_flip() +
  theme_minimal(base_size = 14)
############ 

############ 
# Shannon-poll
############ 
poll <- 
  df %>% 
  filter(poll_dependent == 1)

shannon1000_poll <- lmer(LRR ~ shannon.1000 + (1|ma_id/study_id), data = poll)  
shannon2500_poll <- lmer(LRR ~ shannon.2500 + (1|ma_id/study_id), data = poll)  
shannon5000_poll <- lmer(LRR ~ shannon.5000 + (1|ma_id/study_id), data = poll)  
summary(shannon1000_poll)
summary(shannon2500_poll)
summary(shannon5000_poll)


# AIC
AIC(shannon1000_poll)
AIC(shannon2500_poll)
AIC(shannon5000_poll)


# Calculate R² for each model
r2_1000 <- r.squaredGLMM(shannon1000_poll)
r2_2500 <- r.squaredGLMM(shannon2500_poll)
r2_5000 <- r.squaredGLMM(shannon5000_poll)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by Shannon diversity models for pollinator-dependent crops",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

# Extract fixed effect estimates and CIs
shannon_results <- bind_rows(
  broom.mixed::tidy(shannon1000_poll, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "1000 m"),
  broom.mixed::tidy(shannon2500_poll, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "2500 m"),
  broom.mixed::tidy(shannon5000_poll, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "5000 m")
)

# Keep only the slope for Shannon index (not the intercept)
shannon_results <- shannon_results %>%
  filter(term %in% c("shannon.1000", "shannon.2500", "shannon.5000"))

# Clean term labels
shannon_results$Scale <- factor(shannon_results$Scale, 
                                levels = c("1000 m", "2500 m", "5000 m"))

# Plot
ggplot(shannon_results, aes(x = Scale, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange(color = "steelblue", size = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "Effect of Shannon diversity on yield response (LRR) for pollinator-dependent crops",
       x = "Buffer scale",
       y = "Estimated effect (slope ± 95% CI)") +
  coord_flip() +
  theme_minimal(base_size = 14)


############ 
# Shannon-nopoll
############ 
nopoll <- 
  df %>% 
  filter(poll_dependent == 0)

shannon1000_nopoll <- lmer(LRR ~ shannon.1000 + (1|ma_id/study_id), data = nopoll)  
shannon2500_nopoll <- lmer(LRR ~ shannon.2500 + (1|ma_id/study_id), data = nopoll)  
shannon5000_nopoll <- lmer(LRR ~ shannon.5000 + (1|ma_id/study_id), data = nopoll)  
summary(shannon1000_nopoll)
summary(shannon2500_nopoll)
summary(shannon5000_nopoll)

# AIC
AIC(shannon1000_nopoll)
AIC(shannon2500_nopoll)
AIC(shannon5000_nopoll)


# Calculate R² for each model
r2_1000 <- r.squaredGLMM(shannon1000_nopoll)
r2_2500 <- r.squaredGLMM(shannon2500_nopoll)
r2_5000 <- r.squaredGLMM(shannon5000_nopoll)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by Shannon diversity models for pollinator independent crops",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

# Extract fixed effect estimates and CIs
shannon_results <- bind_rows(
  broom.mixed::tidy(shannon1000_nopoll, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "1000 m"),
  broom.mixed::tidy(shannon2500_nopoll, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "2500 m"),
  broom.mixed::tidy(shannon5000_nopoll, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "5000 m")
)

# Keep only the slope for Shannon index (not the intercept)
shannon_results <- shannon_results %>%
  filter(term %in% c("shannon.1000", "shannon.2500", "shannon.5000"))

# Clean term labels
shannon_results$Scale <- factor(shannon_results$Scale, 
                                levels = c("1000 m", "2500 m", "5000 m"))

# Plot
ggplot(shannon_results, aes(x = Scale, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange(color = "steelblue", size = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "Effect of Shannon diversity on yield response (LRR) for pollinator independent crops",
       x = "Buffer scale",
       y = "Estimated effect (slope ± 95% CI)") +
  coord_flip() +
  theme_minimal(base_size = 14)

############ 

############ 
# H2: ---------------------------------------------------------------------
# H2:	The correlation between percentage of natural habitat and yield varies between crop types and treatments.
############ 
# The following models have convergence problems, thus I use only study_id as random effect
nathab1000 <- lmer(LRR ~ nat.hab.1000 * crop_type_grouped_big + nat.hab.1000 * treatment + (1 | study_id), data = df)
nathab2500 <- lmer(LRR ~ nat.hab.2500 * crop_type_grouped_big + nat.hab.2500 * treatment + (1 | study_id), data = df)
nathab5000 <- lmer(LRR ~ nat.hab.5000 * crop_type_grouped_big + nat.hab.5000 * treatment + (1 | study_id), data = df)
summary(nathab1000)
summary(nathab2500)
summary(nathab5000)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(nathab1000)
r2_2500 <- r.squaredGLMM(nathab2500)
r2_5000 <- r.squaredGLMM(nathab5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by natural habitat models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

# Extract fixed effect estimates and CIs
nathab_results <- bind_rows(
  broom.mixed::tidy(nathab1000, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "1000 m"),
  broom.mixed::tidy(nathab2500, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "2500 m"),
  broom.mixed::tidy(nathab5000, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "5000 m")
)

# Plot the interactions
preds <- ggpredict(nathab1000, terms = c("nat.hab.1000", "crop_type_grouped_big", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment")
preds <- ggpredict(nathab2500, terms = c("nat.hab.2500", "crop_type_grouped_big", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment")
preds <- ggpredict(nathab5000, terms = c("nat.hab.5000", "crop_type_grouped_big", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment")

############ 
# Do the same for natural habitat without grassland
############ 
# The following models have convergence problems, thus I use only study_id as random effect
nathab1000 <- lmer(LRR ~ nat.hab.wo.grass.1000 * crop_type_grouped_big + treatment + (1 | study_id), data = df)
nathab2500 <- lmer(LRR ~ nat.hab.wo.grass.2500 * crop_type_grouped_big + treatment + (1 | study_id), data = df)
nathab5000 <- lmer(LRR ~ nat.hab.wo.grass.5000 * crop_type_grouped_big + treatment + (1 | study_id), data = df)
summary(nathab1000)
summary(nathab2500)
summary(nathab5000)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(nathab1000)
r2_2500 <- r.squaredGLMM(nathab2500)
r2_5000 <- r.squaredGLMM(nathab5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by natural habitat (without grassland) models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

# Extract fixed effect estimates and CIs
nathab_results <- bind_rows(
  broom.mixed::tidy(nathab1000, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "1000 m"),
  broom.mixed::tidy(nathab2500, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "2500 m"),
  broom.mixed::tidy(nathab5000, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "5000 m")
)


# Plot the interactions
preds <- ggpredict(nathab1000, terms = c("nat.hab.wo.grass.1000", "crop_type_grouped_big", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment")
preds <- ggpredict(nathab2500, terms = c("nat.hab.wo.grass.2500", "crop_type_grouped_big", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment")
preds <- ggpredict(nathab5000, terms = c("nat.hab.wo.grass.5000", "crop_type_grouped_big", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment")

############ 

# Elizaveta: add ma_id to H2 ----------------------------------------------
pollnathab1000 <- lmer(LRR ~ nat.hab.1000 * crop_type_grouped_big + nat.hab.1000 * treatment + (1|ma_id/study_id), data = poll)
pollnathab2500 <- lmer(LRR ~ nat.hab.2500 * crop_type_grouped_big + nat.hab.2500 * treatment + (1|ma_id/study_id), data = poll)
pollnathab5000 <- lmer(LRR ~ nat.hab.5000 * crop_type_grouped_big + nat.hab.5000 * treatment + (1|ma_id/study_id), data = poll)
summary(pollnathab1000)
summary(pollathab2500)
summary(pollnathab5000)

# this then again has convergence problems:
nopollnathab1000 <- lmer(LRR ~ nat.hab.1000 * crop_type_grouped_big + nat.hab.1000 * treatment + (1|ma_id/study_id), data = nopoll)
nopollnathab2500 <- lmer(LRR ~ nat.hab.2500 * crop_type_grouped_big + nat.hab.2500 * treatment + (1|ma_id/study_id), data = nopoll)
nopollnathab5000 <- lmer(LRR ~ nat.hab.5000 * crop_type_grouped_big + nat.hab.5000 * treatment + (1|ma_id/study_id), data = nopoll)
summary(nopollnathab1000)
summary(nopollnathab2500)
summary(nopollnathab5000)
# stop of the problematic chunk

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(pollnathab1000)
r2_2500 <- r.squaredGLMM(pollnathab2500)
r2_5000 <- r.squaredGLMM(pollnathab5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by natural habitat models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

# Extract fixed effect estimates and CIs
nathab_results <- bind_rows(
  broom.mixed::tidy(pollnathab1000, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "1000 m"),
  broom.mixed::tidy(pollnathab2500, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "2500 m"),
  broom.mixed::tidy(pollnathab5000, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "5000 m")
)

# Plot the interactions
preds <- ggpredict(pollnathab1000, terms = c("nat.hab.1000", "crop_type_grouped_big", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment")
preds <- ggpredict(pollnathab2500, terms = c("nat.hab.2500", "crop_type_grouped_big", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment")
preds <- ggpredict(pollnathab5000, terms = c("nat.hab.5000", "crop_type_grouped_big", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment")

############ 
# H3: ---------------------------------------------------------------------
# H3:	The correlation between percentage of natural habitat land cover and yield varies with total species richness, 
# climate and location, due to differences in biogeographical characteristics.
############ 
nsrc1000 <- lmer(LRR ~ nat.hab.1000 * SR + nat.hab.1000 * prec_avg_1970.2000 + nat.hab.1000 * temp_avg_1970.2000 + (1 | ma_id/study_id) + (1 | country_new), data = df)
nsrc2500 <- lmer(LRR ~ nat.hab.2500 * SR + nat.hab.2500 * prec_avg_1970.2000 + nat.hab.2500 * temp_avg_1970.2000 + (1 | ma_id/study_id) + (1 | country_new), data = df)
nsrc5000 <- lmer(LRR ~ nat.hab.5000 * SR + nat.hab.5000 * prec_avg_1970.2000 + nat.hab.5000 * temp_avg_1970.2000 + (1 | ma_id/study_id) + (1 | country_new), data = df)
summary(nsrc1000)
summary(nsrc2500)
summary(nsrc5000)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(nsrc1000)
r2_2500 <- r.squaredGLMM(nsrc2500)
r2_5000 <- r.squaredGLMM(nsrc5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by natural habitat, climate and SR models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

# Extract fixed effect estimates and CIs
nsrc_results <- bind_rows(
  broom.mixed::tidy(nsrc1000, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "1000 m"),
  broom.mixed::tidy(nsrc2500, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "2500 m"),
  broom.mixed::tidy(nsrc5000, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "5000 m")
)

# Keep only the coefficients
nsrc_results <- nsrc_results %>%
  filter(term != "(Intercept)")

# Clean term labels
nsrc_results$Scale <- factor(nsrc_results$Scale, 
                             levels = c("1000 m", "2500 m", "5000 m"))

# Plot
ggplot(nsrc_results, aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange(color = "steelblue", size = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(
    title = "Effect of natural habitat, climate and SR on yield response (LRR)",
    x = "Coefficient",
    y = "Estimated effect (slope ± 95% CI)"
  ) +
  coord_flip() +
  facet_grid(term ~ Scale, scales = "free_y", space = "free_y") +
  theme_minimal(base_size = 14) +
  theme(
    strip.text = element_text(size = 12, face = "bold"),
    axis.text.y = element_text(size = 11))
############ 
# Visualize the interactions within 1000 buffer
############ 
# Example: prediction grid for nsrc1000
pred_grid <- expand.grid(
  nat.hab.1000 = seq(min(df$nat.hab.1000, na.rm = TRUE), max(df$nat.hab.1000, na.rm = TRUE), length.out = 30),
  SR = seq(min(df$SR, na.rm = TRUE), max(df$SR, na.rm = TRUE), length.out = 30),
  prec_avg_1970.2000 = mean(df$prec_avg_1970.2000, na.rm = TRUE),
  temp_avg_1970.2000 = mean(df$temp_avg_1970.2000, na.rm = TRUE),
  ma_id = NA,
  study_id = NA,
  country_new = NA
)

pred_grid$LRR_pred <- predict(nsrc1000, newdata = pred_grid, re.form = NA)

fig_3d <- plot_ly(
  x = pred_grid$nat.hab.1000,
  y = pred_grid$SR,
  z = pred_grid$LRR_pred,
  type = "mesh3d",
  colorscale = "Viridis"
) %>%
  layout(
    scene = list(
      xaxis = list(title = "Natural Habitat (1000m)"),
      yaxis = list(title = "Species Richness"),
      zaxis = list(title = "Predicted LRR")
    ),
    title = "3D Interaction: Nat. Habitat × SR"
  )
fig_3d


# Compute marginal effects for the interaction nat.hab.1000 × SR
eff <- ggpredict(nsrc1000, terms = c("nat.hab.1000", "SR [quantile]"))

eff_df <- as.data.frame(eff)

# Plot
# Color-blind-friendly palette (Okabe & Ito, 8 colors)
cb_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", 
                "#0072B2", "#D55E00", "#CC79A7", "#999999")

p <- ggplot(eff_df, aes(x = x, y = predicted, group = group, color = group, fill = group)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.3, color = NA) +
  geom_line(size = 1.5) +
  scale_color_manual(values = cb_palette) +
  scale_fill_manual(values = cb_palette) +
  labs(
    title = "Interaction between Natural Habitat (1000m) and Species Richness",
    x = "Natural Habitat (%)",
    y = "Predicted LRR",
    color = "Species Richness (quantiles)",
    fill = "Species Richness (quantiles)"
  ) +
  theme_minimal(base_size = 14)

p

############ 
# Visualize the interactions within 2500 buffer
############ 
# Example: prediction grid for nsrc2500
pred_grid <- expand.grid(
  nat.hab.2500 = seq(min(df$nat.hab.2500, na.rm = TRUE), max(df$nat.hab.2500, na.rm = TRUE), length.out = 30),
  SR = seq(min(df$SR, na.rm = TRUE), max(df$SR, na.rm = TRUE), length.out = 30),
  prec_avg_1970.2000 = mean(df$prec_avg_1970.2000, na.rm = TRUE),
  temp_avg_1970.2000 = mean(df$temp_avg_1970.2000, na.rm = TRUE),
  ma_id = NA,
  study_id = NA,
  country_new = NA
)

pred_grid$LRR_pred <- predict(nsrc2500, newdata = pred_grid, re.form = NA)

fig_3d <- plot_ly(
  x = pred_grid$nat.hab.2500,
  y = pred_grid$SR,
  z = pred_grid$LRR_pred,
  type = "mesh3d",
  colorscale = "Viridis"
) %>%
  layout(
    scene = list(
      xaxis = list(title = "Natural Habitat (2500m)"),
      yaxis = list(title = "Species Richness"),
      zaxis = list(title = "Predicted LRR")
    ),
    title = "3D Interaction: Nat. Habitat × SR"
  )
fig_3d


# Compute marginal effects for the interaction nat.hab.2500 × SR
eff <- ggpredict(nsrc2500, terms = c("nat.hab.2500", "SR [quantile]"))

eff_df <- as.data.frame(eff)

# Plot
p <- ggplot(eff_df, aes(x = x, y = predicted, group = group, color = group, fill = group)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.3, color = NA) +
  geom_line(size = 1.5) +
  scale_color_manual(values = cb_palette) +
  scale_fill_manual(values = cb_palette) +
  labs(
    title = "Interaction between Natural Habitat (2500m) and Species Richness",
    x = "Natural Habitat (%)",
    y = "Predicted LRR",
    color = "Species Richness (quantiles)",
    fill = "Species Richness (quantiles)"
  ) +
  theme_minimal(base_size = 14)

p

############ 
# Visualize the interactions within 5000 buffer
############ 
# Example: prediction grid for nsrc5000
pred_grid <- expand.grid(
  nat.hab.5000 = seq(min(df$nat.hab.5000, na.rm = TRUE), max(df$nat.hab.5000, na.rm = TRUE), length.out = 30),
  SR = seq(min(df$SR, na.rm = TRUE), max(df$SR, na.rm = TRUE), length.out = 30),
  prec_avg_1970.2000 = mean(df$prec_avg_1970.2000, na.rm = TRUE),
  temp_avg_1970.2000 = mean(df$temp_avg_1970.2000, na.rm = TRUE),
  ma_id = NA,
  study_id = NA,
  country_new = NA
)

pred_grid$LRR_pred <- predict(nsrc5000, newdata = pred_grid, re.form = NA)

fig_3d <- plot_ly(
  x = pred_grid$nat.hab.5000,
  y = pred_grid$SR,
  z = pred_grid$LRR_pred,
  type = "mesh3d",
  colorscale = "Viridis"
) %>%
  layout(
    scene = list(
      xaxis = list(title = "Natural Habitat (5000m)"),
      yaxis = list(title = "Species Richness"),
      zaxis = list(title = "Predicted LRR")
    ),
    title = "3D Interaction: Nat. Habitat × SR"
  )
fig_3d


# Compute marginal effects for the interaction nat.hab.1000 × SR
eff <- ggpredict(nsrc5000, terms = c("nat.hab.5000", "SR [quantile]"))

eff_df <- as.data.frame(eff)

# Plot
p <- ggplot(eff_df, aes(x = x, y = predicted, group = group, color = group, fill = group)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.3, color = NA) +
  geom_line(size = 1.5) +
  scale_color_manual(values = cb_palette) +
  scale_fill_manual(values = cb_palette) +
  labs(
    title = "Interaction between Natural Habitat (5000m) and Species Richness",
    x = "Natural Habitat (%)",
    y = "Predicted LRR",
    color = "Species Richness (quantiles)",
    fill = "Species Richness (quantiles)"
  ) +
  theme_minimal(base_size = 14)

p

############ 

############ 
# H4: ---------------------------------------------------------------------
# H4:	The percentage of arable area is negatively associated with yield, but not in a linear way, 
# because a steep increase of arable land in an area can lead to land degradation and decrease of species richness.  
############ 
# We need to fit a quadratic effect in the model because we expect non-linear effects
crop1000 <- lmer(LRR ~ cropland.1000 + I(cropland.1000^2) + (1 | ma_id/study_id) + (1 | country_new), data = df)
crop2500 <- lmer(LRR ~ cropland.2500 + I(cropland.2500^2) + (1 | ma_id/study_id) + (1 | country_new), data = df)
crop5000 <- lmer(LRR ~ cropland.5000 + I(cropland.5000^2) + (1 | ma_id/study_id) + (1 | country_new), data = df)

# Create a sequence of cropland values for predictions
cropland_seq1000 <- seq(min(df$cropland.1000, na.rm = TRUE), max(df$cropland.1000, na.rm = TRUE), length.out = 100)
cropland_seq2500 <- seq(min(df$cropland.2500, na.rm = TRUE), max(df$cropland.2500, na.rm = TRUE), length.out = 100)
cropland_seq5000 <- seq(min(df$cropland.5000, na.rm = TRUE), max(df$cropland.5000, na.rm = TRUE), length.out = 100)

# Make a new data frame for predictions
pred_df1000 <- data.frame(cropland.1000 = cropland_seq1000)
pred_df2500 <- data.frame(cropland.2500 = cropland_seq2500)
pred_df5000 <- data.frame(cropland.5000 = cropland_seq5000)

# Predict LRR using fixed effects only
pred_df1000$LRR_pred <- predict(crop1000, newdata = pred_df1000, re.form = NA)
pred_df2500$LRR_pred <- predict(crop2500, newdata = pred_df2500, re.form = NA)
pred_df5000$LRR_pred <- predict(crop5000, newdata = pred_df5000, re.form = NA)

# Plot the curve

# Add a buffer column to each prediction df
pred_df1000$buffer <- "1000 m"
pred_df2500$buffer <- "2500 m"
pred_df5000$buffer <- "5000 m"

# Combine all predictions
pred_all <- bind_rows(pred_df1000, pred_df2500, pred_df5000) %>%
  pivot_longer(cols = starts_with("cropland"),
               names_to = "variable",
               values_to = "cropland") %>%
  mutate(buffer = factor(buffer, levels = c("1000 m", "2500 m", "5000 m")))

# Plot all curves
ggplot(pred_all, aes(x = cropland, y = LRR_pred, color = buffer)) +
  geom_line(size = 1) +
  labs(x = "Cropland (%)", y = "Predicted LRR",
       title = "Predicted relationship between cropland and LRR") +
  theme_minimal(base_size = 14) +
  scale_color_manual(values = c("#20A39E", "#FFBA49", "#EF5B5B"))

############ 


# Elizaveta: H4 but with splines ------------------------------------------

# source: https://www.clayford.net/statistics/using-natural-splines-in-linear-modeling/
crop1000_orig <- lmer(LRR ~ cropland.1000 + (1 | ma_id/study_id) + (1 | country_new), data = df)
plot_model(crop1000_spline, type = "slope") +
  theme_bw() +
  theme(
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    plot.title   = element_blank(),        
    plot.subtitle = element_text(size = 12)
  )

crop1000_orig <- lmer(LRR ~ cropland.1000 + (1 | ma_id/study_id) + (1 | country_new), data = df)
crop1000 <- lmer(LRR ~ cropland.1000 + I(cropland.1000^2) + (1 | ma_id/study_id) + (1 | country_new), data = df)
crop1000_spline <- lmer(LRR ~ ns(cropland.1000, df = 3) + (1 | ma_id/study_id) + (1 | country_new), data = df)

AIC(crop1000_orig) # It has the lowest AIC, meaning it fits the data better while penalizing unnecessary complexity.
AIC(crop1000) 
AIC(crop1000_spline) # But splines perform better than crop1000

crop1000_spline <- lmer(LRR ~ ns(cropland.1000, df = 3) + (1 | ma_id/study_id) + (1 | country_new), data = df)
crop2500_spline <- lmer(LRR ~ ns(cropland.2500, df = 3) + (1 | ma_id/study_id) + (1 | country_new), data = df)
crop5000_spline <- lmer(LRR ~ ns(cropland.5000, df = 3) + (1 | ma_id/study_id) + (1 | country_new), data = df)

summary(crop1000_spline)
summary(crop2500_spline)
summary(crop5000_spline)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(crop1000_spline)
r2_2500 <- r.squaredGLMM(crop2500_spline)
r2_5000 <- r.squaredGLMM(crop5000_spline)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by natural habitat, climate and SR models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

# Extract fixed effect estimates and CIs
nsrc_results <- bind_rows(
  broom.mixed::tidy(crop1000_spline, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "1000 m"),
  broom.mixed::tidy(crop2500_spline, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "2500 m"),
  broom.mixed::tidy(crop5000_spline, effects = "fixed", conf.int = TRUE) %>% mutate(Scale = "5000 m")
)

# Keep only the coefficients
nsrc_results <- nsrc_results %>%
  filter(term != "(Intercept)")

# Clean term labels
nsrc_results$Scale <- factor(nsrc_results$Scale, 
                             levels = c("1000 m", "2500 m", "5000 m"))

# Plot
ggplot(nsrc_results, aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange(color = "steelblue", size = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(
    title = "Effect of natural habitat, climate and SR on yield response (LRR)",
    x = "Coefficient",
    y = "Estimated effect (slope ± 95% CI)"
  ) +
  coord_flip() +
  facet_grid(term ~ Scale, scales = "free_y", space = "free_y") +
  theme_minimal(base_size = 14) +
  theme(
    strip.text = element_text(size = 12, face = "bold"),
    axis.text.y = element_text(size = 11))

############ 
# H5: ---------------------------------------------------------------------
# H5:	Landscape composition and configuration within 1 km radius from the field affect the effectiveness 
# of yield treatments stronger than within 5 km radius.
############ 
# Land cover classes are highly correlated, therefore we need a PCA
# Choose the components that explain ~80% of the variance
# for 1000
predictors_1000 <- df %>%
  select(nat.hab.1000, nat.hab.wo.grass.1000, cropland.1000, inert.1000, 
         shannon.1000, simpsonsevenness.1000)
pca_1000 <- prcomp(predictors_1000, center = TRUE, scale. = TRUE)
summary(pca_1000)
df_pca_1000 <- cbind(df, pca_1000$x[, 1:2])
colnames(df_pca_1000)[(ncol(df)+1):(ncol(df)+2)] <- c("PC1_1000", "PC2_1000")

# for 2500
predictors_2500 <- df %>%
  select(nat.hab.2500, nat.hab.wo.grass.2500, cropland.2500, inert.2500, 
         shannon.2500, simpsonsevenness.2500)
pca_2500 <- prcomp(predictors_2500, center = TRUE, scale. = TRUE)
summary(pca_2500)
df_pca_2500 <- cbind(df, pca_2500$x[, 1:2])
colnames(df_pca_2500)[(ncol(df)+1):(ncol(df)+2)] <- c("PC1_2500", "PC2_2500")

# for 5000
predictors_5000 <- df %>%
  select(nat.hab.5000, nat.hab.wo.grass.5000, cropland.5000, inert.5000, 
         shannon.5000, simpsonsevenness.5000)
pca_5000 <- prcomp(predictors_5000, center = TRUE, scale. = TRUE)
summary(pca_5000)
df_pca_5000 <- cbind(df, pca_5000$x[, 1:2])
colnames(df_pca_5000)[(ncol(df)+1):(ncol(df)+2)] <- c("PC1_5000", "PC2_5000")



# Composition vs configuration per buffer

comp1000 <- lmer(LRR ~ (1 | ma_id/study_id) + PC1_1000 + PC2_1000, data = df_pca_1000)
comp2500 <- lmer(LRR ~ (1 | ma_id/study_id) + PC1_2500 + PC2_2500, data = df_pca_2500)
comp5000 <- lmer(LRR ~ (1 | ma_id/study_id) + PC1_5000 + PC2_5000, data = df_pca_5000)


# Now do the same for the configuration
# for 1000
# Extract the first two principal components (PCs)
# Select the relevant columns
pca_vars <- df[, c("nat.hab.peri.area.ratio.1000",
                   "nat.hab.wo.grass.peri.area.ratio.1000",
                   "crop.peri.area.ratio.1000",
                   "inert.peri.area.ratio.1000",
                   "nat.hab.edgelength.1000",
                   "nat.hab.wo.grass.edgelength.1000",
                   "crop.edgelength.1000",
                   "inert.edgelength.1000")]
pca_data1000 <- na.omit(pca_vars)
pca_result1000 <- prcomp(pca_data1000, scale. = TRUE)
summary(pca_result1000)
pc_data1000 <- pca_result1000$x[, 1:4]
pca_data_indices1000 <- rownames(pca_data1000)
df_pca1000 <- df[rownames(df) %in% pca_data_indices1000, ]
df_pca1000$PC1_1000 <- pca_data1000[, 1]
df_pca1000$PC2_1000 <- pca_data1000[, 2]
df_pca1000$PC3_1000 <- pca_data1000[, 3]
df_pca1000$PC4_1000 <- pca_data1000[, 4]


# for 2500
pca_vars <- df[, c("nat.hab.peri.area.ratio.2500",
                   "nat.hab.wo.grass.peri.area.ratio.2500",
                   "crop.peri.area.ratio.2500",
                   "inert.peri.area.ratio.2500",
                   "nat.hab.edgelength.2500",
                   "nat.hab.wo.grass.edgelength.2500",
                   "crop.edgelength.2500",
                   "inert.edgelength.2500")]
pca_data2500 <- na.omit(pca_vars)
pca_result2500 <- prcomp(pca_data2500, scale. = TRUE)
summary(pca_result2500)
pc_data2500 <- pca_result2500$x[, 1:4]
pca_data_indices2500 <- rownames(pca_data2500)
df_pca2500 <- df[rownames(df) %in% pca_data_indices2500, ]
df_pca2500$PC1_2500 <- pca_data2500[, 1]
df_pca2500$PC2_2500 <- pca_data2500[, 2]
df_pca2500$PC3_2500 <- pca_data2500[, 3]
df_pca2500$PC4_2500 <- pca_data2500[, 4]


# for 5000
pca_vars <- df[, c("nat.hab.peri.area.ratio.5000",
                   "nat.hab.wo.grass.peri.area.ratio.5000",
                   "crop.peri.area.ratio.5000",
                   "inert.peri.area.ratio.5000",
                   "nat.hab.edgelength.5000",
                   "nat.hab.wo.grass.edgelength.5000",
                   "crop.edgelength.5000",
                   "inert.edgelength.5000")]
pca_data5000 <- na.omit(pca_vars)
pca_result5000 <- prcomp(pca_data5000, scale. = TRUE)
summary(pca_result5000)
pc_data5000 <- pca_result5000$x[, 1:4]
pca_data_indices5000 <- rownames(pca_data5000)
df_pca5000 <- df[rownames(df) %in% pca_data_indices5000, ]
df_pca5000$PC1_5000 <- pc_data5000[, 1]
df_pca5000$PC2_5000 <- pc_data5000[, 2]
df_pca5000$PC3_5000 <- pc_data5000[, 3]
df_pca5000$PC4_5000 <- pc_data5000[, 4]


# Configuration models
config1000 <- lmer(LRR ~ PC1_1000 + PC2_1000 + PC3_1000 + PC4_1000 + (1 | ma_id/study_id), data = df_pca1000)

config2500 <- lmer(LRR ~ PC1_2500 + PC2_2500 + PC3_2500 + PC4_2500 + (1 | ma_id/study_id), data = df_pca2500)

config5000 <- lmer(LRR ~ PC1_5000 + PC2_5000 + PC3_5000 + PC4_5000 + (1 | ma_id/study_id), data = df_pca5000)

models <- list("comp1000" = comp1000, 
               "comp2500" = comp2500, 
               "comp5000" = comp5000, 
               "config1000" = config1000, 
               "config2500" = config2500, 
               "config5000" = config5000)
# Calculate AIC for all models
aic_results <- data.frame(
  Model = names(models),
  AIC = sapply(models, AIC)
)

# Sort by AIC (lowest first)
aic_results <- aic_results[order(aic_results$AIC), ]



r2_list <- lapply(models, function(m) {
  r <- tryCatch(r.squaredGLMM(m), error = function(e) c(NA, NA))
  # ensure numeric
  c(Marginal = as.numeric(r[1]), Conditional = as.numeric(r[2]))
})

r2_df <- bind_rows(lapply(seq_along(r2_list), function(i) {
  tibble(
    Model       = names(models)[i],
    Marginal    = r2_list[[i]]["Marginal"],
    Conditional = r2_list[[i]]["Conditional"]
  )
}))

r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal,
         Type = ifelse(grepl("^comp", Model), "Composition", "Configuration"),
         Scale = case_when(
           grepl("1000", Model) ~ "1000 m",
           grepl("2500", Model) ~ "2500 m",
           grepl("5000", Model) ~ "5000 m",
           TRUE ~ Model
         ))

# long format (for plotting)
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2") %>%
  mutate(
    Component = factor(Component, levels = c("Marginal", "Random", "Conditional")),
    Scale = factor(Scale, levels = c("1000 m", "2500 m", "5000 m"))
  )


p_r2 <- ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_col(position = "dodge") +
  facet_wrap(~Type) +
  scale_fill_manual(values = c("Marginal" = "skyblue", "Random" = "orange", "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by composition vs configuration models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)


all_results <- bind_rows(
  tidy(comp1000, effects = "fixed", conf.int = TRUE)  %>% mutate(Model = "Composition", Scale = "1000 m"),
  tidy(comp2500, effects = "fixed", conf.int = TRUE)  %>% mutate(Model = "Composition", Scale = "2500 m"),
  tidy(comp5000, effects = "fixed", conf.int = TRUE)  %>% mutate(Model = "Composition", Scale = "5000 m"),
  tidy(config1000, effects = "fixed", conf.int = TRUE) %>% mutate(Model = "Configuration", Scale = "1000 m"),
  tidy(config2500, effects = "fixed", conf.int = TRUE) %>% mutate(Model = "Configuration", Scale = "2500 m"),
  tidy(config5000, effects = "fixed", conf.int = TRUE) %>% mutate(Model = "Configuration", Scale = "5000 m")
)

all_results <- all_results %>%
  filter(term != "(Intercept)") %>%
  mutate(
    Scale = factor(Scale, levels = c("1000 m", "2500 m", "5000 m")),
    term = factor(term)
  )


ggplot(all_results, aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high,
                        color = Scale)) +
  geom_pointrange(position = position_dodge(width = 0.6), size = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  facet_wrap(~Model, scales = "free_y") +   
  coord_flip() +
  labs(title = "Fixed effect estimates (±95% CI)",
       x = "Predictor",
       y = "Estimated slope",
       color = "Buffer scale") +
  theme_minimal(base_size = 14)


############ 


############ 
# Pollinator-dependence
############ 
#Run once
 # df$poll_dependent2 <- factor(df$poll_dependent,
 #                            levels = c(0, 1),
 #                            labels = c("Non-Pollinator Dependent", "Pollinator Dependent"))
ggplot(df, aes(x = crop_type_grouped_small, y = LRR, color = treatment)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +  
  facet_wrap(~ poll_dependent2, scales = "free_x") + 
  labs(title = "LRR per Crop Type and Treatment by Pollinator Dependency",
       x = "Crop Type (Small Groups)", y = "LRR", color = "Treatment") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Create subsets
nopoll<- df[df$poll_dependent == 0, ]
poll <- df[df$poll_dependent == 1, ]
# H2: The correlation between percentage of natural habitat and yield varies between crop types and treatments, due to pollinator dependence.
nathab1000_nopoll <- lmer(LRR ~ nat.hab.1000 * crop_type_grouped_small + nat.hab.1000 * treatment + (1 | study_id), data = nopoll)
nathab2500_nopoll <- lmer(LRR ~ nat.hab.2500 * crop_type_grouped_small + nat.hab.2500 * treatment + (1 | study_id), data = nopoll)
nathab5000_nopoll <- lmer(LRR ~ nat.hab.5000 * crop_type_grouped_small + nat.hab.5000 * treatment + (1 | study_id), data = nopoll)
nathab1000_poll <- lmer(LRR ~ nat.hab.1000 * crop_type_grouped_small+ nat.hab.1000 * treatment + (1 | study_id), data = poll)
nathab2500_poll <- lmer(LRR ~ nat.hab.2500 * crop_type_grouped_small + nat.hab.2500 * treatment + (1 | study_id), data = poll)
nathab5000_poll <- lmer(LRR ~ nat.hab.5000 * crop_type_grouped_small + nat.hab.5000 * treatment + (1 | study_id), data = poll)


# Plot the interactions
preds <- ggpredict(nathab1000_nopoll, terms = c("nat.hab.1000", "crop_type_grouped_small", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment (nathab1000_nopoll)")+
  scale_color_viridis_d(option = "D")  
preds <- ggpredict(nathab2500_nopoll, terms = c("nat.hab.2500", "crop_type_grouped_small", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment (nathab2500_nopoll)")+
  scale_color_viridis_d(option = "D")  
preds <- ggpredict(nathab5000_nopoll, terms = c("nat.hab.5000", "crop_type_grouped_small", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment (nathab5000_nopoll)")+
  scale_color_viridis_d(option = "D")  
preds <- ggpredict(nathab1000_poll, terms = c("nat.hab.1000", "crop_type_grouped_small", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment (nathab1000_poll)")+
  scale_color_viridis_d(option = "D")  
preds <- ggpredict(nathab2500_poll, terms = c("nat.hab.2500", "crop_type_grouped_small", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment (nathab2500_poll)")+
  scale_color_viridis_d(option = "D")  
preds <- ggpredict(nathab5000_poll, terms = c("nat.hab.5000", "crop_type_grouped_small", "treatment"))
plot(preds) + labs(title = "Predicted effect of natural habitat by crop type and treatment (nathab5000_poll)")+
  scale_color_viridis_d(option = "D")  




############ 
# Field size 
############ 
field_size <- lmer(LRR ~ fieldsize + (1 | ma_id/study_id), data = df)

# Extract fixed effects from the model
field_results <- broom.mixed::tidy(field_size, effects = "fixed", conf.int = TRUE)

# Remove intercept
field_results_clean <- field_results %>%
  filter(term != "(Intercept)")

# Manually rename the levels based on actual term names
field_results_clean$term <- factor(field_results_clean$term,
                                   levels = c("fieldsizeverysmall_area_m", "fieldsizesmall_area_m", "fieldsizemedium_area_m", "fieldsizeverylarge_area_m", "fieldsizenofield_area_m"),
                                   labels = c("Very Small", "Small", "Medium", "Very Large", "Not fields"))# Make sure 'term' is a factor in the order you want


# Plot with all points the same color
ggplot(field_results_clean, aes(x = term, y = estimate,
                                ymin = conf.low, ymax = conf.high)) +
  geom_pointrange(size = 1, shape = 23, fill = "#0D324D", color = "#0D324D") +  # rhombus
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
  labs(
    title = "Effect of Field Size on LRR",
    x = "Field Size",
    y = "Estimate ± 95% CI"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(angle = 30, hjust = 1),
    legend.position = "none",
    panel.border = element_rect(color = "black", fill = NA, size = 1)  # outline
  )

########
# Surrounding fields' size
########

field1000vs <- lmer(LRR ~  verysmall_area_m.1000 + (1 | ma_id/study_id), data = df)
field2500vs <- lmer(LRR ~  verysmall_area_m.2500 + (1 | ma_id/study_id), data = df)
field5000vs <- lmer(LRR ~ verysmall_area_m.5000 + (1 | ma_id/study_id), data = df)
field1000s <- lmer(LRR ~  small_area_m.1000 + (1 | ma_id/study_id), data = df)
field2500s <- lmer(LRR ~  small_area_m.2500 + (1 | ma_id/study_id), data = df)
field5000s <- lmer(LRR ~ small_area_m.5000 + (1 | ma_id/study_id), data = df)
field1000m <- lmer(LRR ~  medium_area_m.1000 + (1 | ma_id/study_id), data = df)
field2500m <- lmer(LRR ~  medium_area_m.2500 + (1 | ma_id/study_id), data = df)
field5000m <- lmer(LRR ~ medium_area_m.5000 + (1 | ma_id/study_id), data = df)
field1000l <- lmer(LRR ~  large_area_m.1000 + (1 | ma_id/study_id), data = df)
field2500l <- lmer(LRR ~  large_area_m.2500 + (1 | ma_id/study_id), data = df)
field5000l <- lmer(LRR ~ large_area_m.5000 + (1 | ma_id/study_id), data = df)
#field1000vl <- lmer(LRR ~  verylarge_area_m.1000 + (1 | study_id), data = df)
#field2500vl <- lmer(LRR ~  verylarge_area_m.2500 + (1 | study_id), data = df)
#field5000vl <- lmer(LRR ~ verylarge_area_m.5000 + (1 | study_id), data = df)

models <- list(
  "field1000vs" = field1000vs,
  "field2500vs" = field2500vs,
  "field5000vs" = field5000vs,
  "field1000s" = field1000s,
  "field2500s" = field2500s,
  "field5000s" = field5000s,
  "field1000m" = field1000m,
  "field2500m" = field2500m,
  "field5000m" = field5000m,
  "field1000l" = field1000l,
  "field2500l" = field2500l,
  "field5000l" = field5000l#,
  #  "field1000" = field1000vl,
  #  "field2500" = field2500vl,
  #  "field5000" = field5000vl
)

field_results <- bind_rows(lapply(names(models), function(m) {
  broom.mixed::tidy(models[[m]], effects = "fixed", conf.int = TRUE) %>%
    mutate(Model = m)
}))
field_results_clean <- field_results %>%
  filter(term != "(Intercept)")
# Enforce order
field_results_clean$Model <- factor(
  field_results_clean$Model,
  levels = c(
    "field1000vs", "field1000s", "field1000m", "field1000l",
    "field2500vs", "field2500s", "field2500m", "field2500l",
    "field5000vs", "field5000s", "field5000m", "field5000l"
  )
)
field_results_clean <- field_results_clean %>%
  mutate(
    buffer = factor(case_when(
      Model %in% c("field1000vs", "field1000s", "field1000m", "field1000l") ~ "1000 m",
      Model %in% c("field2500vs", "field2500s", "field2500m", "field2500l") ~ "2500 m",
      Model %in% c("field5000vs", "field5000s", "field5000m", "field5000l") ~ "5000 m"
    ), levels = c("1000 m", "2500 m", "5000 m"))
  )
field_results_clean <- field_results_clean %>%
  mutate(
    field_size = factor(case_when(
      term %in% c("verysmall_area_m.1000", "verysmall_area_m.2500", "verysmall_area_m.5000") ~ "Very Small",
      term %in% c("small_area_m.1000", "small_area_m.2500", "small_area_m.5000") ~ "Small",
      term %in% c("medium_area_m.1000", "medium_area_m.2500", "medium_area_m.5000") ~ "Medium",
      term %in% c("large_area_m.1000", "large_area_m.2500", "large_area_m.5000") ~ "Large"
    ), levels = c("Very Small", "Small", "Medium", "Large"))
  )

ggplot(field_results_clean, aes(x = field_size, y = estimate,
                                ymin = conf.low, ymax = conf.high,
                                color = field_size)) +
  geom_pointrange(size = 1) +  # default points with error bars
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
  labs(
    title = "Effect of Surrounding Field Size on LRR across Buffers",
    x = "Field Size",
    y = "Estimate ± 95% CI",
    color = "Field Size"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(angle = 30, hjust = 1),
    legend.position = "right",
    panel.border = element_rect(color = "black", fill = NA, size = 1)
  ) +
  facet_wrap(~ buffer)


###### 
###### 
# The interaction of field size with surrounding natural habitat.
###### 
fsize_nathab1000 <- lmer(LRR ~ fieldsize*nat.hab.1000 + (1 | ma_id/study_id), data = df)
fsize_nathab2500 <- lmer(LRR ~ fieldsize*nat.hab.2500 + (1 | ma_id/study_id), data = df)
fsize_nathab5000 <- lmer(LRR ~ fieldsize*nat.hab.5000 + (1 | ma_id/study_id), data = df)
summary(fsize_nathab1000)
summary(fsize_nathab2500)
summary(fsize_nathab5000)


# Create a new data frame with all combinations of fieldsize and nat.hab for each buffer
newdata <- bind_rows(
  expand.grid(fieldsize = unique(df$fieldsize),
              nat.hab.1000 = seq(min(df$nat.hab.1000), max(df$nat.hab.1000), length.out = 10),
              ma_id = NA, study_id = NA) %>% mutate(buffer = "1000 m"),
  expand.grid(fieldsize = unique(df$fieldsize),
              nat.hab.2500 = seq(min(df$nat.hab.2500), max(df$nat.hab.2500), length.out = 10),
              ma_id = NA, study_id = NA) %>% mutate(buffer = "2500 m"),
  expand.grid(fieldsize = unique(df$fieldsize),
              nat.hab.5000 = seq(min(df$nat.hab.5000), max(df$nat.hab.5000), length.out = 10),
              ma_id = NA, study_id = NA) %>% mutate(buffer = "5000 m")
)

# Add a column to specify which nat.hab variable to use
newdata <- newdata %>%
  mutate(nat.hab = case_when(
    buffer == "1000 m" ~ nat.hab.1000,
    buffer == "2500 m" ~ nat.hab.2500,
    buffer == "5000 m" ~ nat.hab.5000
  ))

# Generate predicted values
newdata <- newdata %>%
  rowwise() %>%
  mutate(estimate = ifelse(buffer == "1000 m",
                           predict(fsize_nathab1000, newdata = cur_data(), re.form = NA),
                           ifelse(buffer == "2500 m",
                                  predict(fsize_nathab2500, newdata = cur_data(), re.form = NA),
                                  predict(fsize_nathab5000, newdata = cur_data(), re.form = NA)
                           )))

# Plot
ggplot(newdata, aes(x = nat.hab, y = estimate, color = fieldsize, group = fieldsize)) +
  geom_line(size = 1) +
  facet_grid(fieldsize ~ buffer, scales = "free_y") +
  labs(
    title = "Predicted LRR by Field Size and Natural Habitat across Buffers",
    x = "Natural Habitat",
    y = "Predicted LRR",
    color = "Field Size"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1),
    legend.position = "right"
  )


###### 

############ 
# Soil 
############
soil0_5cm_1000 <- lmer(LRR ~ bdod_0.5cm_mean.1000 + cec_0.5cm_mean.1000 + clay_0.5cm_mean.1000 + 
                         nitrogen_0.5cm_mean.1000 + ocd_0.5cm_mean.1000 + phh2o_0.5cm_mean.1000 + 
                         sand_0.5cm_mean.1000 + silt_0.5cm_mean.1000 + soc_0.5cm_mean.1000 + 
                         (1 | ma_id/study_id), data = df)
soil0_5cm_2500 <- lmer(LRR ~ bdod_0.5cm_mean.2500 + cec_0.5cm_mean.2500 + clay_0.5cm_mean.2500 + 
                         nitrogen_0.5cm_mean.2500 + ocd_0.5cm_mean.2500 + phh2o_0.5cm_mean.2500 + 
                         sand_0.5cm_mean.2500 + silt_0.5cm_mean.2500 + soc_0.5cm_mean.2500 + 
                         (1 | ma_id/study_id), data = df)
soil0_5cm_5000 <- lmer(LRR ~ bdod_0.5cm_mean.5000 + cec_0.5cm_mean.5000 + clay_0.5cm_mean.5000 + 
                         nitrogen_0.5cm_mean.5000 + ocd_0.5cm_mean.5000 + phh2o_0.5cm_mean.5000 + 
                         sand_0.5cm_mean.5000 + silt_0.5cm_mean.5000 + soc_0.5cm_mean.5000 + 
                         (1 | ma_id/study_id), data = df)

# Combine models into a list
models <- list(
  "1000 m" = soil0_5cm_1000,
  "2500 m" = soil0_5cm_2500,
  "5000 m" = soil0_5cm_5000
)

# Extract fixed effects with confidence intervals
soil_preds <- bind_rows(lapply(names(models), function(buf) {
  broom.mixed::tidy(models[[buf]], effects = "fixed", conf.int = TRUE) %>%
    mutate(buffer = buf)
}))

# Remove intercept
soil_preds_clean <- soil_preds %>% filter(term != "(Intercept)")

# Make buffer a factor for facets
soil_preds_clean$buffer <- factor(soil_preds_clean$buffer, levels = c("1000 m", "2500 m", "5000 m"))

# Plot estimates with error bars and facets
ggplot(soil_preds_clean, aes(x = term, y = estimate, color = buffer)) +
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high), size = 1, position = position_dodge(width = 0.5)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
  labs(
    title = "Effect of Soil Properties on LRR across Buffers",
    x = "Soil Property",
    y = "Estimate ± 95% CI",
    color = "Buffer"
  ) +
  scale_color_brewer(palette = "Set2") +  # qualitative, nice distinct colors
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(angle = 0, hjust = 1),
    panel.border = element_rect(color = "black", fill = NA, size = 1)
  ) +
  coord_flip()


############

# BELOW starts Elizaveta's part 


# Fertility Index #1  -----------------------------------------------------
# source: https://pmc.ncbi.nlm.nih.gov/articles/PMC10857350/
# status: didnt work 

df_fertility <- df %>%
  mutate(Si_pH = case_when(
    phh2o_15.30cm_mean.1000 <= 7.0 ~ 1 / (1 + (phh2o_15.30cm_mean.1000 / 6.25)^(-2.5)),  # "more is better" up to midpoint of 5.5–7.0
    phh2o_15.30cm_mean.1000 > 7.0  ~ 1 / (1 + (phh2o_15.30cm_mean.1000 / 6.25)^(2.5)),    # "less is better" beyond 7.0
  ))

df_fertility <- 
  df_fertility %>% 
  mutate(
        mean_nitrogen = mean(nitrogen_15.30cm_mean.1000, na.rm = TRUE), 
        Si_nitrogen = 1 / (1 + (nitrogen_15.30cm_mean.1000 /mean_nitrogen)^(-2.5)),
        mean_ocs = mean(ocs_0.30cm_mean.1000, na.rm = TRUE),
        Si_ocs = 1 / (1 + (ocs_0.30cm_mean.1000 /mean_ocs)^(-2.5)))

df_fertility <- 
  df_fertility %>% 
  mutate(fertility = 0.5385*Si_ocs+0.3077*Si_pH*0.1538*Si_nitrogen, na.rm = TRUE)



# Soil Type ---------------------------------------------------------------

df_unscaled_soiltype <- df_unscaled %>%
  mutate(
    total= (silt_15.30cm_mean.1000+sand_15.30cm_mean.1000+clay_15.30cm_mean.1000),
    SAND = (sand_15.30cm_mean.1000 / total)*100,
    SILT = (silt_15.30cm_mean.1000 / total)*100,
    CLAY = (clay_15.30cm_mean.1000 / total)*100
  ) %>%
  filter(!is.na(SAND), !is.na(SILT), !is.na(CLAY))

dfsoiltype <- 
df_unscaled_soiltype %>% 
  mutate( soiltype = soiltexture::TT.points.in.classes( 
  tri.data    = df_unscaled_soiltype[269:271], 
  class.sys   = "USDA.TT"
) )  

# Step 1: Convert matrix column to a proper data frame
dfsoiltype <- as.data.frame(dfsoiltype$soiltype)

# Step 2: Add row identifiers (optional but useful)
dfsoiltype <- dfsoiltype %>%
  mutate(X = row_number())

soiltype_long <- dfsoiltype %>%
  pivot_longer(
    cols = -X,
    names_to = "soiltype",
    values_to = "value"
  ) %>%
  filter(value == 1) %>%
  select(X, soiltype)

df_long <- df_unscaled_soiltype %>%
full_join(soiltype_long, by = join_by(X ==X))


# Scale the new dataset 
df <- as.data.frame(lapply(df_long, function(x) if(is.numeric(x)) round(x, 2) else x))
str(df)

exclude_vars <- c(
  "LRR", "LRR_vi", "ma_id", "measurement_id", "study_id", "control_id",
  "author_year", "study_pubyear", "harvest_year", "longitude_decimal",
  "latitude_decimal", "harvest_year_by_median", "poll_dependent"
)

df <- df %>%
  mutate(across(
    .cols = where(is.numeric) & !all_of(exclude_vars),
    .fns  = scale
  ))

###### 
# H6: The effectivness of the treatment will vary between soil types -----------------
###### 


soiltype <- lmer(LRR ~ soiltype + (1 | ma_id/study_id), data = df)

# Extract fixed effects from the model
soiltype_results <- broom.mixed::tidy(soiltype, effects = "fixed", conf.int = TRUE)

# Remove intercept
soiltype_results_clean <- soiltype_results %>%
  filter(term != "(Intercept)")

# Manually rename the levels based on actual term names
soiltype_results_clean$term <- factor(soiltype_results_clean$term,
                                   levels = c("soiltypeClLo","soiltypeLo", "soiltypeLoSa",
                                              "soiltypeSa", "soiltypeSaCl", "soiltypeSaClLo",
                                              "soiltypeSaLo", "soiltypeSiCl", "soiltypeSiClLo",
                                              "soiltypeSiLo"),
                                   labels = c("ClayLoam","Loam", "LoamySand",
                                              "Sand","SandyClay","SandyClayLoam",
                                              "SandyLoam", "SiltyClay", "SiltyClayLoam",
                                              "SiltyLoam"))


# Plot with all points the same color
ggplot(soiltype_results_clean, aes(x = term, y = estimate,
                                ymin = conf.low, ymax = conf.high)) +
  geom_pointrange(size = 1, shape = 23, fill = "#0D324D", color = "#0D324D") +  # rhombus
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
  labs(
    title = "Effect of Soil Type on LRR",
    x = "Soil Type",
    y = "Estimate ± 95% CI"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(angle = 30, hjust = 1),
    legend.position = "none",
    panel.border = element_rect(color = "black", fill = NA, size = 1)  # outline
  )

# Facet by crop_type and soiltype (trend line per facet, x = harvest_year)
ggplot(df, aes(x = harvest_year_by_median, y = LRR)) +
  geom_point(alpha = 0.5, aes(color = as.factor(soiltype))) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_grid(crop_type_grouped_big ~ soiltype,
             labeller = labeller(.rows = label_wrap_gen(width = 15),
                                 .cols = label_wrap_gen(width = 15))) +
  labs(title = "LRR by Crop Type and Soil Type over Harvest Year",
       x = "Harvest Year", y = "LRR") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

# Facet by crop_type and soiltype (trend line per facet, x = harvest_year)
ggplot(df, aes(x = harvest_year_by_median, y = LRR)) +
  geom_point(alpha = 0.5, aes(color = as.factor(soiltype))) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_grid(treatment ~ soiltype,
             labeller = labeller(.rows = label_wrap_gen(width = 15),
                                 .cols = label_wrap_gen(width = 15))) +
  labs(title = "LRR by Treatment and Soil Type over Harvest Year",
       x = "Harvest Year", y = "LRR") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

###### 
# H7: Latitude decimal and soiltypes and nathab -----------------
###### 

soillat <- lmer(LRR ~ latitude_decimal*soiltype + (1|ma_id/study_id), data = df)  
soillat_splines <- lmer(LRR ~ ns(latitude_decimal, df = 4)*soiltype + (1|ma_id/study_id), data = df)  

AIC(soillat)
AIC(soillat_splines) # the error is too high

summary(soillat_splines)

# Extract fixed effects from the model
soillat_splines_results <- broom.mixed::tidy(soillat_splines, effects = "fixed", conf.int = TRUE)

# Remove intercept
soillat_splines_results_clean <- soillat_splines_results %>%
  filter(term != "(Intercept)")

# Plot with all points the same color
ggplot(soillat_splines_results_clean, aes(x = term, y = estimate,
                                   ymin = conf.low, ymax = conf.high)) +
  geom_pointrange(size = 1, shape = 23, fill = "#0D324D", color = "#0D324D") +  # rhombus
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
  labs(
    title = "Effect of Soil Type on LRR",
    x = "Soil Type",
    y = "Estimate ± 95% CI"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(angle = 30, hjust = 1),
    legend.position = "none",
    panel.border = element_rect(color = "black", fill = NA, size = 1)  # outline
  )

# Done: nothing, all around zero 

###### 
# H8: Latitude decimal and soiltypes and shanons  -----------------
###### 

soillatshannon.1000 <- lmer(LRR ~ latitude_decimal + soiltype + shannon.1000 + (1|ma_id/study_id), data = df)  
soillatshannon.2500 <- lmer(LRR ~ latitude_decimal + soiltype + shannon.2500 + (1|ma_id/study_id), data = df)  
soillatshannon.5000 <- lmer(LRR ~ latitude_decimal + soiltype + shannon.5000 + (1|ma_id/study_id), data = df)  

summary(soillatshannon.1000)
summary(soillatshannon.2500)
summary(soillatshannon.5000)


# Calculate R² for each model
r2_1000 <- r.squaredGLMM(soillatshannon.1000)
r2_2500 <- r.squaredGLMM(soillatshannon.2500)
r2_5000 <- r.squaredGLMM(soillatshannon.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) Soiltype + Latitude + Shannon",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

###### 
# H9: Latitude Spline and soiltypes and shanons  -----------------
###### 

slsspline.1000 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype + shannon.1000 + (1|ma_id/study_id), data = df)  
slsspline.2500 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype + shannon.2500 + (1|ma_id/study_id), data = df)  
slsspline.5000 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype + shannon.5000 + (1|ma_id/study_id), data = df)  

summary(slsspline.1000)
summary(slsspline.2500)
summary(slsspline.5000)

# Compare with without the spline
AIC(slsspline.1000) # spline is better
AIC(soillatshannon.1000)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(slsspline.1000)
r2_2500 <- r.squaredGLMM(slsspline.2500)
r2_5000 <- r.squaredGLMM(slsspline.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) Soiltype + Latitude + Shannon (Spline)",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)


# Compare the effects to the original shannons model ----------------------

shannon1000 <- lmer(LRR ~ shannon.1000 + (1|ma_id/study_id), data = df)  
summary(shannon1000)

###### 
# H10: Latitude decimal and soiltypes and shanons and poll -----------------
###### 

slsspline.poll.1000 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype + shannon.1000 + (1|ma_id/study_id), data = poll)  
slsspline.poll.2500 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype + shannon.2500 + (1|ma_id/study_id), data = poll)  
slsspline.poll.5000 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype + shannon.5000 + (1|ma_id/study_id), data = poll)  

summary(slsspline.poll.1000)
summary(slsspline.poll.2500)
summary(slsspline.poll.5000)

# Calculate R² for each model

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(slsspline.poll.1000)
r2_2500 <- r.squaredGLMM(slsspline.poll.2500)
r2_5000 <- r.squaredGLMM(slsspline.poll.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) Soiltype + Latitude + Shannon (Spline, Poll)",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

###### 
# H11: Latitude decimal and soiltypes and shanons and nopoll -----------------
###### 

slsspline.nopoll.1000 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype + shannon.1000 + (1|ma_id/study_id), data = nopoll)  
slsspline.nopoll.2500 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype + shannon.2500 + (1|ma_id/study_id), data = nopoll)  
slsspline.nopoll.5000 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype + shannon.5000 + (1|ma_id/study_id), data = nopoll)  

summary(slsspline.nopoll.1000)
summary(slsspline.nopoll.2500)
summary(slsspline.nopoll.5000)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(slsspline.nopoll.1000)
r2_2500 <- r.squaredGLMM(slsspline.nopoll.2500)
r2_5000 <- r.squaredGLMM(slsspline.nopoll.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) Soiltype + Latitude + Shannon (Spline, NoPoll)",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)


###### 
# H12: The proportion of natural habitat with control to soiltype will increase the LRR -----------------
# As the nutrient spill overs can happen from the naeighbouring landscapes,
# the proportion of nat.hab in the buffer will contribute to the yield treatment 
# yet again controlled by the soiltype 
###### 

# here i take only the nopoll dataset to only see the nutrient cycling 
nathabsoil.2.1000 <- lmer(LRR ~ ns(nat.hab.1000, df = 2) + soiltype + (1|ma_id/study_id), data = nopoll)  
nathabsoil.3.1000 <- lmer(LRR ~ ns(nat.hab.1000, df = 3) + soiltype + (1|ma_id/study_id), data = nopoll)  
nathabsoil.4.1000 <- lmer(LRR ~ ns(nat.hab.1000, df = 4) + soiltype + (1|ma_id/study_id), data = nopoll)  

AIC(nathabsoil.2.1000)
AIC(nathabsoil.3.1000)
AIC(nathabsoil.4.1000)

plot_model(nathabsoil.1000, type = "slope")


nathabsoil.2.1000 <- lmer(LRR ~ ns(nat.hab.1000, df = 2) + soiltype + (1|ma_id/study_id), data = nopoll)  
nathabsoil.2.2500 <- lmer(LRR ~ ns(nat.hab.2500, df = 2) + soiltype + (1|ma_id/study_id), data = nopoll)  
nathabsoil.2.5000 <- lmer(LRR ~ ns(nat.hab.5000, df = 2) + soiltype + (1|ma_id/study_id), data = nopoll)  


summary(nathabsoil.2.1000)
summary(nathabsoil.2.2500)
summary(nathabsoil.2.5000)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(nathabsoil.2.1000)
r2_2500 <- r.squaredGLMM(nathabsoil.2.2500)
r2_5000 <- r.squaredGLMM(nathabsoil.2.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) Soiltype + Nat.hab (Spline)",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

###### 
# H13: The H12 + interaction term -----------------
###### 


nathabxxxsoil.2.1000 <- lmer(LRR ~ ns(nat.hab.1000, df = 2)* soiltype + (1|ma_id/study_id), data = df)  

AIC(nathabxxxsoil.2.1000)

plot_model(nathabsoil.1000, type = "slope")

summary(nathabxxxsoil.2.1000)

###### 
# H14: The H12 + treatment term -----------------
###### 

# huge errors 
nathabsoiltreatment.2.1000 <- lmer(LRR ~ ns(nat.hab.1000, df = 2) + soiltype*treatment + (1|study_id), data = df)  
nathabsoiltreatment.2.2500 <- lmer(LRR ~ ns(nat.hab.2500, df = 2) + soiltype*treatment + (1|study_id), data = df)  
nathabsoiltreatment.2.5000 <- lmer(LRR ~ ns(nat.hab.5000, df = 2) + soiltype*treatment + (1|study_id), data = df)  


AIC(nathabsoil.2.1000)
AIC(nathabsoil.3.1000)
AIC(nathabsoil.4.1000)

summary(nathabsoiltreatment.2.1000)
summary(nathabsoiltreatment.2.2500)
summary(nathabsoiltreatment.2.5000)



###### 
# H13: Bigger fieldsize will benefit more from the complexity and  -----------------
# proportion of nat. habitat within the buffer then the smaller fields.
# Smaller fields can rather experience pest from increeased complexity
# and nat hab proportion
###### 

fieldsizecomposition.2.1000 <- lmer(LRR ~ ns(nat.hab.peri.area.ratio.1000, df = 2) + shannon.1000*fieldsize+ (1|study_id), data = nopoll)  
fieldsizecomposition.2.2500 <- lmer(LRR ~ ns(nat.hab.peri.area.ratio.2500, df = 2) + shannon.2500*fieldsize+ (1|study_id), data = nopoll)  
fieldsizecomposition.2.5000 <- lmer(LRR ~ ns(nat.hab.peri.area.ratio.5000, df = 2) + shannon.5000*fieldsize+ (1|study_id), data = nopoll)  

summary(fieldsizecomposition.2.1000)
summary(fieldsizecomposition.2.2500)
summary(fieldsizecomposition.2.5000)

###### 
# H14: XXXX  -----------------
###### 

soiltypefieldsize.1000 <- lmer(LRR ~ soiltype + shannon.1000*fieldsize+ (1|study_id), data = nopoll)  
soiltypefieldsize.2500 <- lmer(LRR ~ soiltype + shannon.2500*fieldsize+ (1|study_id), data = nopoll)  
soiltypefieldsize.5000 <- lmer(LRR ~ soiltype + shannon.5000*fieldsize+ (1|study_id), data = nopoll)  

summary(soiltypefieldsize.1000)
summary(soiltypefieldsize.2500)
summary(soiltypefieldsize.5000)

###### 
# H14: XXXX  -----------------
###### 

pollfieldsizecomposition.2.1000 <- lmer(LRR ~ ns(nat.hab.peri.area.ratio.1000, df = 2) + shannon.1000*fieldsize+ (1|study_id), data = poll)  
pollfieldsizecomposition.2.2500 <- lmer(LRR ~ ns(nat.hab.peri.area.ratio.2500, df = 2) + shannon.2500*fieldsize+ (1|study_id), data = poll)  
pollfieldsizecomposition.2.5000 <- lmer(LRR ~ ns(nat.hab.peri.area.ratio.5000, df = 2) + shannon.5000*fieldsize+ (1|study_id), data = poll)  

summary(pollfieldsizecomposition.2.1000)
summary(pollfieldsizecomposition.2.2500)
summary(pollfieldsizecomposition.2.5000)


###### 
# H14: XXXX  -----------------
###### 

dffieldsizecomposition.2.1000 <- lmer(LRR ~ ns(nat.hab.peri.area.ratio.1000, df = 2) + shannon.1000*fieldsize+ (1|study_id), data = df)  
dffieldsizecomposition.2.2500 <- lmer(LRR ~ ns(nat.hab.peri.area.ratio.2500, df = 2) + shannon.2500*fieldsize+ (1|study_id), data = df)  
dffieldsizecomposition.2.5000 <- lmer(LRR ~ ns(nat.hab.peri.area.ratio.5000, df = 2) + shannon.5000*fieldsize+ (1|study_id), data = df)  

summary(dffieldsizecomposition.2.1000)
summary(dffieldsizecomposition.2.2500)
summary(dffieldsizecomposition.2.5000)


###### 
# H14: Splines  -----------------
###### 

globalcheck <- lmer(LRR ~ temp_avg_1970.2000 + prec_avg_1970.2000 + latitude_decimal + soiltype + crop.peri.area.ratio.1000 + nat.hab.peri.area.ratio.1000 + shannon.1000 + fieldsize + SR + nofield_area_m.1000 + (1|ma_id/study_id), data = df)  

plot_model(globalcheck, type = "slope") +
  theme_bw() +
  theme(
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    plot.title   = element_blank(),        
    plot.subtitle = element_text(size = 12)
  )

###### 
# H12: Check the additive effects  -----------------
######

library(mgcv)

model_gam <- gam(LRR ~ s(crop.peri.area.ratio.1000) +
                   fieldsize +
                   s(latitude_decimal) +
                   s(nat.hab.peri.area.ratio.1000) +
                   s(nofield_area_m.1000) +
                   s(shannon.1000) +
                   s(SR) +
                   soiltype,
                 data = df)
plot(model_gam)

library(earth)

df_clean <- df %>%
  drop_na(LRR, crop.peri.area.ratio.1000, fieldsize, latitude_decimal,
          nat.hab.peri.area.ratio.1000, nofield_area_m.1000,
          shannon.1000, SR, soiltype)

model_mars <- earth(LRR ~ crop.peri.area.ratio.1000 +
                      fieldsize +
                      latitude_decimal +
                      nat.hab.peri.area.ratio.1000 +
                      nofield_area_m.1000 +
                      shannon.1000 +
                      SR +
                      soiltype,
                    data = df_clean)

plot(model_mars)



###### 
# H15: H10+treatment -----------------
###### 

slsspline.poll.1000 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype*treatment + shannon.1000 + (1|study_id), data = df)  
slsspline.poll.2500 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype*treatment + shannon.2500 + (1|study_id), data = df)  
slsspline.poll.5000 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype*treatment + shannon.5000 + (1|study_id), data = df)  

summary(slsspline.poll.1000)
summary(slsspline.poll.2500)
summary(slsspline.poll.5000)


dplyr::glimpse(df)


Notes because I forgot my notebook:
  
  - maybe there are some positive effects of biodiversity that are cancelling out the negative ones 
- Miguel plenary talk 
- SEED-DarkDivNet
- Dr Lotte Korell
- soil food 

FOR NEXT WEEK: 
  Detective work behind the esults 
those results to be interpreted 
either biologically find he paper talking about the relationship 
investigative work behind large standard errors


dont throw water with the baby

###### 
# H16: Adding other factors to shannon -----------------
###### 

###############################
# model variations latitude 
latshannon.1000 <- lmer(LRR ~ latitude_decimal + shannon.1000 + (1|ma_id/study_id), data = df)  
lsspline.1000 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + shannon.1000 + (1|ma_id/study_id), data = df)  
lsreversed.1000 <- lmer(LRR ~ latitude_reversed + shannon.1000 + (1|ma_id/study_id), data = df)  

summary(latshannon.1000)
summary(lsspline.1000)
summary(lsreversed.1000)

AIC(latshannon.1000)
AIC(lsspline.1000)
AIC(lsreversed.1000)

###############################

###############################
# model variations latitude and soiltype
soillatshannon.1000 <- lmer(LRR ~ latitude_decimal + soiltype + shannon.1000 + (1|ma_id/study_id), data = df)  
slsspline.1000 <- lmer(LRR ~ ns(latitude_decimal, df = 3) + soiltype + shannon.1000 + (1|ma_id/study_id), data = df)  
slsreversed.1000 <- lmer(LRR ~ latitude_reversed + soiltype + shannon.1000 + (1|ma_id/study_id), data = df)  

summary(soillatshannon.1000)
summary(slsspline.1000)
summary(slsreversed.1000)

AIC(soillatshannon.1000)
AIC(slsspline.1000)
AIC(slsreversed.1000)

###############################

###############################
# latitude reversed model -------------------------------------------------
###############################

###############################
# df
LRRlsreversed.1000 <- lmer(LRR ~ latitude_reversed + shannon.1000 + (1|ma_id/study_id), data = df)  # THIS ONE
CONTROLlsreversed.1000 <- lmer(mean_yield_control_kgha ~ latitude_reversed + shannon.1000 + (1|ma_id/study_id), data = df)  # THIS ONE

summary(LRRlsreversed.1000)
summary(CONTROLlsreversed.1000)

LRRlsreversed.1000 <- lmer(LRR ~ latitude_reversed + shannon.1000 + (1|ma_id/study_id), data = df)  # THIS ONE
LRRlongitude.1000 <- lmer(LRR ~ longitude_decimal + shannon.1000 + (1|ma_id/study_id), data = df)  # THIS ONE

summary(LRRlsreversed.1000)
summary(LRRlongitude.1000)

AIC(LRRlsreversed.1000)
AIC(LRRlongitude.1000)

hist(df$longitude_decimal)

CONTROLlsreversed.1000 <- lmer(mean_yield_control_kgha ~ latitude_reversed + shannon.1000 + (1|ma_id/study_id), data = df)  # THIS ONE

summary(LRRlsreversed.1000)
summary(CONTROLlsreversed.1000)



lsreversedquad.1000 <- lmer(LRR ~ latitude_reversed + I(latitude_reversed^(-2)) + shannon.1000 + (1|ma_id/study_id), data = df)  
lsreversedspline1.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 1) + shannon.1000 + (1|ma_id/study_id), data = df)  
lsreversedspline2.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 2) + shannon.1000 + (1|ma_id/study_id), data = df)  
lsreversedspline3.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 3) + shannon.1000 + (1|ma_id/study_id), data = df)  

AIC(lsreversed.1000)
AIC(lsreversedquad.1000)
AIC(lsreversedspline1.1000)
AIC(lsreversedspline2.1000)
AIC(lsreversedspline3.1000)

summary(lsreversed.1000)
summary(lsreversedquad.1000)
summary(lsreversedspline1.1000)
summary(lsreversedspline2.1000)
summary(lsreversedspline3.1000)

###############################

###############################
# poll 
lsrpoll.1000 <- lmer(LRR ~ latitude_reversed + shannon.1000 + (1|ma_id/study_id), data = poll)  
lsrpollquad.1000 <- lmer(LRR ~ latitude_reversed + I(latitude_reversed^(-2)) + shannon.1000 + (1|ma_id/study_id), data = poll)  
lsrpollspline1.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 1) + shannon.1000 + (1|ma_id/study_id), data = poll)  
lsrpollspline2.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 2) + shannon.1000 + (1|ma_id/study_id), data = poll)  
lsrpollspline3.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 3) + shannon.1000 + (1|ma_id/study_id), data = poll)  

summary(lsrpoll.1000)
summary(lsrpollquad.1000)
summary(lsrpollspline1.1000)
summary(lsrpollspline2.1000)
summary(lsrpollspline3.1000)

AIC(lsrpoll.1000)
AIC(lsrpollquad.1000)
AIC(lsrpollspline1.1000)
AIC(lsrpollspline2.1000)
AIC(lsrpollspline3.1000)


# nopoll 
lsrnopoll.1000 <- lmer(LRR ~ latitude_reversed + shannon.1000 + (1|ma_id/study_id), data = nopoll)  
lsrnopollquad.1000 <- lmer(LRR ~ latitude_reversed + I(latitude_reversed^(-2)) + shannon.1000 + (1|ma_id/study_id), data = nopoll)  
lsrnopollspline1.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 1) + shannon.1000 + (1|ma_id/study_id), data = nopoll)  
lsrnopollspline2.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 2) + shannon.1000 + (1|ma_id/study_id), data = nopoll)  
lsrnopollspline3.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 3) + shannon.1000 + (1|ma_id/study_id), data = nopoll)  

summary(lsrnopoll.1000)
summary(lsrnopollquad.1000)
summary(lsrnopollspline1.1000)
summary(lsrnopollspline2.1000)
summary(lsrnopollspline3.1000)


AIC(lsrnopoll.1000)
AIC(lsrnopollquad.1000)
AIC(lsrnopollspline1.1000)
AIC(lsrnopollspline2.1000)
AIC(lsrnopollspline3.1000)

###############################
# latitude reversed model with soil -------------------------------------------------
###############################

###############################
# df
slsreversed.1000 <- lmer(LRR ~ latitude_reversed + soiltype + shannon.1000 + (1|ma_id/study_id), data = df)  
slsreversedspline1.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 1) + soiltype + shannon.1000 + (1|ma_id/study_id), data = df)  
slsreversedspline2.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 2) + soiltype + shannon.1000 + (1|ma_id/study_id), data = df)  
slsreversedspline3.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 3) + soiltype + shannon.1000 + (1|ma_id/study_id), data = df)  

AIC(slsreversed.1000)
AIC(slsreversedspline1.1000)
AIC(slsreversedspline2.1000)
AIC(slsreversedspline3.1000)

summary(slsreversedspline2.1000)

###############################

###############################
# poll
slsreversedpoll.1000 <- lmer(LRR ~ latitude_reversed + soiltype + shannon.1000 + (1|ma_id/study_id), data = poll)  
slsreversedspline2poll.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 2) + soiltype + shannon.1000 + (1|ma_id/study_id), data = poll)  
slsreversedspline3poll.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 3) + soiltype + shannon.1000 + (1|ma_id/study_id), data = poll)  
slsreversedspline4poll.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 4) + soiltype + shannon.1000 + (1|ma_id/study_id), data = poll)  
slsreversedspline7poll.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 7) + soiltype + shannon.1000 + (1|ma_id/study_id), data = poll)  
slsreversedspline15poll.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 15) + soiltype + shannon.1000 + (1|ma_id/study_id), data = poll)  

AIC(slsreversedpoll.1000)
AIC(slsreversedspline2poll.1000)
AIC(slsreversedspline3poll.1000)
AIC(slsreversedspline4poll.1000)
AIC(slsreversedspline7poll.1000)
AIC(slsreversedspline15poll.1000)


summary(slsreversedspline2poll.1000)

###############################

###############################
# nopoll

slsreversednopoll.1000 <- lmer(LRR ~ latitude_reversed + soiltype + shannon.1000 + (1|ma_id/study_id), data = nopoll)  
slsreversedspline2nopoll.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 2) + soiltype + shannon.1000 + (1|ma_id/study_id), data = nopoll)  
slsreversedspline3nopoll.1000 <- lmer(LRR ~ ns(latitude_reversed, df = 3) + soiltype + shannon.1000 + (1|ma_id/study_id), data = nopoll)  

AIC(slsreversednopoll.1000)
AIC(slsreversedspline2nopoll.1000)
AIC(slsreversedspline3nopoll.1000)

summary(slsreversedspline2nopoll.1000)


###############################

###############################
# shannon and crop.peri.area -------------------------------------------------
###############################

scroppar.1000 <-  lmer(LRR ~ shannon.1000*crop.peri.area.ratio.1000 +SR + fieldsize + (1|ma_id/study_id), data = df)
AIC(scroppar.1000)
summary(scroppar.1000)

###############################
# H17: Does the landscape heterogeneity increase species richness? ---------
###############################

srshannon.1000 <- lmer(SR ~ shannon.1000 + (1|ma_id/study_id), data = df)
srshannon.2500 <- lmer(SR ~ shannon.2500 + (1|ma_id/study_id), data = df)
srshannon.5000 <- lmer(SR ~ shannon.5000 + (1|ma_id/study_id), data = df)

AIC(srshannon.1000)
summary(srshannon.1000)

AIC(srshannon.2500)
summary(srshannon.2500)

AIC(srshannon.5000)
summary(srshannon.5000)

###############################
# simpsons and fieldsize -------------------------------------------------
###############################
df <- df %>% 
  mutate(fieldsize_group = case_when(
    fieldsize == "nofield_area_m" ~ "nofield",
    fieldsize == "medium_area_m" ~ "medium",
    fieldsize == "verysmall_area_m" ~ "small",
    fieldsize == "small_area_m" ~ "small",
    fieldsize == "verylarge_area_m" ~ "large",
    fieldsize == "large_area_m" ~ "large"
    
  ),
  fieldsize_group = as.factor(fieldsize_group),
  fieldsize_group2 = case_when(
    fieldsize == "nofield_area_m" ~ "small",
    fieldsize == "medium_area_m" ~ "large",
    fieldsize == "verysmall_area_m" ~ "small",
    fieldsize == "small_area_m" ~ "small",
    fieldsize == "verylarge_area_m" ~ "large",
    fieldsize == "large_area_m" ~ "large"
    
  ),
  fieldsize_group2 = as.factor(fieldsize_group2))
  

ggplot(df, aes(x = fieldsize_group2, y = shannon.1000, fill = fieldsize_group2)) +
  geom_boxplot(alpha = 0.6, outlier.shape = NA) +    # boxplot without fieldsize_group2 points
  geom_jitter(width = 0.15, alpha = 0.7, color = "black") +  # show individual points
  labs(
    title = "Shannon Diversity Across Field Size Groups",
    x = "Field Size Group",
    y = "Shannon Diversity"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", hjust = 0.5)
  ) +
  scale_fill_brewer(palette = "Set2")


ggplot(df, aes(x = treatment, y = crop.peri.area.ratio.1000, fill = fieldsize_group2)) +
  geom_boxplot(alpha = 0.6, outlier.shape = NA) +    # boxplot without fieldsize_group2 points
  geom_jitter(width = 0.15, alpha = 0.7, color = "black") +  # show individual points
  labs(
    title = "Crop Area Fragmentation Across Treatments and Field Size Groups",
    x = "Treatment",
    y = "Crop Area Fragmentation"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)  # rotate x labels
  ) +
  scale_fill_brewer(palette = "Set2")



###############################
# model 
###############################
dfsmall <- df %>% 
  filter(fieldsize_group2 %in% c("small"))

dflarge <- df %>% 
  filter(fieldsize_group2 %in% c("large"))


df$simpsonsevenness.1000

simpsonlarge.1000 <-  lmer(LRR ~ simpsonsevenness.1000 + (1|ma_id/study_id), data = dflarge)
simpsonsmall.1000 <-  lmer(LRR ~ simpsonsevenness.1000 + (1|ma_id/study_id), data = dfsmall)

shannonlarge.1000 <-  lmer(LRR ~ shannon.1000 + (1|ma_id/study_id), data = dflarge)
shannonsmall.1000 <-  lmer(LRR ~ shannon.1000 + (1|ma_id/study_id), data = dfsmall)



AIC(simpson.1000)
summary(simpsonlarge.1000)
summary(simpsonsmall.1000)
summary(shannonlarge.1000)
summary(shannonsmall.1000)

###############################
# model 
###############################
#1000
simpsonpoll.1000 <-  lmer(LRR ~ simpsonsevenness.1000+fieldsize_group2 + (1|ma_id/study_id), data = poll)
simpsonnopoll.1000 <-  lmer(LRR ~ simpsonsevenness.1000+fieldsize_group2 + (1|ma_id/study_id), data = nopoll)

shannonpoll.1000 <-  lmer(LRR ~ shannon.1000+fieldsize_group2 + (1|ma_id/study_id), data = poll)
shannonnopoll.1000 <-  lmer(LRR ~ shannon.1000+fieldsize_group2 + (1|ma_id/study_id), data = nopoll)


summary(simpsonpoll.1000)
summary(simpsonnopoll.1000)
summary(shannonpoll.1000)
summary(shannonnopoll.1000)

#2500
simpsonpoll.2500 <-  lmer(LRR ~ simpsonsevenness.2500+fieldsize_group2 + (1|ma_id/study_id), data = poll)
simpsonnopoll.2500 <-  lmer(LRR ~ simpsonsevenness.2500+fieldsize_group2 + (1|ma_id/study_id), data = nopoll)

shannonpoll.2500 <-  lmer(LRR ~ shannon.2500+fieldsize_group2 + (1|ma_id/study_id), data = poll)
shannonnopoll.2500 <-  lmer(LRR ~ shannon.2500+fieldsize_group2 + (1|ma_id/study_id), data = nopoll)


summary(simpsonpoll.2500)
summary(simpsonnopoll.2500)
summary(shannonpoll.2500)
summary(shannonnopoll.2500)

#5000
simpsonpoll.5000 <-  lmer(LRR ~ simpsonsevenness.5000+fieldsize_group2 + (1|ma_id/study_id), data = poll)
simpsonnopoll.5000 <-  lmer(LRR ~ simpsonsevenness.5000+fieldsize_group2 + (1|ma_id/study_id), data = nopoll)

shannonpoll.5000 <-  lmer(LRR ~ shannon.5000+fieldsize_group2 + (1|ma_id/study_id), data = poll)
shannonnopoll.5000 <-  lmer(LRR ~ shannon.5000+fieldsize_group2 + (1|ma_id/study_id), data = nopoll)


summary(simpsonpoll.5000)
summary(simpsonnopoll.5000)
summary(shannonpoll.5000)
summary(shannonnopoll.5000)



# Calculate R² for each model
r2_1000 <- r.squaredGLMM(simpsonpoll.1000)
r2_2500 <- r.squaredGLMM(simpsonpoll.2500)
r2_5000 <- r.squaredGLMM(simpsonpoll.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by natural habitat (without grassland) models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(simpsonnopoll.1000)
r2_2500 <- r.squaredGLMM(simpsonnopoll.2500)
r2_5000 <- r.squaredGLMM(simpsonnopoll.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by natural habitat (without grassland) models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)





# Calculate R² for each model
r2_1000 <- r.squaredGLMM(shannonpoll.1000)
r2_2500 <- r.squaredGLMM(shannonpoll.2500)
r2_5000 <- r.squaredGLMM(shannonpoll.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by natural habitat (without grassland) models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(shannonnopoll.1000)
r2_2500 <- r.squaredGLMM(shannonnopoll.2500)
r2_5000 <- r.squaredGLMM(shannonnopoll.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by natural habitat (without grassland) models",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)


###############################
# model 
###############################


cropperiareapoll.1000 <-  lmer(LRR ~ crop.peri.area.ratio.1000*shannon.1000 + (1|ma_id/study_id) , data = poll)
cropperiareapoll.2500 <-  lmer(LRR ~ crop.peri.area.ratio.2500 + (1|ma_id/study_id) + (1|treatment), data = poll)
cropperiareapoll.5000 <-  lmer(LRR ~ crop.peri.area.ratio.5000 + (1|ma_id/study_id) + (1|treatment), data = poll)

summary(cropperiareapoll.1000)
summary(cropperiareapoll.2500)
summary(cropperiareapoll.5000)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(cropperiareapoll.1000)
r2_2500 <- r.squaredGLMM(cropperiareapoll.2500)
r2_5000 <- r.squaredGLMM(cropperiareapoll.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by Crop Fragmentation and 
       Landscape Heterogeneity models in Pollinated Crops",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)


cropperiareanopoll.1000 <-  lmer(LRR ~ crop.peri.area.ratio.1000*shannon.1000 + (1|ma_id/study_id) + (1|treatment), data = nopoll)
excropperiareanopoll.1000 <-  lmer(LRR ~ crop.peri.area.ratio.1000*shannon.1000 + (1|ma_id/study_id) , data = nopoll)
cropperiareanopoll.2500 <-  lmer(LRR ~ crop.peri.area.ratio.2500 + (1|ma_id/study_id) + (1|treatment), data = nopoll)
cropperiareanopoll.5000 <-  lmer(LRR ~ crop.peri.area.ratio.5000 + (1|ma_id/study_id) + (1|treatment), data = nopoll)

summary(cropperiareanopoll.1000)
summary(cropperiareanopoll.2500)
summary(cropperiareanopoll.5000)

# Calculate R² for each model
r2_1000 <- r.squaredGLMM(cropperiareanopoll.1000)
r2_2500 <- r.squaredGLMM(cropperiareanopoll.2500)
r2_5000 <- r.squaredGLMM(cropperiareanopoll.5000)

# Put results into a data frame
r2_df <- data.frame(
  Scale = c("1000 m", "2500 m", "5000 m"),
  Marginal = c(r2_1000[1], r2_2500[1], r2_5000[1]),  # fixed effects
  Conditional = c(r2_1000[2], r2_2500[2], r2_5000[2]) # fixed + random
)

# Add random-only component
r2_df <- r2_df %>%
  mutate(Random = Conditional - Marginal)

# Reshape for plotting
r2_long <- r2_df %>%
  pivot_longer(cols = c("Marginal", "Random", "Conditional"),
               names_to = "Component", values_to = "R2")

# Plot
ggplot(r2_long, aes(x = Scale, y = R2, fill = Component)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Marginal" = "skyblue", 
                               "Random" = "orange", 
                               "Conditional" = "darkgreen")) +
  labs(title = "Variance explained (R²) by Crop Fragmentation and 
       Landscape Heterogeneity models in Non-pollinated Crops",
       x = "Buffer scale", y = "R²") +
  theme_minimal(base_size = 14)


