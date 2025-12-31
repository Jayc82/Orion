# Smart Contracts

This directory contains example Solidity smart contracts for the Orion EVM.

## HelloWorld.sol

A simple smart contract demonstrating basic functionality:
- Storage of a message string
- Getter and setter functions
- Event emission
- Update counter

### Deploying with Hardhat

1. **Install Hardhat in your project:**

```bash
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
```

2. **Initialize Hardhat:**

```bash
npx hardhat init
```

3. **Configure Hardhat for Orion** (`hardhat.config.js`):

```javascript
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    orion: {
      url: "http://127.0.0.1:9933",  // Orion EVM JSON-RPC endpoint
      chainId: 1337,                  // Orion dev chain ID
      accounts: [
        // Add your private key here (for dev/test only!)
        // Use environment variables in production
        "0x..." // Development account private key
      ]
    }
  }
};
```

4. **Copy HelloWorld.sol to your Hardhat project:**

```bash
cp HelloWorld.sol <your-hardhat-project>/contracts/
```

5. **Compile the contract:**

```bash
npx hardhat compile
```

6. **Create a deployment script** (`scripts/deploy.js`):

```javascript
const hre = require("hardhat");

async function main() {
  const HelloWorld = await hre.ethers.getContractFactory("HelloWorld");
  const hello = await HelloWorld.deploy();
  await hello.deployed();

  console.log("HelloWorld deployed to:", hello.address);
  
  // Test the contract
  const message = await hello.getMessage();
  console.log("Initial message:", message);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

7. **Deploy to Orion:**

```bash
npx hardhat run scripts/deploy.js --network orion
```

### Deploying with Remix

1. **Start your Orion node** (see docs/RUNNING_LOCALLY.md)

2. **Open Remix IDE:** https://remix.ethereum.org/

3. **Create a new file** and paste the `HelloWorld.sol` contract

4. **Compile:**
   - Select Solidity compiler 0.8.x
   - Click "Compile HelloWorld.sol"

5. **Deploy:**
   - Go to "Deploy & Run Transactions"
   - Environment: Select "Injected Provider - MetaMask" or "Web3 Provider"
   - If using Web3 Provider, enter: `http://127.0.0.1:9933`
   - Click "Deploy"

6. **Interact:**
   - Call `getMessage()` to read the current message
   - Call `setMessage("New message")` to update it
   - Check the `updateCount` to see how many times it's been updated

### Important Notes

**Frontier RPC Differences:**

Orion uses Substrate's Frontier, which provides Ethereum-compatible JSON-RPC. However, there are some differences from standard Ethereum nodes:

- **Account Format:** Substrate uses SS58 addresses, but the EVM pallet maps them to Ethereum-style addresses (0x...)
- **Block Time:** May differ from Ethereum's ~12s (depends on Aura configuration)
- **Gas Pricing:** Configurable via `pallet-base-fee` (EIP-1559 compatible)

**Development Accounts:**

For local development, you can use Substrate's well-known development keys:

- **Alice:** Pre-funded development account
- **Bob:** Pre-funded development account

The mapping from Substrate to Ethereum addresses is deterministic. Check the Frontier documentation for address derivation.

**Verification:**

After deployment, verify your contract is working:

```bash
# Using Hardhat console
npx hardhat console --network orion

# In console:
const HelloWorld = await ethers.getContractFactory("HelloWorld");
const hello = await HelloWorld.attach("0x..."); // Your deployed address
await hello.getMessage();
await hello.setMessage("Testing Orion EVM!");
await hello.getUpdateCount();
```

### Troubleshooting

**Connection refused:**
- Ensure the Orion node is running: `./target/release/orion-node --dev --tmp`
- Check that RPC is exposed on port 9933

**Transaction fails:**
- Check you have sufficient balance (ORN tokens)
- For dev chains, accounts are pre-funded by default

**Gas estimation errors:**
- Frontier gas estimation may differ from Ethereum
- Try specifying gas limit manually in Hardhat config

**Network timeout:**
- Substrate block production may be slower on first start
- Wait for a few blocks to be produced

For more help, see docs/RUNNING_LOCALLY.md or open an issue on GitHub.
