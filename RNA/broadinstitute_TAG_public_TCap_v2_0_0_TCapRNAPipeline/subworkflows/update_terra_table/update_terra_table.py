import json
import pandas as pd
import firecloud.api as fapi
import argparse

def update_table(sample_sheet,namespace_workspace):
    namespace = namespace_workspace.split("/")[0]
    workspace = namespace_workspace.split("/")[1]
    print(namespace,workspace)
    new_table = sample_sheet.to_csv(sep="\t")
    fapi.upload_entities(
        namespace, workspace,  new_table, "flexible"
    )
def convert_json_to_df(json_file,table_name):
    with open(json_file, 'r') as f:
        data = json.load(f)
    df = pd.DataFrame([data])  # Wrap data in list to create DataFrame from dict
    df.rename(columns={f"{table_name}_id": f"entity:{table_name}_id"}, inplace=True)
    
    return df.set_index(f"entity:{table_name}_id")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--json_file", type=str, required=True)
    parser.add_argument("--namespace_workspace", type=str, required=True)
    parser.add_argument("--table_name", type=str, required=True)
    args = parser.parse_args()
    df = convert_json_to_df(args.json_file,args.table_name)
    update_table(df,args.namespace_workspace)
    df.to_csv('metrics_table.tsv',index=True,sep="\t")

if __name__ == "__main__":
    main()
