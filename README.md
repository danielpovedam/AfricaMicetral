**Git repository for the MICETRAL project at CBGP-IRD.**  
**Title of submitted manuscript:**  
*Invasion dynamics of the house mouse in Africa reveal multiple Eurasian origins, interspecific admixture, and human-mediated dispersal*

We present a large-scale population genomic analysis of 416 whole-genome sequences, including 333 new low-coverage genomes, to investigate the colonization history of African house mouse (*Mus musculus domesticus*) populations.

All scripts used in the different analysis steps are included in this repository.

## Repository structure

00_genomes/ # Genome files and reference
01_QC/ # Quality control scripts
02_mapping/ # Mapping scripts
03_ANGSD_locopipe/ # Loco-pipe depth and GLs
04_relatedness/ # Relatedness analyses (ngsRelate)
05_imputation/ # Genotype imputation (STITCH)
06_merge_vcf/ # Merged VCF files
07_population_structure/ # PCA, NGSadmix, sNMF analyses
08_population_graphs/ # Population graphs and gene flow analyses
09_introgression/ # Introgression analyses (D-/f-statistics)
10_demographic_inference/ # Demographic inference (Relate, Stairway Plot)
11_Heterozygosity_ROH/ # Genetic diversity and ROH analyses

## Contact

**Daniel Poveda Martinez**  
[GitHub profile](https://github.com/danielpovedam)  
Email: danielpovedam@gmail.com 

## License

This code is provided for academic and research purposes.  
If you use this work, please cite the manuscript once it is published.
