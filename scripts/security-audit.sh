#!/usr/bin/env bash

# Orion Security Audit Script
# Performs automated security checks on contracts, configurations, and code

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CRITICAL=0
HIGH=0
MEDIUM=0
LOW=0
INFO=0

# Output file
REPORT_FILE="${1:-security-audit-report.txt}"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Logging functions
log_critical() {
    echo -e "${RED}[CRITICAL]${NC} $1" | tee -a "$REPORT_FILE"
    ((CRITICAL++))
}

log_high() {
    echo -e "${RED}[HIGH]${NC} $1" | tee -a "$REPORT_FILE"
    ((HIGH++))
}

log_medium() {
    echo -e "${YELLOW}[MEDIUM]${NC} $1" | tee -a "$REPORT_FILE"
    ((MEDIUM++))
}

log_low() {
    echo -e "${BLUE}[LOW]${NC} $1" | tee -a "$REPORT_FILE"
    ((LOW++))
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$REPORT_FILE"
    ((INFO++))
}

log_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n" | tee -a "$REPORT_FILE"
}

# Initialize report
init_report() {
    echo "Orion Security Audit Report" > "$REPORT_FILE"
    echo "Generated: $(date)" >> "$REPORT_FILE"
    echo "========================================" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
}

# Check for Solidity compiler
check_solc() {
    log_section "Solidity Compiler Check"
    
    if command -v solc &> /dev/null; then
        local version=$(solc --version | grep Version | cut -d' ' -f2)
        log_info "Solidity compiler found: $version"
    else
        log_medium "Solidity compiler (solc) not found. Install with: npm install -g solc"
    fi
}

# Check for static analysis tools
check_analysis_tools() {
    log_section "Static Analysis Tools Check"
    
    if command -v slither &> /dev/null; then
        log_info "Slither found: $(slither --version)"
    else
        log_low "Slither not found. Install with: pip3 install slither-analyzer"
    fi
    
    if command -v myth &> /dev/null; then
        log_info "Mythril found"
    else
        log_low "Mythril not found. Install with: pip3 install mythril"
    fi
}

# Scan for private keys in codebase
check_private_keys() {
    log_section "Private Key Exposure Check"
    
    local patterns=(
        "0x[a-fA-F0-9]{64}"
        "-----BEGIN.*PRIVATE KEY-----"
        "aws_secret_access_key"
    )
    
    local found=0
    for pattern in "${patterns[@]}"; do
        local matches=$(grep -r -E "$pattern" "$ROOT_DIR" \
            --exclude-dir={node_modules,.git,target,substrate-node.backup} \
            --exclude="*.{lock,md}" 2>/dev/null || true)
        
        if [ -n "$matches" ]; then
            log_critical "Potential private key/secret found: $pattern"
            echo "$matches" | head -5 >> "$REPORT_FILE"
            ((found++))
        fi
    done
    
    if [ $found -eq 0 ]; then
        log_info "No obvious private key exposures found"
    fi
}

# Check for insecure patterns in Solidity
check_solidity_patterns() {
    log_section "Solidity Security Patterns Check"
    
    local contracts_dir="$ROOT_DIR/contracts"
    
    if [ ! -d "$contracts_dir" ]; then
        log_info "No contracts directory found"
        return
    fi
    
    # Check for tx.origin usage
    if grep -r "tx.origin" "$contracts_dir" --include="*.sol" 2>/dev/null; then
        log_high "tx.origin usage found (use msg.sender instead)"
    fi
    
    # Check for unchecked external calls
    if grep -r "\.call{" "$contracts_dir" --include="*.sol" 2>/dev/null | grep -v "require" | grep -v "//"; then
        log_medium "Unchecked external call found (check return value)"
    fi
    
    # Check for delegatecall
    if grep -r "delegatecall" "$contracts_dir" --include="*.sol" 2>/dev/null; then
        log_medium "delegatecall found (ensure proper access control)"
    fi
    
    # Check for selfdestruct
    if grep -r "selfdestruct" "$contracts_dir" --include="*.sol" 2>/dev/null; then
        log_high "selfdestruct found (can lead to locked funds)"
    fi
    
    # Check for timestamp dependence
    if grep -r "block.timestamp" "$contracts_dir" --include="*.sol" 2>/dev/null | wc -l | grep -v "^0$" > /dev/null; then
        log_low "block.timestamp usage found (can be manipulated by miners)"
    fi
    
    log_info "Solidity pattern check complete"
}

# Run Slither if available
run_slither() {
    log_section "Slither Static Analysis"
    
    if ! command -v slither &> /dev/null; then
        log_info "Slither not installed, skipping"
        return
    fi
    
    local contracts_dir="$ROOT_DIR/contracts"
    if [ ! -d "$contracts_dir" ]; then
        log_info "No contracts directory found"
        return
    fi
    
    cd "$contracts_dir"
    for contract in *.sol; do
        if [ -f "$contract" ]; then
            echo "Analyzing $contract..." | tee -a "$REPORT_FILE"
            slither "$contract" 2>&1 | head -50 >> "$REPORT_FILE" || true
        fi
    done
    cd - > /dev/null
}

# Check Docker configurations
check_docker_security() {
    log_section "Docker Security Check"
    
    # Check for privileged containers
    if grep -r "privileged: true" "$ROOT_DIR" --include="docker-compose*.yml" 2>/dev/null; then
        log_high "Privileged Docker container found"
    fi
    
    # Check for exposed ports
    if grep -E "0\.0\.0\.0:[0-9]+" "$ROOT_DIR"/*.yml 2>/dev/null; then
        log_medium "Docker ports exposed on all interfaces (consider restricting)"
    fi
    
    # Check for default passwords
    if grep -E "password:|PASS" "$ROOT_DIR"/*.yml 2>/dev/null | grep -v "changeme" | grep -v "TODO"; then
        log_medium "Potential default password in Docker config"
    fi
    
    log_info "Docker security check complete"
}

# Check dependency vulnerabilities
check_dependencies() {
    log_section "Dependency Vulnerability Check"
    
    # NPM audit if package.json exists
    if [ -f "$ROOT_DIR/package.json" ]; then
        log_info "Running npm audit..."
        cd "$ROOT_DIR"
        npm audit --audit-level=moderate >> "$REPORT_FILE" 2>&1 || log_medium "NPM vulnerabilities found"
        cd - > /dev/null
    fi
    
    # Cargo audit if Cargo.toml exists
    if command -v cargo-audit &> /dev/null && [ -f "$ROOT_DIR/substrate-node/Cargo.toml" ]; then
        log_info "Running cargo audit..."
        cd "$ROOT_DIR/substrate-node"
        cargo audit >> "$REPORT_FILE" 2>&1 || log_medium "Rust dependencies have vulnerabilities"
        cd - > /dev/null
    fi
}

# Check file permissions
check_permissions() {
    log_section "File Permissions Check"
    
    # Check for world-writable files
    local writable=$(find "$ROOT_DIR" -type f -perm -002 2>/dev/null | grep -v ".git" || true)
    if [ -n "$writable" ]; then
        log_medium "World-writable files found:"
        echo "$writable" >> "$REPORT_FILE"
    fi
    
    # Check for executable configs
    local exec_configs=$(find "$ROOT_DIR" -type f \( -name "*.yml" -o -name "*.yaml" -o -name "*.json" \) -executable 2>/dev/null || true)
    if [ -n "$exec_configs" ]; then
        log_low "Executable configuration files found (may not be intentional)"
        echo "$exec_configs" >> "$REPORT_FILE"
    fi
    
    log_info "Permission check complete"
}

# Check for security headers in configs
check_security_headers() {
    log_section "Security Headers Check"
    
    local nginx_configs=$(find "$ROOT_DIR" -name "nginx*.conf" 2>/dev/null || true)
    
    if [ -z "$nginx_configs" ]; then
        log_info "No Nginx configurations found"
        return
    fi
    
    for config in $nginx_configs; do
        if ! grep -q "Strict-Transport-Security" "$config"; then
            log_medium "Missing HSTS header in $config"
        fi
        if ! grep -q "X-Frame-Options" "$config"; then
            log_medium "Missing X-Frame-Options header in $config"
        fi
        if ! grep -q "X-Content-Type-Options" "$config"; then
            log_medium "Missing X-Content-Type-Options header in $config"
        fi
    done
}

# Generate summary
generate_summary() {
    log_section "Audit Summary"
    
    local total=$((CRITICAL + HIGH + MEDIUM + LOW + INFO))
    
    echo "" | tee -a "$REPORT_FILE"
    echo "Total Issues Found: $total" | tee -a "$REPORT_FILE"
    echo "  Critical: $CRITICAL" | tee -a "$REPORT_FILE"
    echo "  High:     $HIGH" | tee -a "$REPORT_FILE"
    echo "  Medium:   $MEDIUM" | tee -a "$REPORT_FILE"
    echo "  Low:      $LOW" | tee -a "$REPORT_FILE"
    echo "  Info:     $INFO" | tee -a "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"
    
    if [ $CRITICAL -gt 0 ]; then
        echo -e "${RED}CRITICAL issues found! Address immediately.${NC}" | tee -a "$REPORT_FILE"
        exit 1
    elif [ $HIGH -gt 0 ]; then
        echo -e "${YELLOW}HIGH severity issues found. Review and address.${NC}" | tee -a "$REPORT_FILE"
        exit 1
    elif [ $MEDIUM -gt 0 ]; then
        echo -e "${YELLOW}MEDIUM severity issues found. Consider addressing.${NC}" | tee -a "$REPORT_FILE"
    else
        echo -e "${GREEN}No critical or high severity issues found.${NC}" | tee -a "$REPORT_FILE"
    fi
    
    echo "" | tee -a "$REPORT_FILE"
    echo "Full report saved to: $REPORT_FILE" | tee -a "$REPORT_FILE"
}

# Main execution
main() {
    echo -e "${BLUE}Orion Security Audit${NC}"
    echo -e "${BLUE}====================${NC}\n"
    
    init_report
    check_solc
    check_analysis_tools
    check_private_keys
    check_solidity_patterns
    run_slither
    check_docker_security
    check_dependencies
    check_permissions
    check_security_headers
    generate_summary
}

# Run main
main
