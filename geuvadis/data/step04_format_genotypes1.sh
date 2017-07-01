#!/bin/bash
# Shell commands to query vcf files and convert them to PLINK format
# Exactly same filters as used in PredictDB pipeline

# This was created manually, european samples which do not have expression data // should be included later in the pipeline
NOEXP="samples_without_expression_data.txt"

PLINK="/opt/plink/plink-1.90/plink"

MERGELIST="all_plink_files.txt"

if [[ -f ${MERGELIST} ]]; then
    rm -rf ${MERGELIST}
fi

# Filter for each chromosome
for chrom in {1..22}; do

    INFILE="GEUVADIS.chr${chrom}.PH1PH2_465.IMPFRQFILT_BIALLELIC_PH.annotv2.genotypes.vcf.gz"
    INTERMEDIATE="GEUVADIS_EUR_hapmapCEU_MAF01_chr${chrom}.vcf.gz"
    OUTFILE="GEUVADIS_EUR_hapmapCEU_MAF01_chr${chrom}"

    bcftools convert -S EUR_samples.txt -i 'MAF>0.01 & TYPE="snp" & N_ALT=1 & ID=@target_snp_ids.txt' ${INFILE} -Oz > ${INTERMEDIATE}
    ${PLINK} --vcf ${INTERMEDIATE} --make-bed --out ${OUTFILE}
    echo ${OUTFILE} >> ${MERGELIST}

done

# Merge the bed files
CHR1FILE="GEUVADIS_EUR_hapmapCEU_MAF01_chr1"
COMBINED="GEUVADIS_EUR_hapmapCEU_MAF01"
OUTFILE="GEUVADIS_EUR_hapmapCEU_MAF01_GXintersect"
${PLINK} --bfile ${CHR1FILE} --merge-list ${MERGELIST} --geno 0.0 --make-bed --out ${COMBINED}
${PLINK} --bfile ${COMBINED} --remove ${NOEXP} --make-bed --out ${OUTFILE}

# Remove the intermediate plink files
rm -rf ${MERGELIST}
for chrom in {1..22}; do
    OUTFILE="GEUVADIS_EUR_hapmapCEU_MAF01_chr${chrom}"
    rm -rf ${OUTFILE}.nosex ${OUTFILE}.bed ${OUTFILE}.bim ${OUTFILE}.fam ${OUTFILE}.log
done
