# Orion Node Dockerfile
# Multi-stage build for optimized production image

# Stage 1: Builder
FROM rustlang/rust:nightly-2024-01-01 as builder

ARG PROFILE=release
WORKDIR /orion

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y \
    cmake \
    pkg-config \
    libssl-dev \
    git \
    gcc \
    build-essential \
    clang \
    libclang-dev \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Install rust wasm target
RUN rustup target add wasm32-unknown-unknown

# Copy workspace files
COPY Cargo.toml Cargo.lock* ./
COPY node ./node
COPY runtime ./runtime

# Build the project
RUN cargo build "--$PROFILE" --locked

# Stage 2: Runtime
FROM ubuntu:22.04

ARG PROFILE=release

# Install runtime dependencies
RUN apt-get update -y && \
    apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /orion

# Copy the binary from builder
COPY --from=builder /orion/target/$PROFILE/orion-node /usr/local/bin/orion-node

# Verify binary
RUN orion-node --version

# Expose ports
# 30333: p2p traffic
# 9933: HTTP RPC
# 9944: WebSocket RPC  
# 9615: Prometheus metrics
EXPOSE 30333 9933 9944 9615

# Create volume for chain data
VOLUME ["/data"]

# Set environment
ENV RUST_BACKTRACE=1

# Default command: run development node
CMD ["orion-node", "--dev", "--rpc-external", "--rpc-cors=all", "--base-path=/data"]
