FROM google/cloud-sdk:slim

RUN apt-get update && apt-get install -y python3.11-venv
RUN python3 -m venv /software/python
ENV PATH=/software/python/bin:$PATH

RUN python -m pip install --upgrade pip && \
	python -m pip install pandas==2.2.3

RUN curl -o /software/cellranger-arc-2.0.2.tar.gz "https://cf.10xgenomics.com/releases/cell-arc/cellranger-arc-2.0.2.tar.gz?Expires=1748254022&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=Z6zTj5B3mlgS9JNt6vfg6Sv6831dXWc2GYSYatn--QBwP3ZaROEROp4JHq2Zs8Xe8mCtbNi~TamqyKDKvMR4xpYkRMUx0WwDD0PXb1ZFsEdfhszL1cZRa1xVVoompK4ElLHa8k8D3dmPgCLMpWicOgWhxPhAOTKiimjTuI3P6NKqphlG902WsiN4go8ukzUb9zCxeu4IbkCCb4GZRibXYDLxzoL1nJe8YXHEElBWNbfTavraeLlhDk4z2EBbGz3~f5SX4GgRSg728Qxs-VBRejnrTXZQ~Qk6zfuPEEGpHJiaVgfl3ZufUF7-bNTxi0dPIgl-7vkx-xS5V-9-gpFTTw__"
RUN tar -xzf /software/cellranger-arc-2.0.2.tar.gz -C /software/

ENV PATH=/software/cellranger-arc-2.0.2:$PATH