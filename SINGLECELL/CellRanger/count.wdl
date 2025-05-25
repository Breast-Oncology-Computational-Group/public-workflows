version 1.0

import "./utils.wdl" as utils

workflow run_cellranger_count {
    input {
        String output_gs_bucket_folder_path
        String sample_name
        String cohort_name
        String zones = "us-central1-a"
    }
    String gs_bucket_path= sub(output_gs_bucket_folder_path, "/+$", "") + "/" + cohort_name + "/" + sample_name + "/GEX"  # remove the trailing slash and add the cohort name and sample name

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
            tr_prefix_name = "cellranger_count",
            zones = zones,
    }

    call utils.updateOutputsInTDR  as update_outputs_in_tdr {
        input:
            outputs_json = format_output.output_dict,
    }
    output {
        File cellranger_count_output_json = format_output.output_dict
        File cellranger_count_ingest_logs = update_outputs_in_tdr.ingest_logs
    }

}

task cellranger_count {
    input {
        String fastq_dir # this path should be a directory that contains the fastq files
        File reference_dir
        String sample_name
        String chemistry


        # optional parameters for cellranger count
        Int? force_cells
        Int? expected_cells
        Boolean include_introns = true
        Boolean no_bam = false
        Boolean no_secondary = true


        # centrolized storage bucket
        String gs_bucket_path

        # runtime
        String docker_image = "us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/cellranger-9.0.1"
        String zones = "us-central1-a"
        String memory = "60G"
        Int cpu = 32
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
        cmd =  "cellranger count --id=sample --transcriptome=reference_dir --fastqs=fastq_dir --sample=~{sample_name} --chemistry=~{chemistry}"

        if '~{include_introns}' == 'true':
            cmd += " --include-introns=true"
        else:
            cmd += " --include-introns=false"

        if '~{no_bam}' == 'true':
            cmd += " --create-bam=false"
        else:
            cmd += " --create-bam=true"

        if '~{no_secondary}' == 'true':
            cmd += " --nosecondary"

        if '~{force_cells}' != '':
            cmd += " --force-cells=~{force_cells}"
        if '~{expected_cells}' != '':
            cmd += " --expected-cells=~{expected_cells}"


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