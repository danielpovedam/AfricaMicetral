######################################################
# Run ROH Analysis in African Populations
######################################################

## Load required packages
library(dplyr)
library(ggplot2)
library(vegan)
library(multcomp)
library(kSamples)
library(tidyr)

#### 1. Filter Population Info ####
pop_data <- read.table(
  "population_info.txt",
  header = TRUE,
  stringsAsFactors = FALSE
)

# Subset to African individuals with n>5 per Population
pop_africa <- pop_data %>%
  filter(Region == "Africa") %>%
  group_by(Population) %>%
  filter(n() > 5) %>%
  ungroup()

# Save filtered pop file
write.table(
  pop_africa,
  file = "population_info_Africa_n5.txt",
  row.names = FALSE,
  quote = FALSE,
  sep = "\t"
)

#### 2. Filter ROH file to African individuals ####
roh <- read.table(
  "roh_results.hom",
  header = TRUE,
  stringsAsFactors = FALSE
)

roh_africa <- roh %>%
  filter(IID %in% pop_africa$IID)

write.table(
  roh_africa,
  file = "roh_results_Africa_n5.hom",
  row.names = FALSE,
  quote = FALSE,
  sep = "\t"
)

#### 3. Compute F_ROH ≥ 1 Mb and Plot ####
roh_filtered <- roh_africa %>%
  filter(KB >= 1000)  # ≥1 Mb

genome_size_kb <- 2.7e6  # 2.7 Gb genome

froh_data <- roh_filtered %>%
  group_by(IID) %>%
  summarise(F_ROH = sum(KB) / genome_size_kb) %>%
  left_join(pop_africa, by = "IID")

# Save results
write.table(
  froh_data,
  file = "FROH_Africa_filtered.txt",
  row.names = FALSE,
  quote = FALSE,
  sep = "\t"
)

# Print mean per Population
froh_data %>%
  group_by(Population) %>%
  summarise(mean_FROH = mean(F_ROH)) %>%
  arrange(mean_FROH) %>%
  print()

# Plot F_ROH
plot_froh <- ggplot(
  froh_data,
  aes(
    x = reorder(Population, F_ROH, FUN = median),
    y = F_ROH,
    fill = Population
  )
) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.7, size = 1.5) +
  labs(
    title = "F_ROH Variation Among African Populations (ROH ≥1 Mb)",
    x = "Population",
    y = "F_ROH"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position = "none")

ggsave(
  "FROH_Africa_filtered.svg",
  plot = plot_froh,
  width = 10, height = 6, dpi = 600
)

# ANOVA and Tukey post-hoc
anova_result <- aov(F_ROH ~ Population, data = froh_data)
summary(anova_result)
summary(glht(anova_result, linfct = mcp(Population = "Tukey")))

#### 4. ROH Percentage of Genome per Population ####
ind_roh <- roh_filtered %>%
  group_by(IID) %>%
  summarise(total_roh_length = sum(KB)) %>%
  mutate(total_roh_length_cm = total_roh_length / 1000,
         roh_percentage = (total_roh_length_cm / 2700) * 100) %>%
  left_join(pop_africa, by = "IID")

pop_roh_summary <- ind_roh %>%
  group_by(Population) %>%
  summarise(
    mean_roh_percentage = mean(roh_percentage),
    sd_roh_percentage = sd(roh_percentage),
    n = n()
  ) %>%
  arrange(mean_roh_percentage)

ggplot(pop_roh_summary, aes(
  x = reorder(Population, mean_roh_percentage),
  y = mean_roh_percentage,
  fill = Population
)) +
  geom_bar(stat = "identity") +
  geom_errorbar(
    aes(
      ymin = mean_roh_percentage - sd_roh_percentage,
      ymax = mean_roh_percentage + sd_roh_percentage
    ),
    width = 0.2
  ) +
  labs(
    title = "Mean Percentage of Genome in ROHs by Population",
    x = "Population",
    y = "Mean ROH (%)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position = "none") ->
  plot_roh_perc

ggsave(
  "ROH_Percentage_by_Population.svg",
  plot = plot_roh_perc,
  width = 10, height = 6, dpi = 600
)

#### 5. ROH length distributions and ECDFs ####
roh_africa_df <- roh_africa %>%
  select(IID, KB) %>%
  mutate(
    ROH_Length_Mb = KB / 1000,
    Population = sub("_\\d+$", "", IID)
  ) %>%
  filter(ROH_Length_Mb >= 1)

ggplot(roh_africa_df, aes(x = ROH_Length_Mb)) +
  stat_ecdf(aes(color = Population, group = IID), geom = "step", alpha = 0.7) +
  labs(
    title = "ECDF of ROH lengths ≥1 Mb",
    x = "ROH length (Mb)",
    y = "Proportion of segments"
  ) +
  theme_minimal() +
  facet_wrap(~ Population, scales = "free_y") ->
  plot_ecdf

ggsave(
  "ROH_ECDF_Africa.svg",
  plot = plot_ecdf,
  width = 10, height = 8, dpi = 600
)

#### 6. Anderson-Darling test of ROH length distributions ####
roh_list <- split(roh_africa_df$ROH_Length_Mb, roh_africa_df$Population)
ad_test <- ad.test(roh_list)
print(ad_test)

#### 7. ROH Length Binning per Individual ####
roh_bins <- roh_africa_df %>%
  mutate(
    cM = ROH_Length_Mb, # 1 Mb = 1 cM
    bin = case_when(
      cM >= 1 & cM < 4 ~ "1-4 cM",
      cM >= 4 & cM < 8 ~ "4-8 cM",
      cM >= 8 & cM < 12 ~ "8-12 cM",
      cM >= 12 & cM < 20 ~ "12-20 cM",
      cM >= 20 ~ ">20 cM"
    )
  ) %>%
  group_by(IID, Population, bin) %>%
  summarise(total_cM = sum(cM), .groups = "drop") %>%
  pivot_wider(names_from = bin, values_from = total_cM, values_fill = 0)

# Save binned ROH summary
write.table(
  roh_bins,
  file = "ROH_binned_cM_per_individual_Africa.txt",
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)



