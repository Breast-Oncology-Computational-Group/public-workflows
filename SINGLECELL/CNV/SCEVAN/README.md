# SCEVAN Workflow

## Overview

The SCEVAN workflow is designed for Copy Number Variation (CNV) analysis in single-cell RNA sequencing data. This workflow runs the SCEVAN algorithm to detect copy number variations and outputs results in HDF5 format.

## Workflow Structure

The workflow consists of a single task `run_scevan` that:
1. Executes the SCEVAN R script with provided inputs
2. Uploads results to Google Cloud Storage
3. Outputs the CNV analysis results as an H5 file

## Inputs

### Required Inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `h5` | File | Input HDF5 file containing single-cell RNA sequencing data |
| `metadata_csv` | File | CSV file containing cell metadata information |
| `params_table` | File | Table containing SCEVAN parameters |
| `scevan_Rscript` | File | R script file containing the SCEVAN analysis code |
| `output_gs_bucket` | String | Google Cloud Storage bucket path for output storage |
| `cohort_name` | String | Name of the cohort being analyzed |
| `sample_name` | String | Name of the sample being analyzed |

### Optional Inputs

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `output_dir` | String | "scevan" | Directory name for output files |
| `zones` | String | "us-central1-a" | Google Cloud compute zones |
| `cpu` | Int | 10 | Number of CPU cores to allocate |
| `memory` | String | "16G" | Memory allocation for the task |
| `docker` | String | "jingxin/scevan:latest" | Docker image to use |
| `preemptible` | Int | 2 | Number of preemptible instances |
| `extra_disk_space` | Int | 10 | Additional disk space in GB |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `cnv_scevan_h5` | File | HDF5 file containing SCEVAN CNV analysis results |

## Runtime Configuration

- **Docker Image**: `jingxin/scevan:latest`
- **Memory**: 16GB (configurable)
- **CPU**: 10 cores (configurable)
- **Boot Disk**: 12GB
- **Data Disk**: Automatically calculated as 2x input file size + extra disk space
- **Preemptible Instances**: 2 (configurable)
- **Compute Zones**: us-central1-a (configurable)

## Usage

### Basic Usage

```wdl
workflow scevan {
    call run_scevan {
        input:
            h5 = "path/to/input.h5",
            metadata_csv = "path/to/metadata.csv",
            params_table = "path/to/params.csv",
            scevan_Rscript = "path/to/scevan.R",
            output_gs_bucket = "gs://your-bucket",
            cohort_name = "your_cohort",
            sample_name = "your_sample"
    }
}
```

### Advanced Usage with Custom Parameters

```wdl
workflow scevan {
    call run_scevan {
        input:
            h5 = "path/to/input.h5",
            metadata_csv = "path/to/metadata.csv",
            params_table = "path/to/params.csv",
            scevan_Rscript = "path/to/scevan.R",
            output_gs_bucket = "gs://your-bucket",
            cohort_name = "your_cohort",
            sample_name = "your_sample",
            output_dir = "custom_output",
            cpu = 16,
            memory = "32G",
            extra_disk_space = 20,
            zones = "us-west1-a"
    }
}
```

## Output Structure

The workflow outputs results to:
- **Local**: `{output_dir}/scevan.h5`
- **Cloud Storage**: `{output_gs_bucket}/{cohort_name}/{sample_name}/{output_dir}/`

## Dependencies

- Google Cloud Platform access
- Docker container with SCEVAN R package
- R environment with required packages
- Google Cloud Storage access for output upload

## Notes

- The workflow automatically removes trailing slashes from the output bucket path
- Disk space is automatically calculated as 2x the input file size plus extra space
- The R script execution uses unlimited stack size (`ulimit -s unlimited`)
- Results are uploaded to Google Cloud Storage using `gsutil -m cp` for parallel upload

## Error Handling

The workflow includes error handling with `set -e` to stop execution on any command failure.

## Resource Requirements

- **Minimum**: 10 CPU cores, 16GB RAM
- **Recommended**: 16+ CPU cores, 32GB+ RAM for large datasets
- **Storage**: 12GB boot disk + 2x input file size + extra space
