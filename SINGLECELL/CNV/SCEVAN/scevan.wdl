version 1.0

workflow scevan {
    call run_scevan {}

    output {
        File cnv_scevan_h5 = run_scevan.cnv_h5
    }
}

task run_scevan {
    input {
        File h5
        File metadata_csv
        File params_table
        File scevan_Rscript
        String output_gs_bucket
        String output_dir = "scevan"
        String zones = "us-central1-a"
        Int cpu = 10
        String memory = "16G"
        String docker = "jingxin/scevan:latest" 
        Int preemptible = 2
        Int extra_disk_space = 10
    }

    command {
        set -e
        
        ulimit -s unlimited

        Rscript ~{scevan_Rscript} ~{h5} ~{metadata_csv} ~{params_table} ~{output_dir}

        gsutil -m cp -r ~{output_dir} gs://~{output_gs_bucket}/~{output_dir}
    }

    output {
        File cnv_h5 = "~{output_dir}/cnv.h5"
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