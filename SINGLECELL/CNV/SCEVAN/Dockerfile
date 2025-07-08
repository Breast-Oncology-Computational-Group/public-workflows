FROM anthonyphis/r_scevan:latest
RUN sudo apt-get -y install libhdf5-dev
RUN Rscript -e "install.packages('hdf5r', repos='http://cran.us.r-project.org')" # for reading hdf5 files
