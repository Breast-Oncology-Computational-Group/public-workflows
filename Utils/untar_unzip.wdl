workflow untar_unzip {
  File input_file
  String output_dir

  call tar_unzip {
    input: input_file = input_file, output_dir = output_dir
  }
}

task tar_unzip {
  File input_file
  String output_dir
  String docker_image = "us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/terrautils:0.1"
  Int memory = 4
  Int cpu = 2
  Int bootDiskSizeGb = 10
  Int nonBootDiskSizeGb = 50
  Int preemptible = 1

  command {
    set -e
    if [[ ~{input_file} == *.tar ]]; then
        tar -xf "~{input_file}" -C output_dir
    elif [[ ~{input_file} == *.zip ]]; then
        unzip ~{input_file} -d output_dir
    else 
        echo "Unsupported file type: ~{input_file}"
        exit 1
    fi
    gsutil -m rsync -r output_dir ~{output_dir}
  }

  output {
    File log = stdout()
  }

  runtime {
    docker: "~{docker_image}"
    memory: "~{memory}G"
    cpu: "~{cpu}"
    bootDiskSizeGb: bootDiskSizeGb
    disks: "local-disk ~{nonBootDiskSizeGb} HDD"
    preemptible: "~{preemptible}"
  }
}