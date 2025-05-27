version 1.0

task sync_to_gcs {
    input {
        Array[File] transfer_files
        String output_directory
        String zone = "us-central1-a"
        String docker_image = "jingxin/scpipe:v0"
        Int memoryGB = 1
        Int cpu = 1
        Int diskGB = 50
    }
    command {
        for file in ~{transfer_files}; do
            gsutil cp $file ~{output_directory}
        done
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