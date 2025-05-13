version 1.0

workflow WES_CN_Uniform_Category {
    input {
        File gene_cn_annotation_file
    }
    call cnv_uniform_category {
        input:
            gene_cn_annotation_file = gene_cn_annotation_file
    }
    
    output {
        File cnv_uniform_category_file = cnv_uniform_category.cnv_uniform_category_file
    }
}

task cnv_uniform_category {
    input {
        File gene_cn_annotation_file
        Int memory = 4
        Int cpu = 1
        Int disk = 8
        String docker_image = "us-central1-docker.pkg.dev/dfciboc-storage-images/dfci-boc/terrautils:0.1"
    }
    command {
        python <<CODE
        import pandas as pd
        
        gene_cn = pd.read_csv("~{gene_cn_annotation_file}", sep='\t',
                          usecols=['sample','gene','LOH','CNAP', 'N', 'AMP_Classification', 'key', 'Loss_Classification','DeepDeletion', 'Variant_Classification', 'Variant_Type']
                          )

        # convert variant classification to uniform category
        gene_cn['Variant_Classification']=(gene_cn.
                                       Variant_Classification.
                                       replace("likely.bi.allelic.inactivation","Likely_biallelic_inactivation",regex=True).
                                       replace("possible.bi.allelic.inactivation","Possible_biallelic_inactivation",regex=True).
                                       replace("bi.allelic.inactivation","LOF_and_LOH",regex=True).
                                       replace("deep.deletion","DeepDEL",regex=True)
        )

        # remove contradictory variants: both gain and loss
        gene_cn = gene_cn.loc[~gene_cn['Variant_Classification'].isin([
            "GAIN","Possible_biallelic_inactivation","Likely_biallelic_inactivation"]),
                          :]

        gene_cn.Variant_Classification=(
            gene_cn['Variant_Classification'].
            replace(
                "GAIN,|,Possible_biallelic_inactivation|Possible_biallelic_inactivation,|,Likely_biallelic_inactivation|Likely_biallelic_inactivation,", "",regex=True).
            replace('AMP,LOF_and_LOH','LOF_and_LOH').
            replace('LOF_and_LOH,DeepDEL','DeepDEL')
            )

        # remove contradictory variants: both gain and loss
        gene_cn = gene_cn.loc[~gene_cn['Variant_Classification'].isin([
            "GAIN","Possible_biallelic_inactivation","Likely_biallelic_inactivation"]),
                          :]
        gene_cn = gene_cn[['sample','gene','Variant_Classification']]
        gene_cn.columns = ['sample','category','value']
        gene_cn.to_csv('cnv_uniform_class.tsv', index=False)
        
        CODE
    }
    output {
        File cnv_uniform_category_file = "cnv_uniform_class.tsv"
    }
    runtime {
        docker: docker_image
        memory: "${memory}G"
        cpu: cpu
        disk: "local-disk ${disk} HDD"
    }
}