FROM debian:bullseye-slim
SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
	apt-get install --no-install-recommends -y unzip build-essential dpkg-dev curl gnupg procps python3 python3-pip && \
	echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
	apt-get update && apt-get install -y google-cloud-cli=510.0.0-0

ENV CLOUDSDK_PYTHON=/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin/python
ENV CLOUDSDK_GSUTIL_PYTHON=/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin/python



RUN ln -s /usr/bin/python3 /usr/bin/python

RUN python -m pip install --upgrade pip && \
	python -m pip install pandas==2.2.3

RUN mkdir /software
RUN curl -o /software/cellranger-atac-2.2.0.tar.gz "https://cf.10xgenomics.com/releases/cell-atac/cellranger-atac-2.2.0.tar.gz?Expires=1748177573&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=VDXbHMBhRLN4U80njvyxlhFqNb~kzrzySYeL8o7xvoX0kmWxEkexyUESN-wEycMgxX1pUiRKotd-E9CghC73d-DDFMaalKZHeArPi-CcyQGF32wJOlC~l9SJWsyOAmgu21SSf97Yt1RxXxGOYmTJRg2fWNf8UCA-2VgrxN75mIlxFF9x-ssVuT9RSWXpqWqjNlev6aWVQOtTDD39MpWUOmUG3D045MsuTXLqieG8H0cBrK-2LpG2fAwsVIGdNqHOnhBLz12lxh2J2gwzbzF77YDN2knu6ft7enh9VkKgOlZerrC9pESpqqgrSUztVmEyHlo53Mv-Fwgv464EzRDeUg__"
RUN tar -xzf /software/cellranger-atac-2.2.0.tar.gz -C /software/

RUN apt-get -qq -y autoremove && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

ENV PATH=/software/cellranger-atac-2.2.0:$PATH
ENV TMPDIR=/tmp