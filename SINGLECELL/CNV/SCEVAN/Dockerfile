FROM anthonyphis/r_scevan:latest
RUN sudo apt-get -y install libhdf5-dev
RUN Rscript -e "install.packages('hdf5r', repos='http://cran.us.r-project.org')" # for reading hdf5 files
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-cli -y
    