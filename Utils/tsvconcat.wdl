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
       import pandas as pd
       import os
       
       dfs = []
       for file in "${sep=',' tsv_files}".split(','):
           if os.path.exists(file):
               df = pd.read_csv(file, sep="\t", encoding="latin1") # for some character encoding issues in MAF files
               if not df.empty:
                   dfs.append(df)
       
       if dfs:
           combined_df = pd.concat(dfs)
           combined_df.to_csv('output.tsv', sep="\t", index=False)
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
        disks: "local-disk " + disk + " HDD"
    }
}