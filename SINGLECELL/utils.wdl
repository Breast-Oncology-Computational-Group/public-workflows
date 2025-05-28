version 1.0

task sync_to_gcs {
    input {
        Array[File] transfer_files
        String output_directory
        String zones = "us-central1-a"
        String docker_image = "jingxin/scpipe:v0"
        Int memoryGB = 1
        Int cpu = 1
        Int diskGB = 20
    }
    command {
        python <<CODE
        import subprocess
        for file in "${sep=',' transfer_files}".split(','):
            subprocess.run("gsutil cp "+ file+ " ~{output_directory}/",shell=True)
        CODE
    }
    output {
        File log = stdout()
    }
    runtime {
        zones: "${zones}"
        docker: "${docker_image}"
        memory: "${memoryGB}G"
        cpu: "${cpu}"
        disks: "local-disk " + diskGB + " HDD"
    }
}