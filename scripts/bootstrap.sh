#!/usr/bin/env bash
# Orion Substrate + EVM Bootstrap Script
#
# This script provides guidance for integrating the Frontier template
# into the Orion blockchain project.
#
# Usage: ./scripts/bootstrap.sh
#
# Prerequisites:
#   - Rust toolchain (stable)
#   - Git
#   - Build essentials (gcc, make, etc.)
#
# For detailed step-by-step instructions, see: docs/FRONTIER_INTEGRATION.md

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "==================================================================="
echo "  Orion Substrate + EVM Bootstrap"
echo "==================================================================="
echo ""

echo -e "${BLUE}RECOMMENDED APPROACH:${NC}"
echo "Use the official Frontier template for a production-ready implementation."
echo ""
echo "See the complete guide at: ${GREEN}docs/FRONTIER_INTEGRATION.md${NC}"
echo ""
echo "Quick summary:"
echo "  1. Clone Frontier template: git clone --branch polkadot-v1.7.0 https://github.com/paritytech/frontier.git"
echo "  2. Copy template files: cp -r frontier/template/* substrate-node/"
echo "  3. Customize for Orion (ORN token, chain ID 1337)"
echo "  4. Build: cargo build --release"
echo ""
echo -e "${YELLOW}==========================================================${NC}"
echo ""

# Step 1: Check prerequisites
echo -e "${GREEN}[1/6] Checking prerequisites...${NC}"

if ! command -v rustc &> /dev/null; then
    echo -e "${RED}Error: Rust is not installed.${NC}"
    echo "Please install Rust from https://rustup.rs/"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git is not installed.${NC}"
    exit 1
fi

echo "  ✓ Rust version: $(rustc --version)"
echo "  ✓ Cargo version: $(cargo --version)"
echo "  ✓ Git version: $(git --version)"
echo ""

# Step 2: Clone Substrate node template (optional, for reference)
echo -e "${GREEN}[2/6] Substrate node template...${NC}"
echo "  Note: For this initial scaffold, we use stubs."
echo "  To integrate the full template, clone from:"
echo "    git clone https://github.com/substrate-developer-hub/substrate-node-template"
echo ""
echo "  For Frontier integration, refer to:"
echo "    https://github.com/paritytech/frontier/tree/master/template"
echo ""

# Step 3: Apply Frontier/EVM configuration
echo -e "${GREEN}[3/6] Frontier/EVM integration guide...${NC}"
echo "  When ready to integrate Frontier, you'll need to:"
echo "    - Add Frontier dependencies to Cargo.toml"
echo "    - Configure EVM pallet in runtime/src/lib.rs"
echo "    - Set up Ethereum RPC in node/src/rpc.rs"
echo "    - Configure chain ID: 1337 (dev)"
echo "    - Map Substrate accounts to Ethereum addresses"
echo ""
echo "  Key pallets to integrate:"
echo "    - pallet-evm: Ethereum Virtual Machine execution"
echo "    - pallet-ethereum: Ethereum transaction format"
echo "    - pallet-base-fee: EIP-1559 dynamic fees"
echo ""

# Step 4: Build instructions
echo -e "${GREEN}[4/6] Build instructions...${NC}"
echo "  To build the node stub (current minimal version):"
echo "    cd substrate-node"
echo "    cargo build --release"
echo ""
echo "  The stub will compile quickly since it's minimal."
echo ""

# Step 5: Development chain spec
echo -e "${GREEN}[5/6] Chain specification...${NC}"
echo "  To generate a development chain spec (after full node is built):"
echo "    ./scripts/generate-specs.sh"
echo ""
echo "  This will create:"
echo "    - specs/dev-spec.json (plain chain spec)"
echo "    - specs/dev-spec-raw.json (raw chain spec for nodes)"
echo ""

# Step 6: Run the node
echo -e "${GREEN}[6/6] Running the node...${NC}"
echo "  Once the full node is built, start it with:"
echo "    cd substrate-node"
echo "    ./target/release/orion-node --dev --tmp"
echo ""
echo "  This will:"
echo "    - Start a development node with --dev flag"
echo "    - Use temporary storage (--tmp)"
echo "    - Expose RPC at http://127.0.0.1:9933"
echo "    - Expose WebSocket at ws://127.0.0.1:9944"
echo ""
echo "  Connect via:"
echo "    - Polkadot.js Apps: https://polkadot.js.org/apps/?rpc=ws://127.0.0.1:9944"
echo "    - Ethereum RPC: http://127.0.0.1:9933 (for Hardhat, MetaMask, etc.)"
echo ""

echo -e "${YELLOW}==================================================================="
echo "  Bootstrap Complete!"
echo "===================================================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Read docs/ARCHITECTURE.md for design details"
echo "  2. Read docs/RUNNING_LOCALLY.md for step-by-step guide"
echo "  3. Build the node stub: cd substrate-node && cargo build"
echo "  4. Deploy example contract: see contracts/README.md"
echo ""
echo "For issues or questions, see the repository README."
echo ""
