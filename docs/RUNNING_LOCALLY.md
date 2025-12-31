# Running Orion Locally

This guide walks you through building and running the Orion Substrate node with EVM support on your local machine.

## Prerequisites

### Required Software

1. **Rust Toolchain**
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source $HOME/.cargo/env
   
   # Install nightly (optional, for latest features)
   rustup toolchain install nightly
   rustup target add wasm32-unknown-unknown --toolchain nightly
   ```

2. **Build Dependencies**

   **Ubuntu/Debian:**
   ```bash
   sudo apt update
   sudo apt install -y build-essential git clang curl libssl-dev llvm libudev-dev pkg-config protobuf-compiler
   ```

   **macOS:**
   ```bash
   brew install openssl cmake llvm protobuf
   ```

3. **Git**
   ```bash
   # Should already be installed, but verify:
   git --version
   ```

### Hardware Requirements

**Minimum:**
- CPU: 2 cores
- RAM: 4 GB
- Storage: 10 GB free space

**Recommended:**
- CPU: 4+ cores
- RAM: 8+ GB
- Storage: 20+ GB SSD

## Quick Start (Current Stub)

The current implementation is a minimal stub to demonstrate the structure. Here's how to build and run it:

### 1. Clone Repository

```bash
git clone https://github.com/Jayc82/Orion.git
cd Orion
```

### 2. Checkout Scaffold Branch

```bash
git checkout substrate-evm-scaffold
```

### 3. Build the Node Stub

```bash
cd substrate-node
cargo build --release
```

This will compile quickly since it's a minimal stub. The binary will be at:
`target/release/orion-node`

### 4. Run the Node Stub

```bash
./target/release/orion-node
```

This will print information about the full implementation requirements.

## Full Implementation Setup

Once the full Substrate node template is integrated, follow these steps:

### 1. Run Bootstrap Script

```bash
./scripts/bootstrap.sh
```

This script will:
- Check prerequisites
- Guide you through Frontier integration
- Provide build instructions

### 2. Build the Full Node

```bash
cd substrate-node
cargo build --release
```

**Note:** The first build will take 15-30 minutes as it compiles all Substrate dependencies.

### 3. Run Development Node

Start a single-node development chain:

```bash
./target/release/orion-node --dev --tmp
```

**Flags:**
- `--dev`: Use development chain spec (Alice as validator, pre-funded accounts)
- `--tmp`: Use temporary database (cleaned on exit)

**What This Does:**
- Starts the Orion node
- Begins producing blocks
- Exposes RPC endpoints:
  - Substrate RPC: `ws://127.0.0.1:9944`
  - Ethereum JSON-RPC: `http://127.0.0.1:9933`

### 4. Verify Node is Running

You should see output like:

```
2024-12-31 12:00:00 Orion Node
2024-12-31 12:00:00 ✨  version 0.1.0-dev
2024-12-31 12:00:00 ❤️   by Orion Contributors
2024-12-31 12:00:00 📋 Chain specification: Development
2024-12-31 12:00:00 🏷  Node name: dashing-arithmetic-1234
2024-12-31 12:00:00 👤 Role: AUTHORITY
2024-12-31 12:00:00 💾 Database: RocksDb at /tmp/.../chains/dev/db/full
2024-12-31 12:00:00 🔨 Initializing Genesis block/state
2024-12-31 12:00:00 👴 Loading GRANDPA authority set from genesis
2024-12-31 12:00:01 🏷  Local node identity: 12D3KooW...
2024-12-31 12:00:01 💤 Listening on /ip4/127.0.0.1/tcp/30333
2024-12-31 12:00:01 🔍 Discovered new external address: /ip4/127.0.0.1/tcp/30333
2024-12-31 12:00:06 🙌 Starting consensus session on top of parent 0x0000...0000
2024-12-31 12:00:06 🎁 Prepared block for proposing at 1 [hash: 0x...]
2024-12-31 12:00:06 ✨ Imported #1 (0x...)
```

## Connecting to the Node

### Option 1: Polkadot.js Apps

1. Open https://polkadot.js.org/apps/
2. Click top-left corner (network selector)
3. Choose "Development" → "Local Node" (ws://127.0.0.1:9944)
4. Click "Switch"

You can now:
- View blocks and extrinsics
- Check balances
- Transfer ORN tokens
- Interact with pallets

### Option 2: Ethereum Tools (MetaMask, Hardhat)

Configure your Ethereum tools to connect to:
- **RPC URL:** http://127.0.0.1:9933
- **Chain ID:** 1337
- **Symbol:** ORN

**MetaMask Setup:**
1. Click network selector
2. "Add Network" → "Add a network manually"
3. Fill in:
   - Network Name: Orion Local
   - RPC URL: http://127.0.0.1:9933
   - Chain ID: 1337
   - Currency Symbol: ORN
4. Save

## Deploying Smart Contracts

### Using Hardhat

See `contracts/README.md` for detailed instructions.

**Quick Deploy:**

1. Install Hardhat in your project:
   ```bash
   npm install --save-dev hardhat
   ```

2. Configure network in `hardhat.config.js`:
   ```javascript
   module.exports = {
     networks: {
       orion: {
         url: "http://127.0.0.1:9933",
         chainId: 1337,
       }
     }
   };
   ```

3. Deploy:
   ```bash
   npx hardhat run scripts/deploy.js --network orion
   ```

### Using Remix

1. Open https://remix.ethereum.org/
2. Create/load your Solidity contract
3. Compile it
4. In "Deploy & Run":
   - Environment: "Web3 Provider"
   - Web3 Provider Endpoint: http://127.0.0.1:9933
5. Deploy and interact

## Generate Chain Specifications

For custom chain configurations:

```bash
./scripts/generate-specs.sh dev
```

This creates:
- `specs/dev-spec.json`: Human-readable chain spec
- `specs/dev-spec-raw.json`: Raw spec for node startup

**Use Custom Spec:**
```bash
./target/release/orion-node --chain=specs/dev-spec-raw.json --tmp
```

## Common Commands

### Start with Custom Port

```bash
./target/release/orion-node \
  --dev \
  --tmp \
  --rpc-port 9934 \
  --ws-port 9945
```

### Purge Chain Data

```bash
./target/release/orion-node purge-chain --dev
```

### Check Node Version

```bash
./target/release/orion-node --version
```

### Enable Verbose Logging

```bash
RUST_LOG=debug ./target/release/orion-node --dev --tmp
```

## Multi-Node Local Testnet

To run multiple validators locally:

### Node 1 (Alice):
```bash
./target/release/orion-node \
  --chain=local \
  --alice \
  --tmp \
  --port 30333 \
  --rpc-port 9933 \
  --ws-port 9944 \
  --node-key 0000000000000000000000000000000000000000000000000000000000000001
```

### Node 2 (Bob):
```bash
./target/release/orion-node \
  --chain=local \
  --bob \
  --tmp \
  --port 30334 \
  --rpc-port 9934 \
  --ws-port 9945 \
  --bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWEyoppNCUx8Yx66oV9fJnriXwCcXwDDUA2kj6vnc6iDEp
```

**Note:** The bootnode address comes from Node 1's startup logs.

## Troubleshooting

### Build Fails with Linker Errors

**Issue:** Missing system dependencies

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install -y build-essential clang

# macOS
xcode-select --install
```

### Node Fails to Start

**Issue:** Port already in use

**Solution:**
```bash
# Find process using port 9933
lsof -i :9933

# Kill it or use different port
./target/release/orion-node --dev --tmp --rpc-port 9934
```

### Cannot Connect with MetaMask

**Issue:** RPC not exposed or CORS issue

**Solution:**
```bash
./target/release/orion-node \
  --dev \
  --tmp \
  --rpc-external \
  --rpc-cors all
```

**Warning:** Only use `--rpc-cors all` for local development!

### Contract Deployment Fails

**Issue:** Insufficient gas or gas price too low

**Solution:** In Hardhat config, specify gas limit:
```javascript
networks: {
  orion: {
    url: "http://127.0.0.1:9933",
    chainId: 1337,
    gas: 5000000,
  }
}
```

### Slow Block Production

**Issue:** Node still initializing or syncing

**Solution:** Wait a few seconds for the first blocks to be produced. In development mode, blocks are produced only when transactions are submitted.

### Build Takes Too Long

**Issue:** Compiling all Substrate dependencies

**Solution:**
- First build takes 15-30 min (normal)
- Use `cargo build` (debug) for faster iteration during development
- Incremental builds are much faster

### Database Errors

**Issue:** Corrupted database from previous runs

**Solution:**
```bash
./target/release/orion-node purge-chain --dev -y
```

## Development Workflow

### Typical Development Cycle

1. **Make changes to runtime or node code**
2. **Rebuild:**
   ```bash
   cargo build --release
   ```
3. **Purge old chain:**
   ```bash
   ./target/release/orion-node purge-chain --dev -y
   ```
4. **Restart node:**
   ```bash
   ./target/release/orion-node --dev --tmp
   ```
5. **Test changes**

### Fast Iteration with Debug Builds

For faster compilation during development:

```bash
cargo build  # Debug build (no --release)
./target/debug/orion-node --dev --tmp
```

Debug builds are 5-10x faster to compile but run slower.

## Next Steps

1. **Deploy Example Contract**
   - See `contracts/README.md`
   - Deploy HelloWorld.sol
   - Interact via Remix or Hardhat

2. **Explore Polkadot.js Apps**
   - View chain state
   - Submit extrinsics
   - Check events

3. **Build Your dApp**
   - Use standard Ethereum tools
   - Connect to http://127.0.0.1:9933
   - Deploy your smart contracts

4. **Join the Community**
   - Report issues on GitHub
   - Contribute improvements
   - Share your projects

## Additional Resources

- **Substrate Docs:** https://docs.substrate.io/
- **Frontier GitHub:** https://github.com/paritytech/frontier
- **Polkadot.js Docs:** https://polkadot.js.org/docs/
- **Solidity Docs:** https://docs.soliditylang.org/

For questions or issues, open a GitHub issue or check the documentation.
