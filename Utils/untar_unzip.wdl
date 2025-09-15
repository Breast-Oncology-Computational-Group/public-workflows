version 1.0

workflow untar_unzip {
  call tar_unzip {}
  output {
    File log = tar_unzip.log
  }
}

task tar_unzip {
  input {
    File input_file
    String output_dir
    String docker_image = "us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/terrautils:0.1"
    Int memory = 4
    Int cpu = 2
    Int bootDiskSizeGb = 10
    Int nonBootDiskSizeGb = 50
    Int preemptible = 1
  }
  command {
    set -e
    python <<CODE
    import os
    import subprocess
    if '~{input_file}'.endswith("tar"):
        subprocess.run('tar -xf ~{input_file} -C output_dir', shell=True)
        print('Extracted tar file: ~{input_file}')
    elif '~{input_file}'.endswith("zip"):
        subprocess.run('unzip ~{input_file} -d output_dir', shell=True)
        print('Extracted zip file: ~{input_file}')
    else:
        raise ValueError('Unsupported file type: ~{input_file}')
    CODE
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