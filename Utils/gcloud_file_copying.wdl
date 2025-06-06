version 1.0

workflow run_gcloud_file_copying {
    call gcloud_file_copying {}
    output {
        File log = gcloud_file_copying.log
    }
}

task gcloud_file_copying {
    input {
        String source_file_path
        String destination_file_path
        String docker_image = "jingxin/scpipe:v0"
        Int memoryGB = 1
        Int cpu = 1
        Int diskGB = 1
        String zone = "us-central1-a"
    }
    command {
        gsutil cp ~{source_file_path} ~{destination_file_path}
    }
    output {
        File log = stdout()
    }
    runtime {
        zone: "${zone}"
        docker: "${docker_image}"
        memory: "${memoryGB}G"
        cpu: "${cpu}"
        disks: "local-disk " + diskGB + " HDD"
    }

}