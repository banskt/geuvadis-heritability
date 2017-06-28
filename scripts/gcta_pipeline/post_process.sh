#!/bin/bash

INFILE=$1
HFILE=$2
OUTDIR=$3

while read GENE; do
    if [[ -f ${OUTDIR}/${GENE}.hsq ]]; then
        HSQ=`grep "V(G)/Vp" ${OUTDIR}/${GENE}.hsq | awk -F$'\t' '{print $2, $3}'`
        echo $GENE $HSQ >> ${HFILE}
    else
        echo $GENE >> ${HFILE}
    fi
done < ${INFILE}
