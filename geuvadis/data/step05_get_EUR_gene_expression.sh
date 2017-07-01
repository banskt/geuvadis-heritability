#!/bin/bash

zless GD462.GeneQuantRPKM.50FN.samplename.resk10.txt.gz | cut -f1,5-284,374-466 > geuvadis.expr.txt
python convert_gx_to_gcta_pheno.py --input geuvadis.expr.txt --outprefix GEUVADIS_EUR_expression
rm -rf geuvadis.expr.txt
