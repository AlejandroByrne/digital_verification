FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Build dependencies for Verilator
RUN apt-get update && apt-get install -y \
    git autoconf g++ flex bison ccache \
    libgoogle-perftools-dev numactl perl python3 make \
    libfl2 libfl-dev zlib1g zlib1g-dev help2man \
    z3 \
    && rm -rf /var/lib/apt/lists/*

# Build Verilator from latest stable
RUN git clone https://github.com/verilator/verilator.git /opt/verilator-src \
    && cd /opt/verilator-src \
    && git checkout stable \
    && autoconf \
    && ./configure --prefix=/opt/verilator \
    && make -j$(nproc) \
    && make install \
    && rm -rf /opt/verilator-src

ENV PATH="/opt/verilator/bin:${PATH}"

# Download UVM reference implementation (Accellera official)
RUN git clone --depth 1 \
    https://github.com/accellera-official/uvm-core.git /opt/uvm-core

# UVM_HOME points to the src directory
ENV UVM_HOME="/opt/uvm-core/src"

WORKDIR /work
