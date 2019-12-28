FROM ubuntu:18.04

ARG BUILD_CONCURRENCY="0"
ARG Z3_FILE="z3-4.8.7.tar.gz"
ARG Z3_DIR="z3-z3-4.8.7"
ARG Z3_CHECKSUM="8c1c49a1eccf5d8b952dadadba3552b0eac67482b8a29eaad62aa7343a0732c3"

ARG SOLC_PATH="https://github.com/ethereum/solidity/releases/download/v0.5.15/"
ARG SOLC_FILE="solidity_0.5.15.tar.gz"
ARG SOLC_DIR="solidity_0.5.15"
ARG SOLC_CHECKSUM="38e3aba8f9950229f0da2d67b8fbfb3b8ec455877109d532230a2b87b296ec96"

# RUN apk --update add python py-pip
# RUN apk --update add --virtual build-dependencies python-dev build-base && \
#     cd ${Z3_DIR} && \
#     python scripts/mk_make.py && \
#     cd build  && \
#     make && \
#     make install && \
#     apk del build-dependencies && \
#     cd ..

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        apt-transport-https \
        binutils \
        clang \
        clang-3.9 \
        curl \
        doxygen \
        default-jdk \
        gcc-multilib \
        gcc-5-multilib \
        git \
        graphviz \
        g++-multilib \
        g++-5-multilib \
        libgmp-dev \
        libgomp1 \
        libomp5 \
        libomp-dev \
        llvm-3.9 \
        make \
        ninja-build \
        python3 \
        python3-setuptools \
        python2.7 \
        python-setuptools \
        wget \
        cmake \
        vim \
        build-essential \
        libboost-all-dev \
        sudo

RUN useradd -m user && \
    echo user:user | chpasswd && \
    cp /etc/sudoers /etc/sudoers.bak && \
    echo 'user  ALL=(root) NOPASSWD: ALL' >> /etc/sudoers
USER user
WORKDIR /home/user

RUN wget ${SOLC_PATH}${SOLC_FILE} && \
    echo "${SOLC_CHECKSUM}  ${SOLC_FILE}" | sha256sum -c && \
    tar -xvf ${SOLC_FILE}

RUN wget https://github.com/z3prover/z3/archive/${Z3_FILE} && \
    echo "${Z3_CHECKSUM}  ${Z3_FILE}" | sha256sum -c && \
    tar -xvf ${Z3_FILE}


WORKDIR /home/user/${Z3_DIR}
RUN  python scripts/mk_make.py && \
     cd build  && \
     make && \
     sudo make install && \
     sudo ln -s /usr/lib/libz3.so /usr/lib/x86_64-linux-gnu/libz3.so

WORKDIR /home/user/${SOLC_DIR}
RUN mkdir build && cd build && cmake .. -DTESTS=0 && make

RUN sudo cp ./build/solc/solc /usr/bin/solc
ENTRYPOINT ["/usr/bin/solc"]
