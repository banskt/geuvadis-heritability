# Calculation of heritability from GEUVADIS dataset
## 1. Download
Scripts for downloading and pre-processing the data are given in `data` directory. The following commands need to be run:
```
./step01_download_files.sh
Rscript step02_get_EUR_samples.R
Rscript step03_get_target_snps.R
./step04_format_genotype1.sh
./step05_get_EUR_gene_expression.sh
```
Note that this will download the data withing the same directory where the commands are being run.


## 2. Analysis
Within `script/gcta_pipeline` modify `run_greml.sh`, and run:
```
./run_greml.sh
```

### Options:
1) `PREFIX="greml"` runs the analysis with a single GRM as discussed in [Yang *et. al.* 2015](http://www.nature.com/ng/journal/v42/n7/abs/ng.608.html), while `PREFIX="greml-ldms"` runs the analysis with multiple GRMs and stratifying the SNPs by segment based LD score, as discussed in [Yang *et. al.* 2015](http://www.nature.com/ng/journal/v47/n10/full/ng.3390.html). 
2) `NPCA=20` sets the number of principal components to be used as 20.
3) The directories need to be set properly.
