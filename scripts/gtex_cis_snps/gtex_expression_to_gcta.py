#/usr/bin/env python

import numpy as np
import pandas as pd
import gzip
import scipy.stats as stats
import argparse
import os
from gtex_normalization import normalize_expression


def get_donors_from_vcf(vcfpath):
    """
    Extract donor IDs from VCF
    """
    with gzip.open(vcfpath) as vcf:
        for line in vcf:
            if line.decode()[:2]=='##': continue
            break
    return line.decode().strip().split('\t')[9:]
    #return ['-'.join(x.split('-')[:2]) for x in line.decode().strip().split('\t')[9:]]


def read_gct(gct_file, donor_ids):
    """
    Load GCT as DataFrame
    """    
    df = pd.read_csv(gct_file, sep='\t', skiprows=2, index_col=0)
    df.drop('Description', axis=1, inplace=True)
    df.index.name = 'gene_id'
    df = df[[i for i in df.columns if '-'.join(i.split('-')[:2]) in donor_ids]]
    return df


def write_gcta(df, fileprefix):
    df = df.transpose()
    df = df.assign(index2 = df.index)
    cols = df.columns.tolist()
    cols = cols[-1:] + cols[:-1]
    df = df[cols]
    df.to_csv(fileprefix + '.pheno', sep='\t', header=False, index=True)
    with open(fileprefix + '.geneids', 'w') as mfile:
        for gene in cols[1:]:
            mfile.write('{:s}\n'.format(gene))


if __name__=='__main__':
    parser = argparse.ArgumentParser(description='Convert GTEx expression to GCTA phenotype format')
    parser.add_argument('expression_gct', help='GCT file with expression in normalized units, e.g., TPM or FPKM')
    parser.add_argument('counts_gct', help='GCT file with read counts')
    parser.add_argument('vcf', help='VCF file with donor IDs')
    parser.add_argument('prefix', help='Prefix for output file names')
    parser.add_argument('-o', '--output_dir', default='.', help='Output directory')
    parser.add_argument('--expression_threshold', type=np.double, default=0.1, help='Selects genes with > expression_threshold expression in at least min_samples')
    parser.add_argument('--count_threshold', type=np.int32, default=5, help='Selects genes with > count_threshold reads in at least min_samples')
    parser.add_argument('--min_samples', type=np.int32, default=10, help='Minimum number of samples that must satisfy thresholds')
    args = parser.parse_args()
    
    print('Generating normalized expression files for GCTA analysis')
    print('Reading files ...')
    donor_ids = get_donors_from_vcf(args.vcf)
    expression_df = read_gct(args.expression_gct, donor_ids)
    counts_df = read_gct(args.counts_gct, donor_ids)

    print('Normalizing using all genes within %i samples ...' % expression_df.shape[1])
    quant_std_df, quant_df = normalize_expression(expression_df, counts_df,
        expression_threshold=args.expression_threshold, count_threshold=args.count_threshold, min_samples=args.min_samples)

    # for consistency with v6/v6p pipeline results, write unsorted expression file for PEER factor calculation
    print('Writing unsorted expression file for PEER factor calculation ...')
    quant_std_df.to_csv(os.path.join(args.output_dir, args.prefix+'.expression.txt'), sep='\t')

    write_gcta(quant_df, os.path.join(args.output_dir, args.prefix))
