version 1.0

task h5ad_to_rds {
    input {
        File h5ad
        String zones = "us-central1-a"
        String docker_image = "jingxin/omnicell:py311 "
        Int memory = 10
        Int cpu = 1
        Int disk = 20
    }
    command {
        OmniCell-utils --outdir . h5ad-to-rds --h5 ~{h5ad}

    }

    output {
        File count_mtrx = "count_mtrx.rds"
        File metadata = "metadata.rds"
    }

    runtime {
        zones: "${zones}"
        docker: "${docker_image}"
        memory: "${memory}G"
        cpu: "${cpu}"
        disks: "local-disk ${disk} HDD"
    }
}