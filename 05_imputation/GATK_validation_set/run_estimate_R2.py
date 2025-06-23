import pandas as pd
import numpy as np
import os

def calculate_r2_per_individual_and_chromosome(genotypes_file, imputed_file, output_file, chunk_size=10000):
    # Create a directory for temporary files if it doesn't exist
    temp_dir = "temp_r2_files"
    if not os.path.exists(temp_dir):
        os.makedirs(temp_dir)

    # Read files in chunks
    genotype_chunks = pd.read_csv(genotypes_file, sep="\t", chunksize=chunk_size)
    imputed_chunks = pd.read_csv(imputed_file, sep="\t", chunksize=chunk_size)

    # Store temporary results
    temp_files = []

    # Process each chunk
    for chunk_idx, (geno_chunk, imp_chunk) in enumerate(zip(genotype_chunks, imputed_chunks)):
        # Merge the chunks on CHROM, POS, REF, ALT to ensure matching SNPs
        merged = pd.merge(geno_chunk, imp_chunk, on=["CHROM", "POS", "REF", "ALT"], suffixes=("_geno", "_imp"))

        # Extract genotype and imputed dosage columns
        geno_cols = [col for col in merged.columns if col.startswith("GT_")]
        imp_cols = [col for col in merged.columns if col.startswith("DS_")]

        # Initialize a dictionary to store R² results
        r2_results = []

        # Calculate R² for each individual
        for individual_geno, individual_imp in zip(geno_cols, imp_cols):
            # Extract observed genotypes and imputed dosages for the individual
            observed_geno = merged[individual_geno].replace(
                {"0/0": 0, "0/1": 1, "1/1": 2, "./.": np.nan}
            ).astype(float)
            imputed_dosage = merged[individual_imp].astype(float)

            # Combine data to drop missing values (NaN)
            valid_data = pd.DataFrame({"observed": observed_geno, "imputed": imputed_dosage}).dropna()

            # Calculate R² if there are enough valid data points
            if len(valid_data) > 1:
                mean_observed = valid_data["observed"].mean()
                mean_imputed = valid_data["imputed"].mean()

                numerator = np.sum(
                    (valid_data["imputed"] - mean_imputed) * (valid_data["observed"] - mean_observed)
                )
                denominator = np.sqrt(
                    np.sum((valid_data["imputed"] - mean_imputed) ** 2)
                    * np.sum((valid_data["observed"] - mean_observed) ** 2)
                )
                r2 = (numerator / denominator) ** 2 if denominator != 0 else np.nan
            else:
                r2 = np.nan  # Not enough data points

            # Append results (CHROM, Individual, R²)
            r2_results.append({
                "CHROM": merged["CHROM"].iloc[0],
                "Individual": individual_geno.replace("GT_", ""),
                "R2": r2
            })

        # Save results for this chunk to a temporary file
        temp_file = f"{temp_dir}/r2_chunk_{chunk_idx}.txt"
        temp_files.append(temp_file)
        pd.DataFrame(r2_results).to_csv(temp_file, sep="\t", index=False)

    # Combine all temporary files into the final output
    all_results = pd.concat([pd.read_csv(f, sep="\t") for f in temp_files])
    all_results.to_csv(output_file, sep="\t", index=False)

    # Clean up temporary files
    for temp_file in temp_files:
        os.remove(temp_file)

    return output_file


# Example usage
genotypes_file = "filtered_final_genotypes.txt"
imputed_file = "imputed_dosage.txt"
output_file = "r2_results_per_individual_and_chromosome.txt"

calculate_r2_per_individual_and_chromosome(genotypes_file, imputed_file, output_file)

