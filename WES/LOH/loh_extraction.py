# -- coding: utf-8 --
#! /usr/bin/env python3

import polars as pl
import argparse
def extract_loh(gene_cn_file):
    """
    Extract LOH from gene_cn_file from ABSOLUTE output
    """
    df = pl.read_csv(gene_cn_file, separator="\t").drop_nulls(subset=["expected.a2", "expected.a1",'LOH'])
    assert all(df['expected.a2'] >= df['expected.a1']), "expected.a2 (greater CN) should be greater than expected.a1 (lesser CN)"

    df = df.with_columns(
        pl.when(pl.col("LOH")==0).then(pl.lit('N')
        ).otherwise(
            pl.when((pl.col("expected.a1").round(0)==0) & (pl.col("corrected_total_cn").round(0)==1)).then(pl.lit('CL-LOH'))
            .when((pl.col("expected.a1").round(0)==0) & (pl.col("corrected_total_cn").round(0)==2)).then(pl.lit('CN-LOH'))
            .when((pl.col("expected.a1").round(0)==0) & (pl.col("corrected_total_cn").round(0)>2)).then(pl.lit('LOH(Other)'))
        ).alias("LOH_type")
    ).filter(pl.col("LOH_type") != 'N')

    return df[['sample','gene', 'LOH_type']].unique()

    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract LOH from gene_cn_file from ABSOLUTE output")
    parser.add_argument('-i', "--gene_cn_file", type=str, required=True, help="Path to the gene_cn_file from ABSOLUTE output")
    parser.add_argument('-o', "--output_file", type=str, required=True, help="Path to the output file")
    args = parser.parse_args()

    loh_df = extract_loh(args.gene_cn_file)
    loh_df.write_csv(args.output_file, separator="\t")