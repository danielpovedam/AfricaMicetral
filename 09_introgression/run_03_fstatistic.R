##########################################################
# estimate_f.R
#
# Author: Daniel Poveda M.
# Date: 2025-06-16
# 
# Description:
# ------------
# This script estimates the admixture proportion f based on ABBA-BABA (D statistic) output.
# It follows the methodology outlined in:
#   - Tutorial: https://github.com/simonhmartin/tutorials/tree/master/ABBA_BABA_whole_genome
#   - Martin et al. (2015). Evaluating the use of ABBA-BABA statistics to locate introgressed loci. Mol. Biol. Evol. 32:244-257.
#
# Theory:
# --------
# D is a statistic that tests for excess ABBA or BABA sites indicating introgression.
# f estimates the proportion of the genome introgressed by comparing the observed D to the D under complete admixture.
# Complete admixture is simulated by placing a second P3 lineage in place of P2.
#

# Load tidyverse for data manipulation
library(dplyr)

# Read the input table
data <- read.table(
  file = "table_f.txt",
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE
)

# Print column names to verify file structure
cat("Columns found in the input file:\n")
print(names(data))

# Convert columns to numeric as needed
data <- data %>%
  mutate(
    Comparision = as.numeric(Comparision),
    D = as.numeric(D),
    `JK.D` = as.numeric(`JK.D`),
    `VJK.D` = as.numeric(`VJK.D`),
    Z = as.numeric(Z),
    pvalue = as.numeric(pvalue),
    nABBA = as.numeric(nABBA),
    nBABA = as.numeric(nBABA),
    nBlocks = as.numeric(nBlocks)
  )

# Extract the row corresponding to complete admixture (Comparision == 14)
comp <- data %>% filter(Comparision == 14)
if(nrow(comp) != 1){
  stop(
    "Error: Expected exactly one row for complete admixture (Comparision==14).",
    call. = FALSE
  )
}

# D and standard error for the complete admixture config
D_comp <- comp$D
SE_comp <- sqrt(comp$`VJK.D`)

# Filter observed comparisons
obs <- data %>% filter(Comparision != 14)

# Compute f, standard error, and 95% CI
obs <- obs %>%
  mutate(
    f = D / D_comp,
    SE_obs = sqrt(`VJK.D`),
    SE_f = f * sqrt((SE_obs / D)^2 + (SE_comp / D_comp)^2),
    f_CI_lower = f - 1.96 * SE_f,
    f_CI_upper = f + 1.96 * SE_f
  )

# Prepare the results
result <- obs %>%
  select(Comparision, H1, H2, H3, H4, Z, D, f, SE_f, f_CI_lower, f_CI_upper)

# Print a preview
cat("\nPreview of f estimates:\n")
print(head(result))

# Write the results to file
write.table(
  result,
  file = "f_estimates_chr7.txt",
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)

cat("\nDone. Estimates saved to f_estimates.txt\n")

