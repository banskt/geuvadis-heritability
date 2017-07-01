#!/bin/bash

INFILE="_infile"
OUTDIR="_outdir"
ONCDIR="_oncdir"
HPREFIX="_hprefix"

HFILE="${HPREFIX}_hsq.txt"
while read GENE; do
    if [[ -f ${OUTDIR}/${GENE}.hsq ]]; then
        HSQ=`grep "V(G)/Vp" ${OUTDIR}/${GENE}.hsq | awk -F$'\t' '{print $2, $3}'`
        echo $GENE $HSQ >> ${HFILE}
    else
        echo $GENE >> ${HFILE}
    fi
done < ${INFILE}

HFILE="${HPREFIX}_hsq_noconstraint.txt"
while read GENE; do
    if [[ -f ${ONCDIR}/${GENE}.hsq ]]; then
        HSQ=`grep "V(G)/Vp" ${ONCDIR}/${GENE}.hsq | awk -F$'\t' '{print $2, $3}'`
        echo $GENE $HSQ >> ${HFILE}
    else
        echo $GENE >> ${HFILE}
    fi
done < ${INFILE}
