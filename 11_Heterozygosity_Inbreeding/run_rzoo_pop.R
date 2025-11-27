#!/usr/bin/env Rscript
library(RZooRoH)
library(data.table)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("Usage: Rscript run_rzoo_pop.R <POP>")

pop <- args[1]
base_dir <- "/home/dpoveda/micetral/software/rzooroh"
rzoo_dir <- file.path(base_dir, "per_pop_rzoo")
rzoo_file <- file.path(rzoo_dir, paste0(pop, "_rzoo_genetic.txt"))
sample_file <- file.path(base_dir, "sample_lists", paste0(pop, ".samples"))
out_dir <- file.path(base_dir, "rzoo_results_new_genetic_map")
dir.create(out_dir, showWarnings = FALSE)

cat("\n=== Running rZooRoH for population:", pop, "===\n")

# Load data
zdata <- zoodata(
  genofile = rzoo_file,
  zformat = "gp",
  samplefile = sample_file,
  chrcol = 1,
  poscol = 3,
  supcol = 5,
  min_maf = 0.05
)

# Define K=14 model with relevant timescales
K <- 14
krates <- c(2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384)
model <- zoomodel(predefined = TRUE, K = K, krates = krates)

# Run model
results <- zoorun(model, zdata, nT = 1, fb = TRUE)

# Save main results
output_file <- file.path(out_dir, paste0("zoorun_result_", pop, ".RData"))
save(results, file = output_file)

cat("✅ Results saved to:", output_file, "\n")


