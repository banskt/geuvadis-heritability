import pandas as pd
import argparse
import os

def write_gcta(df, filepath):
    df = df.transpose()
    df = df.assign(index2 = df.index)
    cols = df.columns.tolist()
    cols = cols[-1:] + cols[:-1]
    df = df[cols]
    df.to_csv(filepath, sep='\t', header=False, index=True)


parser = argparse.ArgumentParser(description='Combine covariates into a single matrix')
parser.add_argument('pca_file', help='')
parser.add_argument('cov_file', help='')
parser.add_argument('outfile', help='')
parser.add_argument('--add_covariates', default=[], nargs='+', help='')
parser.add_argument('-o', '--output_dir', default='.', help='Output directory')
args = parser.parse_args()

print('Combining covariates ... ', end='', flush=True)
cov_df = pd.read_csv(args.cov_file, sep='\t', index_col=0, dtype=str)
pca_df = pd.read_csv(args.pca_file, sep=' ', index_col=0, header=None, dtype=str)
colnames = ['dupe']
colnames += [ 'pca%i' % (i+1) for i in range(len(pca_df.columns)-1)]
rownames = ['-'.join(i.split('-')[:2]) for i in pca_df.index]
pca_df.columns = colnames
pca_df.index = rownames
pca_df = pca_df.drop('dupe', axis = 1)
pca_df_t = pca_df.transpose()
combined_df = pd.concat([pca_df_t[cov_df.columns], cov_df], axis=0)

for cov in args.add_covariates:
    additional_df = pd.read_csv(cov, sep='\t', index_col=0, dtype=str).transpose()
    combined_df = pd.concat([combined_df, additional_df[cov_df.columns]], axis=0)

combined_df.index.name = 'cov_id'
write_gcta(combined_df, os.path.join(args.output_dir, args.outfile))
print('done.')
