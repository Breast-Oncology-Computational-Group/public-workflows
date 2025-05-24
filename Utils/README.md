# Workflow Overview

## tsvconcat
The `tsvconcat` workflow takes an array of TSV files as input and combines them into a single TSV file. It handles empty files and ensures proper concatenation of data.

### Inputs

- `tsv_files`: Array of TSV files to concatenate

### Outputs

- `output`: A single TSV file containing the concatenated data from all input files

### Implementation Details

The workflow uses Polars to efficiently read and concatenate TSV files. It:
1. Reads each input TSV file
2. Skips any files that don't exist or are empty
3. Concatenates all valid dataframes
4. Writes the result to a single output TSV file
5. Creates an empty file if no valid data is found

### Docker Requirements

This workflow uses the Docker image: `us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/terrautils:0.1`


## Gcloud_file_copying

The `gcloud_file_copying` workflow provides a simple way to copy files using Google Cloud Storage's `gsutil` command.

### Inputs

- `source_file_path`: Path to the source file in Google Cloud Storage
- `destination_file_path`: Path where the file should be copied to in Google Cloud Storage
- `memoryGB`: Memory allocation in GB (default: 1)
- `cpu`: Number of CPU cores (default: 1)
- `diskGB`: Disk space allocation in GB (default: 1)

### Outputs

This workflow does not produce any outputs as it performs a direct file copy operation.

### Implementation Details

The workflow uses the `gsutil cp` command to copy files between Google Cloud Storage locations. It:
1. Takes source and destination paths as input
2. Uses gsutil to perform the file copy operation
3. Maintains the original file permissions and metadata

### Docker Requirements

This workflow uses the Docker image: `us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/terrautils:0.1`
