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

