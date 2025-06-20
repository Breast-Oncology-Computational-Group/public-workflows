# InferCNV Workflow

## Overview

The `infercnv.wdl` workflow performs Copy Number Variation (CNV) inference on single-cell RNA sequencing data using the InferCNV algorithm. This workflow processes gene expression data in H5AD format and generates CNV analysis outputs from InferCNV.

## Workflow Description

The workflow consists of two main steps:

1. **Data Conversion**: Converts H5AD format gene expression data to RDS format using the `h5ad_to_rds` utility from the utils module
2. **CNV Analysis**: Runs InferCNV analysis on the converted data to identify copy number variations

## Inputs

### Required Inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `gex_h5ad` | File | Gene expression data in H5AD format |

### Optional Inputs

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `zones` | String | "us-central1-a" | Google Cloud zones for computation |
| `preemptible` | Int | 2 | Number of preemptible instances |

### Required Task-Level Inputs

The following inputs are required for the `run_infercnv` task but are not exposed at the workflow level. These need to be provided through the task configuration:

| Parameter | Type | Description |
|-----------|------|-------------|
| `annotations_file_csv` | File | CSV file containing cell annotations with required columns: barcode, cnv_group, and cnv_celltype. The cnv_group column must contain at least two categories: "reference" and "case". Only cells from these two groups are included in the analysis. Reference group cells serve as the baseline for comparison, and their cnv_celltype values are used as reference group names. Important: ensure that case and reference cells do not share the same cnv_celltype categories to avoid conflicts in the analysis.|
| `gene_order_file` | File | File containing gene chromosomal positions and ordering |
| `infercnv_Rscript` | File | R script for running InferCNV analysis |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `infercnv_output` | File | Compressed tar.gz file containing all InferCNV analysis results |

## Workflow Tasks

### 1. h5ad_to_rds

**Purpose**: Converts H5AD format gene expression data to RDS format for R processing.

**Inputs**:
- `h5ad`: Input H5AD file
- `zones`: Google Cloud zones (inherited from workflow)

**Outputs**:
- `raw_counts_rds`: RDS file containing raw count matrix
- `metadata`: RDS file containing cell metadata

**Runtime Configuration**:
- Docker: `jingxin/omnicell:py311`
- Memory: 10GB
- CPU: 1
- Disk: 20GB HDD

### 2. run_infercnv

**Purpose**: Performs CNV inference analysis using the InferCNV R package.

**Inputs**:
- `raw_counts_rds`: Raw count matrix in RDS format (from h5ad_to_rds task)
- `annotations_file_csv`: CSV file containing cell annotations/clusters
- `gene_order_file`: File containing gene chromosomal positions
- `infercnv_Rscript`: R script for running InferCNV analysis
- `additional_args`: Additional command-line arguments for InferCNV (optional)
- `zones`: Google Cloud zones
- `cpu`: Number of CPU cores (default: 1)
- `memory`: Memory allocation (default: 12GB)
- `docker`: Docker image (default: trinityctat/infercnv:latest)
- `preemptible`: Number of preemptible instances (default: 2)
- `extra_disk_space`: Additional disk space in GB (default: 10)

**Outputs**:
- `infercnv_full_outputs`: Compressed tar.gz file containing all analysis results

**Runtime Configuration**:
- Docker: `trinityctat/infercnv:latest`
- Memory: 12GB (configurable)
- CPU: 1 (configurable)
- Boot Disk: 12GB
- Data Disk: Calculated based on input size × 2 + extra space
- Preemptible: 2 instances (configurable)

## Usage

### Basic Usage

```bash
java -jar cromwell.jar run infercnv.wdl \
  --inputs inputs.json
```

### Input JSON Example

```json
{
  "infercnv.gex_h5ad": "gs://bucket/path/to/expression_data.h5ad",
  "infercnv.zones": "us-central1-a",
  "infercnv.preemptible": 2
}
```

### Advanced Usage with Custom Parameters

```json
{
  "infercnv.gex_h5ad": "gs://bucket/path/to/expression_data.h5ad",
  "infercnv.zones": "us-central1-a",
  "infercnv.preemptible": 2,
  "infercnv.run_infercnv.cpu": 4,
  "infercnv.run_infercnv.memory": "24G",
  "infercnv.run_infercnv.additional_args": "--cutoff=0.1 --smooth_method=pyramidinal"
}
```

## Input File Requirements

### H5AD File Format
The input H5AD file should contain:
- Raw count matrix in the `X` layer or as the main matrix
- Cell metadata with cluster/annotation information
- Gene information with chromosomal positions

### Annotations File (CSV)
The annotations file should contain:
- Cell identifiers matching those in the H5AD file
- Cluster/group assignments for each cell
- Optional: additional metadata columns

### Gene Order File
The gene order file should contain:
- Gene identifiers matching those in the H5AD file
- Chromosomal positions (chromosome, start, end)
- Gene ordering information

## Dependencies

### External Dependencies
- **Cromwell**: Workflow execution engine
- **Google Cloud Platform**: For computation resources
- **Docker**: Container runtime

### Software Dependencies
- **OmniCell-utils**: For H5AD to RDS conversion (imported from utils.wdl)
- **InferCNV R package**: For CNV analysis
- **R**: Statistical computing environment

## Output Structure

The workflow produces a compressed tar.gz file containing the InferCNV analysis results, which typically includes:

- **infercnv.observations.txt**: Processed expression data
- **infercnv.references.txt**: Reference expression profiles
- **infercnv.infercnv_obj**: R object with analysis results
- **HMM_CNV_predictions.*.txt**: HMM-based CNV predictions
- **CNV_predictions.*.txt**: CNV prediction files
- **plots/**: Directory containing visualization plots
- **run.final.infercnv_obj**: Final analysis object

## Troubleshooting

### Common Issues

1. **Memory Errors**: Increase the `memory` parameter if encountering out-of-memory errors
2. **Disk Space**: Adjust `extra_disk_space` if the workflow fails due to insufficient disk space
3. **Timeout Issues**: Consider using more CPU cores or adjusting the `preemptible` setting

### Performance Optimization

- For large datasets, increase `cpu` and `memory` parameters
- Use multiple preemptible instances for cost optimization
- Consider using different zones for better resource availability

## Version Information

- **Workflow Version**: 1.0
- **InferCNV Version**: Latest (trinityctat/infercnv:latest)
- **OmniCell Version**: py311 (jingxin/omnicell:py311)