#!/bin/bash

# Orion Testnet Helper Script
# Manage multi-node testnet deployment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TESTNET_DIR="${PROJECT_ROOT}/substrate-node"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Display usage information
usage() {
    cat << EOF
Orion Testnet Helper - Manage multi-node testnet deployment

Usage: $0 <command> [options]

Commands:
    start           Start the 3-validator testnet
    stop            Stop the testnet
    restart         Restart the testnet
    status          Show testnet status
    logs [node]     View logs (alice, bob, charlie, or all)
    clean           Stop and remove all data
    health          Check health of all validators
    peers           Show peer connections
    metrics         Show prometheus metrics URL
    ui              Show UI URLs
    help            Show this help message

Examples:
    $0 start                    # Start the testnet
    $0 logs alice               # View Alice's logs
    $0 status                   # Check testnet status
    $0 clean                    # Clean up everything

EOF
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Start the testnet
start_testnet() {
    print_info "Starting Orion 3-validator testnet..."
    
    cd "${TESTNET_DIR}"
    
    if docker-compose -f docker-compose.testnet.yml ps | grep -q "^.*Up"; then
        print_warning "Testnet is already running"
        print_info "Use '$0 restart' to restart or '$0 stop' to stop first"
        return 0
    fi
    
    print_info "Building images and starting containers..."
    docker-compose -f docker-compose.testnet.yml up -d
    
    print_info "Waiting for validators to start..."
    sleep 10
    
    print_success "Testnet started!"
    echo ""
    print_info "Validator RPC endpoints:"
    echo "  Alice:   http://localhost:9933 (ws://localhost:9944)"
    echo "  Bob:     http://localhost:9934 (ws://localhost:9945)"
    echo "  Charlie: http://localhost:9935 (ws://localhost:9946)"
    echo ""
    print_info "UI and Monitoring:"
    echo "  Polkadot.js Apps: http://localhost:3000"
    echo "  Prometheus:       http://localhost:9090"
    echo "  Grafana:          http://localhost:3001 (admin/admin)"
    echo ""
    print_info "Check status with: $0 status"
    print_info "View logs with: $0 logs [alice|bob|charlie|all]"
}

# Stop the testnet
stop_testnet() {
    print_info "Stopping Orion testnet..."
    
    cd "${TESTNET_DIR}"
    docker-compose -f docker-compose.testnet.yml stop
    
    print_success "Testnet stopped"
}

# Restart the testnet
restart_testnet() {
    print_info "Restarting Orion testnet..."
    
    stop_testnet
    sleep 3
    start_testnet
}

# Show testnet status
show_status() {
    print_info "Orion Testnet Status"
    echo ""
    
    cd "${TESTNET_DIR}"
    docker-compose -f docker-compose.testnet.yml ps
}

# View logs
view_logs() {
    local node="${1:-all}"
    
    cd "${TESTNET_DIR}"
    
    case "$node" in
        alice)
            docker-compose -f docker-compose.testnet.yml logs -f validator-alice
            ;;
        bob)
            docker-compose -f docker-compose.testnet.yml logs -f validator-bob
            ;;
        charlie)
            docker-compose -f docker-compose.testnet.yml logs -f validator-charlie
            ;;
        all)
            docker-compose -f docker-compose.testnet.yml logs -f validator-alice validator-bob validator-charlie
            ;;
        *)
            print_error "Unknown node: $node"
            print_info "Valid options: alice, bob, charlie, all"
            exit 1
            ;;
    esac
}

# Clean up testnet
clean_testnet() {
    print_warning "This will stop the testnet and remove all data"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_info "Cancelled"
        return 0
    fi
    
    print_info "Stopping and removing containers..."
    
    cd "${TESTNET_DIR}"
    docker-compose -f docker-compose.testnet.yml down -v
    
    print_success "Testnet cleaned up"
}

# Check health of validators
check_health() {
    print_info "Checking validator health..."
    echo ""
    
    local validators=("Alice:9933" "Bob:9934" "Charlie:9935")
    
    for validator in "${validators[@]}"; do
        local name="${validator%%:*}"
        local port="${validator##*:}"
        
        if curl --max-time 5 -s -f "http://localhost:${port}/health" > /dev/null 2>&1; then
            print_success "$name is healthy"
        else
            print_error "$name is not responding"
        fi
    done
}

# Show peer connections
show_peers() {
    print_info "Fetching peer information..."
    echo ""
    
    print_info "Alice's peers:"
    curl -s -H "Content-Type: application/json" \
         -d '{"id":1, "jsonrpc":"2.0", "method":"system_peers"}' \
         http://localhost:9933 | jq -r '.result | length' | \
         xargs -I {} echo "  Connected to {} peers"
    
    print_info "Bob's peers:"
    curl -s -H "Content-Type: application/json" \
         -d '{"id":1, "jsonrpc":"2.0", "method":"system_peers"}' \
         http://localhost:9934 | jq -r '.result | length' | \
         xargs -I {} echo "  Connected to {} peers"
    
    print_info "Charlie's peers:"
    curl -s -H "Content-Type: application/json" \
         -d '{"id":1, "jsonrpc":"2.0", "method":"system_peers"}' \
         http://localhost:9935 | jq -r '.result | length' | \
         xargs -I {} echo "  Connected to {} peers"
}

# Show metrics URL
show_metrics() {
    echo ""
    print_info "Prometheus Metrics:"
    echo "  Alice:   http://localhost:9615/metrics"
    echo "  Bob:     http://localhost:9616/metrics"
    echo "  Charlie: http://localhost:9617/metrics"
    echo ""
    print_info "Prometheus Dashboard: http://localhost:9090"
    print_info "Grafana Dashboard:    http://localhost:3001"
}

# Show UI URLs
show_ui() {
    echo ""
    print_info "Web Interfaces:"
    echo "  Polkadot.js Apps: http://localhost:3000"
    echo "  Grafana:          http://localhost:3001 (admin/admin)"
    echo "  Prometheus:       http://localhost:9090"
    echo ""
    print_info "RPC Endpoints:"
    echo "  Alice:   http://localhost:9933 (ws://localhost:9944)"
    echo "  Bob:     http://localhost:9934 (ws://localhost:9945)"
    echo "  Charlie: http://localhost:9935 (ws://localhost:9946)"
}

# Main script logic
main() {
    check_docker
    
    case "${1:-help}" in
        start)
            start_testnet
            ;;
        stop)
            stop_testnet
            ;;
        restart)
            restart_testnet
            ;;
        status)
            show_status
            ;;
        logs)
            view_logs "${2:-all}"
            ;;
        clean)
            clean_testnet
            ;;
        health)
            check_health
            ;;
        peers)
            show_peers
            ;;
        metrics)
            show_metrics
            ;;
        ui)
            show_ui
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            usage
            exit 1
            ;;
    esac
}

main "$@"
