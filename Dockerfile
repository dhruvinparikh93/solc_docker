FROM alpine

RUN apk update
RUN apk upgrade

ARG BUILD_CONCURRENCY="0"
ARG Z3_PATH="https://github.com/z3prover/z3/archive/"
ARG Z3_FILE="z3-4.8.7.tar.gz"
ARG Z3_DIR="z3-z3-4.8.7"
ARG Z3_CHECKSUM="8c1c49a1eccf5d8b952dadadba3552b0eac67482b8a29eaad62aa7343a0732c3"

ARG SOLC_PATH="https://github.com/ethereum/solidity/releases/download/v0.5.15/"
ARG SOLC_FILE="solidity_0.5.15.tar.gz"
ARG SOLC_DIR="solidity_0.5.15"
ARG SOLC_CHECKSUM="38e3aba8f9950229f0da2d67b8fbfb3b8ec455877109d532230a2b87b296ec96"

WORKDIR /workspace
RUN wget ${SOLC_PATH}${SOLC_FILE} && \
    echo "${SOLC_CHECKSUM}  ${SOLC_FILE}" | sha256sum -c && \
    tar -xf ${SOLC_FILE}

RUN wget ${Z3_PATH}${Z3_FILE} && \
    echo "${Z3_CHECKSUM}  ${Z3_FILE}" | sha256sum -c && \
    tar -xf ${Z3_FILE}

RUN apk --update add python py-pip
RUN apk --update add --virtual build-dependencies python-dev build-base && \
    cd ${Z3_DIR} && \
    python scripts/mk_make.py && \
    cd build  && \
    make && \
    make install && \
    apk del build-dependencies && \
    cd ..

WORKDIR /workspace/${SOLC_DIR}
RUN ./scripts/install_deps.sh
RUN cmake -DCMAKE_BUILD_TYPE=Release
RUN make
RUN make install

ENTRYPOINT ["/usr/local/bin/solc"]
