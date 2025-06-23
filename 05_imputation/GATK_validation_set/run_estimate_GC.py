import pandas as pd
import numpy as np
import os

def calculate_gc_per_individual_and_chromosome(true_genotypes_file, imputed_genotypes_file, output_file, chunk_size=10000):
    # Create a directory for temporary files if it doesn't exist
    temp_dir = "temp_gc_files"
    if not os.path.exists(temp_dir):
        os.makedirs(temp_dir)

    # Initialize an empty list to store results
    temp_files = []

    # Process the input files in chunks to avoid memory issues
    true_chunks = pd.read_csv(true_genotypes_file, sep="\t", chunksize=chunk_size)
    imputed_chunks = pd.read_csv(imputed_genotypes_file, sep="\t", chunksize=chunk_size)

    for chunk_idx, (true_chunk, imputed_chunk) in enumerate(zip(true_chunks, imputed_chunks)):
        # Extract CHROM and individual genotypes
        true_genotypes = true_chunk.iloc[:, 4:]
        imputed_genotypes = imputed_chunk.iloc[:, 4:]

        chrom = true_chunk["CHROM"]
        pos = true_chunk["POS"]

        # Create a temporary file for this chunk
        temp_file = f"{temp_dir}/gc_chunk_{chunk_idx}.txt"
        temp_files.append(temp_file)

        # Initialize a dictionary to store GC per individual and chromosome
        gc_results = []

        # Calculate GC for each individual
        for individual in true_genotypes.columns:
            true_individual = true_genotypes[individual]
            imputed_individual = imputed_genotypes[individual]

            # Initialize counts
            mRefRef, mRefAlt, mAltAlt = 0, 0, 0
            xRefRef, xRefAlt, xAltAlt = 0, 0, 0

            # Iterate through SNPs for the individual
            for true_allele, imputed_allele in zip(true_individual, imputed_individual):
                if true_allele == '0/0' and imputed_allele == '0/0':
                    mRefRef += 1
                elif true_allele == '0/1' and imputed_allele == '0/1':
                    mRefAlt += 1
                elif true_allele == '1/1' and imputed_allele == '1/1':
                    mAltAlt += 1
                elif true_allele == '0/0' and imputed_allele == '0/1':
                    xRefRef += 1
                elif true_allele == '0/1' and imputed_allele == '0/0':
                    xRefAlt += 1
                elif true_allele == '1/1' and imputed_allele == '0/1':
                    xAltAlt += 1

            # Calculate GC
            numerator = mRefRef + mRefAlt + mAltAlt
            denominator = xRefRef + xRefAlt + xAltAlt + mRefAlt + mAltAlt + mRefRef

            GC = numerator / denominator if denominator > 0 else 0

            # Store results
            gc_results.append({
                "CHROM": chrom.iloc[0],
                "Individual": individual,
                "GC": GC
            })

        # Save chunk results to a temporary file
        pd.DataFrame(gc_results).to_csv(temp_file, sep="\t", index=False)

    # Combine all temporary files
    final_gc_results = pd.concat([pd.read_csv(f, sep="\t") for f in temp_files])
    final_gc_results.to_csv(output_file, sep="\t", index=False)

    # Clean up temporary files
    for temp_file in temp_files:
        os.remove(temp_file)

    return output_file

# Example usage
true_genotypes_file = "filtered_final_genotypes.txt"
imputed_genotypes_file = "imputed_genotypes.txt"
output_file = "gc_results_per_individual_and_chromosome.txt"

calculate_gc_per_individual_and_chromosome(true_genotypes_file, imputed_genotypes_file, output_file)

