version 1.0

import "./utils.wdl" as utils

workflow run_cellranger_atac {

    call cellranger_atac {}
    call utils.format_cellranger_output {
        input: output_dir = cellranger_atac.output_dir
    }
    output {
        File cellranger_atac_output_dir = cellranger_atac.output_dir
        File cellranger_atac_output_dir_gs = cellranger_atac.output_dir_gs
    }
}

task cellranger_atac {
    input {
        File fastq_dir
        File reference_dir
        File genome_dir
        String sample_name
        String chemistry
        String gbucket_path
        String docker_image
        Int memoryGB
        Int cpu
        Int diskGB
    }
    command {
        # untar the fastq_dir and reference_dir
        mkdir -p fastq_dir
        mkdir -p reference_dir
        tar -xf ~{fastq_dir} -C fastq_dir --strip-components 1
        tar -xf ~{reference_dir} -C reference_dir --strip-components 1

        # run cellranger-atac count
        cellranger-atac count \
        --id=sample \
        --transcriptome=reference_dir \
        --fastqs=fastq_dir \
        --sample=~{sample_name} \
        --chemistry=~{chemistry} \
        --jobmode=local \
        --localcores=~{cpu} \
        --localmem=~{memoryGB} 

        gsutil -q -m rsync -d -r sample/outs gs://~{gbucket_path}/~{sample_name}/ATAC 
    }
    output {
        File output_dir
    }
    runtime {
        docker: docker_image
        memory: "~{memoryGB} GB"
        cpu: cpu
        disk: "~{diskGB} GB"
    }
}