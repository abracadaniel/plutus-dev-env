FROM arradev/cardano-node:latest AS node
FROM arradev/cardano-addresses:latest AS addresses
FROM arradev/bech32:latest AS bech32
FROM debian:buster-slim as build

# Install build dependencies
RUN apt-get update -y \
    && apt-get install automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf liblmdb-dev -y \
    && apt-get install -y libsqlite3-dev m4 ca-certificates gcc libc6-dev curl liblzma-dev postgresql libpq-dev bc \
    && apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Install GHC
ENV CABAL_VERSION=3.8.1.0 \
    GHC_VERSION=8.10.7 \
    PATH="$HOME/.cabal/bin:/root/.ghcup/bin:$PATH"
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh \
    && ghcup install ghc ${GHC_VERSION} \
    && ghcup install cabal ${CABAL_VERSION} \
    && ghcup set ghc ${GHC_VERSION} \
    && ghcup set cabal ${CABAL_VERSION}

# Install libsodium
ARG LIBSODIUM_VERSION
RUN git clone https://github.com/input-output-hk/libsodium \
    && cd libsodium \
    && git fetch --all --recurse-submodules --tags \
    && git tag \
    && git checkout $LIBSODIUM_VERSION \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd .. && rm -rf libsodium
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
    PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

# Install Secp256k1
RUN git clone https://github.com/bitcoin-core/secp256k1 \
    && cd secp256k1 \
    && git checkout ac83be33 \
    && ./autogen.sh \
    && ./configure --enable-module-schnorrsig --enable-experimental \
    && make && make install \
    && cd .. && rm -rf secp256k1

# Copy compiled binaries
COPY --from=node /bin/cardano* /bin/
COPY --from=addresses /bin/cardano-address /bin/
COPY --from=bech32 /bin/bech32 /bin/

# Copy scripts
COPY scripts/ /scripts/
ENV PATH="$PATH:/scripts/"

RUN mkdir /workspace/
WORKDIR /workspace/

ENTRYPOINT ["/bin/bash"]
