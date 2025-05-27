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
    }
    String output_directory_stripped = sub(output_directory, "/+$", "") +'/'+cohort +'/'+ sample_id

    call cellbender_remove_background_gpu {
        input:
            sample_name = sample_id,
    }

    call sync_to_gcs {
        input:
            output_directory = output_directory_stripped,
            cellbender_log = cellbender_remove_background_gpu.log,
            cellbender_pdf = cellbender_remove_background_gpu.pdf,
            cellbender_ckpt_file = cellbender_remove_background_gpu.ckpt_file,
            cellbender_droplets_removed_h5 = cellbender_remove_background_gpu.filtered_h5,
            cellbender_report_html = cellbender_remove_background_gpu.report_html,
            cellbender_metrics_csv = cellbender_remove_background_gpu.metrics_csv,
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

task sync_to_gcs {
    input {
        String output_directory
        String cellbender_log
        String cellbender_pdf
        String cellbender_ckpt_file
        String cellbender_droplets_removed_h5
        String cellbender_report_html
        String cellbender_metrics_csv
        String zone = "us-central1-a"
        String docker_image = "jingxin/scpipe:v0"
        Int memoryGB = 1
        Int cpu = 1
        Int diskGB = 50
    }
    command {
        gsutil cp ~{cellbender_log} "~{output_directory}/cellbender.log"
        gsutil cp ~{cellbender_pdf} "~{output_directory}/cellbender.pdf"
        gsutil cp ~{cellbender_ckpt_file} "~{output_directory}/cellbender_ckpt.tar.gz"
        gsutil cp ~{cellbender_droplets_removed_h5} "~{output_directory}/cellbender_filtered.h5"
        gsutil cp ~{cellbender_report_html} "~{output_directory}/cellbender_report.html"
        gsutil cp ~{cellbender_metrics_csv} "~{output_directory}/cellbender_metrics.csv"

    }
    output {
        File log = stdout()
    }
    runtime {
        zone: "${zone}"
        docker: "${docker_image}"
        memory: "${memoryGB}G"
        cpu: "${cpu}"
        disks: "local-disk " + diskGB + " HDD"
    }
}

task cellbender_remove_background_gpu {

    input {

        # File-related inputs
        String sample_name
        File input_file_unfiltered  # all barcodes, raw data
        File? barcodes_file  # for MTX and NPZ formats, the bacode information is in a separate file
        File? genes_file  # for MTX and NPZ formats, the gene information is in a separate file
        File? checkpoint_file  # start from a saved checkpoint
        File? truth_file  # only for developers using simulated data

        # Docker image with CellBender
        String? docker_image = "us.gcr.io/broad-dsde-methods/cellbender:0.3.0"

        # Used by developers for testing non-dockerized versions of CellBender
        String? dev_git_hash__  # leave blank to run CellBender normally

        # Method configuration inputs
        Int? expected_cells
        Int? total_droplets_included
        Float? force_cell_umi_prior
        Float? force_empty_umi_prior
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
        Boolean? estimator_multiple_cpu
        Boolean? constant_learning_rate
        Boolean? debug

        # Hardware-related inputs
        String hardware_zones = "us-central1-a"
        Int hardware_disk_size_GB = 50
        Int hardware_boot_disk_size_GB = 20
        Int hardware_preemptible_tries = 2
        Int hardware_max_retries = 0
        Int hardware_cpu_count = 4
        Int hardware_memory_GB = 32
        String hardware_gpu_type = "nvidia-tesla-t4"
        String nvidia_driver_version = "470.82.01"  # need >=465.19.01 for CUDA 11.3

    }

    # For development only: install a non dockerized version of CellBender
    Boolean install_from_git = (if defined(dev_git_hash__) then true else false)


    command {

        set -e  # fail the workflow if there is an error

        # install a specific commit of cellbender from github if called for (-- developers only)
        if [[ ~{install_from_git} == true ]]; then
            echo "Uninstalling pre-installed cellbender"
            yes | pip uninstall cellbender
            echo "Installing cellbender from github"
            # this more succinct version is broken in some older versions of cellbender
            echo "pip install --no-cache-dir -U git+https://github.com/broadinstitute/CellBender.git@~{dev_git_hash__}"
            # yes | pip install --no-cache-dir -U git+https://github.com/broadinstitute/CellBender.git@~{dev_git_hash__}
            # this should always work
            git clone -q https://github.com/broadinstitute/CellBender.git /cromwell_root/CellBender
            cd /cromwell_root/CellBender
            git checkout -q ~{dev_git_hash__}
            yes | pip install -U pip setuptools
            yes | pip install --no-cache-dir -U -e /cromwell_root/CellBender
            pip list
            cd /cromwell_root
        fi

        # put the barcodes_file in the right place, if it is provided
        if [[ ! -z "~{barcodes_file}" ]]; then
            dir=$(dirname ~{input_file_unfiltered})
            if [[ "~{input_file_unfiltered}" == *.npz ]]; then
                name="row_index.npy"
            elif [[ "~{barcodes_file}" == *.gz ]]; then
                name="barcodes.tsv.gz"
            else
                name="barcodes.tsv"
            fi
            echo "Moving barcodes file to "$dir"/"$name
            echo "mv ~{barcodes_file} "$dir"/"$name
            [ -f $dir/$name ] || mv ~{barcodes_file} $dir/$name
        fi

        # put the genes_file in the right place, if it is provided
        if [[ ! -z "~{genes_file}" ]]; then
            dir=$(dirname ~{input_file_unfiltered})
            if [[ "~{input_file_unfiltered}" == *.npz ]]; then
                name="col_index.npy"
            elif [[ "~{genes_file}" == *.gz ]]; then
                name="features.tsv.gz"
            else
                name="genes.tsv"
            fi
            echo "Moving genes file to "$dir"/"$name
            echo "mv ~{genes_file} "$dir"/"$name
            [ -f $dir/$name ] || mv ~{genes_file} $dir/$name
        fi

        # use the directory as the input in the case of an MTX file
        if [[ "~{input_file_unfiltered}" == *.mtx* ]]; then
            input=$(dirname ~{input_file_unfiltered})
        else
            input=~{input_file_unfiltered}
        fi

        cellbender remove-background \
            --input $input \
            --output "~{sample_name}_out.h5" \
            --cuda \
            ~{"--checkpoint " + checkpoint_file} \
            ~{"--expected-cells " + expected_cells} \
            ~{"--total-droplets-included " + total_droplets_included} \
            ~{"--fpr " + fpr} \
            ~{"--model " + model} \
            ~{"--low-count-threshold " + low_count_threshold} \
            ~{"--epochs " + epochs} \
            ~{"--force-cell-umi-prior " + force_cell_umi_prior} \
            ~{"--force-empty-umi-prior " + force_empty_umi_prior} \
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
            ~{true="--estimator-multiple-cpu " false=" " estimator_multiple_cpu} \
            ~{true="--constant-learning-rate " false=" " constant_learning_rate} \
            ~{true="--debug " false=" " debug} \
            ~{"--truth " + truth_file}
  }

  output {
    File log = "~{sample_name}_out.log"
    File pdf = "~{sample_name}_out.pdf"
    File filtered_h5 = "~{sample_name}_out_filtered.h5" # containing only the droplets which were determined to have a > 50% posterior probability of containing cells.
    File report_html= "~{sample_name}_out_report.html"
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
        maxRetries: hardware_max_retries  # can be used in case of a PAPI error code 2 failure to install GPU drivers
  }
}