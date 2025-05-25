FROM debian:bookworm-slim

FROM debian:bookworm-slim

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
	apt-get install --no-install-recommends -y unzip rsync build-essential dpkg-dev curl gnupg procps python3 python3-pip python3-venv

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
	apt-get update -y && apt-get install -y google-cloud-cli=510.0.0-0

ENV CLOUDSDK_PYTHON=/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin/python
ENV CLOUDSDK_GSUTIL_PYTHON=/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin/python

RUN python3 -m venv /software/python
ENV PATH=/software/python/bin:$PATH

RUN python -m pip install --upgrade pip --no-cache-dir && \
	python -m pip install pandas==2.2.3 --no-cache-dir


RUN curl -o /software/cellranger-9.0.1.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-9.0.1.tar.gz?Expires=1748184933&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=A67uHyzrH6pdNjOSQYmSNdxgmVAGg3ZItbt0eMGwaUue2hc6Z3xHzwzEcSKqmvCCmq~ANDiD8nb0Oyz-kx0rr~tHEfB9fReNLtM~JqCqauG1Xa12LUzbDGT5y-jspuBkiXvNO1UhmKUWOltlY-jw6z5KJjvpLFLYCtHW~SDgZ7CQfz4wDPVfF4zGcYHF86S3s2fcdTGUpK7AW-T3Dob~yi2gbomo0wzzeNjYdFzNNPNAMw7F-BgzXQgMnEGsGfA6dB1N8dvyh0Dlu-TlzuQT~1A8MMf9Pf4bwfROLSbfTDv8-38MbaetPu3YYKMHujO808ZpuHNksQIus8eCudBZPQ__"
RUN tar -xzf /software/cellranger-9.0.1.tar.gz -C /software/

RUN apt-get -qq -y autoremove && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

ENV PATH=/software:/software/cellranger-9.0.1:$PATH
ENV TMPDIR=/tmp
