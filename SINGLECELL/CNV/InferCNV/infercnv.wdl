version 1.0

workflow infercnv {
    call run_infercnv {}

    output {
        File cnv_infercnv_h5 = run_infercnv.cnv_infercnv_h5
    }
}

task run_infercnv {
    input {
        File h5
        File metadata_csv
        File params_table
        File infercnv_Rscript
        String output_gs_bucket
        String cohort_name
        String sample_name
        String output_dir = "infercnv"
        String zones = "us-central1-a"
        Int cpu = 10
        String memory = "16G"
        String docker = "jingxin/infercnv:latest" 
        Int preemptible = 2
        Int extra_disk_space = 10
    }
    String gs_bucket_path= sub(output_gs_bucket, "/+$", "") + "/" + cohort_name + "/" + sample_name  # remove the trailing slash and add the cohort name and sample name
    command {
        set -e

        Rscript ~{infercnv_Rscript} ~{h5} ~{metadata_csv} ~{params_table} ~{output_dir}
        gsutil -m cp -r ~{output_dir} ~{gs_bucket_path}/~{output_dir}
    }

    output {
        File cnv_infercnv_h5 = "~{output_dir}/infercnv.h5"
    }

    runtime {
        docker: docker
        memory: memory
        bootDiskSizeGb: 12
        disks: "local-disk " + ceil(size(h5, "GB")*2 + extra_disk_space) + " HDD"
        cpu: cpu
        preemptible: preemptible
        zones: zones
    }
}