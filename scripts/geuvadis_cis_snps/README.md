# Calculation of heritability using only cis SNPs
## 1. Data
For data download and pre-processing, see the `genome_wide` analysis.
Here, we performed the following steps to get the starting data:
1) Use `PLINK` to split the combined bed, bim and fam files to separate chromosomes.
2) Copy 2 files from the `genome_wide` pre-processing:
    a) `GEUVADIS_EUR_expression.geneids`
    b) `GEUVADIS_EUR_expression.txt`
3) Download `gencode.v12.annotation.gtf.gz` from [here](ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_12/gencode.v12.annotation.gtf.gz). 
Unzip using:
```bash
gunzip -d gencode.v12.annotation.gtf.gz
```
Note that this file is also required in the results folder for plotting.

## 2. Analysis
Within `script/cis_snps` modify `run_greml.sh`, and run it in bash:
```bash
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
```bash
./post_process.sh
```
