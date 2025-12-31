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

1. **Clone the repository and checkout the scaffold branch:**
   ```bash
   git clone https://github.com/Jayc82/Orion.git
   cd Orion
   git checkout substrate-evm-scaffold
   ```

2. **Build the minimal stub:**
   ```bash
   cd substrate-node
   cargo build --release
   ./target/release/orion-node
   ```

3. **Follow the setup guide:**
   - Read `docs/ARCHITECTURE.md` for design decisions
   - Read `docs/RUNNING_LOCALLY.md` for complete setup instructions
   - Run `./scripts/bootstrap.sh` for guided integration

4. **Deploy an example contract:**
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

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) - Technical architecture and design decisions
- [`docs/RUNNING_LOCALLY.md`](docs/RUNNING_LOCALLY.md) - Step-by-step guide to build and run locally
- [`contracts/README.md`](contracts/README.md) - Smart contract deployment guide

### Development Status

🚧 **Current Phase**: Initial scaffold with stubs

This is an intentionally lightweight scaffold to enable fast iteration. The next steps are:

1. ✅ Repository structure and documentation
2. ✅ Minimal buildable stubs with clear integration instructions
3. 🔄 Integrate full Substrate node template with Frontier
4. 🔄 Deploy to local testnet
5. 🔄 Public testnet with multiple validators
6. 🔄 Mainnet preparation and security audits

### Contributing

Contributions are welcome! Key areas for contribution:

- Integrating the full Substrate node template
- Adding example dApps and contracts
- Improving documentation
- Testing and reporting issues

Please see issues labeled with `help-wanted` or `good-first-issue`.

### Next Steps & Issues

Track the development progress:

- **Issue #1**: Integrate full Substrate node template with Frontier
- **Issue #2**: Add polkadot-js web UI example and wallet integration  
- **Issue #3**: Add multi-node testnet deployment scripts

(Issue numbers will be updated once created)

### Resources

- [Substrate Documentation](https://docs.substrate.io/)
- [Frontier (EVM on Substrate)](https://github.com/paritytech/frontier)
- [Polkadot.js Apps](https://polkadot.js.org/apps/)
- [Substrate Node Template](https://github.com/substrate-developer-hub/substrate-node-template)

### License

See [LICENSE](LICENSE) file for details.
