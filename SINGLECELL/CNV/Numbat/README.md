# Numbat
Numbat is a computational method for detecting copy number variations (CNVs) in single-cell RNA-seq data. This workflow implements the Numbat for CNV detection using raw counts and BAM files.
## Overview

The workflow consists of two main steps:
1. Preparation of allele frequency data from BAM files
2. CNV detection using Numbat

## Required Input
  - File: Single-cell RNA-seq data in H5AD format
  - File: aligned reads in BAM format
  - File: Cell barcodes file in TSV format

## Workflow Components

### 1. Allele Frequency Preparation (`preprare_allele_df` task)

This task processes BAM files to generate allele frequency information:
- Inputs:
  - BAM file with aligned reads
  - Cell barcodes file
  - Sample ID
- Outputs:
  - Allele counts file in TSV format

### 2. CNV Detection (`numbat` task)

Performs CNV detection using both gene expression and allele frequency data:
- Inputs:
  - Gene expression count matrix
  - Allele frequency data
  - Cell type annotations
  - Genome build specification
- Outputs:
  - CNV

## Docker Images

The workflow uses the following Docker image:
- `jingxin/numbat:v1.4.2` which modified the entrypoint to be `/bin/bash` for `pkharchenkolab/numbat-rbase:v1.4.2`

## References

For more information about Numbat, please refer to:
- Numbat GitHub repository: https://github.com/kharchenkolab/numbat

