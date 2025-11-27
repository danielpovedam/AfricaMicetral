#### final version ####
#!/usr/bin/env Rscript ========================================================== MSMC-IM summary plotting (rCCR focus only) Custom axis 
# labels (10, 100, 0.5k, 1k, 2k, 5k)  ==========================================================
library(readr) library(dplyr) library(ggplot2) library(scales)
# ========================================================== 1. Read and clean summary file 
# ==========================================================
summary_df <- read_table( "./results/summary_mMrCCR_FIXED_new_comparisions.tsv", col_names = c("pair", "tgens", "m", "M", "MSMCrCCR") ) 
summary_df <- summary_df %>%
  filter(pair != "pair") %>% mutate( tgens = as.numeric(tgens), m = as.numeric(m), M = as.numeric(M), MSMCrCCR = as.numeric(MSMCrCCR), years 
    = tgens * 0.5
  ) %>% filter(!is.na(tgens) & tgens > 0)
# ========================================================== 2. Define population-pair groups 
# ==========================================================
group1a <- c("SOUTH_EUR_TUNEZ", "SPAIN_MOR_ARG", "SPAIN_NIGER") group1b <- c("NORTH_EUR_BENIN", "NORTH_EUR_MALI", "NORTH_EUR_GABON") group1c 
<- c("NORTH_EUR_SENEGAL", "NORTH_EUR_USA", "WEST_ASIA_MOR_ARG") group2 <- c("SOUTH_EUR_NORTH_EUR", "NORTH_EUR_SPAIN", "SOUTH_EUR_SPAIN") 
group3 <- c("WEST_ASIA_NORTH_EUR", "WEST_ASIA_SOUTH_EUR", "WEST_ASIA_SPAIN", "WEST_ASIA_MOR_ARG")
# ========================================================== 3. Helper: crossing finder 
# ==========================================================
cross_at <- function(x, y, x0) { o <- order(x); x <- x[o]; y <- y[o] hit <- which(diff((y - x0) >= 0) != 0) if (length(hit) == 0) 
  return(NA_real_) i <- hit[1] x[i] + (x0 - y[i]) * (x[i+1] - x[i]) / (y[i+1] - y[i])
}
# ========================================================== 4. Compute divergence times (Tdiv) 
# ==========================================================
tdiv_table <- summary_df %>% group_by(pair) %>% summarise( Tdiv_rCCR0.5_yrs = cross_at(years, MSMCrCCR, 0.5), .groups = "drop" ) %>% mutate( 
    Tdiv_rCCR0.5_gens = Tdiv_rCCR0.5_yrs / 0.5
  ) %>% mutate(across(where(is.numeric), ~ round(.x, 1))) write.table(tdiv_table, "./results/Tdiv_summary_NEW.tsv", sep = "\t", quote = 
            FALSE, row.names = FALSE)
print(tdiv_table)
# ========================================================== 5. Reference years + axis formatter 
# ==========================================================
ref_years <- c(10, 100, 500, 1000, 2000, 5000, 10000) format_years <- function(x) { sapply(x, function(val) { if (val < 1000) 
    return(as.character(val)) if (val == 500) return("0.5k") paste0(val / 1000, "k")
  })
}
# ========================================================== 6. Plot helper functions 
# ==========================================================
plot_msmc_cumulative <- function(df, outfile) { ann <- tdiv_table %>% filter(pair %in% unique(df$pair)) p <- df %>% ggplot(aes(x = years, y 
    = M)) + annotation_logticks(sides = "b", color = "grey70", alpha = 0.5) + geom_area(fill = "#4C72B0", alpha = 0.7) + geom_line(color = 
    "#4C72B0", linewidth = 0.8) + geom_step(aes(y = MSMCrCCR), linetype = "dashed",
              color = "black", linewidth = 0.6) + geom_hline(yintercept = 0.5, color = "red", linetype = "dotted", linewidth = 0.8) +
    # --- rCCR = 0.5 line only ---
    geom_vline(data = ann, aes(xintercept = Tdiv_rCCR0.5_yrs), color = "blue", linetype = "dotted", linewidth = 0.9, na.rm = TRUE) + 
    geom_vline(xintercept = ref_years, linetype = "dashed",
               color = "grey40", alpha = 0.5) + scale_x_log10( breaks = ref_years, labels = format_years(ref_years), limits = c(10, 100000), 
      sec.axis = sec_axis(
        ~ ./0.5, name = expression(Generations~ago~(log[10]~scale~with~0.5~years/gen)), breaks = ref_years / 0.5, labels = 
        format_years(ref_years)
      ) ) + scale_y_continuous(limits = c(0, 1), name = "Cumulative migration probability (M)") + facet_wrap(~pair, ncol = 1, strip.position 
    = "right") + theme_bw(base_size = 13) + theme(
      panel.grid = element_blank(), strip.background = element_rect(fill = "grey95", color = NA), strip.text = element_text(size = 10, face 
      = "bold"), axis.title.x = element_text(size = 13), axis.title.y = element_text(size = 13)
    ) ggsave(outfile, p, width = 7, height = 10)
}
plot_msmc_rate <- function(df, outfile) { medata <- df %>% group_by(pair) %>% summarise(median_val = median(tgens, na.rm = TRUE))
  
  p <- df %>% ggplot(aes(x = years, y = m)) + annotation_logticks(sides = "b", color = "grey70", alpha = 0.5) + geom_step(color = "#4C72B0", 
    linewidth = 0.8) + geom_vline(data = medata, aes(xintercept = median_val * 0.5),
               linetype = "dotted", color = "red") + geom_vline(xintercept = ref_years, linetype = "dashed", color = "grey40", alpha = 0.5) 
               +
    scale_x_log10( breaks = ref_years, labels = format_years(ref_years), limits = c(10, 100000), sec.axis = sec_axis( ~ ./0.5, name = 
        expression(Generations~ago~(log[10]~scale~with~0.5~years/gen)), breaks = ref_years / 0.5, labels = format_years(ref_years)
      ) ) + scale_y_continuous(name = "Symmetric migration rate (m)") + facet_wrap(~pair, ncol = 1, strip.position = "right") + 
    theme_bw(base_size = 13) + theme(
      panel.grid = element_blank(), strip.background = element_rect(fill = "grey95", color = NA), strip.text = element_text(size = 10, face 
      = "bold"), axis.title.x = element_text(size = 13), axis.title.y = element_text(size = 13)
    ) ggsave(outfile, p, width = 7, height = 10)
}
# ========================================================== 7. Produce plots per subgroup 
# ==========================================================
df1a <- summary_df %>% filter(pair %in% group1a)
plot_msmc_cumulative(df1a, "./results/MSMC_IM_Group1a_Cumulative.pdf")

df1b <- summary_df %>% filter(pair %in% group1b)
plot_msmc_cumulative(df1b, "./results/MSMC_IM_Group1b_Cumulative.pdf")


df1c <- summary_df %>% filter(pair %in% group1c)
plot_msmc_cumulative(df1c, "./results/MSMC_IM_Group1c_Cumulative.pdf")


df2 <- summary_df %>% filter(pair %in% group2)
plot_msmc_cumulative(df2, "./results/MSMC_IM_Group2_Cumulative.pdf")


df3 <- summary_df %>% filter(pair %in% group3)
plot_msmc_cumulative(df3, "./results/MSMC_IM_Group3_Cumulative.pdf")



