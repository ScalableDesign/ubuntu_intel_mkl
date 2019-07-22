# Use Ubuntu 18.04 as a base image
FROM ubuntu:18.04
LABEL maintainer "Laurent ESCALIER, Scalable Design <laurent.escalier@scalable-design.com>"
LABEL version "1.0"

USER root
WORKDIR /tmp

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential \
    apt-utils \
    gnupg2 \
    software-properties-common

ENV BUILD_PACKAGES="\
    gcc \
    g++ \
    gfortran \
    wget \
    cpio \
    "
RUN apt-get update && \
    apt-get install -y --no-install-recommends $BUILD_PACKAGES

RUN add-apt-repository universe && \
    add-apt-repository main && \
    apt-get update

# INTEL Performance Libraries
RUN wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
    apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
    wget https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list  && \
    apt-get update

ENV INTEL_PACKAGES="\
    intel-mkl-2019.4-070 \
    intel-ipp-2019.4-070 \
    intel-tbb-2019.6-070 \
    intel-daal-2019.4-070 \
    intel-mpi-2019.4-070 \
    intelpython3 \
    "

RUN  apt-get install -y --no-install-recommends $INTEL_PACKAGES

# Configuration to use Intel MKL as standard
RUN update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so     \
    libblas.so-x86_64-linux-gnu      /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so.3   \
    libblas.so.3-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so   \
    liblapack.so-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so.3 \
    liblapack.so.3-x86_64-linux-gnu  /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    echo "/opt/intel/lib/intel64"     >  /etc/ld.so.conf.d/mkl.conf && \
    echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/mkl.conf && \
    echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/intel.conf && \
    ldconfig && \
    echo "source /opt/intel/mkl/bin/mklvars.sh intel64" >> /etc/bash.bashrc && \
    echo "MKL_THREADING_LAYER=GNU" >> /etc/environment

ENV PATH="/opt/intel/intelpython3/bin/:${PATH}"

ENV OMP_NUM_THREADS=6

# Add python, numpy, matplotlib
ENV PYTHON_PACKAGES="\
    intel-scikit-learn \
    matplotlib \
    daal4py \
    tbb4py \
    mkl \
    daal \
    ipp \
    impi \
    tbb \
    intel-openmp \
    pandas \
    "

RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir $PYTHON_PACKAGES

