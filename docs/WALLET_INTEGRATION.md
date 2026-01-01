# Wallet Integration Guide

Complete guide for integrating MetaMask and Polkadot.js extension with the Orion network.

## Table of Contents

1. [Overview](#overview)
2. [MetaMask Integration](#metamask-integration)
3. [Polkadot.js Extension](#polkadotjs-extension)
4. [Development Accounts](#development-accounts)
5. [Testing Transactions](#testing-transactions)
6. [Troubleshooting](#troubleshooting)

## Overview

Orion supports both Ethereum-style wallets (MetaMask) and Substrate-native wallets (Polkadot.js extension) due to its Frontier EVM integration.

### Supported Wallets

- **MetaMask**: For Ethereum-compatible interactions (EVM contracts, ERC20 tokens)
- **Polkadot.js Extension**: For Substrate-native interactions (pallets, governance)
- **Hardware Wallets**: Ledger and Trezor (via MetaMask)

## MetaMask Integration

### Installation

1. Install MetaMask browser extension:
   - Chrome: https://chrome.google.com/webstore
   - Firefox: https://addons.mozilla.org/firefox
   - Brave: Pre-installed or from Chrome Web Store

2. Create or import a wallet
3. Keep your seed phrase secure!

### Adding Orion Network

#### Method 1: Manual Configuration

1. Open MetaMask
2. Click network dropdown (top center)
3. Click "Add Network" → "Add a network manually"
4. Enter the following details:

```
Network Name: Orion Development
New RPC URL: http://localhost:9933
Chain ID: 1251
Currency Symbol: ORN
Block Explorer URL: (leave empty for local)
```

5. Click "Save"

#### Method 2: Programmatic (dApp)

Add this code to your dApp:

```javascript
async function addOrionNetwork() {
  try {
    await window.ethereum.request({
      method: 'wallet_addEthereumChain',
      params: [{
        chainId: '0x4E3', // 1251 in hex
        chainName: 'Orion Development',
        nativeCurrency: {
          name: 'Orion',
          symbol: 'ORN',
          decimals: 18
        },
        rpcUrls: ['http://localhost:9933'],
        blockExplorerUrls: null
      }]
    });
  } catch (error) {
    console.error('Failed to add network:', error);
  }
}
```

### Production Network Configuration

For testnet or mainnet (replace with actual endpoints when available):

```
Network Name: Orion Testnet
New RPC URL: https://rpc.testnet.orion.network  (EXAMPLE - replace with actual)
Chain ID: 1251
Currency Symbol: ORN
Block Explorer URL: https://explorer.testnet.orion.network  (EXAMPLE - replace with actual)
```

> **Note**: The URLs above are placeholders. Replace with actual testnet/mainnet endpoints when deployed.

## Polkadot.js Extension

### Installation

1. Install extension:
   - Chrome: https://chrome.google.com/webstore (search "Polkadot{.js}")
   - Firefox: https://addons.mozilla.org/firefox

2. Create or import account
3. Allow the extension to access Polkadot.js Apps

### Connecting to Orion

1. Open Polkadot.js Apps: https://polkadot.js.org/apps/
2. Click the network selector (top left)
3. Choose "Development" → "Local Node"
4. Or add custom endpoint:
   - Click "Development" → "Custom"
   - Enter: `ws://localhost:9944`
   - Save and connect

### Using Docker Setup

If using docker-compose, Polkadot.js UI is available at:
- http://localhost:3000

It's pre-configured to connect to your Orion node.

## Development Accounts

Orion comes with pre-funded development accounts for testing.

### Substrate Accounts (Polkadot.js)

Well-known development accounts:

| Name | Address | Private Key |
|------|---------|------------|
| Alice | 5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY | 0xe5be9a5092b81bca64be81d212e7f2f9eba183bb7a90954f7b76361f6edb5c0a |
| Bob | 5FHneW46xGXgs5mUiveU4sbTyGBzmstUspZC92UhjJM694ty | 0x398f0c28f98885e046333d4a41c19cee4c37368a9832c6502f6cfd182e2aef89 |
| Charlie | 5FLSigC9HGRKVhB9FiEo4Y3koPsNmBmLJbpXg2mp1hXcS59Y | 0xbc1ede780f784bb6991a585e4f6e61522c14e1cae6ad0895fb57b9a205a8f938 |

### Ethereum Accounts (MetaMask)

Pre-funded EVM accounts:

| Name | Address | Private Key |
|------|---------|------------|
| Alith | 0xf24FF3a9CF04c71Dbc94D0b566f7A27B94566cac | 0x5fb92d6e98884f76de468fa3f6278f8807c48bebc13595d45af5bdc4da702133 |
| Baltathar | 0x3Cd0A705a2DC65e5b1E1205896BaA2be8A07c6e0 | 0x8075991ce870b93a8870eca0c0f91913d12f47948ca0fd25b49c6fa7cdbeee8b |
| Charleth | 0x798d4Ba9baf0064Ec19eB4F0a1a45785ae9D6DFc | 0x0b6e18cafb6ed99687ec547bd28139cafdd2bffe70e6b688025de6b445aa5c5b |
| Dorothy | 0x773539d4Ac0e786233D90A233654ccEE26a613D9 | 0x39539ab1876910bbf3a223d84a29e28f1cb4e2e456503e7e91ed39b2e7223d68 |
| Ethan | 0xFf64d3F6efE2317EE2807d223a0Bdc4c0c49dfDB | 0x7dce9bc8babb68fec1409be38c8e1a52650206a7ed90ff956ae8a6d15eeaaef4 |
| Faith | 0xC0F0f4ab324C46e55D02D0033343B4Be8A55532d | 0xb9d2ea9a615f3165812e8d44de0d24da9bbd164b65c4f0573e1ce2c8dbd9c8df |

### Importing to MetaMask

1. Open MetaMask
2. Click account icon → "Import Account"
3. Select "Private Key"
4. Paste one of the private keys above
5. Click "Import"

⚠️ **Warning**: These accounts are for development only. Never use these keys on mainnet!

### Funding Custom Accounts

To fund a new account in development:

```bash
# Using Polkadot.js Apps
1. Go to Accounts → Transfer
2. From: Alice (pre-funded)
3. To: Your new account address
4. Amount: 1000 ORN
5. Submit transaction

# Using substrate-node CLI
./target/release/orion-node key inspect <address>
```

## Testing Transactions

### Simple Transfer (MetaMask)

1. Open MetaMask
2. Select "Send"
3. Enter recipient address
4. Enter amount (e.g., 0.1 ORN)
5. Confirm transaction
6. Wait for confirmation (3-6 seconds)

### Deploy Smart Contract

See the contracts/README.md for detailed instructions.

Quick example:

```javascript
// Using ethers.js
const { ethers } = require('ethers');

// Connect to Orion
const provider = new ethers.providers.JsonRpcProvider('http://localhost:9933');
const wallet = new ethers.Wallet('PRIVATE_KEY', provider);

// Deploy contract
const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet);
const contract = await factory.deploy();
await contract.deployed();

console.log('Contract deployed at:', contract.address);
```

### Interact with Contract

```javascript
// Call view function
const message = await contract.getMessage();
console.log('Message:', message);

// Send transaction
const tx = await contract.setMessage('Hello Orion!');
await tx.wait();
console.log('Transaction hash:', tx.hash);
```

## Example dApp Integration

### Basic Connection

```html
<!DOCTYPE html>
<html>
<head>
  <title>Orion dApp</title>
  <script src="https://cdn.jsdelivr.net/npm/ethers@5.7.2/dist/ethers.umd.min.js"></script>
</head>
<body>
  <h1>Orion dApp Example</h1>
  <button id="connect">Connect Wallet</button>
  <div id="status"></div>
  <div id="balance"></div>

  <script>
    const statusEl = document.getElementById('status');
    const balanceEl = document.getElementById('balance');
    
    document.getElementById('connect').addEventListener('click', async () => {
      if (typeof window.ethereum !== 'undefined') {
        try {
          // Request account access
          const accounts = await window.ethereum.request({ 
            method: 'eth_requestAccounts' 
          });
          
          const account = accounts[0];
          statusEl.textContent = `Connected: ${account}`;
          
          // Get balance
          const provider = new ethers.providers.Web3Provider(window.ethereum);
          const balance = await provider.getBalance(account);
          const balanceInOrn = ethers.utils.formatEther(balance);
          
          balanceEl.textContent = `Balance: ${balanceInOrn} ORN`;
        } catch (error) {
          statusEl.textContent = `Error: ${error.message}`;
        }
      } else {
        statusEl.textContent = 'MetaMask not installed!';
      }
    });
    
    // Listen for account changes
    if (typeof window.ethereum !== 'undefined') {
      window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length === 0) {
          statusEl.textContent = 'Disconnected';
          balanceEl.textContent = '';
        }
      });
    }
  </script>
</body>
</html>
```

### With React

```jsx
import { useState, useEffect } from 'react';
import { ethers } from 'ethers';

function App() {
  const [account, setAccount] = useState('');
  const [balance, setBalance] = useState('');
  const [provider, setProvider] = useState(null);

  const connectWallet = async () => {
    if (typeof window.ethereum !== 'undefined') {
      try {
        const accounts = await window.ethereum.request({ 
          method: 'eth_requestAccounts' 
        });
        const account = accounts[0];
        setAccount(account);

        const provider = new ethers.providers.Web3Provider(window.ethereum);
        setProvider(provider);

        const balance = await provider.getBalance(account);
        setBalance(ethers.utils.formatEther(balance));
      } catch (error) {
        console.error('Error connecting wallet:', error);
      }
    } else {
      alert('MetaMask not installed!');
    }
  };

  useEffect(() => {
    if (window.ethereum) {
      window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length === 0) {
          setAccount('');
          setBalance('');
        } else {
          setAccount(accounts[0]);
        }
      });

      window.ethereum.on('chainChanged', () => {
        window.location.reload();
      });
    }
  }, []);

  return (
    <div className="App">
      <h1>Orion dApp</h1>
      {account ? (
        <div>
          <p>Connected: {account}</p>
          <p>Balance: {balance} ORN</p>
        </div>
      ) : (
        <button onClick={connectWallet}>Connect Wallet</button>
      )}
    </div>
  );
}

export default App;
```

## Troubleshooting

### MetaMask Issues

**Problem**: Transaction fails with "Nonce too high"
- **Solution**: Reset account in MetaMask: Settings → Advanced → Reset Account

**Problem**: Cannot connect to network
- **Solution**: Check node is running: `docker ps` or check logs
- Verify RPC endpoint: http://localhost:9933

**Problem**: Gas estimation fails
- **Solution**: Orion uses different gas mechanics. Try setting manual gas limit:
  ```javascript
  const tx = await contract.method({
    gasLimit: 1000000
  });
  ```

### Polkadot.js Extension Issues

**Problem**: Cannot see Orion network
- **Solution**: Add custom endpoint manually: ws://localhost:9944

**Problem**: Transactions stuck
- **Solution**: Check node logs, verify account has funds

**Problem**: Extension not connecting to dApp
- **Solution**: Refresh page, check extension permissions

### Common Errors

**Error**: "insufficient funds"
- Import a pre-funded development account
- Or transfer funds from Alice/Alith

**Error**: "execution reverted"
- Check contract function parameters
- Verify contract is deployed correctly
- Check transaction gas limit

**Error**: "network connection timeout"
- Ensure node is running
- Check firewall settings
- Verify correct RPC/WS endpoints

## Security Best Practices

1. **Never share private keys** - Especially on mainnet
2. **Verify network** - Always check you're on the correct network
3. **Test first** - Test all transactions on development network
4. **Backup seeds** - Keep seed phrases secure and backed up
5. **Use hardware wallets** - For mainnet and large amounts
6. **Verify contracts** - Audit smart contracts before interacting
7. **Check addresses** - Always verify recipient addresses

## Additional Resources

- **MetaMask Documentation**: https://docs.metamask.io/
- **Polkadot.js Documentation**: https://polkadot.js.org/docs/
- **Ethers.js Documentation**: https://docs.ethers.org/
- **Web3.js Documentation**: https://web3js.readthedocs.io/
- **Orion Architecture**: See docs/ARCHITECTURE.md
- **Contract Deployment**: See contracts/README.md

## Next Steps

1. Follow the wallet setup instructions above
2. Import a development account
3. Deploy the HelloWorld contract (see contracts/README.md)
4. Build your first dApp using the examples above
5. Explore advanced features in docs/FRONTIER_INTEGRATION.md

For issues or questions, see docs/RUNNING_LOCALLY.md troubleshooting section.
