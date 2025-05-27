version 1.0

## Copyright Broad Institute, 2022
##
## LICENSING :
## This script is released under the WDL source code license (BSD-3)
## (see LICENSE in https://github.com/openwdl/wdl).
workflow run_cellbender_remove_background {
    input {
        String output_directory
        String sample_id
        String cohort
        File raw_feature_h5
    }
    String output_directory_stripped = sub(output_directory, "/+$", "") +'/'+cohort +'/'+ sample_id

    call cellbender_remove_background_gpu {
        input:
            output_directory = output_directory_stripped,
            sample_name = sample_id,
    }
   
    output {
      String cellbender_log = "~{output_directory_stripped}/cellbender.log"
      String cellbender_pdf = "~{output_directory_stripped}/cellbender.pdf"
      String cellbender_ckpt_file = "~{output_directory_stripped}/cellbender_ckpt.tar.gz"
      String cellbender_droplets_removed_h5 = "~{output_directory_stripped}/cellbender_filtered.h5" # containing only the droplets which were determined to have a > 50% posterior probability of containing cells.
      String cellbender_report_html = "~{output_directory_stripped}/cellbender_report.html"
      String cellbender_metrics_csv = "~{output_directory_stripped}/cellbender_metrics.csv"
      String cellbender_version = cellbender_remove_background_gpu.version
    }

}


task cellbender_remove_background_gpu {
  input {
    # File-related inputs
    String sample_name
    File rna_count_raw_feature_h5
    
    # Outputs
    String output_directory  # Google bucket path

    # Docker image with CellBender
    String docker_image = "us.gcr.io/broad-dsde-methods/cellbender:0.3.0"

    String? exclude_feature_types = "Peaks"
    File? checkpoint_file
    File? truth_file
    # Method configuration inputs
    Int? expected_cells
    Int? total_droplets_included
    String? model
    Int? low_count_threshold
    String? fpr  # in quotes: floats separated by whitespace: the output false positive rate(s)
    Int? epochs
    Int? z_dim
    String? z_layers  # in quotes: integers separated by whitespace
    Float? empty_drop_training_fraction
    Float? learning_rate
    String? exclude_feature_types  # in quotes: strings separated by whitespace
    String? ignore_features  # in quotes: integers separated by whitespace
    Float? projected_ambient_count_threshold
    Float? checkpoint_mins
    Float? final_elbo_fail_fraction
    Float? epoch_elbo_fail_fraction
    Int? num_training_tries
    Float? learning_rate_retry_mult
    Int? posterior_batch_size
    Boolean? constant_learning_rate
    Boolean? debug

    # Hardware-related inputs
    String hardware_zones = "us-central1-a us-central1-c"
    Int hardware_disk_size_GB = 50
    Int hardware_boot_disk_size_GB = 20
    Int hardware_preemptible_tries = 2
    Int hardware_cpu_count = 4
    Int hardware_memory_GB = 15
    String hardware_gpu_type = "nvidia-tesla-t4"
    String nvidia_driver_version = "470.82.01"  # need >=465.19.01 for CUDA 11.3
  }
  command {
    set -e  # fail the workflow if there is an error

    cellbender remove-background \
      --input "~{rna_count_raw_feature_h5}" \
      --output "~{sample_name}_out.h5" \
      --cuda \
      ~{"--exclude-feature-types " + exclude_feature_types} \
      ~{"--checkpoint " + checkpoint_file} \
      ~{"--expected-cells " + expected_cells} \
      ~{"--total-droplets-included " + total_droplets_included} \
      ~{"--fpr " + fpr} \
      ~{"--model " + model} \
      ~{"--low-count-threshold " + low_count_threshold} \
      ~{"--epochs " + epochs} \
      ~{"--z-dim " + z_dim} \
      ~{"--z-layers " + z_layers} \
      ~{"--empty-drop-training-fraction " + empty_drop_training_fraction} \
      ~{"--exclude-feature-types " + exclude_feature_types} \
      ~{"--ignore-features " + ignore_features} \
      ~{"--projected-ambient-count-threshold " + projected_ambient_count_threshold} \
      ~{"--learning-rate " + learning_rate} \
      ~{"--checkpoint-mins " + checkpoint_mins} \
      ~{"--final-elbo-fail-fraction " + final_elbo_fail_fraction} \
      ~{"--epoch-elbo-fail-fraction " + epoch_elbo_fail_fraction} \
      ~{"--num-training-tries " + num_training_tries} \
      ~{"--learning-rate-retry-mult " + learning_rate_retry_mult} \
      ~{"--posterior-batch-size " + posterior_batch_size} \
      ~{true="--constant-learning-rate " false=" " constant_learning_rate} \
      ~{true="--debug " false=" " debug} \
      ~{"--truth " + truth_file}


      gsutil -m cp ${sample_name}_out.log ${output_directory}/cellbender.log
      gsutil -m cp ${sample_name}_out.pdf ${output_directory}/cellbender.pdf
      gsutil -m cp ${sample_name}_out_filtered.h5 ${output_directory}/cellbender_filtered.h5
      gsutil -m cp ckpt.tar.gz ${output_directory}/cellbender_ckpt.tar.gz

      gsutil -m cp ${sample_name}_out_report.html ${output_directory}/cellbender_report.html
      gsutil -m cp ${sample_name}_out_metrics.csv ${output_directory}/cellbender_metrics.csv
  }

  output {
    File log = "${sample_name}_out.log"
    File pdf = "${sample_name}_out.pdf"
    File filtered_h5 = "${sample_name}_out_filtered.h5" # containing only the droplets which were determined to have a > 50% posterior probability of containing cells.
    File report_html= "${sample_name}_out_report.html"
    File metrics_csv= "${sample_name}_out_metrics.csv"
    # Array[File] h5_array = glob("${sample_name}_out*.h5")  # v2 creates a number of outputs depending on "fpr"
    String output_dir = "${output_directory}/${sample_name}"

    File ckpt_file = "ckpt.tar.gz"
    String version = "${docker_image}"
  }

  runtime {
    docker: "~{docker_image}"
    bootDiskSizeGb: hardware_boot_disk_size_GB
    disks: "local-disk ~{hardware_disk_size_GB} HDD"
    memory: "~{hardware_memory_GB}G"
    cpu: hardware_cpu_count
    zones: "~{hardware_zones}"
    gpuCount: 1
    gpuType: "~{hardware_gpu_type}"
    nvidiaDriverVersion: "~{nvidia_driver_version}"
    preemptible: hardware_preemptible_tries
    checkpointFile: "ckpt.tar.gz"
    maxRetries: 0
  }
}