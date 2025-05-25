import pandas as pd
import subprocess
import tempfile

def extract_from_cellranger_arc(
    temp_dir,
    link = "https://cf.10xgenomics.com/releases/cell-arc/cellranger-arc-2.0.2.tar.gz?Expires=1748254022&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=Z6zTj5B3mlgS9JNt6vfg6Sv6831dXWc2GYSYatn--QBwP3ZaROEROp4JHq2Zs8Xe8mCtbNi~TamqyKDKvMR4xpYkRMUx0WwDD0PXb1ZFsEdfhszL1cZRa1xVVoompK4ElLHa8k8D3dmPgCLMpWicOgWhxPhAOTKiimjTuI3P6NKqphlG902WsiN4go8ukzUb9zCxeu4IbkCCb4GZRibXYDLxzoL1nJe8YXHEElBWNbfTavraeLlhDk4z2EBbGz3~f5SX4GgRSg728Qxs-VBRejnrTXZQ~Qk6zfuPEEGpHJiaVgfl3ZufUF7-bNTxi0dPIgl-7vkx-xS5V-9-gpFTTw__"
):	
    cmd = f"curl -o {temp_dir}/cellranger-arc.tar.gz '{link}'"
    subprocess.run(cmd, shell=True)
    subprocess.run(f"tar -xzf {temp_dir}/cellranger-arc.tar.gz -C {temp_dir} --strip-components=1", shell=True)
    atac_barcodes = pd.read_csv(f"{temp_dir}/lib/python/atac/barcodes/737K-arc-v1.txt.gz",header=None)[0]
    gex_barcodes = pd.read_csv(f"{temp_dir}/lib/python/cellranger/barcodes/737K-arc-v1.txt.gz",header=None)[0]
    barcodes = pd.DataFrame({"GEX_barcode": gex_barcodes, "ATAC_barcode": atac_barcodes})
    return barcodes


def main():
    # get the barcode translation table
    with tempfile.TemporaryDirectory() as temp_dir:
        barcodes = extract_from_cellranger_arc(temp_dir)
        barcodes.to_csv('barcodes.csv',index=False)

if __name__ == "__main__":
    main()