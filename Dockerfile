FROM rocker/r-ver:4.4.1

ARG BUILD_DATE
ARG GIT_REVISION

# See Open Containers Image Spec for info on the annotations.
LABEL org.opencontainers.image.authors="The rCRUX Programmers"
LABEL org.opencontainers.image.base.name="docker.io/rocker/r-ver:4.4.1"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.description="Generate CRUX metabarcoding reference libraries in R"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"
LABEL org.opencontainers.image.ref.name="ubuntu"
LABEL org.opencontainers.image.revision="${GIT_REVISION}"
LABEL org.opencontainers.image.source="https://github.com/CalCOFI/rCRUX"
LABEL org.opencontainers.image.title="rCRUX"
LABEL org.opencontainers.image.vendor="The rCRUX Project"
# This is the short commit hash of the "version" of rCRUX built in to the docker
# image, with an additional build number. This commit should match the one
# below.
LABEL org.opencontainers.image.version="1d371a9-1"

# Install system dependencies needed by R packages.
RUN <<EOF
apt-get -y update 
apt-get -y install \
  curl \
  libcurl4-openssl-dev \
  libglpk-dev \
  libicu-dev \
  libxml2-dev \
  make \
  zlib1g \
  zlib1g-dev
rm -rf /var/lib/apt/lists/*
EOF

# Install the R packages.
RUN <<EOF
R -q -e 'install.packages("devtools", dependencies=TRUE)'
R -q -e 'if(!requireNamespace("BiocManager")){ install.packages("BiocManager") }; BiocManager::install("phyloseq")'
R -q -e 'devtools::install_github("cpauvert/psadd@6407bd88c1436101640e103a927515ada8c7f520", dependencies=TRUE)'
R -q -e 'devtools::install_github("mooreryan/rCRUX@1d371a9c592e0e0ce66e4de9dce5728c7333ec86", dependencies=TRUE)'
EOF

# Install runtime dependencies.
RUN <<EOF
# Install NCBI BLAST.
curl https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.16.0/ncbi-blast-2.16.0+-x64-linux.tar.gz | tar xz
mv ncbi-blast-2.16.0+/bin/blastn /usr/local/bin 
mv ncbi-blast-2.16.0+/bin/blastdbcmd /usr/local/bin 
rm -r ncbi-blast-2.16.0+

# Install SeqKit.
curl -L https://github.com/shenwei356/seqkit/releases/download/v2.8.2/seqkit_linux_amd64.tar.gz | tar xz
mv seqkit /usr/local/bin
EOF
