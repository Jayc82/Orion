#!/usr/bin/env bash
# Generate Chain Specification Files
#
# This script generates chain spec JSON files for the Orion node.
# It should be run after the node binary is built.
#
# Usage: ./scripts/generate-specs.sh [spec-name]
#
# Example:
#   ./scripts/generate-specs.sh dev
#   ./scripts/generate-specs.sh local
#
# Output:
#   specs/<name>-spec.json       - Plain chain spec (human-readable)
#   specs/<name>-spec-raw.json   - Raw chain spec (for node startup)

set -e

# Configuration
NODE_BINARY="substrate-node/target/release/orion-node"
SPEC_DIR="specs"
SPEC_NAME="${1:-dev}"  # Default to 'dev' if not provided

echo "==================================================================="
echo "  Orion Chain Spec Generator"
echo "==================================================================="
echo ""

# Check if node binary exists
if [ ! -f "$NODE_BINARY" ]; then
    echo "Error: Node binary not found at $NODE_BINARY"
    echo ""
    echo "Please build the node first:"
    echo "  cd substrate-node"
    echo "  cargo build --release"
    echo ""
    echo "Note: Current stub implementation doesn't generate specs."
    echo "This script will work once the full Substrate node is integrated."
    exit 1
fi

# Create specs directory
mkdir -p "$SPEC_DIR"

echo "Generating chain spec for: $SPEC_NAME"
echo ""

# Generate plain chain spec
echo "[1/2] Generating plain chain spec..."
# TODO: Uncomment when full node is available
# $NODE_BINARY build-spec --chain="$SPEC_NAME" > "$SPEC_DIR/${SPEC_NAME}-spec.json"
echo "  Command: $NODE_BINARY build-spec --chain=$SPEC_NAME > $SPEC_DIR/${SPEC_NAME}-spec.json"
echo "  (Skipped: stub node doesn't support build-spec yet)"
echo ""

# Generate raw chain spec
echo "[2/2] Generating raw chain spec..."
# TODO: Uncomment when full node is available
# $NODE_BINARY build-spec --chain="$SPEC_DIR/${SPEC_NAME}-spec.json" --raw > "$SPEC_DIR/${SPEC_NAME}-spec-raw.json"
echo "  Command: $NODE_BINARY build-spec --chain=$SPEC_DIR/${SPEC_NAME}-spec.json --raw > $SPEC_DIR/${SPEC_NAME}-spec-raw.json"
echo "  (Skipped: stub node doesn't support build-spec yet)"
echo ""

echo "==================================================================="
echo "  Chain Spec Generation (Stub)"
echo "==================================================================="
echo ""
echo "When the full node is built, this script will generate:"
echo "  - $SPEC_DIR/${SPEC_NAME}-spec.json"
echo "  - $SPEC_DIR/${SPEC_NAME}-spec-raw.json"
echo ""
echo "The chain spec will include:"
echo "  - Runtime: OrionRuntime"
echo "  - Token: ORN (18 decimals)"
echo "  - Chain ID: 1337 (EVM)"
echo "  - Consensus: Aura + Grandpa"
echo "  - Initial validators/authorities"
echo ""
echo "To use a custom chain spec:"
echo "  ./target/release/orion-node --chain=$SPEC_DIR/${SPEC_NAME}-spec-raw.json"
echo ""
