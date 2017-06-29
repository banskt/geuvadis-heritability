#!/bin/bash

BASEDIR="${HOME}/gwas-eQTL/gEUVADIS_heritability"
DATADIR="${BASEDIR}/gEUVADIS_data_split_by_chrom"

JOBPREFIX="greml"
WORKDIR="${BASEDIR}/cis_heritability"
CODEDIR=`pwd`
SCRATCH=""
GTFFILE="${DATADIR}/gencode.v12.annotation.gtf"
GEXFILE="${DATADIR}/GEUVADIS_EUR_expression.txt"
GIDFILE="${DATADIR}/GEUVADIS_EUR_expression.geneids"
PLKFILE="${DATADIR}/GEUVADIS_EUR_hapmapCEU_MAF01_GXintersect_chr_insertnum_"
NUMGENE=100


#=========== No external values should be needed beyond this ================

JOBDIR="${WORKDIR}/jobsub"

if [[ ! -d ${WORKDIR} ]]; then
    mkdir -p ${WORKDIR}
fi

if [[ ! -d ${JOBDIR} ]]; then
    mkdir -p ${JOBDIR}
fi

CWD=`pwd`

cd ${JOBDIR}
split -a 3 -d -l ${NUMGENE} ${GIDFILE} geneid_

for FILE in `ls geneid_*`;do

    INDEX=`echo ${FILE} | cut -d'_' -f2`

    # if scratch is not defined above, create one within the jobdir
    if [[ "${SCRATCH}" == "" ]]; then
        MTMPDIR="${JOBDIR}/${FILE}_scratch"
        if [[ ! -d ${MTMPDIR} ]]; then
            mkdir -p ${MTMPDIR}
        fi
    fi

    # get the full path of the split geneid file
    SPLTFIL="${JOBDIR}/${FILE}"

    # create the job submission file
    sed "s|_JOBNAME|${JOBPREFIX}_${INDEX}|g;
       18s|_workdir|${WORKDIR}|g;
       19s|_codedir|${CODEDIR}|g;
       20s|_scratch|${MTMPDIR}|g;
       22s|_gtffile|${GTFFILE}|g;
       23s|_gxfile_|${GEXFILE}|g;
       24s|_gidfile|${SPLTFIL}|g;
       25s|_plkfile|${PLKFILE}|g;
       26s|_numgene|${NUMGENE}|g;" ${CWD}/greml.bsub > ${FILE}.bsub

    # Submit the job
    bsub < ${FILE}.bsub

done

cd ${CWD}

# ============ Create the post processing file =======================
echo "Creating post-processing file"
sed "3s|_inpfile|${GIDFILE}|;
     4s|_workdir|${WORKDIR}|;" post_process.sh > tmp.sh
mv tmp.sh post_process.sh
chmod +x post_process.sh

