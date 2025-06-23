# -------------------------------
# Full R Script for Filtering Relatives
# using the KING column from ngsRelate output
# -------------------------------

# Step 1: Load the ngsRelate output data
data <- read.table("vcf.res", header = TRUE)

# Filter pairs where KING > 0.177
related_pairs <- data[data$KING > 0.177, ]

# Print the number of related pairs
cat("Number of related pairs with KING > 0.177:", nrow(related_pairs), "\n")

# Save the list of related pairs to a file
write.table(related_pairs[, c("ida", "idb", "KING")], "related_pairs.txt", quote = FALSE, row.names = FALSE, col.names = TRUE)

# Count how many times each individual appears
individual_counts <- table(c(related_pairs$ida, related_pairs$idb))

# Sort individuals by how often they appear (descending)
sorted_counts <- sort(individual_counts, decreasing = TRUE)

# Create a set to remove
to_remove <- c()

for (i in seq_len(nrow(related_pairs))) {
  a <- related_pairs$ida[i]
  b <- related_pairs$idb[i]
  
  # Remove the individual appearing more frequently
  if (a %in% to_remove | b %in% to_remove) {
    next  # Skip already removed individuals
  } else if (sorted_counts[a] > sorted_counts[b]) {
    to_remove <- c(to_remove, a)
  } else {
    to_remove <- c(to_remove, b)
  }
}

# Save the list of removed individuals
write.table(to_remove, "samples_to_remove.txt", quote = FALSE, row.names = FALSE, col.names = FALSE)
cat("Number of samples to remove:", length(to_remove), "\n")

