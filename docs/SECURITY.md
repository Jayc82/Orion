# Orion Security Guide

## Table of Contents

1. [Security Policy](#security-policy)
2. [Reporting Vulnerabilities](#reporting-vulnerabilities)
3. [Development vs Production](#development-vs-production)
4. [Smart Contract Security](#smart-contract-security)
5. [Node Security](#node-security)
6. [Network Security](#network-security)
7. [Operational Security](#operational-security)
8. [Security Checklist](#security-checklist)
9. [References](#references)

## Security Policy

### Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

### Security Updates

- Security patches are released as soon as possible after discovery
- Critical vulnerabilities receive immediate hotfixes
- All security updates are announced via GitHub Security Advisories

## Reporting Vulnerabilities

**⚠️ DO NOT create public GitHub issues for security vulnerabilities**

### Responsible Disclosure

If you discover a security vulnerability, please follow these steps:

1. **Email**: Send details to security@orion-network.example (replace with actual email)
2. **Include**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)
3. **Wait**: Allow 90 days for the team to address before public disclosure
4. **Recognition**: Contributors will be acknowledged (if desired)

### Bug Bounty

We are considering a bug bounty program for the mainnet launch. Details TBA.

## Development vs Production

### ⚠️ Critical Distinction

**The current implementation is for DEVELOPMENT/TESTING ONLY.**

### Development Environment Characteristics

- **Pre-funded accounts**: Development accounts (Alith, Baltathar, etc.) have known private keys
- **Open RPC**: No authentication on RPC endpoints
- **Single node**: No Byzantine Fault Tolerance
- **Test chain ID**: Chain ID 1251 is for testing
- **No TLS**: Unencrypted RPC connections
- **Sudo access**: Root-level access enabled

### Production Environment Requirements

- **Secure keys**: All keys must be generated securely and stored in hardware wallets/HSM
- **Authenticated RPC**: Implement authentication and rate limiting
- **Multi-validator**: Minimum 3-4 validators for BFT
- **Unique chain ID**: Register a unique chain ID (not 1251)
- **TLS encryption**: All RPC endpoints must use HTTPS/WSS
- **Remove sudo**: Disable sudo pallet for mainnet
- **Monitoring**: Implement comprehensive monitoring and alerting

## Smart Contract Security

### Common Vulnerabilities

#### 1. Reentrancy

**Vulnerable Code:**
```solidity
function withdraw() public {
    uint256 amount = balances[msg.sender];
    // VULNERABLE: External call before state update
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] = 0;
}
```

**Secure Code:**
```solidity
function withdraw() public nonReentrant {
    uint256 amount = balances[msg.sender];
    // Safe: State update before external call
    balances[msg.sender] = 0;
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
}
```

#### 2. Integer Overflow/Underflow

**Pre-Solidity 0.8.0:** Use SafeMath library
**Solidity 0.8.0+:** Built-in overflow protection

```solidity
// Solidity 0.8.0+ automatically checks
function transfer(uint256 amount) public {
    balances[msg.sender] -= amount; // Reverts on underflow
    balances[to] += amount;          // Reverts on overflow
}
```

#### 3. Access Control

**Vulnerable:**
```solidity
function mint(address to, uint256 amount) public {
    // Anyone can mint!
    totalSupply += amount;
    balances[to] += amount;
}
```

**Secure:**
```solidity
address public owner;

modifier onlyOwner() {
    require(msg.sender == owner, "Not authorized");
    _;
}

function mint(address to, uint256 amount) public onlyOwner {
    totalSupply += amount;
    balances[to] += amount;
}
```

#### 4. Front-Running

**Issue**: Transactions are public before mining

**Mitigation**:
- Commit-reveal schemes
- Minimum time delays
- Use of oracles for pricing
- Slippage protection

```solidity
function swap(uint256 minAmountOut) public {
    uint256 amountOut = calculateSwap();
    require(amountOut >= minAmountOut, "Slippage too high");
    // ... execute swap
}
```

### Best Practices

#### Use OpenZeppelin Contracts

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SecureToken is ERC20, Ownable, Pausable, ReentrancyGuard {
    // Your secure implementation
}
```

#### Input Validation

```solidity
function transfer(address to, uint256 amount) public returns (bool) {
    require(to != address(0), "Transfer to zero address");
    require(amount > 0, "Amount must be positive");
    require(balances[msg.sender] >= amount, "Insufficient balance");
    // ... transfer logic
}
```

#### Events for Transparency

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
event AdminAction(address indexed admin, string action, uint256 timestamp);

function criticalOperation() public onlyOwner {
    // ... operation
    emit AdminAction(msg.sender, "Critical operation", block.timestamp);
}
```

#### Emergency Stop

```solidity
contract Pausable {
    bool public paused;
    address public owner;
    
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    
    function pause() public onlyOwner {
        paused = true;
    }
    
    function unpause() public onlyOwner {
        paused = false;
    }
}
```

### Testing & Auditing

#### Automated Testing

```bash
# Install testing tools
npm install --save-dev @nomiclabs/hardhat-waffle ethereum-waffle chai

# Run tests
npx hardhat test

# Coverage
npx hardhat coverage
```

#### Static Analysis

```bash
# Install Slither
pip3 install slither-analyzer

# Analyze contracts
slither contracts/

# Install Mythril
pip3 install mythril

# Analyze for vulnerabilities
myth analyze contracts/SecureToken.sol
```

#### Manual Audit Checklist

- [ ] All functions have appropriate access control
- [ ] No reentrancy vulnerabilities
- [ ] Integer overflow/underflow protected
- [ ] Input validation on all public functions
- [ ] Events emitted for state changes
- [ ] Gas optimization reviewed
- [ ] Emergency stop mechanism
- [ ] Upgrade mechanism (if applicable)
- [ ] Time-locked admin functions
- [ ] External call failures handled

### Professional Audit

Before mainnet deployment, engage professional auditors:
- [Trail of Bits](https://www.trailofbits.com/)
- [OpenZeppelin](https://openzeppelin.com/security-audits/)
- [ConsenSys Diligence](https://consensys.net/diligence/)
- [Quantstamp](https://quantstamp.com/)

## Node Security

### Key Management

#### Development Keys (⚠️ NEVER USE IN PRODUCTION)

```
Alith: 0x5fb92d6e98884f76de468fa3f6278f8807c48bebc13595d45af5bdc4da702133
Bob:   0x8075991ce870b93a8870eca0c0f91913d12f47948ca0fd25b49c6fa7cdbeee8b
```

**These keys are PUBLIC. Anyone can access funds.**

#### Production Key Generation

```bash
# Generate secure random key
openssl rand -hex 32

# Or use hardware wallet
# - Ledger
# - Trezor
# - YubiKey with OpenPGP

# Or use a Key Management Service
# - AWS KMS
# - Google Cloud KMS
# - Azure Key Vault
```

#### Key Storage

**❌ NEVER:**
- Commit keys to version control
- Store keys in plain text
- Share keys via email/chat
- Use default/example keys in production

**✅ DO:**
- Use hardware wallets for validators
- Encrypt keys at rest (AES-256)
- Use HSM for high-value operations
- Implement key rotation procedures
- Maintain offline backups in secure location

#### Key Rotation

```bash
# 1. Generate new keys
./scripts/generate-keys.sh

# 2. Add new validator
polkadot-js-api tx.session.setKeys(newKeys)

# 3. Wait for session change (2-4 hours)

# 4. Remove old validator

# 5. Securely destroy old keys
```

### Network Configuration

#### Firewall Rules (UFW Example)

```bash
# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH (change from default 22)
sudo ufw allow 2222/tcp

# P2P (validator communication)
sudo ufw allow 30333/tcp

# Prometheus metrics (internal only)
sudo ufw allow from 10.0.0.0/8 to any port 9615

# RPC (only from trusted IPs)
sudo ufw allow from 1.2.3.4 to any port 9933
sudo ufw allow from 1.2.3.4 to any port 9944

# Enable firewall
sudo ufw enable
```

#### Rate Limiting

```nginx
# Nginx rate limiting
limit_req_zone $binary_remote_addr zone=rpc:10m rate=10r/s;

server {
    location /rpc {
        limit_req zone=rpc burst=20;
        proxy_pass http://localhost:9933;
    }
}
```

### TLS/SSL Configuration

#### Let's Encrypt Setup

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d rpc.orion-network.example

# Auto-renewal (add to crontab)
0 3 * * * certbot renew --quiet
```

#### Nginx Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name rpc.orion-network.example;
    
    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/rpc.orion-network.example/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rpc.orion-network.example/privkey.pem;
    
    # Strong encryption
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers on;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Proxy to node
    location / {
        proxy_pass http://localhost:9933;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

### Monitoring & Intrusion Detection

#### Prometheus Metrics

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'orion-validators'
    static_configs:
      - targets:
        - 'validator1:9615'
        - 'validator2:9615'
        - 'validator3:9615'
```

#### Alert Rules

```yaml
# alerts.yml
groups:
  - name: orion
    rules:
      - alert: ValidatorDown
        expr: up{job="orion-validators"} == 0
        for: 5m
        annotations:
          summary: "Validator {{ $labels.instance }} is down"
          
      - alert: HighMemoryUsage
        expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1
        for: 5m
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
```

#### Log Monitoring

```bash
# Install fail2ban
sudo apt-get install fail2ban

# Configure for SSH
sudo cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = 2222
maxretry = 3
bantime = 3600
EOF

sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## Network Security

### Validator Security

#### Network Topology

```
Internet
    |
[Firewall/Load Balancer]
    |
[Sentry Nodes] (Public RPC)
    |
[Private Network]
    |
[Validator Nodes] (No public access)
```

#### Sentry Node Pattern

- Validators connect only to trusted sentry nodes
- Sentry nodes handle public P2P connections
- Validators have no direct internet exposure
- Reduces DDoS attack surface

```bash
# Validator config (--reserved-only --reserved-nodes)
./orion-node \
  --validator \
  --reserved-only \
  --reserved-nodes /ip4/10.0.1.10/tcp/30333/p2p/SentryNode1 \
  --reserved-nodes /ip4/10.0.1.11/tcp/30333/p2p/SentryNode2
```

#### DDoS Protection

```bash
# SYN flood protection
sudo sysctl -w net.ipv4.tcp_syncookies=1

# Limit connections
sudo iptables -A INPUT -p tcp --dport 30333 -m connlimit --connlimit-above 50 -j REJECT

# Rate limit
sudo iptables -A INPUT -p tcp --dport 30333 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
```

### Consensus Security

#### Validator Selection

- Use secure randomness for validator selection
- Implement slashing for misbehavior
- Monitor validator performance

#### Slashing Conditions

```rust
// Runtime configuration
impl pallet_staking::Config for Runtime {
    type SlashDeferDuration = SlashDeferDuration;
    type SlashCancelOrigin = EnsureRoot<AccountId>;
    // ... other config
}
```

## Operational Security

### Deployment Checklist

#### Pre-Production

- [ ] All contracts professionally audited
- [ ] Penetration testing completed
- [ ] Load testing completed (1000+ TPS)
- [ ] Disaster recovery plan documented
- [ ] Backup and restore procedures tested
- [ ] Monitoring and alerting configured
- [ ] Incident response team identified
- [ ] Legal review completed

#### Production Launch

- [ ] All keys generated securely
- [ ] Hardware wallets configured
- [ ] TLS certificates installed
- [ ] Firewall rules applied
- [ ] Rate limiting configured
- [ ] Monitoring dashboards live
- [ ] On-call rotation established
- [ ] Communication channels setup

#### Post-Launch

- [ ] 24/7 monitoring active
- [ ] Regular security updates applied
- [ ] Periodic penetration testing
- [ ] Bug bounty program active
- [ ] Incident response drills conducted
- [ ] Regular backups verified

### Incident Response

#### Detection

- Monitor for unusual activity
- Set up alerts for anomalies
- Regular log review
- Community reporting channel

#### Response

1. **Identify**: Confirm the incident
2. **Contain**: Isolate affected systems
3. **Eradicate**: Remove the threat
4. **Recover**: Restore normal operations
5. **Learn**: Post-mortem analysis

#### Communication

- Internal: Immediate team notification
- External: Public disclosure (if necessary)
- Authorities: Report to relevant agencies (if required)

### Backup & Recovery

#### What to Backup

- Validator keys (encrypted)
- Chain database (snapshots)
- Configuration files
- Monitoring data
- Logs (30+ days)

#### Backup Schedule

- **Chain state**: Daily snapshots
- **Configurations**: On every change
- **Keys**: Secure offline storage
- **Logs**: Continuous archival

#### Recovery Procedure

```bash
# 1. Restore from backup
sudo systemctl stop orion-node
sudo rm -rf /var/lib/orion/chains/orion_dev
sudo tar -xzf backup-YYYYMMDD.tar.gz -C /var/lib/orion/

# 2. Verify integrity
sha256sum -c backup-YYYYMMDD.sha256

# 3. Restart node
sudo systemctl start orion-node

# 4. Monitor sync
journalctl -u orion-node -f
```

## Security Checklist

### Development Phase

- [ ] Code review by multiple developers
- [ ] Unit tests for all functionality
- [ ] Integration tests
- [ ] Fuzzing tests
- [ ] Static analysis (Slither, Mythril)
- [ ] Dependency audit (`npm audit`, `cargo audit`)

### Pre-Production

- [ ] Professional security audit completed
- [ ] Audit findings addressed
- [ ] Penetration testing completed
- [ ] Load testing completed
- [ ] Testnet deployment successful
- [ ] Documentation review

### Production Deployment

- [ ] Unique chain ID registered
- [ ] All keys generated securely
- [ ] Hardware wallets configured
- [ ] TLS/SSL certificates installed
- [ ] Firewall rules implemented
- [ ] Rate limiting configured
- [ ] Monitoring active
- [ ] Backup procedures in place
- [ ] Incident response plan ready
- [ ] Team training completed

### Ongoing Operations

- [ ] Regular security updates applied
- [ ] Dependency updates reviewed
- [ ] Periodic security audits
- [ ] Penetration testing (quarterly)
- [ ] Log review (weekly)
- [ ] Backup verification (monthly)
- [ ] Incident response drills (quarterly)
- [ ] Key rotation (annually)

## References

### Standards & Guidelines

- [CWE Top 25](https://cwe.mitre.org/top25/)
- [OWASP Smart Contract Top 10](https://owasp.org/www-project-smart-contract-top-10/)
- [ConsenSys Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/)
- [Solidity Security Considerations](https://docs.soliditylang.org/en/latest/security-considerations.html)

### Tools

- **Static Analysis**: Slither, Mythril, Manticore
- **Fuzzing**: Echidna, Harvey
- **Formal Verification**: Certora, K Framework
- **Testing**: Hardhat, Truffle, Foundry
- **Monitoring**: Prometheus, Grafana, ELK Stack

### Learning Resources

- [Smart Contract Security Verification Standard](https://github.com/securing/SCSVS)
- [Blockchain Security Database](https://consensys.github.io/blockchainSecurityDB/)
- [Ethereum Security](https://ethereum.org/en/security/)
- [Substrate Security](https://docs.substrate.io/maintain/runtime-upgrades/)

---

**Remember**: Security is an ongoing process, not a one-time task. Stay vigilant, keep learning, and always prioritize user safety.

For questions or concerns, contact: security@orion-network.example
