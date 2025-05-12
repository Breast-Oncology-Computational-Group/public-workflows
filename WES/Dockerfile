FROM google/cloud-sdk:slim
LABEL maintainer="Jingxin Fu <jingxin@broadinstitute.org>"
RUN apt-get update && apt-get -y install curl libssl-dev libcurl4-openssl-dev libgeos-dev libopenmpi-dev build-essential libz-dev\
	libxml2-dev git time && \
	apt-get clean && rm -rf /var/tmp/* \
	/tmp/* /var/lib/apt/lists/*
# Build Mamba 
RUN curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
	bash Miniforge3-$(uname)-$(uname -m).sh -b -p "/opt/miniforge3"
ENV PATH="/opt/miniforge3/bin:${PATH}"
COPY conda-env.yml .
RUN mamba env create -f conda-env.yml
ENV PATH="/opt/miniforge3/envs/WESutils/bin:${PATH}"
COPY LOH/loh_extraction.py /scripts/loh_extraction.py
