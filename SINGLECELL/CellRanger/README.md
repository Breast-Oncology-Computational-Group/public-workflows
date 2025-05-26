# Cellranger

## count.wdl
### Input
**Required Parameters:**
- `output_gs_bucket_folder_path`: Google Storage bucket path for output
- `sample_name`: Sample name in the FASTQ file (e.g., [sample_name]_R1_001.fastq.gz)
- `cohort_name`: Name of the cohort
- `sample_id`: Sample ID in the Terra table
- `zones`: Google Cloud zone (default: "us-central1-a")
- `namespace_workspace`: Terra workspace namespace for output file table reference

#### Terra Table Reference
**Files output from cellranger count**
```
Outputs:
- Run summary HTML:                      /home/jdoe/runs/sample345/outs/web_summary.html
- Run summary CSV:                       /home/jdoe/runs/sample345/outs/metrics_summary.csv
- BAM:                                   /home/jdoe/runs/sample345/outs/possorted_genome_bam.bam
- BAM index:                             /home/jdoe/runs/sample345/outs/possorted_genome_bam.bam.bai
- Filtered feature-barcode matrices MEX:    /home/jdoe/runs/sample345/outs/filtered_feature_bc_matrix
- Filtered feature-barcode matrices HDF5:   /home/jdoe/runs/sample345/outs/filtered_feature_bc_matrix.h5
- Unfiltered feature-barcode matrices MEX:  /home/jdoe/runs/sample345/outs/raw_feature_bc_matrix
- Unfiltered feature-barcode matrices HDF5: /home/jdoe/runs/sample345/outs/raw_feature_bc_matrix_h5.h5
- Secondary analysis output CSV:         /home/jdoe/runs/sample345/outs/analysis
- Per-molecule read information:         /home/jdoe/runs/sample345/outs/molecule_info.h5
- Loupe Browser file:               /home/jdoe/runs/sample345/outs/cloupe.cloupe
```
**Table in Terra workspace**

| column_name_in_terra_sample_table | value |
|------------|-----------|
| cellranger_count_web_summary_html | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/web_summary.html` |
| cellranger_count_metrics_summary_csv | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/metrics_summary.csv` |
| cellranger_count_bam | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/possorted_genome_bam.bam` |
| cellranger_count_bam_index | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/possorted_genome_bam.bam.bai` |
| cellranger_count_filtered_feature_bc_matrix | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/filtered_feature_bc_matrix` |
| cellranger_count_filtered_feature_bc_matrix_h5 | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/filtered_feature_bc_matrix.h5` |
| cellranger_count_raw_feature_bc_matrix | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/raw_feature_bc_matrix` |
| cellranger_count_raw_feature_bc_matrix_h5 | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/raw_feature_bc_matrix.h5` |
| cellranger_count_analysis | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/analysis` |
| cellranger_count_molecule_info | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/molecule_info.h5` |
| cellranger_count_cloupe | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/GEX/cloupe.cloupe` |

**Task-Specific Parameters:**
- `fastq_dir`: Directory containing FASTQ files
- `reference_dir`: Reference genome directory
- `chemistry`: Chemistry version

**Optional Parameters:**
- `force_cells`: Force pipeline to use this number of cells
- `expected_cells`: Expected number of recovered cells
- `include_introns`: Include intronic reads (default: true)
- `no_bam`: Skip BAM file creation (default: false)
- `no_secondary`: Skip secondary analysis (default: true)

### Output
- `cellranger_count_output_json`: JSON file containing output metadata
- `cellranger_count_ingest_logs`: Logs from Terra table ingestion

---

## atac_count.wdl
### Input
**Required Parameters:**
- `input_gs_bucket_path`: Google Storage bucket input path
- `sample_name`: Sample name in the FASTQ file
- `cohort_name`: Name of the cohort
- `sample_id`: Sample ID in the Terra table
- `zones`: Google Cloud zone (default: "us-central1-a")
- `namespace_workspace`: Terra workspace namespace for output file table reference

#### Terra Table Reference
**Files output from cellranger-atac count**
```
Outputs:
- Per-barcode fragment counts & metrics:        /home/jdoe/runs/sample345/outs/singlecell.csv
- Position sorted BAM file:                     /home/jdoe/runs/sample345/outs/possorted_bam.bam
- Position sorted BAM index:                    /home/jdoe/runs/sample345/outs/possorted_bam.bam.bai
- Summary of all data metrics:                  /home/jdoe/runs/sample345/outs/summary.json
- HTML file summarizing data & analysis:        /home/jdoe/runs/sample345/outs/web_summary.html
- Bed file of all called peak locations:        /home/jdoe/runs/sample345/outs/peaks.bed
- Smoothed transposition site track:            /home/jdoe/runs/sample345/outs/cut_sites.bigwig
- Raw peak barcode matrix in hdf5 format:       /home/jdoe/runs/sample345/outs/raw_peak_bc_matrix.h5
- Raw peak barcode matrix in mex format:        /home/jdoe/runs/sample345/outs/raw_peak_bc_matrix
- Directory of analysis files:                  /home/jdoe/runs/sample345/outs/analysis
- Filtered peak barcode matrix in hdf5 format:  /home/jdoe/runs/sample345/outs/filtered_peak_bc_matrix.h5
- Filtered peak barcode matrix in mex format:   /home/jdoe/runs/sample345/outs/filtered_peak_bc_matrix
- Barcoded and aligned fragment file:           /home/jdoe/runs/sample345/outs/fragments.tsv.gz
- Fragment file index:                          /home/jdoe/runs/sample345/outs/fragments.tsv.gz.tbi
- Filtered tf barcode matrix in hdf5 format:    /home/jdoe/runs/sample345/outs/filtered_tf_bc_matrix.h5
- Filtered tf barcode matrix in mex format:     /home/jdoe/runs/sample345/outs/filtered_tf_bc_matrix
- Loupe Browser input file:                     /home/jdoe/runs/sample345/outs/cloupe.cloupe
- csv summarizing important metrics and values: /home/jdoe/runs/sample345/outs/summary.csv
- Annotation of peaks with genes:               /home/jdoe/runs/sample345/outs/peak_annotation.tsv
- Peak-motif associations:                      /home/jdoe/runs/sample345/outs/peak_motif_mapping.bed
```
**Table in Terra workspace**

| column_name_in_terra_sample_table | value |
|------------|-----------|
| cellranger-atac_count_web_summary_html | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/web_summary.html` |
| cellranger-atac_count_summary_json | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/summary.json` |
| cellranger-atac_count_summary_csv | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/summary.csv` |
| cellranger-atac_count_fragments | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/fragments.tsv.gz` |
| cellranger-atac_count_fragments_index | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/fragments.tsv.gz.tbi` |
| cellranger-atac_count_filtered_peak_bc_matrix_h5 | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/filtered_peak_bc_matrix.h5` |
| cellranger-atac_count_filtered_tf_bc_matrix_h5 | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/filtered_tf_bc_matrix.h5` |
| cellranger-atac_count_peak_annotation | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/peak_annotation.tsv` |
| cellranger-atac_count_peak_motif_mapping | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/peak_motif_mapping.bed` |
| cellranger-atac_count_possorted_bam | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/possorted_bam.bam` |
| cellranger-atac_count_possorted_bam_index | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/possorted_bam.bam.bai` |
| cellranger-atac_count_cloupe | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ATAC/cloupe.cloupe` |

**Task-Specific Parameters:**
- `fastq_dir`: Directory containing FASTQ files
- `reference_dir`: Reference genome directory
- `chemistry`: Chemistry version

**Optional Parameters:**
- `force_cells`: Force pipeline to use this number of cells
- `dim_reduce`: Dimensionality reduction method
- `peaks`: Custom peaks file

### Output
- `cellranger_atac_count_output_json`: JSON file containing output metadata
- `cellranger_atac_count_ingest_logs`: Logs from Terra table ingestion

---

## arc_count.wdl
### Input
**Required Parameters:**
- `input_gs_bucket_path`: Google Storage bucket input path
- `sample_name`: Sample name in the FASTQ file
- `cohort_name`: Name of the cohort
- `sample_id`: Sample ID in the Terra table
- `zones`: Google Cloud zone (default: "us-central1-a")
- `namespace_workspace`: Terra workspace namespace for output file table reference

#### Terra Table Reference
**Files output from cellranger-atac count**
```
- Run summary HTML:                              /home/jdoe/runs/sample345/outs/web_summary.html
- Run summary metrics CSV:                       /home/jdoe/runs/sample345/outs/summary.csv
- Per barcode summary metrics:                   /home/jdoe/runs/sample345/outs/per_barcode_metrics.csv
- Filtered feature barcode matrix MEX:           /home/jdoe/runs/sample345/outs/filtered_feature_bc_matrix
- Filtered feature barcode matrix HDF5:          /home/jdoe/runs/sample345/outs/filtered_feature_bc_matrix.h5
- Raw feature barcode matrix MEX:                /home/jdoe/runs/sample345/outs/raw_feature_bc_matrix
- Raw feature barcode matrix HDF5:               /home/jdoe/runs/sample345/outs/raw_feature_bc_matrix.h5
- Loupe browser visualization file:              /home/jdoe/runs/sample345/outs/cloupe.cloupe
- GEX Position-sorted alignments BAM:            /home/jdoe/runs/sample345/outs/gex_possorted_bam.bam
- GEX Position-sorted alignments BAM index:      /home/jdoe/runs/sample345/outs/gex_possorted_bam.bam.bai
- GEX Per molecule information file:             /home/jdoe/runs/sample345/outs/gex_molecule_info.h5
- ATAC Position-sorted alignments BAM:           /home/jdoe/runs/sample345/outs/atac_possorted_bam.bam
- ATAC Position-sorted alignments BAM index:     /home/jdoe/runs/sample345/outs/atac_possorted_bam.bam.bai
- ATAC Per fragment information file:            /home/jdoe/runs/sample345/outs/atac_fragments.tsv.gz
- ATAC Per fragment information index:           /home/jdoe/runs/sample345/outs/atac_fragments.tsv.gz.tbi
- ATAC peak locations:                           /home/jdoe/runs/sample345/outs/atac_peaks.bed
- ATAC smoothed transposition site track:        /home/jdoe/runs/sample345/outs/atac_cut_sites.bigwig
- ATAC peak annotations based on proximal genes: /home/jdoe/runs/sample345/outs/atac_peak_annotation.tsv

```
**Table in Terra workspace**

| column_name_in_terra_sample_table | value |
|------------|-----------|
| cellranger_arc_count_web_summary_html | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/web_summary.html` |
| cellranger_arc_count_summary_csv | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/summary.csv` |
| cellranger_arc_count_per_barcode_metrics_csv | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/per_barcode_metrics.csv` |
| cellranger_arc_count_filtered_feature_bc_matrix | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/filtered_feature_bc_matrix` |
| cellranger_arc_count_filtered_feature_bc_matrix_h5 | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/filtered_feature_bc_matrix.h5` |
| cellranger_arc_count_raw_feature_bc_matrix | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/raw_feature_bc_matrix` |
| cellranger_arc_count_raw_feature_bc_matrix_h5 | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/raw_feature_bc_matrix.h5` |
| cellranger_arc_count_cloupe | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/cloupe.cloupe` |
| cellranger_arc_count_gex_bam | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/gex_possorted_bam.bam` |
| cellranger_arc_count_gex_bam_index | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/gex_possorted_bam.bam.bai` |
| cellranger_arc_count_gex_molecule_info | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/gex_molecule_info.h5` |
| cellranger_arc_count_atac_bam | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/atac_possorted_bam.bam` |
| cellranger_arc_count_atac_bam_index | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/atac_possorted_bam.bam.bai` |
| cellranger_arc_count_atac_fragments | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/atac_fragments.tsv.gz` |
| cellranger_arc_count_atac_fragments_index | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/atac_fragments.tsv.gz.tbi` |
| cellranger_arc_count_atac_peaks | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/atac_peaks.bed` |
| cellranger_arc_count_atac_cut_sites | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/atac_cut_sites.bigwig` |
| cellranger_arc_count_atac_peak_annotation | `{output_gs_bucket_folder_path}/{cohort_name}/{sample_name}/ARC/atac_peak_annotation.tsv` |

**Task-Specific Parameters:**
- `gex_fastq_dir`: Directory containing gene expression FASTQ files
- `atac_fastq_dir`: Directory containing ATAC FASTQ files
- `reference_dir`: Reference genome directory

**Optional Parameters:**
- `gex_exclude_introns`: Exclude intronic reads (default: false)
- `no_bam`: Skip BAM file creation (default: false)
- `min_atac_count`: Minimum ATAC count per cell
- `min_gex_count`: Minimum gene expression count per cell
- `peaks`: Custom peaks file

### Output
- `cellranger_arc_count_output_json`: JSON file containing output metadata
- `cellranger_arc_count_ingest_logs`: Logs from Terra table ingestion