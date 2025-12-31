# Frontier Template Integration Guide

This guide provides detailed step-by-step instructions for integrating the official Frontier template into the Orion project and customizing it for the ORN token and chain ID 1337.

## Why Use the Frontier Template?

Building a Substrate + Frontier node from scratch requires:
- 2000+ lines of carefully crafted runtime code
- Deep expertise in Substrate's FRAME framework
- Understanding of complex pallet configurations
- Knowledge of EVM precompile implementations
- Correct dependency version combinations

The official Frontier template provides:
- ✅ **Production-ready** code tested by Parity Technologies
- ✅ **Compatible dependencies** that are known to work together
- ✅ **Complete implementation** of all required pallets
- ✅ **Working examples** of EVM integration
- ✅ **Up-to-date** with the latest Substrate and Frontier APIs

## Prerequisites

Before starting, ensure you have:

```bash
# Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustup default stable
rustup update
rustup target add wasm32-unknown-unknown

# Build dependencies (Ubuntu/Debian)
sudo apt install -y build-essential git clang curl libssl-dev llvm libudev-dev pkg-config protobuf-compiler

# Or on macOS
brew install openssl cmake llvm protobuf
```

## Step 1: Clone the Frontier Template

Navigate to a temporary directory and clone the Frontier repository:

```bash
# Create a temporary workspace
cd /tmp
mkdir frontier-integration
cd frontier-integration

# Clone Frontier at the stable polkadot-v1.7.0 branch
git clone --depth 1 --branch polkadot-v1.7.0 https://github.com/paritytech/frontier.git

# Verify the clone was successful
ls -la frontier/template/
```

You should see:
```
frontier/template/
├── node/          # Node implementation with Ethereum RPC
├── runtime/       # Runtime with EVM pallets configured
└── Cargo.toml     # Workspace configuration
```

## Step 2: Backup Current Orion Substrate Node

Before replacing files, backup your current work:

```bash
# Navigate to your Orion repository
cd /path/to/Orion

# Backup the current substrate-node directory
cp -r substrate-node substrate-node.backup

# Or create a git stash if you have uncommitted changes
git stash push -m "Backup before Frontier template integration"
```

## Step 3: Copy Frontier Template Files

Replace the substrate-node directory with the Frontier template:

```bash
# Remove old stub files (keep docs and scripts)
rm -rf substrate-node/node substrate-node/runtime
rm substrate-node/Cargo.toml

# Copy Frontier template
cp -r /tmp/frontier-integration/frontier/template/* substrate-node/

# Verify the copy
ls -la substrate-node/
```

You should now have:
```
substrate-node/
├── Cargo.toml
├── node/
│   ├── Cargo.toml
│   ├── build.rs
│   └── src/
│       ├── benchmarking.rs
│       ├── chain_spec.rs
│       ├── cli.rs
│       ├── command.rs
│       ├── eth.rs
│       ├── main.rs
│       ├── rpc.rs
│       └── service.rs
└── runtime/
    ├── Cargo.toml
    ├── build.rs
    └── src/
        ├── lib.rs
        └── precompiles.rs
```

## Step 4: Customize for Orion

Now customize the template for the Orion blockchain.

### 4.1 Update Runtime Constants

Edit `substrate-node/runtime/src/lib.rs`:

```rust
// Find and update these constants (around line 40-60)

/// Orion native token symbol
pub const TOKEN_SYMBOL: &str = "ORN";  // Change from "UNIT" or whatever default

/// Token decimals (18 for EVM compatibility)
pub const TOKEN_DECIMALS: u8 = 18;

/// SS58 prefix for Orion
pub const SS58_PREFIX: u16 = 42;  // Keep 42 for dev, or register a unique prefix

/// EVM Chain ID for Orion development
pub const CHAIN_ID: u64 = 1337;  // Already 1337 in template, verify this

// Find the runtime version struct and update
#[sp_version::runtime_version]
pub const VERSION: RuntimeVersion = RuntimeVersion {
    spec_name: create_runtime_str!("orion"),          // Change from "frontier-template"
    impl_name: create_runtime_str!("orion"),          // Change from "frontier-template"
    authoring_version: 1,
    spec_version: 100,
    impl_version: 1,
    apis: RUNTIME_API_VERSIONS,
    transaction_version: 1,
    state_version: 1,
};
```

### 4.2 Update Chain ID in EVM Pallet Config

In the same file (`substrate-node/runtime/src/lib.rs`), find the `pallet_evm_chain_id` configuration:

```rust
// Find the Config implementation for pallet_evm_chain_id
parameter_types! {
    pub const ChainId: u64 = 1337;  // Verify this is set to 1337
}

impl pallet_evm_chain_id::Config for Runtime {
    type RuntimeEvent = RuntimeEvent;
}
```

### 4.3 Update Node Binary Name

Edit `substrate-node/node/Cargo.toml`:

```toml
[package]
name = "orion-node"                    # Change from "frontier-template-node"
version = "0.1.0"
description = "Orion Substrate Node with EVM support (Frontier)"
authors = ["Orion Contributors"]
license = "Apache-2.0"
edition = "2021"
repository = "https://github.com/Jayc82/Orion"

# ... rest of the file
```

### 4.4 Update Workspace Name

Edit `substrate-node/Cargo.toml`:

```toml
[workspace]
members = [
    "node",
    "runtime",
]

[workspace.package]
authors = ["Orion Contributors"]
edition = "2021"
repository = "https://github.com/Jayc82/Orion"
license = "Apache-2.0"

# ... rest of the file
```

### 4.5 Update Chain Spec

Edit `substrate-node/node/src/chain_spec.rs`:

```rust
// Find the chain spec functions and update names

pub fn development_config() -> Result<ChainSpec, String> {
    let wasm_binary = WASM_BINARY.ok_or_else(|| "Development wasm not available".to_string())?;

    Ok(ChainSpec::from_genesis(
        // Name
        "Orion Development",              // Change from "Frontier Development"
        // ID
        "orion_dev",                      // Change from "frontier_dev"
        ChainType::Development,
        // ... rest
    ))
}

pub fn local_testnet_config() -> Result<ChainSpec, String> {
    let wasm_binary = WASM_BINARY.ok_or_else(|| "Development wasm not available".to_string())?;

    Ok(ChainSpec::from_genesis(
        // Name
        "Orion Local Testnet",            // Change from "Frontier Local Testnet"
        // ID
        "orion_local_testnet",            // Change from "frontier_local_testnet"
        ChainType::Local,
        // ... rest
    ))
}
```

### 4.6 Update CLI Branding

Edit `substrate-node/node/src/cli.rs`:

```rust
// Find the Cli struct and update the about field

#[derive(Debug, clap::Parser)]
#[command(
    propagate_version = true,
    args_conflicts_with_subcommands = true,
    subcommand_required = true
)]
#[command(about = "Orion Node - Substrate with Frontier EVM")]  // Update this line
pub struct Cli {
    // ... rest
}
```

### 4.7 Update Node Description

Edit `substrate-node/node/src/command.rs`:

```rust
// Find the version function and update the description

pub fn run() -> sc_cli::Result<()> {
    let cli = Cli::from_args();
    
    // The version function will automatically use the values from Cargo.toml
    // Just ensure Cargo.toml was updated in step 4.3
    
    // ... rest of the function
}
```

## Step 5: Build the Orion Node

Now build the node to ensure everything works:

```bash
cd substrate-node

# First build - this will take 15-30 minutes
cargo build --release

# Expected output: target/release/orion-node
```

If the build succeeds, you'll have a fully functional Orion node at:
```
substrate-node/target/release/orion-node
```

## Step 6: Verify the Configuration

Run the node to verify it's properly configured:

```bash
./target/release/orion-node --version
```

Expected output:
```
orion-node 0.1.0-..
```

Check the chain spec:
```bash
./target/release/orion-node build-spec --chain dev > /tmp/orion-spec.json
cat /tmp/orion-spec.json | grep -E '"name"|"id"|"chainType"'
```

Expected output should show:
```json
  "name": "Orion Development",
  "id": "orion_dev",
  "chainType": "Development"
```

## Step 7: Run the Development Node

Start the node in development mode:

```bash
./target/release/orion-node --dev --tmp
```

You should see output like:
```
2024-12-31 12:00:00 Orion Node
2024-12-31 12:00:00 ✨  version 0.1.0-...
2024-12-31 12:00:00 ❤️   by Orion Contributors
2024-12-31 12:00:00 📋 Chain specification: Orion Development
2024-12-31 12:00:00 🏷  Node name: ...
2024-12-31 12:00:00 👤 Role: AUTHORITY
2024-12-31 12:00:00 💾 Database: RocksDb at /tmp/.../chains/orion_dev/db/full
2024-12-31 12:00:00 🔨 Initializing Genesis block/state
...
2024-12-31 12:00:06 🎁 Prepared block for proposing at 1
2024-12-31 12:00:06 ✨ Imported #1
```

## Step 8: Test EVM Functionality

Connect to the node and test EVM functionality:

### 8.1 Using Polkadot.js Apps

1. Open https://polkadot.js.org/apps/
2. Click on the network dropdown (top-left)
3. Select "Development" → "Local Node" (ws://127.0.0.1:9944)
4. Verify connection shows "Orion Development"

### 8.2 Using MetaMask

1. Open MetaMask
2. Add network:
   - **Network Name:** Orion Local
   - **RPC URL:** http://127.0.0.1:9933
   - **Chain ID:** 1337
   - **Currency Symbol:** ORN
3. Import a development account (Alice's EVM address)

### 8.3 Deploy HelloWorld Contract

Use the HelloWorld.sol contract from `contracts/` directory:

```bash
# Install Hardhat in a test directory
cd /tmp/orion-test
npm install --save-dev hardhat

# Configure Hardhat for Orion
cat > hardhat.config.js << 'EOF'
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.19",
  networks: {
    orion: {
      url: "http://127.0.0.1:9933",
      chainId: 1337,
      accounts: ["0x<alice_private_key>"]  // Use Alice's dev key
    }
  }
};
EOF

# Copy HelloWorld.sol
cp /path/to/Orion/contracts/HelloWorld.sol contracts/

# Compile
npx hardhat compile

# Deploy
npx hardhat run scripts/deploy.js --network orion
```

If the contract deploys successfully, your Orion node with EVM is working! 🎉

## Step 9: Update Orion Documentation

Update the Orion documentation to reflect the Frontier template integration:

### 9.1 Update RUNNING_LOCALLY.md

Edit `docs/RUNNING_LOCALLY.md` and update the build instructions:

```markdown
## Building the Node

The Orion node is based on the Frontier template with customizations:

```bash
cd substrate-node
cargo build --release
```

The first build takes 15-30 minutes. Subsequent builds are incremental.
```

### 9.2 Update ARCHITECTURE.md

Edit `docs/ARCHITECTURE.md` and add a section about the Frontier template:

```markdown
## Implementation

The Orion runtime is based on the official Frontier template (polkadot-v1.7.0) with the following customizations:

- **Token Symbol:** ORN (18 decimals)
- **Chain ID:** 1337 (development)
- **Runtime Name:** orion
- **SS58 Prefix:** 42 (generic Substrate for development)

The template provides production-ready implementations of:
- Substrate FRAME pallets (System, Balances, Timestamp, Transaction Payment)
- Consensus pallets (Aura for block production, Grandpa for finality)
- EVM pallets (pallet-evm, pallet-ethereum, pallet-base-fee)
- Ethereum JSON-RPC compatibility (fc-rpc)
```

## Step 10: Update Scripts

Update the bootstrap script to reflect the new reality:

Edit `scripts/bootstrap.sh`:

```bash
# Update the message
echo "The Orion node is based on the Frontier template."
echo "To rebuild or modify:"
echo "  cd substrate-node"
echo "  cargo build --release"
echo ""
echo "To run:"
echo "  ./target/release/orion-node --dev --tmp"
```

## Troubleshooting

### Build Errors

**Issue:** Linker errors during build
```
Solution: Install build dependencies
sudo apt install -y build-essential clang
```

**Issue:** WASM builder errors
```
Solution: Add wasm32 target
rustup target add wasm32-unknown-unknown
```

**Issue:** Git dependency fetch errors
```
Solution: Clear cargo cache and retry
rm -rf ~/.cargo/registry
rm -rf ~/.cargo/git
cargo build --release
```

### Runtime Errors

**Issue:** Node fails to start
```
Solution: Purge the database
./target/release/orion-node purge-chain --dev -y
```

**Issue:** Cannot connect with Polkadot.js
```
Solution: Check RPC is exposed
./target/release/orion-node --dev --tmp --rpc-external --rpc-cors all
```

### EVM Issues

**Issue:** Cannot deploy contracts
```
Solution: Verify chain ID and RPC endpoint
- Chain ID should be 1337
- RPC should be http://127.0.0.1:9933
- Check node logs for errors
```

**Issue:** Gas estimation fails
```
Solution: Specify gas manually in Hardhat
networks: {
  orion: {
    url: "http://127.0.0.1:9933",
    chainId: 1337,
    gas: 5000000,
    gasPrice: 1000000000
  }
}
```

## Additional Customizations

### Adding Custom Precompiles

To add custom EVM precompiles, edit `substrate-node/runtime/src/precompiles.rs`:

```rust
use pallet_evm_precompile_modexp::Modexp;
use pallet_evm_precompile_sha3fips::Sha3FIPS256;
use pallet_evm_precompile_simple::{ECRecover, Identity, Ripemd160, Sha256};

// Add your custom precompile here
use my_custom_precompile::MyPrecompile;

pub struct FrontierPrecompiles<R>(PhantomData<R>);

impl<R> PrecompileSet for FrontierPrecompiles<R>
where
    // ... existing code ...
{
    fn execute(&self, handle: &mut impl PrecompileHandle) -> Option<PrecompileResult> {
        match handle.code_address() {
            // Ethereum precompiles (0x01 - 0x08)
            a if a == hash(1) => Some(ECRecover::execute(handle)),
            a if a == hash(2) => Some(Sha256::execute(handle)),
            // ... existing precompiles ...
            
            // Custom Orion precompiles (0x400+)
            a if a == hash(0x400) => Some(MyPrecompile::execute(handle)),
            
            _ => None,
        }
    }
}
```

### Modifying Consensus Parameters

To change block time or other consensus parameters, edit `substrate-node/runtime/src/lib.rs`:

```rust
// Block time: 6 seconds (Aura slot duration)
parameter_types! {
    pub const MinimumPeriod: u64 = SLOT_DURATION / 2;
}

// To change to 12 seconds:
pub const SLOT_DURATION: u64 = 12000;  // milliseconds
```

### Adding New Pallets

To add additional pallets to the runtime:

1. Add dependency in `substrate-node/runtime/Cargo.toml`
2. Import the pallet in `substrate-node/runtime/src/lib.rs`
3. Configure the pallet with `impl pallet_name::Config for Runtime { ... }`
4. Add to `construct_runtime!` macro
5. Update `std` feature list if needed

## Summary

You've successfully integrated the Frontier template into Orion! Your node now has:

- ✅ Full Substrate node with Aura + Grandpa consensus
- ✅ Complete EVM support via Frontier pallets
- ✅ Ethereum JSON-RPC compatibility
- ✅ ORN token with 18 decimals
- ✅ Chain ID 1337 for development
- ✅ Production-ready code base

Next steps:
1. Test thoroughly with smart contract deployments
2. Customize precompiles if needed
3. Configure for testnet deployment
4. Set up validators and generate keys
5. Deploy to a multi-node testnet

## References

- **Frontier Template:** https://github.com/paritytech/frontier/tree/polkadot-v1.7.0/template
- **Substrate Documentation:** https://docs.substrate.io/
- **Frontier Documentation:** https://github.com/paritytech/frontier
- **Polkadot.js Apps:** https://polkadot.js.org/apps/
- **EVM Pallet:** https://github.com/paritytech/frontier/tree/master/frame/evm

For questions or issues, consult the Frontier GitHub issues or Substrate Stack Exchange.
