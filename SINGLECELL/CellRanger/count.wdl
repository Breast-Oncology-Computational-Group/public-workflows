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

        python <<CODE
        import subprocess
        cmd =  "cellranger count --id=sample --transcriptome=reference_dir --fastqs=fastq_dir --sample=~{sample_name} --chemistry=~{chemistry}"
        if ~{include_introns}:
            cmd += " --include-introns"
        if ~{no_bam}:
            cmd += " --no-bam"
        if ~{no_secondary}:
            cmd += " --no-secondary"
        if ~{libraries}:
            cmd += " --libraries ~{libraries}"
        if ~{force_cells}:
            cmd += " --force-cells ~{force_cells}"
        if ~{expected_cells}:
            cmd += " --expected-cells ~{expected_cells}"
        if ~{target_panel}:
            cmd += " --target-panel ~{target_panel}"
        if ~{r1_length}:
            cmd += " --r1-length ~{r1_length}"
        if ~{r2_length}:
            cmd += " --r2-length ~{r2_length}"
        if ~{feature_ref}:
            cmd += " --feature-ref ~{feature_ref}"

        print(cmd)
        subprocess.run(cmd, shell=True)

        CODE

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