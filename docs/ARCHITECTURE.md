# Orion Architecture

## Overview

Orion is a Layer-1 blockchain that combines Bitcoin-style security with Ethereum-style smart contracts using Substrate framework with Frontier EVM integration.

## Technology Stack

### Substrate Framework

**What is Substrate?**
- Modular blockchain framework by Parity Technologies
- Powers Polkadot, Kusama, and many other chains
- Provides core blockchain primitives (networking, consensus, storage, runtime)
- Highly customizable and upgradeable

**Why Substrate?**
- Battle-tested in production (Polkadot network)
- Rich ecosystem of pallets (blockchain modules)
- Built-in support for chain upgrades without hard forks
- Strong security guarantees
- Active development and community

### Frontier - EVM Integration

**What is Frontier?**
- Ethereum compatibility layer for Substrate
- Enables running Ethereum smart contracts on Substrate
- Provides Ethereum JSON-RPC compatibility
- Maintained by Parity Technologies

**Why Frontier?**
- Full EVM compatibility (run any Solidity contract)
- Ethereum tooling works out of the box (Hardhat, Remix, MetaMask)
- Dual account system: Substrate + Ethereum addresses
- Proven in production (Moonbeam, Astar, and others)

**Components:**
- `pallet-evm`: Ethereum Virtual Machine execution
- `pallet-ethereum`: Ethereum transaction format support
- `pallet-base-fee`: EIP-1559 dynamic fee mechanism
- `fc-rpc`: Ethereum-compatible JSON-RPC server

## Consensus Mechanism

### Aura (Authority Round)

**Block Production:**
- Slot-based block production
- Validators take turns producing blocks in a round-robin fashion
- Deterministic and fast finality
- Suitable for permissioned and consortium chains

**Configuration:**
- Block time: 6 seconds (configurable)
- Validators: Initial set configured in chain spec
- Can be modified through governance

### Grandpa (GHOST-based Recursive Ancestor Deriving Prefix Agreement)

**Finality:**
- Byzantine fault-tolerant finality gadget
- Finalizes chains of blocks, not individual blocks
- Can finalize even with network partitions (up to 1/3 Byzantine nodes)
- Separate from block production

**Why Aura + Grandpa?**
- Aura provides fast block production
- Grandpa provides deterministic finality
- Together: predictable performance for development and testnets
- Production-ready: same consensus used by Polkadot parachains

### Future Consensus Options

For mainnet, consider:
- **BABE (Blind Assignment for Blockchain Extension):** More decentralized block production
- **Proof of Stake:** Token-based validator selection
- **NPoS (Nominated Proof of Stake):** Polkadot-style staking

## Token Economics

### ORN Token

**Symbol:** ORN
**Decimals:** 18 (same as ETH for EVM compatibility)
**Total Supply:** TBD (to be determined by governance)

**Use Cases:**
- Transaction fees (gas)
- Staking for validators
- Governance voting
- Smart contract deployment

**Fee Model:**
- EIP-1559 compatible (base fee + priority fee)
- Base fee adjusts dynamically based on network usage
- Fees burned to reduce supply over time

## Chain Configuration

### Network Parameters

| Parameter | Development | Testnet | Mainnet |
|-----------|-------------|---------|---------|
| Chain ID (EVM) | 1337 | TBD | TBD |
| Runtime Name | OrionRuntime | OrionRuntime | OrionRuntime |
| SS58 Prefix | 42 (generic) | TBD | TBD |
| Block Time | 6 seconds | 6 seconds | TBD |
| Consensus | Aura+Grandpa | Aura+Grandpa | TBD |

### Runtime Pallets

**Core System:**
- `frame-system`: Core system functionality
- `pallet-timestamp`: On-chain timestamps
- `pallet-balances`: Native token (ORN) management
- `pallet-transaction-payment`: Fee handling

**Consensus:**
- `pallet-aura`: Block production
- `pallet-grandpa`: Finality

**EVM Compatibility:**
- `pallet-evm`: Ethereum Virtual Machine
- `pallet-ethereum`: Ethereum transaction format
- `pallet-base-fee`: Dynamic fee adjustment (EIP-1559)

**Governance (Future):**
- `pallet-democracy`: On-chain governance
- `pallet-collective`: Council for fast-track decisions
- `pallet-treasury`: Community funds management

**Development:**
- `pallet-sudo`: Superuser access (dev/testnet only)

## Architecture Decisions

### 1. Substrate vs Custom Blockchain

**Decision:** Use Substrate

**Rationale:**
- Proven in production with billions in TVL
- Rich ecosystem and tooling
- Active development and security updates
- Faster time to market than building from scratch
- Interoperability with Polkadot ecosystem

### 2. EVM vs Native Smart Contracts

**Decision:** EVM via Frontier (with option for Wasm contracts later)

**Rationale:**
- Largest developer ecosystem (Solidity)
- Existing tooling (Hardhat, Truffle, Remix)
- Wallet support (MetaMask, etc.)
- Can add ink! (Wasm) contracts later for advanced use cases

### 3. Consensus for Development

**Decision:** Aura + Grandpa

**Rationale:**
- Predictable performance for development
- Fast finality for better UX
- Simple validator setup for testnets
- Can migrate to more decentralized consensus for mainnet

### 4. Account System

**Decision:** Dual account system (Substrate + Ethereum)

**Rationale:**
- Substrate accounts: Full blockchain functionality
- Ethereum addresses: Seamless EVM integration
- Automatic mapping between both formats
- Users can use either address format

## Roadmap

### Phase 1: Scaffold (Current)
- [x] Repository structure
- [x] Minimal node stub with build instructions
- [x] Example Solidity contract
- [x] Documentation and scripts
- [ ] Full Substrate node template integration

### Phase 2: Core Implementation
- [ ] Integrate full Substrate node template
- [ ] Configure Frontier EVM pallets
- [ ] Set up Ethereum JSON-RPC
- [ ] Test EVM functionality
- [ ] Deploy to local testnet

### Phase 3: Developer Tools
- [ ] Polkadot.js apps configuration
- [ ] Example wallet integration (MetaMask)
- [ ] Faucet for testnet tokens
- [ ] Block explorer integration

### Phase 4: Testnet
- [ ] Multi-node testnet deployment
- [ ] Public RPC endpoints
- [ ] Validator onboarding
- [ ] Community testing

### Phase 5: Mainnet Preparation
- [ ] Security audits
- [ ] Tokenomics finalization
- [ ] Governance activation
- [ ] Migration to production consensus

## Security Considerations

### Current (Development)

- Sudo pallet enabled (centralized control)
- Known development keys
- Single validator (or small set)
- No slashing or punishment mechanisms

### Future (Production)

- Remove sudo pallet
- Multi-signature governance
- Slashing for malicious validators
- Bug bounty program
- External security audits

## Next Steps

1. **Integrate Full Node Template**
   - Clone upstream Substrate node template
   - Apply Frontier EVM integration
   - Configure runtime pallets
   - Test build and runtime

2. **Set Up Development Environment**
   - Build node binary
   - Generate chain specs
   - Start single-node chain
   - Connect with Polkadot.js

3. **Deploy and Test Contracts**
   - Deploy HelloWorld.sol
   - Verify EVM functionality
   - Test with Hardhat and Remix
   - Document any issues

4. **Community Development**
   - Create GitHub issues for tasks
   - Accept contributions
   - Build example applications
   - Grow developer community

## Resources

- **Substrate:** https://docs.substrate.io/
- **Frontier:** https://github.com/paritytech/frontier
- **Substrate Node Template:** https://github.com/substrate-developer-hub/substrate-node-template
- **Polkadot.js:** https://polkadot.js.org/
- **Substrate Stack Exchange:** https://substrate.stackexchange.com/

## Contributing

See the main repository README for contribution guidelines. For architectural discussions, open an issue with the "architecture" label.
