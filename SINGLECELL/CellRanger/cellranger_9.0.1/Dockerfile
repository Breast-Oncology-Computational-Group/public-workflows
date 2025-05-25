FROM google/cloud-sdk:slim

RUN apt-get update && apt-get install -y python3.11-venv
RUN python3 -m venv /software/python
ENV PATH=/software/python/bin:$PATH

RUN python -m pip install --upgrade pip && \
	python -m pip install pandas==2.2.3

RUN curl -o /software/cellranger-9.0.1.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-9.0.1.tar.gz?Expires=1748184933&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=A67uHyzrH6pdNjOSQYmSNdxgmVAGg3ZItbt0eMGwaUue2hc6Z3xHzwzEcSKqmvCCmq~ANDiD8nb0Oyz-kx0rr~tHEfB9fReNLtM~JqCqauG1Xa12LUzbDGT5y-jspuBkiXvNO1UhmKUWOltlY-jw6z5KJjvpLFLYCtHW~SDgZ7CQfz4wDPVfF4zGcYHF86S3s2fcdTGUpK7AW-T3Dob~yi2gbomo0wzzeNjYdFzNNPNAMw7F-BgzXQgMnEGsGfA6dB1N8dvyh0Dlu-TlzuQT~1A8MMf9Pf4bwfROLSbfTDv8-38MbaetPu3YYKMHujO808ZpuHNksQIus8eCudBZPQ__"
RUN tar -xzf /software/cellranger-9.0.1.tar.gz -C /software/

ENV PATH=/software/cellranger-9.0.1:$PATH

