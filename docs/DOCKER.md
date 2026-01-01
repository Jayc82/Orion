# Docker Setup for Orion Node

This guide explains how to build and run the Orion Substrate node with EVM support using Docker, which resolves dependency issues that may occur with local builds.

## Prerequisites

- Docker Engine 20.10+ ([Install Docker](https://docs.docker.com/get-docker/))
- Docker Compose 2.0+ (included with Docker Desktop)
- At least 4GB RAM allocated to Docker
- At least 10GB free disk space

## Quick Start

### Option 1: Using Docker Compose (Recommended)

The easiest way to run Orion with Docker:

```bash
cd substrate-node

# Build and start the node
docker-compose up -d

# View logs
docker-compose logs -f orion-node

# Stop the node
docker-compose down

# Stop and remove volumes (clears chain data)
docker-compose down -v
```

This will:
- Build the Orion node Docker image
- Start the node in development mode
- Start Polkadot.js Apps UI on http://localhost:3000
- Expose RPC endpoints on ports 9933 (HTTP) and 9944 (WebSocket)

### Option 2: Using Docker Directly

For more control over the build and run process:

```bash
cd substrate-node

# Build the image
docker build -t orion-node:latest .

# Run development node
docker run -d \
  --name orion-dev \
  -p 9933:9933 \
  -p 9944:9944 \
  -p 30333:30333 \
  -v orion-data:/data \
  orion-node:latest

# View logs
docker logs -f orion-dev

# Stop the node
docker stop orion-dev
docker rm orion-dev
```

## Build Options

### Development Build (Faster, Larger)

```bash
docker build --build-arg PROFILE=debug -t orion-node:dev .
```

### Release Build (Slower, Optimized)

```bash
docker build --build-arg PROFILE=release -t orion-node:latest .
```

### Build with Caching

To speed up subsequent builds:

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with cache
docker build -t orion-node:latest .
```

## Running Different Configurations

### Development Node (Default)

```bash
docker run -d \
  --name orion-dev \
  -p 9933:9933 \
  -p 9944:9944 \
  orion-node:latest
```

### Development Node with Custom Chain Spec

```bash
docker run -d \
  --name orion-dev \
  -p 9933:9933 \
  -p 9944:9944 \
  -v $(pwd)/chain-specs:/chain-specs \
  orion-node:latest \
  orion-node --dev --chain=/chain-specs/orion-dev.json
```

### Production Node (Manual Seal)

```bash
docker run -d \
  --name orion-node \
  -p 9933:9933 \
  -p 9944:9944 \
  -p 30333:30333 \
  -v orion-data:/data \
  orion-node:latest \
  orion-node \
    --base-path=/data \
    --chain=orion_dev \
    --rpc-external \
    --rpc-cors=all \
    --rpc-methods=Safe \
    --name=orion-validator-1
```

### Archive Node

```bash
docker run -d \
  --name orion-archive \
  -p 9933:9933 \
  -p 9944:9944 \
  -p 30333:30333 \
  -v orion-archive:/data \
  orion-node:latest \
  orion-node \
    --base-path=/data \
    --chain=orion_dev \
    --pruning=archive \
    --rpc-external \
    --rpc-cors=all
```

## Accessing the Node

### Using Polkadot.js Apps

If using docker-compose, the UI is available at:
- http://localhost:3000

Or connect to the node directly:
- Go to https://polkadot.js.org/apps/
- Click on the network dropdown (top left)
- Select "Development" → "Local Node"
- Or add custom endpoint: `ws://localhost:9944`

### Using MetaMask

1. Open MetaMask
2. Add a new network with these settings:
   - Network Name: Orion Local
   - RPC URL: http://localhost:9933
   - Chain ID: 1251
   - Currency Symbol: ORN
   - Block Explorer: (leave empty for local)

### Using curl (HTTP RPC)

```bash
# Get node health
curl -H "Content-Type: application/json" \
  -d '{"id":1, "jsonrpc":"2.0", "method": "system_health"}' \
  http://localhost:9933

# Get chain name
curl -H "Content-Type: application/json" \
  -d '{"id":1, "jsonrpc":"2.0", "method": "system_chain"}' \
  http://localhost:9933

# Get EVM chain ID
curl -H "Content-Type: application/json" \
  -d '{"id":1, "jsonrpc":"2.0", "method": "eth_chainId"}' \
  http://localhost:9933
```

## Docker Compose Services

### Orion Node Service

The main blockchain node service:
- Image: Built from local Dockerfile
- Ports: 9933 (HTTP RPC), 9944 (WS RPC), 30333 (P2P), 9615 (metrics)
- Volume: `orion-data` for persistent chain data
- Network: `orion-network`

### Polkadot.js Apps UI Service (Optional)

Web-based UI for interacting with the node:
- Image: `jacogr/polkadot-js-apps:latest`
- Port: 3000 (HTTP)
- Pre-configured to connect to the Orion node

To disable the UI service:

```bash
docker-compose up -d orion-node
```

## Managing Chain Data

### View Chain Data

```bash
docker run --rm -v orion-data:/data busybox ls -lh /data
```

### Backup Chain Data

```bash
docker run --rm -v orion-data:/data -v $(pwd):/backup busybox \
  tar czf /backup/orion-backup-$(date +%Y%m%d).tar.gz -C /data .
```

### Restore Chain Data

```bash
docker run --rm -v orion-data:/data -v $(pwd):/backup busybox \
  tar xzf /backup/orion-backup-YYYYMMDD.tar.gz -C /data
```

### Clear Chain Data

```bash
# Stop and remove with volumes
docker-compose down -v

# Or manually
docker volume rm orion-data
```

## Troubleshooting

### Build Fails with Dependency Errors

The Docker build uses locked dependencies which should resolve most issues. If you still encounter problems:

```bash
# Try with a clean build (no cache)
docker build --no-cache -t orion-node:latest .

# Or update Rust nightly version in Dockerfile
# Edit Dockerfile line: FROM rustlang/rust:nightly-2024-01-01
```

### Node Won't Start

Check logs:
```bash
docker-compose logs orion-node
# or
docker logs orion-dev
```

Common issues:
- **Port already in use**: Another service is using 9933, 9944, or 30333
- **Insufficient memory**: Increase Docker memory limit to at least 4GB
- **Corrupted chain data**: Clear data with `docker-compose down -v`

### RPC Connection Refused

Ensure the node is running with external RPC enabled:
```bash
docker-compose logs orion-node | grep "Running JSON-RPC"
```

Check that ports are properly mapped:
```bash
docker ps | grep orion-node
```

### Slow Build Times

- **Enable BuildKit**: `export DOCKER_BUILDKIT=1`
- **Use release profile only when needed**: Debug builds are faster
- **Increase Docker resources**: Allocate more CPU and RAM in Docker settings

### Out of Disk Space

Docker images and volumes can consume significant space:

```bash
# Check Docker disk usage
docker system df

# Clean up unused images and containers
docker system prune -a

# Remove specific volumes
docker volume rm orion-data
```

## Performance Optimization

### Multi-Core Builds

Utilize multiple CPU cores during compilation:

```bash
docker build \
  --build-arg CARGO_BUILD_JOBS=4 \
  -t orion-node:latest .
```

### Persistent Rust Cache

To speed up repeated builds, mount a cache volume:

```bash
docker build \
  --mount=type=cache,target=/usr/local/cargo/registry \
  --mount=type=cache,target=/orion/target \
  -t orion-node:latest .
```

## Production Deployment

For production deployments:

1. **Use release builds**: `--build-arg PROFILE=release`
2. **Enable telemetry and monitoring**: Expose port 9615 for Prometheus
3. **Use proper secrets management**: Don't hardcode keys
4. **Set resource limits**: Use Docker resource constraints
5. **Configure health checks**: Add health checks to docker-compose.yml
6. **Use orchestration**: Consider Kubernetes for multi-node deployments

Example production docker-compose snippet:

```yaml
services:
  orion-node:
    build:
      args:
        PROFILE: release
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9933/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## Advanced Usage

### Interactive Shell in Container

```bash
# Start a bash shell in running container
docker exec -it orion-dev /bin/bash

# Or start a new container with shell
docker run -it --entrypoint /bin/bash orion-node:latest
```

### Export Chain Spec

```bash
docker run --rm orion-node:latest \
  orion-node build-spec --chain=orion_dev > orion-dev-spec.json
```

### Generate Keys

```bash
docker run --rm orion-node:latest \
  orion-node key generate --scheme Sr25519
```

## Multi-Node Setup

To run multiple nodes (e.g., for a local testnet), see the docker-compose examples in `/scripts/docker/` directory.

## Security Considerations

- **Never expose RPC publicly without authentication**
- **Use `--rpc-methods=Safe` in production** (not `Unsafe`)
- **Restrict CORS** (don't use `--rpc-cors=all` in production)
- **Keep base images updated** for security patches
- **Use secrets management** for validator keys
- **Enable firewall rules** for P2P port (30333)

## References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Substrate Docker Guide](https://docs.substrate.io/tutorials/build-a-blockchain/simulate-network/)
- [Frontier GitHub](https://github.com/paritytech/frontier)
- [Polkadot.js Apps](https://polkadot.js.org/apps/)

## Support

For issues specific to:
- **Docker setup**: Check this guide and Docker logs
- **Orion node**: See `docs/RUNNING_LOCALLY.md` and `docs/ARCHITECTURE.md`
- **Frontier integration**: See `docs/FRONTIER_INTEGRATION.md`
