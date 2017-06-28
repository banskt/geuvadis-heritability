#!/usr/bin/env python
# Author: Saikat Banerjee

import numpy as np
import collections
import argparse


class GeneExpression(collections.namedtuple('_GeneExpression', ['geneid', 'expr_arr'])):
    __slots__ = ()


def read_geuvadis_expression(filepath):
    gx = list()
    with open(filepath, 'r') as gxfile:
        sample_id = gxfile.readline().strip().split()[1:]
        for l in gxfile:
            lsplit = l.strip().split()
            x = np.array(lsplit[1:]).astype(float)
            gene = lsplit[0]
            gx.append(GeneExpression(geneid = gene, expr_arr = x))
    return sample_id, gx


def write_gcta_phenotype(fileprefix, samples, gx):

    filepath = '{0}.txt'.format(fileprefix)
    with open(filepath, 'w') as pfile:
        for i, sample in enumerate(samples):
            pheno = ['{0}'.format(x.expr_arr[i]) for x in gx]
            pstr  = '\t'.join(pheno)
            pfile.write('{0} \t {0} \t {1}\n'.format(sample, pstr))

    filepath = '{0}.geneids'.format(fileprefix)
    with open(filepath, 'w') as mfile:
        for x in gx:
            mfile.write('{0}\n'.format(x.geneid))


def fpkm_filter(gx, exthres=0.1, smin=10):
    fgx = list()
    removed = list()
    for x in gx:
        if np.sum(x.expr_arr > exthres) >= smin:
            fgx.append(x)
        else:
            removed.append(x)
    if len(removed) > 0:
        print('{0} genes removed by fpkm filter\n'.format(len(removed)))
        #print('with ids:\n{0}\n'.format(', '.join([x.geneid for x in removed])))
    return fgx


def parse_args():
    parser = argparse.ArgumentParser(description='Convert GEUVADIS expression to GCTA input')
    
    parser.add_argument('--input',
                        type=str,
                        dest='inputfile',
                        metavar='FILE',
                        help='input expression file')

    parser.add_argument('--outprefix',
                        type=str,
                        dest='outprefix',
                        metavar='PREFIX',
                        help='prefix of output file')

    parser.add_argument('--expression_threshold',
                        type=np.double,
                        dest='exthres',
                        default=0.1, 
                        help='Selects genes with > expression_threshold expression in at least min_samples')

    parser.add_argument('--min_samples',
                        type=np.int32,
                        dest='smin',
                        default=10,
                        help='Minimum number of samples that must satisfy thresholds')

    opts = parser.parse_args()
    return opts

opts = parse_args()
samples, gx = read_geuvadis_expression(opts.inputfile)
fgx = fpkm_filter(gx, opts.exthres, opts.smin)
write_gcta_phenotype(opts.outprefix, samples, fgx)
