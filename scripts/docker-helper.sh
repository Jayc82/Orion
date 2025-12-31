#!/bin/bash
# Orion Node Docker Helper Script
# Simplifies common Docker operations for Orion node

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NODE_DIR="$PROJECT_ROOT/substrate-node"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_msg() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

print_header() {
    echo ""
    print_msg "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_msg "$BLUE" "  $1"
    print_msg "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_msg "$RED" "❌ Docker is not installed!"
        print_msg "$YELLOW" "Please install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
        print_msg "$RED" "❌ Docker Compose is not installed!"
        print_msg "$YELLOW" "Please install Docker Compose or update Docker to include compose plugin"
        exit 1
    fi
}

# Function to use docker compose or docker-compose
docker_compose_cmd() {
    if docker compose version &> /dev/null 2>&1; then
        docker compose "$@"
    else
        docker-compose "$@"
    fi
}

# Show usage
show_usage() {
    cat << EOF
Orion Node Docker Helper

Usage: $0 [COMMAND]

Commands:
    start       Build and start Orion node with Docker Compose
    stop        Stop Orion node
    restart     Restart Orion node
    logs        Show and follow Orion node logs
    status      Show running status
    clean       Stop and remove all containers and volumes (clears chain data)
    build       Build Docker image
    shell       Open shell in running container
    health      Check node health
    help        Show this help message

Examples:
    $0 start        # Start the node
    $0 logs         # View logs
    $0 stop         # Stop the node
    $0 clean        # Remove everything and start fresh

For more details, see docs/DOCKER.md
EOF
}

# Start the node
cmd_start() {
    print_header "🚀 Starting Orion Node"
    
    cd "$NODE_DIR"
    
    if docker_compose_cmd ps | grep -q "orion-node.*Up"; then
        print_msg "$YELLOW" "⚠️  Node is already running!"
        print_msg "$YELLOW" "Use '$0 restart' to restart or '$0 stop' to stop first"
        exit 0
    fi
    
    print_msg "$GREEN" "Building and starting Orion node..."
    docker_compose_cmd up -d
    
    echo ""
    print_msg "$GREEN" "✅ Orion node started successfully!"
    echo ""
    print_msg "$BLUE" "Access points:"
    print_msg "$BLUE" "  • Polkadot.js UI:  http://localhost:3000"
    print_msg "$BLUE" "  • HTTP RPC:        http://localhost:9933"
    print_msg "$BLUE" "  • WebSocket RPC:   ws://localhost:9944"
    print_msg "$BLUE" "  • Prometheus:      http://localhost:9615"
    echo ""
    print_msg "$YELLOW" "View logs with: $0 logs"
}

# Stop the node
cmd_stop() {
    print_header "⏹️  Stopping Orion Node"
    
    cd "$NODE_DIR"
    docker_compose_cmd stop
    
    print_msg "$GREEN" "✅ Node stopped"
}

# Restart the node
cmd_restart() {
    print_header "🔄 Restarting Orion Node"
    
    cd "$NODE_DIR"
    docker_compose_cmd restart
    
    print_msg "$GREEN" "✅ Node restarted"
}

# Show logs
cmd_logs() {
    print_header "📋 Orion Node Logs"
    
    cd "$NODE_DIR"
    docker_compose_cmd logs -f orion-node
}

# Show status
cmd_status() {
    print_header "📊 Orion Node Status"
    
    cd "$NODE_DIR"
    docker_compose_cmd ps
}

# Clean everything
cmd_clean() {
    print_header "🧹 Cleaning Orion Node"
    
    print_msg "$YELLOW" "⚠️  This will:"
    print_msg "$YELLOW" "   - Stop all containers"
    print_msg "$YELLOW" "   - Remove all containers"
    print_msg "$YELLOW" "   - Remove all volumes (DELETE CHAIN DATA)"
    echo ""
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_msg "$YELLOW" "Cancelled"
        exit 0
    fi
    
    cd "$NODE_DIR"
    docker_compose_cmd down -v
    
    print_msg "$GREEN" "✅ All cleaned up"
}

# Build image
cmd_build() {
    print_header "🔨 Building Orion Node Image"
    
    cd "$NODE_DIR"
    docker_compose_cmd build
    
    print_msg "$GREEN" "✅ Build complete"
}

# Open shell
cmd_shell() {
    print_header "🐚 Opening Shell in Orion Container"
    
    cd "$NODE_DIR"
    
    if ! docker_compose_cmd ps | grep -q "orion-node.*Up"; then
        print_msg "$RED" "❌ Node is not running!"
        print_msg "$YELLOW" "Start it first with: $0 start"
        exit 1
    fi
    
    docker_compose_cmd exec orion-node /bin/bash
}

# Check health
cmd_health() {
    print_header "🏥 Checking Orion Node Health"
    
    if ! curl -s http://localhost:9933 > /dev/null 2>&1; then
        print_msg "$RED" "❌ Cannot connect to RPC endpoint"
        print_msg "$YELLOW" "Is the node running? Check with: $0 status"
        exit 1
    fi
    
    # Check system health
    HEALTH=$(curl -s -H "Content-Type: application/json" \
        -d '{"id":1, "jsonrpc":"2.0", "method": "system_health"}' \
        http://localhost:9933)
    
    print_msg "$GREEN" "✅ Node is responding"
    echo ""
    echo "$HEALTH" | python3 -m json.tool 2>/dev/null || echo "$HEALTH"
    
    # Check chain name
    echo ""
    CHAIN=$(curl -s -H "Content-Type: application/json" \
        -d '{"id":1, "jsonrpc":"2.0", "method": "system_chain"}' \
        http://localhost:9933)
    
    print_msg "$BLUE" "Chain: $(echo "$CHAIN" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)"
    
    # Check EVM chain ID
    CHAIN_ID=$(curl -s -H "Content-Type: application/json" \
        -d '{"id":1, "jsonrpc":"2.0", "method": "eth_chainId"}' \
        http://localhost:9933)
    
    print_msg "$BLUE" "EVM Chain ID: $(echo "$CHAIN_ID" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)"
}

# Main script
main() {
    check_docker
    
    case "${1:-}" in
        start)
            cmd_start
            ;;
        stop)
            cmd_stop
            ;;
        restart)
            cmd_restart
            ;;
        logs)
            cmd_logs
            ;;
        status)
            cmd_status
            ;;
        clean)
            cmd_clean
            ;;
        build)
            cmd_build
            ;;
        shell)
            cmd_shell
            ;;
        health)
            cmd_health
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_msg "$RED" "❌ Unknown command: ${1:-}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
