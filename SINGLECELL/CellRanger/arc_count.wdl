version 1.0

import "./utils.wdl" as utils

workflow run_cellranger_arc_count {
    input {
        String input_gs_bucket_path
        String sample_name # this the sample name in the FASTQ file. e.g. [sample_name]_R1_001.fastq.gz
        String cohort_name 
        String sample_id # this is the sample id in the Terra table
        String zones = "us-central1-a"
    }
    String gs_bucket_path= sub(input_gs_bucket_path, "/+$", "") + "/" + cohort_name + "/" + sample_name + "/ARC"  # remove the trailing slash and add the cohort name and sample name

    call cellranger_arc_count {
        input:
            sample_name = sample_name,
            gs_bucket_path = gs_bucket_path,
            zones = zones
    }

    call utils.format_cellranger_output as format_output {
        input:
            output_dir = cellranger_arc_count.output_dir,
            gs_bucket_path = gs_bucket_path,
            sample_id = sample_id,
            tr_prefix_name = "cellranger_arc_count",
            zones = zones,
    }

    call utils.updateOutputsInTerraTable  as update_outputs_in_terra_table {
        input:
            outputs_json = format_output.output_dict,
    }
    output {
        File cellranger_arc_count_output_json = format_output.output_dict
        File cellranger_arc_count_ingest_logs = update_outputs_in_terra_table.ingest_logs
    }

}

task cellranger_arc_count {
    input {
        String gex_fastq_dir # this path should be a directory that contains the fastq files for the GEX data
        String atac_fastq_dir # this path should be a directory that contains the fastq files for the ATAC data
        File reference_dir
        String sample_name


        # optional parameters for cellranger count
        Boolean gex_exclude_introns = false
        Boolean no_bam = false
        Int? min_atac_count
        Int? min_gex_count
        File? peaks


        # centrolized storage bucket
        String gs_bucket_path

        # runtime
        String docker_image = "us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/cellranger-arc:2.0.2"
        String zones = "us-central1-a"
        String memory = "160G"
        Int cpu = 64
        Int diskGB = 700
    }
    command {
        # untar the reference_dir
        mkdir -p reference_dir
        tar -xf ~{reference_dir} -C reference_dir --strip-components 1

        # localize the FASTQ files from the bucket to the container
        mkdir -p gex_fastq_dir
        gsutil -q -m rsync -r ~{gex_fastq_dir} gex_fastq_dir

        mkdir -p atac_fastq_dir
        gsutil -q -m rsync -r ~{atac_fastq_dir} atac_fastq_dir

        # run cellranger count
        python <<CODE
        import os
        # create a libraries.csv file
        with open('libraries.csv', 'w') as f:
            f.write('fastqs,sample,library_type\n')
            f.write(os.path.abspath('gex_fastq_dir')+',~{sample_name},Gene Expression\n')
            f.write(os.path.abspath('atac_fastq_dir')+',~{sample_name},Chromatin Accessibility\n')

        import subprocess
        cmd =  "cellranger-arc count --id=sample --reference=reference_dir --libraries=libraries.csv"

        if '~{gex_exclude_introns}' == 'true':
            cmd += " --gex-exclude-introns"
        if '~{no_bam}' == 'true':
            cmd += " --no-bam"
        
        if '~{min_atac_count}' != '':
            cmd += " --min-atac-count=~{min_atac_count}"

        if '~{min_gex_count}' != '':
            cmd += " --min-gex-count=~{min_gex_count}"

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