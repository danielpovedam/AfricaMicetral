# snmf_analysis.R

# Description: sNMF analysis of merged_common_variants.vcf using LEA

# Load required library
library(LEA)

# Convert VCF to .geno format
vcf2geno("merged_common_variants.vcf", output = "merged_common_variants.geno")

# Run sNMF for K = 1 to 10 with 10 repetitions
project <- snmf("merged_common_variants.geno", K = 1:10, ploidy = 2, entropy = TRUE, repetitions = 10)

# Plot cross-entropy to select best K
plot(project, col = "blue4", cex = 1.4, pch = 19)
# Manually inspect or choose best run
best_run <- which.min(cross.entropy(project, K = 3))  # Example: choose K = 3

# Define colors
my.colors <- c("#992323", "#f8e1b5", "#2cb9c4ff", "#0289b7", "orange", "cyan", "pink", "yellow", "brown", "gray")

# Load metadata
pop_data <- read.table("pop_exom_wgs_cluster.txt", header = TRUE, sep = "\t")

# --------------------
# Plotting barplot for K = 3
# --------------------
barchart(project, K = 3, run = best_run,
         border = NA, space = 0,
         col = my.colors,
         xlab = "Individuals", ylab = "Ancestry proportions",
         main = "Ancestry matrix K = 3") -> bp

axis(1, at = 1:length(bp$order), labels = pop_data$ind[bp$order], las = 2, cex.axis = 0.4)

# --------------------
# Extract Q-matrix and merge with metadata
# --------------------
qmatrix <- Q(project, K = 3, run = best_run)
rownames(qmatrix) <- pop_data$ind
qmatrix_df <- as.data.frame(qmatrix)
qmatrix_df$ind <- rownames(qmatrix_df)

merged_data <- merge(pop_data, qmatrix_df, by = "ind")
colnames(merged_data)[5:9] <- paste0("K", 1:3)

# Save individual-level ancestry matrix
write.table(merged_data, file = "individual_ancestry_K3.txt", sep = "\t", row.names = FALSE, quote = FALSE)

# --------------------
# Calculate average ancestry proportions per country
# --------------------
average_ancestry <- aggregate(. ~ country, data = merged_data[, c("country", paste0("K", 1:5))], mean)
write.table(average_ancestry, file = "average_ancestry_per_country_K5.txt", sep = "\t", row.names = FALSE, quote = FALSE)

# --------------------
# Automate for multiple K values
# --------------------

process_k <- function(K) {
  qmat <- Q(project, K = K, run = best_run)
  rownames(qmat) <- pop_data$ind
  qmat_df <- as.data.frame(qmat)
  qmat_df$ind <- rownames(qmat_df)
  merged <- merge(pop_data, qmat_df, by = "ind")
  colnames(merged)[(ncol(merged)-K+1):ncol(merged)] <- paste0("K", 1:K)
  
  # Save individual-level table
  write.table(merged, file = paste0("individual_ancestry_K", K, ".txt"),
              sep = "\t", row.names = FALSE, quote = FALSE)
  
  # Calculate and save average per country
  avg <- aggregate(. ~ country, data = merged[, c("country", paste0("K", 1:K))], mean)
  write.table(avg, file = paste0("average_ancestry_per_country_K", K, ".txt"),
              sep = "\t", row.names = FALSE, quote = FALSE)
}

# Apply to K = 2:6
for (k in 2:6) {
  process_k(k)
}

# --------------------
# End of script
# --------------------

