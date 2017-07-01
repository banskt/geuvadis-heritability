#!/bin/bash

INFILE="/usr/users/sbanerj/gwas-eQTL/gtex_data/gtex_wholeblood_normalized.geneids"
WORKDIR="/usr/users/sbanerj/gwas-eQTL/heritability/gtex/cis_heritability"

GREML="${WORKDIR}/greml"
GREML_NOC="${WORKDIR}/greml_noconstraint"
GREML_LDMS="${WORKDIR}/greml-ldms"
GREML_LDMS_NOC="${WORKDIR}/greml-ldms_noconstraint"

for DIR in ${GREML} ${GREML_LDMS} ${GREML_NOC} ${GREML_LDMS_NOC}; do
    HFILE="${DIR}.txt"
    while read GENE; do
        if [[ -f ${DIR}/${GENE}.hsq ]]; then
            HSQ=`grep "V(G)/Vp" ${DIR}/${GENE}.hsq | awk -F$'\t' '{print $2, $3}'`
            echo $GENE $HSQ >> ${HFILE}
        else
            echo $GENE >> ${HFILE}
        fi
    done < ${INFILE}
done
