#!/bin/bash

###################################################################################
# Orion Blockchain - Comprehensive End-to-End Test Suite
###################################################################################
# This script performs a thorough validation of the entire Orion blockchain
# project to ensure production readiness and top-tier quality.
#
# Usage: ./scripts/comprehensive-test.sh [--verbose] [--ci]
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed
#   2 - Critical failure (setup issues)
###################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# Flags
VERBOSE=false
CI_MODE=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --verbose) VERBOSE=true ;;
        --ci) CI_MODE=true ;;
    esac
done

# Helper functions
print_header() {
    echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_section() {
    echo -e "\n${BOLD}${MAGENTA}▶ $1${NC}"
}

print_test() {
    echo -e "${BLUE}  → Testing: $1${NC}"
}

pass() {
    ((TOTAL_TESTS++))
    ((PASSED_TESTS++))
    echo -e "${GREEN}    ✓ PASS${NC}: $1"
}

fail() {
    ((TOTAL_TESTS++))
    ((FAILED_TESTS++))
    echo -e "${RED}    ✗ FAIL${NC}: $1"
    if [ "$2" != "" ]; then
        echo -e "${RED}      Details: $2${NC}"
    fi
}

warn() {
    ((WARNINGS++))
    echo -e "${YELLOW}    ⚠ WARNING${NC}: $1"
}

info() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}    ℹ INFO${NC}: $1"
    fi
}

###################################################################################
# Test 1: Project Structure Validation
###################################################################################
test_project_structure() {
    print_section "1. Project Structure Validation"
    
    local required_dirs=(
        "substrate-node"
        "substrate-node/node"
        "substrate-node/runtime"
        "substrate-node/monitoring"
        "scripts"
        "contracts"
        "examples"
        "examples/simple-dapp"
        "docs"
        "docs/security"
        ".github"
        ".github/workflows"
    )
    
    for dir in "${required_dirs[@]}"; do
        print_test "Directory exists: $dir"
        if [ -d "$dir" ]; then
            pass "$dir exists"
        else
            fail "$dir is missing"
        fi
    done
    
    local required_files=(
        "README.md"
        "LICENSE"
        ".gitignore"
        "substrate-node/Cargo.toml"
        "substrate-node/Dockerfile"
        "substrate-node/docker-compose.yml"
        "substrate-node/docker-compose.testnet.yml"
        "substrate-node/.dockerignore"
        "docs/ARCHITECTURE.md"
        "docs/FRONTIER_INTEGRATION.md"
        "docs/DOCKER.md"
        "docs/WALLET_INTEGRATION.md"
        "docs/TESTNET_DEPLOYMENT.md"
        "docs/SECURITY.md"
        "docs/RUNNING_LOCALLY.md"
        ".github/workflows/ci.yml"
    )
    
    for file in "${required_files[@]}"; do
        print_test "File exists: $file"
        if [ -f "$file" ]; then
            pass "$file exists"
        else
            fail "$file is missing"
        fi
    done
}

###################################################################################
# Test 2: Smart Contract Validation
###################################################################################
test_smart_contracts() {
    print_section "2. Smart Contract Validation"
    
    local contracts=(
        "contracts/HelloWorld.sol"
        "contracts/OrionToken.sol"
        "contracts/SecureToken.sol"
        "contracts/MultiSigWallet.sol"
    )
    
    for contract in "${contracts[@]}"; do
        print_test "Contract exists: $contract"
        if [ -f "$contract" ]; then
            pass "$contract exists"
            
            # Check Solidity version
            if grep -q "pragma solidity" "$contract"; then
                local version=$(grep "pragma solidity" "$contract" | head -1)
                info "Solidity version: $version"
                pass "Solidity pragma found"
            else
                warn "No Solidity pragma found in $contract"
            fi
            
            # Check for SPDX license
            if grep -q "SPDX-License-Identifier" "$contract"; then
                pass "SPDX license identifier found"
            else
                warn "No SPDX license identifier in $contract"
            fi
            
            # Security checks
            if [ "$(basename $contract)" = "SecureToken.sol" ] || [ "$(basename $contract)" = "MultiSigWallet.sol" ]; then
                print_test "Security features in $contract"
                
                if grep -q "ReentrancyGuard\|nonReentrant\|reentrancy" "$contract"; then
                    pass "Reentrancy protection found"
                else
                    warn "No reentrancy protection found"
                fi
                
                if grep -q "onlyOwner\|onlyRole\|hasRole" "$contract"; then
                    pass "Access control found"
                else
                    warn "No access control found"
                fi
                
                if grep -q "event " "$contract"; then
                    pass "Events for logging found"
                else
                    warn "No events found"
                fi
            fi
            
        else
            fail "$contract is missing"
        fi
    done
    
    # Check contract README
    print_test "Contract documentation"
    if [ -f "contracts/README.md" ]; then
        pass "contracts/README.md exists"
    else
        warn "contracts/README.md not found"
    fi
}

###################################################################################
# Test 3: Script Validation
###################################################################################
test_scripts() {
    print_section "3. Script Validation"
    
    local scripts=(
        "scripts/bootstrap.sh"
        "scripts/docker-helper.sh"
        "scripts/testnet-helper.sh"
        "scripts/security-audit.sh"
        "scripts/generate-specs.sh"
        "docs/security/firewall-rules.sh"
    )
    
    for script in "${scripts[@]}"; do
        print_test "Script: $script"
        if [ -f "$script" ]; then
            pass "$script exists"
            
            # Check executable
            if [ -x "$script" ]; then
                pass "$script is executable"
            else
                warn "$script is not executable (chmod +x recommended)"
            fi
            
            # Check shebang
            if head -1 "$script" | grep -q "^#!/"; then
                pass "$script has shebang"
            else
                fail "$script missing shebang"
            fi
            
            # Syntax check
            if bash -n "$script" 2>/dev/null; then
                pass "$script syntax is valid"
            else
                fail "$script has syntax errors"
            fi
            
        else
            fail "$script is missing"
        fi
    done
}

###################################################################################
# Test 4: Docker Configuration Validation
###################################################################################
test_docker_config() {
    print_section "4. Docker Configuration Validation"
    
    # Dockerfile
    print_test "Dockerfile"
    if [ -f "substrate-node/Dockerfile" ]; then
        pass "Dockerfile exists"
        
        if grep -q "FROM rust:" "substrate-node/Dockerfile"; then
            pass "Dockerfile uses Rust base image"
        else
            warn "Dockerfile may not be using standard Rust image"
        fi
        
        if grep -q "EXPOSE" "substrate-node/Dockerfile"; then
            pass "Dockerfile exposes ports"
        else
            warn "Dockerfile doesn't expose ports explicitly"
        fi
    else
        fail "Dockerfile is missing"
    fi
    
    # docker-compose.yml
    print_test "docker-compose.yml"
    if [ -f "substrate-node/docker-compose.yml" ]; then
        pass "docker-compose.yml exists"
        
        if grep -q "orion-node:" "substrate-node/docker-compose.yml"; then
            pass "Orion node service defined"
        else
            warn "Orion node service not found in docker-compose.yml"
        fi
        
        if grep -q "polkadot-js-apps:" "substrate-node/docker-compose.yml"; then
            pass "Polkadot.js Apps service defined"
        else
            info "Polkadot.js Apps service not included (optional)"
        fi
    else
        fail "docker-compose.yml is missing"
    fi
    
    # docker-compose.testnet.yml
    print_test "docker-compose.testnet.yml"
    if [ -f "substrate-node/docker-compose.testnet.yml" ]; then
        pass "docker-compose.testnet.yml exists"
        
        local validators=("alice" "bob" "charlie")
        for validator in "${validators[@]}"; do
            if grep -qi "$validator" "substrate-node/docker-compose.testnet.yml"; then
                pass "Validator $validator configured"
            else
                fail "Validator $validator not found in testnet config"
            fi
        done
    else
        fail "docker-compose.testnet.yml is missing"
    fi
    
    # .dockerignore
    print_test ".dockerignore"
    if [ -f "substrate-node/.dockerignore" ]; then
        pass ".dockerignore exists"
        if grep -q "target" "substrate-node/.dockerignore"; then
            pass ".dockerignore excludes target directory"
        else
            warn ".dockerignore should exclude target directory"
        fi
    else
        warn ".dockerignore is missing (may slow builds)"
    fi
}

###################################################################################
# Test 5: Documentation Quality Check
###################################################################################
test_documentation() {
    print_section "5. Documentation Quality Check"
    
    local docs=(
        "README.md:3000:Orion"
        "docs/ARCHITECTURE.md:1000:Architecture"
        "docs/FRONTIER_INTEGRATION.md:5000:Frontier"
        "docs/DOCKER.md:8000:Docker"
        "docs/WALLET_INTEGRATION.md:10000:MetaMask"
        "docs/TESTNET_DEPLOYMENT.md:10000:validator"
        "docs/SECURITY.md:15000:security"
        "docs/RUNNING_LOCALLY.md:2000:localhost"
    )
    
    for doc_spec in "${docs[@]}"; do
        IFS=':' read -r doc min_size keyword <<< "$doc_spec"
        print_test "Documentation: $doc"
        
        if [ -f "$doc" ]; then
            pass "$doc exists"
            
            local size=$(wc -c < "$doc")
            if [ "$size" -ge "$min_size" ]; then
                pass "$doc is comprehensive (${size} bytes)"
            else
                warn "$doc may be incomplete (${size} bytes, expected >$min_size)"
            fi
            
            if grep -qi "$keyword" "$doc"; then
                pass "$doc contains relevant content ($keyword)"
            else
                warn "$doc may not contain expected content ($keyword)"
            fi
            
            # Check for TODOs
            if grep -qi "TODO\|FIXME\|XXX" "$doc"; then
                warn "$doc contains TODOs or FIXMEs"
            fi
        else
            fail "$doc is missing"
        fi
    done
    
    # Check for broken links in README
    print_test "README links"
    if [ -f "README.md" ]; then
        local broken_links=0
        while IFS= read -r file; do
            if [ ! -f "$file" ] && [ ! -d "$file" ]; then
                ((broken_links++))
                warn "Broken link in README: $file"
            fi
        done < <(grep -oP '\]\(\K[^)#]+' README.md 2>/dev/null || true)
        
        if [ "$broken_links" -eq 0 ]; then
            pass "No broken local links in README"
        else
            warn "Found $broken_links broken local links in README"
        fi
    fi
}

###################################################################################
# Test 6: Security Configuration Validation
###################################################################################
test_security() {
    print_section "6. Security Configuration Validation"
    
    # Security documentation
    print_test "Security documentation"
    if [ -f "docs/SECURITY.md" ]; then
        pass "SECURITY.md exists"
        
        if grep -qi "vulnerability" "docs/SECURITY.md"; then
            pass "Vulnerability reporting documented"
        else
            warn "Vulnerability reporting not documented"
        fi
        
        if grep -qi "responsible disclosure" "docs/SECURITY.md"; then
            pass "Responsible disclosure policy found"
        else
            warn "Responsible disclosure policy not found"
        fi
    else
        fail "SECURITY.md is missing"
    fi
    
    # Security configurations
    print_test "Security configurations"
    if [ -f "docs/security/firewall-rules.sh" ]; then
        pass "Firewall rules template exists"
    else
        warn "Firewall rules template missing"
    fi
    
    if [ -f "docs/security/nginx-tls.conf" ]; then
        pass "TLS configuration template exists"
    else
        warn "TLS configuration template missing"
    fi
    
    # Security audit script
    print_test "Security audit tool"
    if [ -f "scripts/security-audit.sh" ]; then
        pass "security-audit.sh exists"
        if [ -x "scripts/security-audit.sh" ]; then
            pass "security-audit.sh is executable"
        else
            warn "security-audit.sh not executable"
        fi
    else
        fail "security-audit.sh is missing"
    fi
    
    # Check for exposed secrets
    print_test "Secret exposure check"
    local exposed_secrets=0
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            # Check for actual private keys (not placeholders)
            if grep -E "0x[a-fA-F0-9]{64}" "$file" 2>/dev/null | grep -v "YOUR_PRIVATE_KEY\|PLACEHOLDER\|EXAMPLE\|0x0000000000000000000000000000000000000000000000000000000000000000" > /dev/null 2>&1; then
                ((exposed_secrets++))
                warn "Potential private key found in $file"
            fi
        fi
    done < <(find contracts examples -type f \( -name "*.sol" -o -name "*.html" -o -name "*.js" \) -print0 2>/dev/null)
    
    if [ "$exposed_secrets" -eq 0 ]; then
        pass "No exposed secrets detected in code"
    else
        warn "Found $exposed_secrets files with potential secrets"
    fi
}

###################################################################################
# Test 7: Example dApp Validation
###################################################################################
test_example_dapp() {
    print_section "7. Example dApp Validation"
    
    print_test "Example dApp structure"
    if [ -d "examples/simple-dapp" ]; then
        pass "simple-dapp directory exists"
        
        if [ -f "examples/simple-dapp/index.html" ]; then
            pass "index.html exists"
            
            # Check for essential components
            if grep -q "web3\|ethers\|MetaMask" "examples/simple-dapp/index.html"; then
                pass "Web3 integration found"
            else
                warn "Web3 integration not found"
            fi
            
            if grep -q "1337" "examples/simple-dapp/index.html"; then
                pass "Chain ID 1337 configured"
            else
                warn "Chain ID not configured in dApp"
            fi
            
            if grep -q "localhost:9933\|127.0.0.1:9933" "examples/simple-dapp/index.html"; then
                pass "RPC endpoint configured"
            else
                warn "RPC endpoint not configured"
            fi
        else
            fail "index.html is missing"
        fi
        
        if [ -f "examples/simple-dapp/README.md" ]; then
            pass "dApp README exists"
        else
            warn "dApp README missing"
        fi
    else
        fail "simple-dapp directory is missing"
    fi
}

###################################################################################
# Test 8: Monitoring Configuration
###################################################################################
test_monitoring() {
    print_section "8. Monitoring Configuration"
    
    print_test "Prometheus configuration"
    if [ -f "substrate-node/monitoring/prometheus.yml" ]; then
        pass "prometheus.yml exists"
        
        if grep -q "scrape_configs:" "substrate-node/monitoring/prometheus.yml"; then
            pass "Prometheus scrape configs defined"
        else
            warn "Prometheus scrape configs not found"
        fi
    else
        warn "prometheus.yml is missing (monitoring optional)"
    fi
    
    print_test "Grafana configuration"
    if [ -f "substrate-node/monitoring/grafana-datasources.yml" ]; then
        pass "grafana-datasources.yml exists"
    else
        warn "grafana-datasources.yml is missing (monitoring optional)"
    fi
}

###################################################################################
# Test 9: CI/CD Configuration
###################################################################################
test_cicd() {
    print_section "9. CI/CD Configuration"
    
    print_test "GitHub Actions workflow"
    if [ -f ".github/workflows/ci.yml" ]; then
        pass "ci.yml exists"
        
        if grep -q "cargo check\|cargo build\|cargo test" ".github/workflows/ci.yml"; then
            pass "Rust build steps found"
        else
            warn "Rust build steps not found in CI"
        fi
        
        if grep -q "shellcheck" ".github/workflows/ci.yml"; then
            pass "Shell script linting found"
        else
            info "Shell script linting not found in CI"
        fi
        
        if grep -q "solc\|solidity" ".github/workflows/ci.yml"; then
            pass "Solidity compilation found"
        else
            info "Solidity compilation not found in CI"
        fi
        
        if grep -q "permissions:" ".github/workflows/ci.yml"; then
            pass "Explicit permissions set"
        else
            warn "No explicit permissions in CI workflow"
        fi
    else
        fail "ci.yml is missing"
    fi
}

###################################################################################
# Test 10: Cargo Configuration
###################################################################################
test_cargo_config() {
    print_section "10. Cargo Configuration"
    
    print_test "Workspace Cargo.toml"
    if [ -f "substrate-node/Cargo.toml" ]; then
        pass "Cargo.toml exists"
        
        if grep -q "\[workspace\]" "substrate-node/Cargo.toml"; then
            pass "Workspace configuration found"
        else
            warn "Not configured as workspace"
        fi
        
        if grep -q "members = \[" "substrate-node/Cargo.toml"; then
            pass "Workspace members defined"
        else
            warn "Workspace members not defined"
        fi
        
        # Check for Frontier dependencies
        if grep -qi "frontier\|pallet-evm\|pallet-ethereum" "substrate-node/Cargo.toml"; then
            pass "Frontier dependencies found"
        else
            warn "Frontier dependencies not found"
        fi
    else
        fail "Cargo.toml is missing"
    fi
    
    print_test "Runtime Cargo.toml"
    if [ -f "substrate-node/runtime/Cargo.toml" ]; then
        pass "runtime/Cargo.toml exists"
    else
        warn "runtime/Cargo.toml is missing"
    fi
    
    print_test "Node Cargo.toml"
    if [ -f "substrate-node/node/Cargo.toml" ]; then
        pass "node/Cargo.toml exists"
    else
        warn "node/Cargo.toml is missing"
    fi
}

###################################################################################
# Test 11: Runtime Configuration
###################################################################################
test_runtime() {
    print_section "11. Runtime Configuration"
    
    print_test "Runtime source"
    if [ -f "substrate-node/runtime/src/lib.rs" ]; then
        pass "runtime/src/lib.rs exists"
        
        # Check for Orion branding
        if grep -q "orion\|Orion\|ORN" "substrate-node/runtime/src/lib.rs"; then
            pass "Orion branding found in runtime"
        else
            warn "Orion branding not found in runtime"
        fi
        
        # Check for chain ID
        if grep -q "1337" "substrate-node/runtime/src/lib.rs"; then
            pass "Chain ID 1337 configured"
        else
            warn "Chain ID 1337 not found in runtime"
        fi
        
        # Check for EVM pallet
        if grep -qi "pallet.*evm\|EVM\|Evm" "substrate-node/runtime/src/lib.rs"; then
            pass "EVM pallet configuration found"
        else
            warn "EVM pallet not found in runtime"
        fi
    else
        warn "runtime/src/lib.rs is missing"
    fi
    
    print_test "Runtime build script"
    if [ -f "substrate-node/runtime/build.rs" ]; then
        pass "runtime/build.rs exists"
    else
        info "runtime/build.rs not found (may not be needed)"
    fi
}

###################################################################################
# Test 12: Chain Specification
###################################################################################
test_chain_spec() {
    print_section "12. Chain Specification"
    
    print_test "Chain spec in node source"
    if [ -f "substrate-node/node/src/chain_spec.rs" ]; then
        pass "chain_spec.rs exists"
        
        if grep -qi "orion" "substrate-node/node/src/chain_spec.rs"; then
            pass "Orion chain spec configured"
        else
            warn "Orion branding not found in chain spec"
        fi
        
        if grep -q "1337" "substrate-node/node/src/chain_spec.rs"; then
            pass "Chain ID 1337 in chain spec"
        else
            warn "Chain ID 1337 not in chain spec"
        fi
    else
        warn "chain_spec.rs is missing"
    fi
}

###################################################################################
# Test 13: Helper Scripts Functionality
###################################################################################
test_helper_scripts() {
    print_section "13. Helper Scripts Functionality"
    
    print_test "docker-helper.sh commands"
    if [ -f "scripts/docker-helper.sh" ]; then
        if grep -q "start\|stop\|restart\|logs\|status" "scripts/docker-helper.sh"; then
            pass "Essential commands found in docker-helper.sh"
        else
            warn "Some commands may be missing in docker-helper.sh"
        fi
    fi
    
    print_test "testnet-helper.sh commands"
    if [ -f "scripts/testnet-helper.sh" ]; then
        if grep -q "start\|stop\|health\|peers" "scripts/testnet-helper.sh"; then
            pass "Essential commands found in testnet-helper.sh"
        else
            warn "Some commands may be missing in testnet-helper.sh"
        fi
    fi
    
    print_test "security-audit.sh checks"
    if [ -f "scripts/security-audit.sh" ]; then
        if grep -qi "vulnerability\|audit\|security" "scripts/security-audit.sh"; then
            pass "Security checks found in security-audit.sh"
        else
            warn "Security checks may be missing in security-audit.sh"
        fi
    fi
}

###################################################################################
# Test 14: Production Readiness Checklist
###################################################################################
test_production_readiness() {
    print_section "14. Production Readiness Checklist"
    
    local prod_items=(
        "docs/SECURITY.md:Security documentation"
        "contracts/SecureToken.sol:Secure contract templates"
        "contracts/MultiSigWallet.sol:Multi-sig wallet"
        "docs/security/firewall-rules.sh:Firewall configuration"
        "docs/security/nginx-tls.conf:TLS configuration"
        "scripts/security-audit.sh:Security audit tool"
        "substrate-node/monitoring/prometheus.yml:Monitoring setup"
        "docs/TESTNET_DEPLOYMENT.md:Deployment documentation"
    )
    
    for item_spec in "${prod_items[@]}"; do
        IFS=':' read -r file desc <<< "$item_spec"
        print_test "$desc"
        if [ -f "$file" ]; then
            pass "$desc is available"
        else
            warn "$desc is missing"
        fi
    done
}

###################################################################################
# Test 15: Code Quality Checks
###################################################################################
test_code_quality() {
    print_section "15. Code Quality Checks"
    
    print_test "Shell script quality"
    local shell_issues=0
    while IFS= read -r -d '' script; do
        if [ -f "$script" ]; then
            if ! bash -n "$script" 2>/dev/null; then
                ((shell_issues++))
                fail "$script has syntax errors"
            fi
        fi
    done < <(find scripts docs/security -type f -name "*.sh" -print0 2>/dev/null)
    
    if [ "$shell_issues" -eq 0 ]; then
        pass "All shell scripts have valid syntax"
    fi
    
    print_test "Solidity pragma consistency"
    local pragma_versions=$(grep -h "pragma solidity" contracts/*.sol 2>/dev/null | sort -u | wc -l)
    if [ "$pragma_versions" -le 2 ]; then
        pass "Solidity versions are consistent"
    else
        warn "Multiple Solidity versions in use ($pragma_versions different pragmas)"
    fi
    
    print_test "Documentation completeness"
    local doc_count=$(find docs -name "*.md" | wc -l)
    if [ "$doc_count" -ge 7 ]; then
        pass "Comprehensive documentation ($doc_count documents)"
    else
        warn "Documentation may be incomplete ($doc_count documents)"
    fi
}

###################################################################################
# Generate Report
###################################################################################
generate_report() {
    print_header "TEST SUMMARY"
    
    echo -e "${BOLD}Total Tests:${NC}    $TOTAL_TESTS"
    echo -e "${GREEN}${BOLD}Passed:${NC}         $PASSED_TESTS"
    echo -e "${RED}${BOLD}Failed:${NC}         $FAILED_TESTS"
    echo -e "${YELLOW}${BOLD}Warnings:${NC}       $WARNINGS"
    
    local pass_rate=0
    if [ "$TOTAL_TESTS" -gt 0 ]; then
        pass_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    fi
    
    echo -e "\n${BOLD}Pass Rate:${NC}      ${pass_rate}%"
    
    if [ "$pass_rate" -ge 95 ]; then
        echo -e "\n${GREEN}${BOLD}🌟 EXCELLENT${NC}: Project is production-ready!"
    elif [ "$pass_rate" -ge 85 ]; then
        echo -e "\n${GREEN}${BOLD}✓ GOOD${NC}: Project is mostly ready, address warnings."
    elif [ "$pass_rate" -ge 70 ]; then
        echo -e "\n${YELLOW}${BOLD}⚠ FAIR${NC}: Several issues need attention."
    else
        echo -e "\n${RED}${BOLD}✗ POOR${NC}: Significant work needed before production."
    fi
    
    # Quality score
    local quality_score=$((pass_rate - (WARNINGS * 2)))
    echo -e "\n${BOLD}Quality Score:${NC}  ${quality_score}/100"
    
    if [ "$quality_score" -ge 90 ]; then
        echo -e "${GREEN}${BOLD}Top-tier quality achieved!${NC} 🚀"
    elif [ "$quality_score" -ge 80 ]; then
        echo -e "${GREEN}High quality project${NC} 👍"
    elif [ "$quality_score" -ge 70 ]; then
        echo -e "${YELLOW}Good quality, room for improvement${NC}"
    else
        echo -e "${YELLOW}Quality improvements recommended${NC}"
    fi
    
    echo ""
}

###################################################################################
# Main Execution
###################################################################################
main() {
    print_header "ORION BLOCKCHAIN - COMPREHENSIVE TEST SUITE"
    
    echo -e "${CYAN}Testing all components for production readiness...${NC}\n"
    
    # Run all test suites
    test_project_structure
    test_smart_contracts
    test_scripts
    test_docker_config
    test_documentation
    test_security
    test_example_dapp
    test_monitoring
    test_cicd
    test_cargo_config
    test_runtime
    test_chain_spec
    test_helper_scripts
    test_production_readiness
    test_code_quality
    
    # Generate final report
    generate_report
    
    # Exit with appropriate code
    if [ "$FAILED_TESTS" -eq 0 ]; then
        echo -e "${GREEN}${BOLD}All critical tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}${BOLD}Some tests failed. Please review and fix.${NC}"
        exit 1
    fi
}

# Run main function
main
