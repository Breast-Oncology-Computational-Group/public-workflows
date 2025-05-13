import pandas as pd

gene_cn = pd.read_csv(file_path,sep='\t',
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

# remove non-cancerous variants
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

gene_cn = gene_cn.loc[~gene_cn['Variant_Classification'].isin([
    "GAIN","Possible_biallelic_inactivation","Likely_biallelic_inactivation"]),
                      :]
gene_cn.rename(columns={
    'gene':'category',
    'Variant_Classification':'value'
})[['sample','category','value']].drop_duplicates().to_csv('cnv_uniform_class.csv', index=False)