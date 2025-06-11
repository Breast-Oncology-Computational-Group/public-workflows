version 1.0

task h5ad_to_rds {
    input {
        File h5ad
        String zones = "us-central1-a"
        String docker_image = "jingxin/scpipe:v3"
        Int memory = 10
        Int cpu = 1
        Int disk = 20
    }
    command <<< # When using the triple angled brackets, variables within the command section are referenced with a tilde ~ instead of a dollar sign $
        R --no-save  <<RSCRIPT
        
        library(reticulate)
        ad <- import("anndata")
        data_ad <- ad$read_h5ad("~{h5ad}")
        exp.rawdata <- as.matrix(data_ad$X)
        obs <- as.data.frame(data_ad$obs)
        rownames(exp.rawdata) <- data_ad$obs_names$to_list()
        colnames(exp.rawdata) <- data_ad$var_names$to_list()
        exp.rawdata <- t(exp.rawdata)
        saveRDS(exp.rawdata, "count_mtrx.rds")
        saveRDS(obs, "metadata.rds")

        RSCRIPT
    >>>

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