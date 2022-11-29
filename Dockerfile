FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install -y \
    build-essential cmake \
    curl wget vim python3.7 python3.7-dev python3-pip \
    git pkg-config libssl-dev software-properties-common \
    zip unzip tar

RUN apt-get update

# Install smt-solvers: (1) yices2
RUN wget https://yices.csl.sri.com/releases/2.6.4/yices-2.6.4-x86_64-pc-linux-gnu.tar.gz \
  && tar -xzvf yices-2.6.4-x86_64-pc-linux-gnu.tar.gz \
  && cd yices-2.6.4 \
  && ./install-yices

# (2) boolector
RUN git clone https://github.com/boolector/boolector \
  && cd boolector \
  && ./contrib/setup-lingeling.sh \
  && ./contrib/setup-btor2tools.sh \
  && ./configure.sh && cd build && make

ENV PATH="${PATH}:/boolector/build/bin"

# (3) z3: takes ~40 minutes to install
# RUN \
#    mkdir -p temp && cd /temp &&\
#    git clone https://github.com/Z3Prover/z3.git &&\
#    cd z3 && \
#    git checkout z3-4.8.13 &&\
#    python scripts/mk_make.py &&\
#    cd build &&\
#    make &&\
#    make install

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup override set nightly

# Install geth, evm
RUN wget https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-1.10.4-aa637fd3.tar.gz
RUN tar -xf geth-alltools-linux-amd64-1.10.4-aa637fd3.tar.gz \
  && cp geth-alltools-linux-amd64-1.10.4-aa637fd3/* /usr/local/bin/

# Install solc through solc-select
RUN python3.7 -m pip install -U pip
RUN pip install solc-select \
    && solc-select install 0.8.13 \
    && solc-select use 0.8.13

WORKDIR /app

# Install EthBMC
RUN git clone https://github.com/baolean/EthBMC.git \
  && cd EthBMC \
  && git checkout forge \
  && cargo build --release \
  && cargo build --lib \
  && mkdir queries

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash

RUN git clone https://github.com/baolean/foundry.git \
  && cd foundry \
  && git checkout symexec \
  && /root/.foundry/bin/foundryup --path .

ENTRYPOINT ["/bin/bash", "EthBMC/start.sh"]