FROM debian:bookworm-slim

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
	apt-get install --no-install-recommends -y unzip rsync build-essential dpkg-dev curl gnupg procps python3 python3-pip python3-venv

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
	apt-get update -y && apt-get install -y google-cloud-cli=510.0.0-0


RUN python3 -m venv /software/python
ENV PATH=/software/python/bin:$PATH

RUN python -m pip install --upgrade pip --no-cache-dir && \
	python -m pip install pandas==2.2.3 --no-cache-dir

RUN curl -o /software/cellranger-9.0.1.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-9.0.1.tar.gz?Expires=1748068260&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=V2fq0N0Dkwd2fEM5yZ4zCyGcaulAxO06z0kZOjDr~IcnssweaYoFuxF9InD39Yx2Oft-7riER3fiQBCVGAQZSQgg6AnkoA2MivsfP1HBzhKgnJLQmQ~0TrVWwMtppTRnHkcLJ6Q2A7pVg1iLjBh22xF9yNXZTPtj5RXf7ba4CFZ2y6ENzsllj~LE3nfoh~jklUt0KWHuFLGMmliIrQ4xu81wnHnliA-X0a86srnscI-XChsouBlnceZHoFEoN3d8~YtW7DeEqLG0d4uKL0SDsHTPtOPkH66l-Q4SsYLZXz-aLVTDDJcNsEe1iYfrkBBkHT5liZ4uqhYf3taAsj6A2g__"
RUN tar -xzf /software/cellranger-9.0.1.tar.gz -C /software/


RUN apt-get -qq -y autoremove && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

ENV PATH=/software:/software/cellranger-9.0.1:$PATH
ENV TMPDIR=/tmp

ENV CLOUDSDK_PYTHON=/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin/python
ENV CLOUDSDK_GSUTIL_PYTHON=/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin/python