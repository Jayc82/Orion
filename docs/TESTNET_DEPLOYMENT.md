# Orion Multi-Node Testnet Deployment Guide

This guide provides complete instructions for deploying a multi-validator Orion testnet with monitoring and management tools.

## Overview

The Orion testnet deployment includes:
- **3 Validator Nodes**: Alice (bootnode), Bob, and Charlie
- **Polkadot.js Apps UI**: Web interface for interacting with the network
- **Prometheus**: Metrics collection
- **Grafana**: Metrics visualization
- **Automated Management**: Helper scripts for easy operation

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Orion Testnet Network                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────┐ │
│  │   Validator  │◄──►│   Validator  │◄──►│Validator │ │
│  │    Alice     │    │     Bob      │    │ Charlie  │ │
│  │  (Bootnode)  │    │              │    │          │ │
│  └──────────────┘    └──────────────┘    └──────────┘ │
│         │                   │                   │       │
│         └───────────────────┴───────────────────┘       │
│                             │                            │
│  ┌─────────────────────────┼──────────────────────┐    │
│  │                          │                       │    │
│  │  ┌────────────┐   ┌────────────┐   ┌────────┐ │    │
│  │  │Polkadot.js │   │Prometheus  │   │Grafana │ │    │
│  │  │    Apps    │   │  Metrics   │   │  Viz   │ │    │
│  │  │ :3000      │   │  :9090     │   │ :3001  │ │    │
│  │  └────────────┘   └────────────┘   └────────┘ │    │
│  │                  Monitoring Layer               │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- At least 8GB RAM available
- 20GB disk space
- Ports available: 9933-9935, 9944-9946, 30333-30335, 9615-9617, 3000-3001, 9090

### Start the Testnet

```bash
# Option 1: Use the helper script (recommended)
./scripts/testnet-helper.sh start

# Option 2: Use docker-compose directly
cd substrate-node
docker-compose -f docker-compose.testnet.yml up -d
```

### Check Status

```bash
./scripts/testnet-helper.sh status
```

### View Logs

```bash
# View all validator logs
./scripts/testnet-helper.sh logs

# View specific validator
./scripts/testnet-helper.sh logs alice
./scripts/testnet-helper.sh logs bob
./scripts/testnet-helper.sh logs charlie
```

## Network Configuration

### Validator Nodes

| Validator | HTTP RPC         | WebSocket         | P2P Port | Metrics Port |
|-----------|------------------|-------------------|----------|--------------|
| Alice     | localhost:9933   | localhost:9944    | 30333    | 9615         |
| Bob       | localhost:9934   | localhost:9945    | 30334    | 9616         |
| Charlie   | localhost:9935   | localhost:9946    | 30335    | 9617         |

### Web Interfaces

| Service        | URL                    | Credentials   |
|----------------|------------------------|---------------|
| Polkadot.js UI | http://localhost:3000  | None          |
| Prometheus     | http://localhost:9090  | None          |
| Grafana        | http://localhost:3001  | admin/admin   |

### Network Details

- **Chain Spec**: local (3-validator testnet)
- **Chain ID**: 1337 (EVM)
- **Consensus**: Aura (block production) + Grandpa (finality)
- **Block Time**: ~6 seconds
- **Session Length**: 10 minutes
- **Validators**: 3 (Alice, Bob, Charlie)

## Using the Testnet Helper Script

The `testnet-helper.sh` script provides convenient commands for managing the testnet.

### Available Commands

```bash
# Start the testnet
./scripts/testnet-helper.sh start

# Stop the testnet
./scripts/testnet-helper.sh stop

# Restart the testnet
./scripts/testnet-helper.sh restart

# Show status
./scripts/testnet-helper.sh status

# View logs
./scripts/testnet-helper.sh logs [alice|bob|charlie|all]

# Check validator health
./scripts/testnet-helper.sh health

# Show peer connections
./scripts/testnet-helper.sh peers

# Show metrics URLs
./scripts/testnet-helper.sh metrics

# Show UI URLs
./scripts/testnet-helper.sh ui

# Clean up everything (removes all data)
./scripts/testnet-helper.sh clean

# Show help
./scripts/testnet-helper.sh help
```

## Connecting to the Testnet

### With Polkadot.js Apps

1. Open http://localhost:3000
2. The UI should automatically connect to Alice's node
3. If not, go to Settings → select "Local Node" endpoint

### With MetaMask

Add a custom network with these settings:
- **Network Name**: Orion Testnet
- **RPC URL**: http://localhost:9933 (or 9934, 9935 for other validators)
- **Chain ID**: 1337
- **Currency Symbol**: ORN

### With Polkadot.js Extension

1. Install the Polkadot.js extension
2. Import development accounts (Alice, Bob, Charlie)
3. Use the extension with Polkadot.js Apps

### With Web3 Libraries

```javascript
// Using ethers.js
const provider = new ethers.providers.JsonRpcProvider('http://localhost:9933');

// Using web3.js
const web3 = new Web3('http://localhost:9933');
```

## Deploying Smart Contracts

### Using the Example dApp

1. Start the testnet
2. Open `examples/simple-dapp/index.html` in your browser
3. Configure MetaMask to connect to the testnet
4. Deploy and interact with contracts

### Using Remix IDE

1. Open Remix IDE (https://remix.ethereum.org)
2. Write or load your Solidity contract
3. In Deploy & Run:
   - Environment: "Injected Provider - MetaMask"
   - Make sure MetaMask is connected to Orion Testnet
4. Deploy the contract

### Using Hardhat

Create a `hardhat.config.js`:

```javascript
module.exports = {
  networks: {
    orion_testnet: {
      url: "http://localhost:9933",
      chainId: 1337,
      accounts: [
        // Alith's private key (pre-funded development account)
        "0x5fb92d6e98884f76de468fa3f6278f8807c48bebc13595d45af5bdc4da702133"
      ]
    }
  },
  solidity: "0.8.20"
};
```

Deploy:
```bash
npx hardhat run scripts/deploy.js --network orion_testnet
```

## Monitoring

### Prometheus Metrics

Access Prometheus at http://localhost:9090

**Useful Queries:**
- Block height: `substrate_block_height`
- Peers: `substrate_sub_libp2p_peers_count`
- Transactions: `substrate_txpool_validations_scheduled`
- Finalized blocks: `substrate_finality_grandpa_round`

### Grafana Dashboards

Access Grafana at http://localhost:3001 (admin/admin)

1. Log in with default credentials
2. Go to Dashboards → Import
3. Import Substrate/Polkadot dashboards from Grafana.com:
   - Dashboard ID: 13840 (Substrate Node)
   - Dashboard ID: 11467 (Substrate Network)

### Health Checks

```bash
# Check if all validators are healthy
./scripts/testnet-helper.sh health

# Check peer connections
./scripts/testnet-helper.sh peers

# View real-time logs
./scripts/testnet-helper.sh logs alice
```

## Testing the Network

### 1. Check Block Production

```bash
# Using curl to check latest block
curl -H "Content-Type: application/json" \
     -d '{"id":1, "jsonrpc":"2.0", "method":"chain_getBlock"}' \
     http://localhost:9933

# Watch blocks being produced
./scripts/testnet-helper.sh logs alice | grep "Imported"
```

### 2. Test EVM Functionality

```bash
# Deploy the HelloWorld contract
cd contracts
# Follow deployment instructions in README.md

# Or use the example dApp
open examples/simple-dapp/index.html
```

### 3. Test Finality

Check that blocks are being finalized:

```bash
curl -H "Content-Type: application/json" \
     -d '{"id":1, "jsonrpc":"2.0", "method":"chain_getFinalizedHead"}' \
     http://localhost:9933
```

### 4. Test Peer Discovery

All validators should be connected to each other:

```bash
./scripts/testnet-helper.sh peers
```

Expected output: Each validator should show 2 peers.

## Troubleshooting

### Validators Not Connecting

**Problem**: Validators show 0 peers

**Solutions**:
1. Check that Alice (bootnode) is running:
   ```bash
   docker ps | grep validator-alice
   ```

2. Verify network connectivity:
   ```bash
   docker network inspect orion_orion-testnet
   ```

3. Check logs for connection errors:
   ```bash
   ./scripts/testnet-helper.sh logs bob
   ```

### Blocks Not Being Produced

**Problem**: Block height not increasing

**Solutions**:
1. Check validator logs for errors:
   ```bash
   ./scripts/testnet-helper.sh logs
   ```

2. Verify all validators are running:
   ```bash
   ./scripts/testnet-helper.sh status
   ```

3. Check validator session keys:
   ```bash
   curl -H "Content-Type: application/json" \
        -d '{"id":1, "jsonrpc":"2.0", "method":"author_hasSessionKeys", "params":["0x..."]}' \
        http://localhost:9933
   ```

### High Resource Usage

**Problem**: Docker containers using too much CPU/memory

**Solutions**:
1. Check resource usage:
   ```bash
   docker stats
   ```

2. Adjust resource limits in `docker-compose.testnet.yml`:
   ```yaml
   services:
     validator-alice:
       deploy:
         resources:
           limits:
             cpus: '2'
             memory: 2G
   ```

3. Reduce Prometheus retention:
   ```yaml
   prometheus:
     command:
       - '--storage.tsdb.retention.time=7d'
   ```

### Ports Already in Use

**Problem**: Cannot start testnet, ports are in use

**Solutions**:
1. Check which process is using the port:
   ```bash
   lsof -i :9933
   ```

2. Stop the single-node development setup:
   ```bash
   docker-compose -f docker-compose.yml down
   ```

3. Or change ports in `docker-compose.testnet.yml`

### Data Corruption

**Problem**: Chain database is corrupted

**Solution**:
```bash
# Clean up and restart
./scripts/testnet-helper.sh clean
./scripts/testnet-helper.sh start
```

## Advanced Configuration

### Adding More Validators

To add a 4th validator:

1. Add to `docker-compose.testnet.yml`:
```yaml
validator-dave:
  build:
    context: .
    dockerfile: Dockerfile
  container_name: orion-validator-dave
  ports:
    - "9936:9933"
    - "9947:9944"
    - "30336:30333"
  command: >
    orion-node
    --base-path=/data
    --chain=local
    --dave
    --validator
    --bootnodes=/dns/validator-alice/tcp/30333/p2p/12D3KooWEyoppNCUx8Yx66oV9fJnriXwCcXwDDUA2kj6vnc6iDEp
  networks:
    - orion-testnet
```

2. Update the chain spec to include Dave's session keys

### Custom Chain Specification

Generate a custom chain spec:

```bash
# Inside the container
docker exec orion-validator-alice orion-node build-spec --chain=local > custom-spec.json

# Edit the spec (add accounts, change parameters, etc.)
nano custom-spec.json

# Convert to raw format
docker exec -i orion-validator-alice orion-node build-spec --chain=custom-spec.json --raw > custom-spec-raw.json

# Use in docker-compose.testnet.yml
command: >
  orion-node
  --base-path=/data
  --chain=/config/custom-spec-raw.json
  ...
```

### Enabling Archive Node

To run Alice as an archive node (stores all historical state):

```yaml
validator-alice:
  command: >
    orion-node
    --base-path=/data
    --chain=local
    --alice
    --validator
    --pruning=archive
    --unsafe-rpc-external
    --unsafe-ws-external
```

### External Access

To expose the testnet to external networks:

1. Update docker-compose to bind to 0.0.0.0:
```yaml
ports:
  - "0.0.0.0:9933:9933"
```

2. Update firewall rules to allow external access

3. **Security Warning**: Only do this for development. For production:
   - Remove `--rpc-methods=Unsafe`
   - Remove `--rpc-cors=all`
   - Use proper authentication
   - Use reverse proxy with SSL

## Production Deployment

For production deployment, consider:

### 1. Security Hardening

- Remove development accounts
- Disable unsafe RPC methods
- Use proper SSL/TLS certificates
- Implement firewall rules
- Use non-root Docker user

### 2. High Availability

- Run validators on separate physical machines
- Use load balancers for RPC endpoints
- Implement automatic failover
- Set up backup validators

### 3. Monitoring & Alerting

- Configure Grafana alerts
- Set up log aggregation (ELK stack)
- Monitor disk space and network bandwidth
- Track block production and finality

### 4. Backup & Recovery

- Regular database backups
- Snapshot chain state
- Document recovery procedures
- Test disaster recovery

### 5. Performance Tuning

- Optimize database settings
- Tune network parameters
- Configure proper resource limits
- Use SSD storage

## Network Maintenance

### Upgrading Validators

Rolling upgrade process:

```bash
# Upgrade Bob (non-bootnode)
docker-compose -f docker-compose.testnet.yml stop validator-bob
docker-compose -f docker-compose.testnet.yml build validator-bob
docker-compose -f docker-compose.testnet.yml up -d validator-bob

# Wait for Bob to sync
./scripts/testnet-helper.sh logs bob

# Repeat for Charlie
docker-compose -f docker-compose.testnet.yml stop validator-charlie
docker-compose -f docker-compose.testnet.yml build validator-charlie
docker-compose -f docker-compose.testnet.yml up -d validator-charlie

# Finally upgrade Alice (bootnode)
docker-compose -f docker-compose.testnet.yml stop validator-alice
docker-compose -f docker-compose.testnet.yml build validator-alice
docker-compose -f docker-compose.testnet.yml up -d validator-alice
```

### Rotating Session Keys

To rotate validator session keys:

```bash
# Generate new keys
curl -H "Content-Type: application/json" \
     -d '{"id":1, "jsonrpc":"2.0", "method":"author_rotateKeys"}' \
     http://localhost:9933

# Set the new keys in chain state (requires sudo)
# Use Polkadot.js Apps → Extrinsics → session.setKeys()
```

## Support & Resources

### Documentation

- Main README: `../README.md`
- Docker Guide: `../docs/DOCKER.md`
- Wallet Integration: `../docs/WALLET_INTEGRATION.md`
- Architecture: `../docs/ARCHITECTURE.md`

### Community

- GitHub Issues: Report bugs and request features
- Substrate Documentation: https://docs.substrate.io
- Frontier Documentation: https://github.com/paritytech/frontier

### Development Accounts

See `docs/WALLET_INTEGRATION.md` for complete list of pre-funded development accounts with private keys.

## License

See LICENSE file in repository root.
