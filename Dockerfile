FROM ubuntu:22.04

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    build-essential cmake \
    curl wget vim python3 python3-pip \
    git pkg-config libssl-dev software-properties-common \
    zip unzip tar

RUN apt-get update

# Install smt-solvers: (1) yices2
RUN add-apt-repository ppa:sri-csl/formal-methods \
  && apt-get update \
  && apt-get install -y yices2

# (2) boolector
RUN git clone https://github.com/boolector/boolector \
  && cd boolector \
  && ./contrib/setup-lingeling.sh \
  && ./contrib/setup-btor2tools.sh \
  && ./configure.sh && cd build && make

ENV PATH="${PATH}:/boolector/build/bin"

# (3) Z3
RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.12.1/z3-4.12.1-x64-glibc-2.35.zip \
    && unzip z3-4.12.1-x64-glibc-2.35.zip \
    && rm z3-4.12.1-x64-glibc-2.35.zip \
    && mv z3-4.12.1-x64-glibc-2.35 z3 

ENV PATH=/z3/bin:$PATH

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup override set nightly

# Install geth, evm
RUN wget https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-1.10.4-aa637fd3.tar.gz
RUN tar -xf geth-alltools-linux-amd64-1.10.4-aa637fd3.tar.gz \
  && rm geth-alltools-linux-amd64-1.10.4-aa637fd3.tar.gz \
  && cp geth-alltools-linux-amd64-1.10.4-aa637fd3/* /usr/local/bin/

# Install solc through solc-select
RUN pip install solc-select \
    && solc-select install 0.8.13 \
    && solc-select use 0.8.13

# Install EthBMC
RUN git clone https://github.com/baolean/EthBMC.git \
  && cd EthBMC \
  && cargo build --release \
  && mkdir queries

ENV PATH=/EthBMC/target/release:$PATH

ENTRYPOINT ["/bin/bash"]