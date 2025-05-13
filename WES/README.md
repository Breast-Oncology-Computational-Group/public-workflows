# Workflow description

## Gene_CN_Uniform_Category

This workflow processes gene copy number (CN) annotation files to create a uniform categorization of copy number variants.

### Input
- `gene_cn_annotation_file`: A TSV file containing gene copy number annotations with columns including sample, gene, LOH, CNAP, AMP_Classification, Loss_Classification, DeepDeletion, Variant_Classification, and Variant_Type.

### Process
1. Reads the input TSV file
2. Standardizes variant classifications by:
   - Converting "likely.bi.allelic.inactivation" to "Likely_biallelic_inactivation"
   - Converting "possible.bi.allelic.inactivation" to "Possible_biallelic_inactivation"
   - Converting "bi.allelic.inactivation" to "LOF_and_LOH"
   - Converting "deep.deletion" to "DeepDEL"
3. Removes contradictory variants (those that are both gain and loss)
4. Cleans up variant classifications by removing specific patterns and resolving conflicts
5. Renames columns for standardization:
   - 'gene' → 'category'
   - 'Variant_Classification' → 'value'
6. Outputs a simplified TSV with only sample, category, and value columns

### Output
- `cnv_uniform_category_file`: A TSV file with standardized copy number variant classifications containing three columns: sample, category, and value.

