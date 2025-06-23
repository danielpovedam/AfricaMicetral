#!/bin/bash
# liftover_vcf_gatk_chr1to19.sh
# Este script filtra el VCF para conservar solo las variantes de chr1 a chr19
# y luego realiza el liftover de mm10 a mm39 usando GATK 4.2.6.1.
# Uso: bash liftover_vcf_gatk_chr1to19.sh

# Cargar los módulos necesarios
module load bioinfo/GATK/4.2.6.1
module load bioinfo/Bcftools/1.9


# Definir rutas de archivos
VCF_ENTRADA="/home/dpoveda/micetral/software/exone/data/new/exome_renamed.vcf.gz"
VCF_FILTRADO="/home/dpoveda/micetral/software/exone/data/new/exome_renamed_chr1to19.vcf.gz"
CHAIN="/home/dpoveda/micetral/software/imputation/chains/mm10ToMm39.over.chain.gz"
REF_GENOMA="/home/dpoveda/micetral/software/imputation/chains/GRCm39_renamed.fna"
DICT_REF="/home/dpoveda/micetral/software/imputation/chains/GRCm39_renamed.dict"
VCF_SALIDA="/home/dpoveda/micetral/software/exone/data/new/exome_lifted_mm39_gatk.vcf.gz"
VCF_RECHAZADOS="/home/dpoveda/micetral/software/exone/data/new/exome_lifted_mm39_gatk.reject.vcf"

# 1. Filtrar el VCF para conservar únicamente las variantes en chr1 a chr19
echo "Filtrando variantes para conservar solo chr1 a chr19..."
bcftools view -r chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19 \
    -Oz -o "${VCF_FILTRADO}" "${VCF_ENTRADA}"
bcftools index "${VCF_FILTRADO}"

# 2. Verificar y crear el diccionario de referencia si no existe
if [ ! -f "${DICT_REF}" ]; then
    echo "El diccionario de referencia no existe. Creándolo..."
    gatk CreateSequenceDictionary -R "${REF_GENOMA}" -O "${DICT_REF}"
fi

# 3. Ejecutar LiftoverVcf con GATK
echo "Ejecutando LiftoverVcf..."
gatk LiftoverVcf \
    -I "${VCF_FILTRADO}" \
    -O "${VCF_SALIDA}" \
    -CHAIN "${CHAIN}" \
    -REJECT "${VCF_RECHAZADOS}" \
    -R "${REF_GENOMA}"

# 4. Indexar el VCF resultante
echo "Indexando el VCF de salida..."
bcftools index "${VCF_SALIDA}"

echo "Proceso completado."

