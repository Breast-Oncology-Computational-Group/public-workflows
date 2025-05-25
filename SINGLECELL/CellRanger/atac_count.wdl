version 1.0

import "./utils.wdl" as utils

workflow run_cellranger_atac_count {
    input {
        String input_gs_bucket_path
        String sample_name # this the sample name in the FASTQ file. e.g. [sample_name]_R1_001.fastq.gz
        String cohort_name 
        String sample_id # this is the sample id in the Terra table
        String zones = "us-central1-a"
    }
    String gs_bucket_path= sub(input_gs_bucket_path, "/+$", "") + "/" + cohort_name + "/" + sample_name + "/ATAC"  # remove the trailing slash and add the cohort name and sample name

    call cellranger_atac_count {
        input:
            sample_name = sample_name,
            gs_bucket_path = gs_bucket_path,
            zones = zones
    }

    call utils.format_cellranger_output as format_output {
        input:
            output_dir = cellranger_atac_count.output_dir,
            gs_bucket_path = gs_bucket_path,
            sample_id = sample_id,
            tr_prefix_name = "cellranger_atac_count",
            zones = zones,
    }

    call utils.updateOutputsInTerraTable  as update_outputs_in_terra_table {
        input:
            outputs_json = format_output.output_dict,
    }
    output {
        File cellranger_atac_count_output_json = format_output.output_dict
        File cellranger_atac_count_ingest_logs = update_outputs_in_terra_table.ingest_logs
    }

}

task cellranger_atac_count {
    input {
        String fastq_dir # this path should be a directory that contains the fastq files
        File reference_dir
        String sample_name
        String chemistry


        # optional parameters for cellranger count
        Int? force_cells
        String? dim_reduce
        File? peaks


        # centrolized storage bucket
        String gs_bucket_path

        # runtime
        String docker_image = "us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/cellranger-atac:2.2.0"
        String zones = "us-central1-a"
        String memory = "60G"
        Int cpu = 64
        Int diskGB = 500
    }
    command {
        # untar the reference_dir
        mkdir -p reference_dir
        tar -xf ~{reference_dir} -C reference_dir --strip-components 1

        # localize the FASTQ files from the bucket to the container
        mkdir -p fastq_dir
        gsutil -q -m rsync -r ~{fastq_dir} fastq_dir

        # run cellranger count  
        python <<CODE
        import subprocess
        cmd =  "cellranger atac count --id=sample --transcriptome=reference_dir --fastqs=fastq_dir --sample=~{sample_name} --chemistry=~{chemistry}"

        if '~{force_cells}' != '':
            cmd += " --force-cells=~{force_cells}"
        if '~{dim_reduce}' != '':
            cmd += " --dim-reduce=~{dim_reduce}"
        if '~{peaks}' != '':
            cmd += " --peaks=~{peaks}"
            

        print(cmd)
        subprocess.run(cmd, shell=True)

        CODE

        gsutil -q -m rsync -d -r sample/outs ~{gs_bucket_path}
    }
    output {
        Array[File] output_dir = glob("sample/outs/*")
    }
    runtime {
        docker: docker_image
        zones: zones
        memory: memory
        bootDiskSizeGb: 12
        cpu: cpu
        disks: "local-disk ~{diskGB} HDD"
    }
}