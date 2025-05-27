version 1.0


task format_cellranger_output {
    input {
        Array[File] output_dir
        String gs_bucket_path
        String tr_prefix_name
        String sample_id
        String zones = "us-central1-a"
        String docker_image = "jingxin/update_terra_table:0.1"
        Int cpu = 1
        Int memory_mb = 2000
        Int disk_size_gb = 50
    }
    command {
        python <<CODE
        import json
        import os
        # format the dictionary of output_dir
        output_dict = dict()
        for file in "${sep=',' output_dir}".split(','):
            file_name = os.path.basename(file)
            table_name = "~{tr_prefix_name}_" + file_name.replace(".", "_")
            output_dict[table_name] = "~{gs_bucket_path}/"+file_name
        output_dict["sample_id"] = "~{sample_id}"
        # save the output_dict to a json file
        with open("output_dict.json", "w") as f:
            json.dump(output_dict, f)
        
        CODE
    }
    output {
        File output_dict = "output_dict.json"
    }

    runtime {
        zones: zones
        docker: docker_image
        cpu: cpu
        memory: "~{memory_mb} MiB"
        disks: "local-disk ~{disk_size_gb} HDD"
    }
}


task updateOutputsInTerraTable {
  input {
    String namespace_workspace
    File outputs_json
    String table_name = "sample"

    String docker_image = "jingxin/update_terra_table:0.1"
    Int cpu = 1
    Int memory_mb = 2000
    Int disk_size_gb = 10
  }

  command <<<

    python -u /scripts/update_terra_table.py \
    --json_file ~{outputs_json} \
    --namespace_workspace ~{namespace_workspace} \
    --table_name ~{table_name}
  >>>

  runtime {
    docker: docker_image
    cpu: cpu
    memory: "~{memory_mb} MiB"
    disks: "local-disk ~{disk_size_gb} HDD"
  }

  output {
    File ingest_logs = stdout()
  }
}