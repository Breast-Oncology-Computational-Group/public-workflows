FROM google/cloud-sdk:slim

RUN apt-get update && apt-get install -y python3.11-venv
RUN python3 -m venv /software/python
ENV PATH=/software/python/bin:$PATH

RUN python -m pip install --upgrade pip && \
	python -m pip install pandas==2.2.3

RUN curl -o /software/cellranger-atac-2.2.0.tar.gz "https://cf.10xgenomics.com/releases/cell-atac/cellranger-atac-2.2.0.tar.gz?Expires=1748227121&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=JuDlQrCcaX6ZLfPdnNuUc9liSyNc5Ci095xmw1yfasx4R9PojoLRDeo2uDiHnKPSxGpUOQsxwDiU730Gy30ms2TLeha17kVbshXmdD8YJ7ByTFnaXdmbbNJ2LQ2GQnZjO3b0zJyBC~O6Gdjo~RecTEt8DIGkIr61N8t5WnnzojI03hZX77H~rQSczwsHRU0hNBQNEEmANX0TTI3M2LwizgD~w~LwiG0um6wtzGT2sA5Q9LG9gAEVPRQo3x7AZcqJA1hd4X-ufx8tqdkos6I6JIHtmaramUcSOPZcTcObSfjYxI1OSyxPlABa-Ott6LLowIIkPfodLWpNbJs~wG2zkQ__"
RUN tar -xzf /software/cellranger-atac-2.2.0.tar.gz -C /software/

ENV PATH=/software/cellranger-atac-2.2.0:$PATH