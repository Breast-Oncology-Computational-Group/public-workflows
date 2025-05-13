version 1.0

workflow tsvconcat {
    input {
        Array[File] tsv_files
    }

    call concat_task {
        input:
            tsv_files = tsv_files
    }
    
    output {
        File concat_tsv = concat_task.concat_tsv
    }
}

task concat_task {
    input {
        Array[File] tsv_files
        Int memory = 4
        Int cpu = 1
        Int disk = 8
        String docker_image = "us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/terrautils:0.1"
    }
    command {
       python <<CODE
       import polars as pl
       import os
       
       dfs = []
       for file in "${sep=',' tsv_files}".split(','):
           if os.path.exists(file):
               df = pl.read_csv(file, separator="\t")
               if not df.is_empty():
                   dfs.append(df)
       
       if dfs:
           combined_df = pl.concat(dfs)
           combined_df.write_csv('output.tsv', separator="\t")
       else:
           # Create empty file if no valid data
           with open('output.tsv', 'w') as f:
               pass
       CODE
    }
    output {
        File concat_tsv = "output.tsv"
    }
    runtime {
        docker: "${docker_image}"
        memory: "${memory}G"
        cpu: "${cpu}"
        disk: "local-disk " + disk + " HDD"
    }
}