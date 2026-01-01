# Orion Example dApp

Simple, standalone HTML dApp for interacting with the Orion network.

## Features

- 👛 Connect MetaMask wallet
- 📊 Display account balance and network info
- 💸 Send ORN transactions
- 📝 Interact with HelloWorld smart contract
- 🔄 Real-time updates

## Quick Start

### Prerequisites

1. **MetaMask Extension**: Install from [metamask.io](https://metamask.io)
2. **Orion Node Running**: Start with Docker or locally
   ```bash
   cd substrate-node
   docker-compose up -d
   ```

### Setup

1. **Add Orion Network to MetaMask**:
   - Network Name: `Orion Development`
   - RPC URL: `http://localhost:9933`
   - Chain ID: `1337`
   - Currency Symbol: `ORN`

2. **Import Development Account**:
   - Click MetaMask → Import Account → Private Key
   - Use one of the pre-funded accounts (see docs/WALLET_INTEGRATION.md)
   - Example (Alith): `0x5fb92d6e98884f76de468fa3f6278f8807c48bebc13595d45af5bdc4da702133`

3. **Open the dApp**:
   ```bash
   # Option 1: Open directly in browser
   open index.html
   
   # Option 2: Use a local server
   python3 -m http.server 8000
   # Then visit http://localhost:8000
   ```

4. **Connect Wallet**:
   - Click "Connect MetaMask"
   - Approve the connection
   - Your account info will appear

## Using the dApp

### View Account Info

After connecting, you'll see:
- Your Ethereum address
- ORN balance
- Current network

Click "🔄 Refresh Balance" to update.

### Send Transactions

1. Enter recipient address (0x...)
2. Enter amount in ORN
3. Click "Send ORN"
4. Confirm in MetaMask
5. Wait for confirmation

### Interact with Contracts

1. **Deploy HelloWorld Contract**:
   ```bash
   cd ../../contracts
   # Follow deployment instructions in README.md
   ```

2. **Load Contract in dApp**:
   - Paste contract address
   - Click "Load Contract"

3. **Get Current Message**:
   - Click "Get Message"
   - Current message displays below

4. **Set New Message**:
   - Enter new message text
   - Click "Set Message"
   - Confirm transaction in MetaMask
   - Message updates automatically

## Development Accounts

Pre-funded accounts for testing:

| Name | Address | Private Key (first 20 chars) |
|------|---------|------------------------------|
| Alith | 0xf24FF3a9CF04c71Dbc94D0b566f7A27B94566cac | 0x5fb92d6e98884f76de468... |
| Baltathar | 0x3Cd0A705a2DC65e5b1E1205896BaA2be8A07c6e0 | 0x8075991ce870b93a8870ec... |
| Charleth | 0x798d4Ba9baf0064Ec19eB4F0a1a45785ae9D6DFc | 0x0b6e18cafb6ed99687ec54... |

⚠️ **Never use these keys on mainnet!**

Full keys available in: `docs/WALLET_INTEGRATION.md`

## Troubleshooting

### "MetaMask not installed"
- Install MetaMask browser extension
- Refresh the page

### "Please switch to Orion network"
- Make sure you've added Orion network to MetaMask
- Select "Orion Development" from network dropdown

### "insufficient funds"
- Import a pre-funded development account
- Or receive funds from another account

### Connection timeout
- Ensure Orion node is running: `docker ps` or `ps aux | grep orion`
- Check RPC endpoint is accessible: `curl http://localhost:9933`

### Transaction fails
- Check you have enough ORN for gas
- Verify contract address is correct
- Check console for detailed error messages

## Code Structure

```
index.html
├── HTML - Page structure
├── CSS - Styling (embedded)
└── JavaScript
    ├── Ethers.js (CDN) - Ethereum library
    ├── Connection logic - MetaMask integration
    ├── Account management - Balance, address display
    ├── Transaction handling - Send ORN
    └── Contract interaction - HelloWorld methods
```

## Customization

### Add Your Own Contract

1. **Update ABI**:
   ```javascript
   const YourContractABI = [
       "function yourMethod() view returns (string)",
       "function setData(uint256 value)"
   ];
   ```

2. **Create Contract Instance**:
   ```javascript
   contract = new ethers.Contract(
       contractAddress, 
       YourContractABI, 
       signer
   );
   ```

3. **Call Methods**:
   ```javascript
   // View function
   const result = await contract.yourMethod();
   
   // Transaction
   const tx = await contract.setData(42);
   await tx.wait();
   ```

### Styling

Modify the `<style>` section for custom appearance:
- Colors: Change `#667eea` (primary color)
- Fonts: Update `font-family` values
- Layout: Adjust `.card`, `.container` styles

### Network Configuration

Change network details in the connection logic:
```javascript
if (network.chainId !== YOUR_CHAIN_ID) {
    // Show error or switch network
}
```

## Advanced Features

### Adding Token Support

```javascript
// ERC20 ABI
const ERC20_ABI = [
    "function balanceOf(address) view returns (uint256)",
    "function transfer(address to, uint256 amount) returns (bool)"
];

// Check token balance
const tokenContract = new ethers.Contract(TOKEN_ADDRESS, ERC20_ABI, provider);
const balance = await tokenContract.balanceOf(userAccount);
```

### Event Listening

```javascript
// Listen for transfers
contract.on("Transfer", (from, to, amount) => {
    console.log(`Transfer: ${from} → ${to}: ${amount}`);
});
```

### Multiple Networks

```javascript
const NETWORKS = {
    1337: { name: 'Orion Dev', rpc: 'http://localhost:9933' },
    1338: { name: 'Orion Test', rpc: 'https://rpc.testnet.orion.network' }
};
```

## Next Steps

1. Deploy more complex contracts (see `contracts/` directory)
2. Add ERC20 token support
3. Implement NFT features
4. Build a full React/Vue application
5. Explore Polkadot.js for Substrate features

## Resources

- **Wallet Integration Guide**: `docs/WALLET_INTEGRATION.md`
- **Contract Deployment**: `contracts/README.md`
- **Running Locally**: `docs/RUNNING_LOCALLY.md`
- **Ethers.js Docs**: https://docs.ethers.org/
- **MetaMask Docs**: https://docs.metamask.io/

## License

MIT - See LICENSE file in repository root
