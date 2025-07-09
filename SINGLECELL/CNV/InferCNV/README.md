# InferCNV Workflow

## Overview

The `infercnv.wdl` workflow performs Copy Number Variation (CNV) inference on single-cell RNA sequencing data using the InferCNV algorithm. This workflow processes gene expression data in H5 format and generates CNV analysis outputs from InferCNV.

## Workflow Description

The workflow consists of a single main task:

1. **CNV Analysis**: Runs InferCNV analysis on H5 format gene expression data to identify copy number variations and outputs results to Google Cloud Storage

## Inputs

### Required Inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `h5` | File | Gene expression data in H5 format |
| `metadata_csv` | File | CSV file containing cell metadata and annotations |
| `params_table` | File | Parameters table for InferCNV analysis |
| `gene_order_file` | File | File containing gene chromosomal positions and ordering |
| `infercnv_Rscript` | File | R script for running InferCNV analysis |
| `output_gs_bucket` | String | Google Cloud Storage bucket for output storage |

### Optional Inputs

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `output_dir` | String | "infercnv" | Output directory name |
| `zones` | String | "us-central1-a" | Google Cloud zones for computation |
| `cpu` | Int | 10 | Number of CPU cores |
| `memory` | String | "16G" | Memory allocation |
| `docker` | String | "jingxin/infercnv:latest" | Docker image for execution |
| `preemptible` | Int | 2 | Number of preemptible instances |
| `extra_disk_space` | Int | 10 | Additional disk space in GB |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `cnv_infercnv_h5` | File | H5 file containing CNV analysis results |

## Workflow Tasks

### run_infercnv

**Purpose**: Performs CNV inference analysis using the InferCNV R package and uploads results to Google Cloud Storage.

**Inputs**:
- `h5`: Gene expression data in H5 format
- `metadata_csv`: CSV file containing cell metadata and annotations
- `params_table`: Parameters table for InferCNV analysis
- `gene_order_file`: File containing gene chromosomal positions
- `infercnv_Rscript`: R script for running InferCNV analysis
- `output_gs_bucket`: Google Cloud Storage bucket for output storage
- `output_dir`: Output directory name (default: "infercnv")
- `zones`: Google Cloud zones (default: "us-central1-a")
- `cpu`: Number of CPU cores (default: 10)
- `memory`: Memory allocation (default: "16G")
- `docker`: Docker image (default: "jingxin/infercnv:latest")
- `preemptible`: Number of preemptible instances (default: 2)
- `extra_disk_space`: Additional disk space in GB (default: 10)

**Outputs**:
- `cnv_infercnv_h5`: H5 file containing CNV analysis results

**Runtime Configuration**:
- Docker: `jingxin/infercnv:latest`
- Memory: 16GB (configurable)
- CPU: 10 cores (configurable)
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
  "infercnv.h5": "gs://bucket/path/to/expression_data.h5",
  "infercnv.metadata_csv": "gs://bucket/path/to/metadata.csv",
  "infercnv.params_table": "gs://bucket/path/to/params_table.csv",
  "infercnv.gene_order_file": "gs://bucket/path/to/gene_order.txt",
  "infercnv.infercnv_Rscript": "gs://bucket/path/to/infercnv.R",
  "infercnv.output_gs_bucket": "my-output-bucket",
  "infercnv.zones": "us-central1-a",
  "infercnv.preemptible": 2
}
```

### Advanced Usage with Custom Parameters

```json
{
  "infercnv.h5": "gs://bucket/path/to/expression_data.h5",
  "infercnv.metadata_csv": "gs://bucket/path/to/metadata.csv",
  "infercnv.params_table": "gs://bucket/path/to/params_table.csv",
  "infercnv.gene_order_file": "gs://bucket/path/to/gene_order.txt",
  "infercnv.infercnv_Rscript": "gs://bucket/path/to/infercnv.R",
  "infercnv.output_gs_bucket": "my-output-bucket",
  "infercnv.zones": "us-central1-a",
  "infercnv.cpu": 16,
  "infercnv.memory": "32G",
  "infercnv.preemptible": 2,
  "infercnv.extra_disk_space": 20
}
```

## Input File Requirements

### H5 File Format
The input H5 file should contain:
- Gene expression data in a format compatible with the InferCNV R script
- Cell and gene identifiers

### Metadata CSV File
The metadata CSV file should contain:
- Cell identifiers matching those in the H5 file
- Cell annotations and cluster assignments
- Any additional metadata required for the analysis

### Parameters Table
The parameters table should contain:
- Configuration parameters for the InferCNV analysis
- Analysis-specific settings and thresholds

### Gene Order File
The gene order file should contain:
- Gene identifiers matching those in the H5 file
- Chromosomal positions (chromosome, start, end)
- Gene ordering information

## Dependencies

### External Dependencies
- **Cromwell**: Workflow execution engine
- **Google Cloud Platform**: For computation resources and storage
- **Docker**: Container runtime

### Software Dependencies
- **InferCNV R package**: For CNV analysis
- **R**: Statistical computing environment
- **gsutil**: For Google Cloud Storage operations

## Output Structure

The workflow produces:
- **cnv.h5**: H5 file containing CNV analysis results
- **Output directory**: Uploaded to the specified Google Cloud Storage bucket containing all InferCNV analysis results

## Troubleshooting

### Common Issues

1. **Memory Errors**: Increase the `memory` parameter if encountering out-of-memory errors
2. **Disk Space**: Adjust `extra_disk_space` if the workflow fails due to insufficient disk space
3. **Timeout Issues**: Consider using more CPU cores or adjusting the `preemptible` setting
4. **GCS Upload Issues**: Ensure the `output_gs_bucket` is accessible and has appropriate permissions

### Performance Optimization

- For large datasets, increase `cpu` and `memory` parameters
- Use multiple preemptible instances for cost optimization
- Consider using different zones for better resource availability
- Adjust `extra_disk_space` based on expected output size

## Version Information

- **Workflow Version**: 1.0
- **Docker Image**: jingxin/infercnv:latest
- **Default CPU**: 10 cores
- **Default Memory**: 16GB