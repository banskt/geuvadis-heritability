# Calculation of heritability using only cis SNPs
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
About 60GB of data will be downloaded.


## 2. Analysis
Within `script/cis_snps` modify `run_greml.sh`, and run it in bash:
```
./run_greml.sh
```
The directories need to be set properly in the script.
It will run the analysis in 4 different ways: 
1) with a single GRM as discussed in [Yang *et. al.* 2010](http://www.nature.com/ng/journal/v42/n7/abs/ng.608.html)
2) same as 1 but without constraint
3) with multiple GRMs and stratifying the SNPs by segment based LD score, as discussed in [Yang *et. al.* 2015](http://www.nature.com/ng/journal/v47/n10/full/ng.3390.html)
4) same as 3 but without constraints

This will run the jobs in `BSUB` queue and produce intermediate results in the working directory. 


## 3. Post process
The above step will also modify the post-processing script inplace.
It reads heritability results from all output files and put them in 4 corresponding files for the 4 options used.
```
./post_process.sh
```
