version 1.0

workflow extract_loh {
    input {
        File gene_cn_file
        String docker_image="us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/terrautils:0.1"
    }
    call loh_extraction {
        input:
            gene_cn_file = gene_cn_file,
            docker_image = docker_image
    }

     output {
            File loh_file = loh_extraction.loh_file
        }
}

task loh_extraction {
    input {
        File gene_cn_file
        String docker_image
        Int memory = 4
        Int cpu = 1
        Int disk = 8
    }
    command {
        python /scripts/loh_extraction.py -i ${gene_cn_file} -o loh.tsv
    }
    output {
        File loh_file = "loh.tsv"
    }
    runtime {
        docker: "${docker_image}"
        memory: "${memory}G"
        cpu: "${cpu}"
        disk: "local-disk " + disk + " HDD"
    }
}