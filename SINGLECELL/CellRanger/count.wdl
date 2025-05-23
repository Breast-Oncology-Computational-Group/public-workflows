version 1.0

import "./utils.wdl" as utils

workflow run_cellranger_count {
    input {
        String gs_bucket_path
        String sample_name
        String zones = "us-central1-a"
    }
    call cellranger_count {
        input:
            sample_name = sample_name,
            gs_bucket_path = gs_bucket_path,
            zones = zones,
    }

    call utils.format_cellranger_output as format_output {
        input: 
            output_dir = cellranger_count.output_dir,
            gs_bucket_path = gs_bucket_path,
            sample_name = sample_name,
            tool_name = "cellranger_count",
            zones = zones,
    }

    call utils.updateOutputsInTDR {
        input:
            outputs_json = format_output.output_dict,
    }

}

task cellranger_count {
    input {
        File fastq_dir
        File reference_dir
        File genome_dir
        String sample_name
        String chemistry


        # optional parameters for cellranger count
        Int? force_cells
        Int? expected_cells
        File? target_panel
        Int? r1_length
        Int? r2_length
        File? libraries
        File? feature_ref
        Boolean include_introns = true
        Boolean no_bam = false
        Boolean no_secondary = true


        # centrolized storage bucket
        String gs_bucket_path

        # runtime
        String docker_image = "us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/cellranger-9.0.1"
        String zones = "us-central1-a"
        Int memoryGB = 120
        Int cpu = 32
        Int diskGB = 500
    }
    command {
        # untar the fastq_dir and reference_dir
        mkdir -p fastq_dir
        mkdir -p reference_dir
        tar -xf ~{fastq_dir} -C fastq_dir --strip-components 1
        tar -xf ~{reference_dir} -C reference_dir --strip-components 1

        # run cellranger count
        cellranger count \
        --id=sample \
        --transcriptome=reference_dir \
        --fastqs=fastq_dir \
        --sample=~{sample_name} \
        --chemistry=~{chemistry} \
        ~{if include_introns then "--include-introns" else ""} \
        ~{if no_bam then "--no-bam" else ""} \
        ~{if no_secondary then "--no-secondary" else ""} \
        ~{--libraries libraries} \
        ~{--force_cells force_cells} \
        ~{--expected_cells expected_cells} \
        ~{--target_panel target_panel} \
        ~{--r1_length r1_length} \
        ~{--r2_length r2_length} \
        ~{--feature_ref feature_ref} \

        gsutil -q -m rsync -d -r sample/outs gs://~{gs_bucket_path}/~{sample_name}/GEX
    }
    output {
        Array[File] output_dir = glob("sample/outs/*")
    }
    runtime {
        docker: docker_image
        zones: zones
        memory: "~{memoryGB} GB"
        cpu: cpu
        disk: "~{diskGB} GB"
    }
}