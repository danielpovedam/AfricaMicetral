#!/usr/bin/env Rscript

library(readr)
library(dplyr)
library(stringr)
library(purrr)

results_dir <- "./results"

# === List all MSMC-IM estimate files ===
est_files <- list.files(results_dir, pattern = "MSMC_IM\\.estimates\\.txt$", full.names = TRUE)

# === Function to read and merge one pair ===
read_pair <- function(est_path) {
  base <- sub("\\.estimates\\.txt$", "", est_path)
  fit_path <- paste0(base, ".fittingdetails.txt")
  pair <- basename(est_path) |>
    sub("\\.im\\.b1_1e-08\\.b2_1e-06\\.MSMC_IM\\.estimates\\.txt$", "", x = _)

  # --- Read .estimates.txt ---
  est <- suppressMessages(read_table(
    est_path,
    skip = 1,
    col_names = c("left_time_boundary", "im_N1", "im_N2", "m", "M"),
    show_col_types = FALSE
  ))

  est <- est |>
    mutate(
      pair = pair,
      tgens = as.numeric(left_time_boundary),
      m = as.numeric(m),
      M = as.numeric(M),
      t_round = round(as.numeric(left_time_boundary), 6)
    ) |>
    select(pair, tgens, t_round, m, M) |>
    filter(is.finite(tgens))

  # --- Read .fittingdetails.txt ---
  fit_raw <- suppressMessages(read_table(fit_path, col_names = FALSE, skip = 3))
  if (ncol(fit_raw) < 9) {
    stop("Unexpected fittingdetails format for: ", fit_path)
  }

  fit <- fit_raw |>
    transmute(tgens_fit = as.numeric(X1), MSMCrCCR = as.numeric(X9)) |>
    mutate(t_round = round(tgens_fit, 6)) |>
    filter(is.finite(t_round))

  # --- Merge safely by t_round ---
  merged <- left_join(est, fit, by = "t_round") |>
    mutate(MSMCrCCR = as.numeric(MSMCrCCR)) |>
    select(pair, tgens, m, M, MSMCrCCR) |>
    arrange(tgens)

  merged
}

# === Combine all pairs ===
summary_df <- map_dfr(est_files, read_pair)

# === Save output ===
outfile <- file.path(results_dir, "summary_mMrCCRs.tsv")
write_tsv(summary_df, outfile)

# === Diagnostics ===
cat("\n✅ Wrote merged file:", outfile, "\n")
cat("Pairs processed:", length(unique(summary_df$pair)), "\n")
summary_df %>%
  count(pair, name = "rows") %>%
  arrange(rows) %>%
  print(n = Inf)

