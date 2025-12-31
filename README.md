# Orion

Orion Coin: A Layer-1 blockchain combining Bitcoin-style security with Ethereum-style smart contracts.

## Substrate + EVM Scaffold

We've added an initial scaffold for building Orion on Substrate with Frontier/EVM integration. This provides a foundation for developers to build and test a local development chain with full Ethereum compatibility.

### What's Included

The scaffold branch (`substrate-evm-scaffold`) includes:

- **Substrate Node Template Stub**: Minimal Rust scaffold with TODOs for integrating the full Substrate node template + Frontier
- **Bootstrap Scripts**: Automated setup scripts to clone upstream Substrate template and apply EVM integration
- **Example Smart Contract**: HelloWorld.sol Solidity contract with deployment instructions
- **Documentation**: Architecture guide and step-by-step local running instructions
- **CI Workflow**: GitHub Actions workflow for automated testing

### Quick Start

**Option A: Using Docker (Recommended - Solves Dependency Issues)**

The easiest and most reliable way to build and run Orion:

```bash
cd substrate-node

# Build and start with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f orion-node

# Access Polkadot.js UI at http://localhost:3000
# Connect MetaMask to http://localhost:9933 (Chain ID: 1337)
```

See [`docs/DOCKER.md`](docs/DOCKER.md) for complete Docker documentation.

**Option B: Use the Frontier Template (Manual Build)**

Follow the comprehensive integration guide:
```bash
# See detailed instructions in docs/FRONTIER_INTEGRATION.md
cd /tmp
git clone --depth 1 --branch polkadot-v1.7.0 https://github.com/paritytech/frontier.git
cp -r frontier/template/* /path/to/Orion/substrate-node/
cd /path/to/Orion/substrate-node
# Customize for Orion (see docs/FRONTIER_INTEGRATION.md)
cargo build --release
./target/release/orion-node --dev --tmp
```

**Option C: Build from Stub**

1. **Clone the repository and checkout the scaffold branch:**
   ```bash
   git clone https://github.com/Jayc82/Orion.git
   cd Orion
   git checkout substrate-evm-scaffold
   ```

2. **Follow the setup guide:**
   - Read `docs/FRONTIER_INTEGRATION.md` for complete Frontier template integration ⭐ **RECOMMENDED**
   - Read `docs/ARCHITECTURE.md` for design decisions
   - Read `docs/RUNNING_LOCALLY.md` for complete setup instructions
   - Run `./scripts/bootstrap.sh` for guided integration

3. **Deploy an example contract:**
   - See `contracts/README.md` for Solidity deployment with Hardhat or Remix
   - Connect to local node at `http://127.0.0.1:9933`

### Key Features

- **EVM Compatibility**: Deploy Solidity contracts using standard Ethereum tools (Hardhat, Remix, MetaMask)
- **Substrate Framework**: Built on battle-tested Substrate with rich ecosystem
- **Frontier Integration**: Full Ethereum JSON-RPC compatibility
- **ORN Token**: Native token with 18 decimals for EVM compatibility
- **Aura + Grandpa Consensus**: Fast block production and deterministic finality for development

### Architecture

- **Runtime**: Substrate runtime with EVM pallet (Frontier)
- **Consensus**: Aura (block production) + Grandpa (finality)
- **Token**: ORN (18 decimals)
- **Chain ID**: 1337 (development)
- **RPC Endpoints**: 
  - Substrate WebSocket: `ws://127.0.0.1:9944`
  - Ethereum JSON-RPC: `http://127.0.0.1:9933`

### Documentation

- [`docs/DOCKER.md`](docs/DOCKER.md) - **🐳 Docker setup guide** (SOLVES DEPENDENCY ISSUES)
- [`docs/FRONTIER_INTEGRATION.md`](docs/FRONTIER_INTEGRATION.md) - **⭐ Complete guide to integrate Frontier template** (RECOMMENDED)
- [`docs/WALLET_INTEGRATION.md`](docs/WALLET_INTEGRATION.md) - **👛 MetaMask & Polkadot.js wallet setup**
- [`docs/TESTNET_DEPLOYMENT.md`](docs/TESTNET_DEPLOYMENT.md) - **🌐 Multi-node testnet deployment** (NEW)
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) - Technical architecture and design decisions
- [`docs/RUNNING_LOCALLY.md`](docs/RUNNING_LOCALLY.md) - Step-by-step guide to build and run locally
- [`contracts/README.md`](contracts/README.md) - Smart contract deployment guide
- [`examples/simple-dapp/`](examples/simple-dapp/) - Example dApp with wallet integration

### Development Status

🚧 **Current Phase**: Production testnet preparation

Progress:

1. ✅ Repository structure and documentation
2. ✅ Minimal buildable stubs with clear integration instructions
3. ✅ Integrate full Substrate node template with Frontier
4. ✅ Docker deployment solution
5. ✅ Wallet integration (MetaMask & Polkadot.js)
6. ✅ Example dApp with contract interaction
7. ✅ Multi-node local testnet deployment
8. 🔄 Public testnet with multiple validators
9. 🔄 Mainnet preparation and security audits

### Contributing

Contributions are welcome! Key areas for contribution:

- Integrating the full Substrate node template
- Adding example dApps and contracts
- Improving documentation
- Testing and reporting issues

Please see issues labeled with `help-wanted` or `good-first-issue`.

### Next Steps & Issues

Track the development progress:

- **Issue #1**: ✅ Integrate full Substrate node template with Frontier (COMPLETED)
- **Issue #2**: ✅ Add polkadot-js web UI example and wallet integration (COMPLETED)
- **Issue #3**: 🔄 Add multi-node testnet deployment scripts (NEXT)

### Quick Test: Example dApp

After starting your node with Docker:

1. Open [`examples/simple-dapp/index.html`](examples/simple-dapp/index.html) in your browser
2. Click "Connect MetaMask"
3. Import a development account (see [`docs/WALLET_INTEGRATION.md`](docs/WALLET_INTEGRATION.md))
4. Try sending ORN or interacting with contracts!

See [`examples/simple-dapp/README.md`](examples/simple-dapp/README.md) for complete instructions.

### Resources

- [Substrate Documentation](https://docs.substrate.io/)
- [Frontier (EVM on Substrate)](https://github.com/paritytech/frontier)
- [Polkadot.js Apps](https://polkadot.js.org/apps/)
- [Substrate Node Template](https://github.com/substrate-developer-hub/substrate-node-template)

### License

See [LICENSE](LICENSE) file for details.
