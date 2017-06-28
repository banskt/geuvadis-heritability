#!/bin/bash

BASEDIR="/usr/users/sbanerj/gwas-eQTL/geuvadis-heritability"
DATADIR="${BASEDIR}/geuvadis-heritability/data"

PREFIX="greml-ldms"
NPCA=20
NGENE=100

PHENOFILE="${DATADIR}/GEUVADIS_EUR_expression.txt"
GENEIDFILE="${DATADIR}/GEUVADIS_EUR_expression.geneids"
BFILE="${DATADIR}/GEUVADIS_EUR_hapmapCEU_MAF01_GXintersect"
GCTA="/usr/users/sbanerj/packages/gcta/gcta-1.26/gcta64"

WORKDIR="${BASEDIR}/${PREFIX}_${NPCA}pc"
JOBDIR="${WORKDIR}/${PREFIX}_${NPCA}pc_jobsub"
PCFILE="${WORKDIR}/${PREFIX}_${NPCA}pc"
OUTDIR="${WORKDIR}/reml_res"
ONCDIR="${WORKDIR}/reml_noconstraint_res"
GRMFILE="${WORKDIR}/${PREFIX}"

#===================== Be careful before changing things below =======================#

case $PREFIX in
    "greml") 
        OPTION="--grm"
        MCASE=1
        ;;
    "greml-ldms")
        OPTION="--mgrm"
        MCASE=2
        ;;
    *) 
        echo "Unknown option ${PREFIX}"
        exit
        ;;
esac

if [[ ! -d ${JOBDIR} ]]; then
    mkdir -p ${JOBDIR}
fi

# keep current working directory in memory
CWD=`pwd`

# change to workdir and run GCTA, create Principal components, create result directories
cd ${WORKDIR}

if [[ $MCASE == 1 ]]; then
    ${GCTA} --bfile ${BFILE} --autosome --maf 0.01 --make-grm --out ${GRMFILE} --thread-num 16
fi

if [[ $MCASE == 2 ]]; then
    ${GCTA} --bfile ${BFILE} --ld-score-region 200 --out strat --thread-num 16
    Rscript ${CWD}/stratify_snps.R strat.score.ld
    ${GCTA} --bfile ${BFILE} --extract snp_group1.txt --autosome --maf 0.01 --make-grm --out ldgroup01
    ${GCTA} --bfile ${BFILE} --extract snp_group2.txt --autosome --maf 0.01 --make-grm --out ldgroup02
    ${GCTA} --bfile ${BFILE} --extract snp_group3.txt --autosome --maf 0.01 --make-grm --out ldgroup03
    ${GCTA} --bfile ${BFILE} --extract snp_group4.txt --autosome --maf 0.01 --make-grm --out ldgroup04
    echo "ldgroup01" >> ${GRMFILE}
    echo "ldgroup02" >> ${GRMFILE}
    echo "ldgroup03" >> ${GRMFILE}
    echo "ldgroup04" >> ${GRMFILE}
fi
   
${GCTA} ${OPTION} ${GRMFILE}  --pca ${NPCA}  --out ${PCFILE}

if [[ ! -d $OUTDIR ]]; then
    mkdir ${OUTDIR}
fi

if [[ ! -d $ONCDIR ]]; then
    mkdir ${ONCDIR}
fi

# change to job submission directory, submit jobs and come back
cd ${JOBDIR}
split -a 3 -d -l ${NGENE} ${GENEIDFILE} geneid_

for file in `ls geneid_*`;do
    INDEX=`echo $file | cut -d'_' -f2`
    sed "s|JOBNAME|${PREFIX}_${INDEX}|g;
         11s|_workdir|${WORKDIR}|;
         12s|_pheno|${PHENOFILE}|;
         13s|_gene_id_filename|${JOBDIR}/${file}|;
         14s|_pcfile|${PCFILE}.eigenvec|;
         15s|_outdir|${OUTDIR}|;
         16s|_oncdir|${ONCDIR}|;
         17s|_grmfile|${GRMFILE}|;
         18s|_ngene|${NGENE}|;
         20s|_gcta_source|${GCTA}|;
         33,34s|--option|${OPTION}|;" ${CWD}/greml.bsub > ${file}.bsub
    bsub < ${file}.bsub
done

cd ${CWD}
