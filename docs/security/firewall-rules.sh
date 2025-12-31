#!/bin/bash
# Firewall Configuration for Orion Validator Nodes
# Use with UFW (Uncomplicated Firewall) on Ubuntu/Debian

# WARNING: Review and customize for your specific network setup
# This script is a template - test in a safe environment first

set -e

echo "Configuring firewall for Orion validator node..."

# Install UFW if not present
if ! command -v ufw &> /dev/null; then
    echo "Installing UFW..."
    sudo apt-get update
    sudo apt-get install -y ufw
fi

# Reset to defaults (WARNING: This will clear existing rules)
echo "Resetting UFW to defaults..."
sudo ufw --force reset

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (CHANGE THIS PORT if you've customized SSH)
# IMPORTANT: Ensure you have alternative access before enabling!
SSH_PORT=22  # Change to your SSH port
echo "Allowing SSH on port $SSH_PORT..."
sudo ufw allow $SSH_PORT/tcp comment 'SSH Access'

# Allow P2P networking for validators (Substrate default)
echo "Allowing P2P networking (port 30333)..."
sudo ufw allow 30333/tcp comment 'Substrate P2P'

# Allow Prometheus metrics (ONLY from internal network)
# Replace 10.0.0.0/8 with your internal network range
INTERNAL_NETWORK="10.0.0.0/8"
echo "Allowing Prometheus metrics from internal network..."
sudo ufw allow from $INTERNAL_NETWORK to any port 9615 proto tcp comment 'Prometheus Metrics (Internal)'

# RPC endpoints (ONLY allow from trusted IPs)
# For production, use a reverse proxy with authentication instead
# Uncomment and replace TRUSTED_IP with your actual IP
# TRUSTED_IP="1.2.3.4"
# sudo ufw allow from $TRUSTED_IP to any port 9933 proto tcp comment 'HTTP RPC (Trusted)'
# sudo ufw allow from $TRUSTED_IP to any port 9944 proto tcp comment 'WebSocket RPC (Trusted)'

echo ""
echo "WARNING: RPC ports (9933, 9944) are NOT open by default."
echo "For production, use a reverse proxy with TLS and authentication."
echo "For development, uncomment the lines above and add your trusted IP."
echo ""

# Rate limiting for P2P (protect against connection floods)
echo "Configuring rate limiting..."
sudo ufw limit 30333/tcp comment 'P2P Rate Limit'

# Enable logging
sudo ufw logging on

# Show configured rules before enabling
echo ""
echo "Configured firewall rules:"
sudo ufw show added

# Confirm before enabling
read -p "Enable these firewall rules? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo ufw --force enable
    echo ""
    echo "Firewall enabled successfully!"
    echo ""
    echo "Current status:"
    sudo ufw status verbose
    echo ""
    echo "IMPORTANT NEXT STEPS:"
    echo "1. Verify SSH access before closing this session"
    echo "2. Configure your RPC reverse proxy with TLS"
    echo "3. Set up monitoring and alerting"
    echo "4. Regularly review firewall logs: sudo journalctl -u ufw"
else
    echo "Firewall configuration cancelled."
fi
