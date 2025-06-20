version 1.0

import "../utils.wdl" as utils

workflow infercnv {
    input {
        File gex_h5ad
        String zones = "us-central1-a"
        Int preemptible = 2
    }

    call utils.h5ad_to_rds as h5ad_to_rds {
        input:
            h5ad = gex_h5ad,
            zones = zones,
    }
    call run_infercnv {
        input:
            raw_counts_rds = h5ad_to_rds.raw_counts_rds,
            gene_order_file = gene_order_file,
            zones = zones,
    }

    output {
        File infercnv_output = run_infercnv.infercnv_full_outputs
    }
}

task run_infercnv {
    input {
        File raw_counts_rds
        File annotations_file_csv
        File gene_order_file
        File infercnv_Rscript
        String additional_args = ""
        String zones = "us-central1-a"
        Int cpu = 1
        String memory = "12G"
        String docker = "trinityctat/infercnv:latest" 
        Int preemptible = 2
        Int extra_disk_space = 10
    }

    command {
        set -e
        
        ulimit -s unlimited

        mkdir infercnv

        Rscript ~{infercnv_Rscript} \
        --raw_counts_matrix ~{raw_counts_rds} \
        --annotations_file ~{annotations_file_csv} \
        --gene_order_file ~{gene_order_file} \
        --num_threads ~{cpu} \
        --out_dir infercnv \
        ~{additional_args}

        tar -cvzf infercnv_full_outputs.tar.gz infercnv
    }

    output {
        File infercnv_full_outputs = "infercnv_full_outputs.tar.gz"
    }

    runtime {
        docker: docker
        memory: memory
        bootDiskSizeGb: 12
        disks: "local-disk " + ceil(size(raw_counts_matrix, "GB")*2 + extra_disk_space) + " HDD"
        cpu: cpu
        preemptible: preemptible
        zones: zones
    }
}