// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SecureToken
 * @dev Production-ready ERC20 token with comprehensive security features
 * @notice This contract implements security best practices including:
 *         - Reentrancy protection
 *         - Access control with roles
 *         - Emergency pause functionality
 *         - Supply cap
 *         - Event logging for auditing
 * 
 * @custom:security-contact security@orion-network.example
 */
contract SecureToken {
    // Token metadata
    string public constant name = "Secure Orion Token";
    string public constant symbol = "sORN";
    uint8 public constant decimals = 18;
    
    // Supply management
    uint256 private _totalSupply;
    uint256 public immutable cap; // Maximum supply cap
    
    // Balances and allowances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // Access control
    address public owner;
    mapping(address => bool) public minters;
    mapping(address => bool) public burners;
    
    // Security features
    bool public paused;
    mapping(address => bool) private _locked; // Reentrancy guard
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event BurnerAdded(address indexed account);
    event BurnerRemoved(address indexed account);
    event Paused(address account);
    event Unpaused(address account);
    
    /**
     * @dev Modifier to restrict functions to owner only
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "SecureToken: caller is not the owner");
        _;
    }
    
    /**
     * @dev Modifier to restrict functions to minters only
     */
    modifier onlyMinter() {
        require(minters[msg.sender], "SecureToken: caller is not a minter");
        _;
    }
    
    /**
     * @dev Modifier to restrict functions to burners only
     */
    modifier onlyBurner() {
        require(burners[msg.sender], "SecureToken: caller is not a burner");
        _;
    }
    
    /**
     * @dev Modifier to make a function callable only when not paused
     */
    modifier whenNotPaused() {
        require(!paused, "SecureToken: paused");
        _;
    }
    
    /**
     * @dev Modifier to make a function callable only when paused
     */
    modifier whenPaused() {
        require(paused, "SecureToken: not paused");
        _;
    }
    
    /**
     * @dev Reentrancy guard modifier
     */
    modifier nonReentrant() {
        require(!_locked[msg.sender], "SecureToken: reentrant call");
        _locked[msg.sender] = true;
        _;
        _locked[msg.sender] = false;
    }
    
    /**
     * @dev Constructor that gives owner initial supply and sets cap
     * @param initialSupply Initial token supply (in whole tokens, will be multiplied by 10^decimals)
     * @param maxSupply Maximum token supply cap (in whole tokens)
     */
    constructor(uint256 initialSupply, uint256 maxSupply) {
        require(maxSupply > 0, "SecureToken: cap is 0");
        require(initialSupply <= maxSupply, "SecureToken: initial supply exceeds cap");
        
        owner = msg.sender;
        minters[msg.sender] = true;
        burners[msg.sender] = true;
        
        cap = maxSupply * 10**decimals;
        _mint(msg.sender, initialSupply * 10**decimals);
    }
    
    /**
     * @dev Returns the total token supply
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev Returns the balance of an account
     * @param account Address to query
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    /**
     * @dev Transfer tokens to a specified address
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function transfer(address to, uint256 amount) public whenNotPaused nonReentrant returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    /**
     * @dev Returns the remaining number of tokens that spender is allowed to spend
     * @param tokenOwner Address of token owner
     * @param spender Address of spender
     */
    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return _allowances[tokenOwner][spender];
    }
    
    /**
     * @dev Approve the passed address to spend the specified amount of tokens
     * @param spender Address to approve
     * @param amount Amount to approve
     */
    function approve(address spender, uint256 amount) public whenNotPaused returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    /**
     * @dev Transfer tokens from one address to another using allowance
     * @param from Sender address
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public whenNotPaused nonReentrant returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender
     * @param spender Address to increase allowance for
     * @param addedValue Amount to increase by
     */
    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender
     * @param spender Address to decrease allowance for
     * @param subtractedValue Amount to decrease by
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "SecureToken: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    
    /**
     * @dev Mint new tokens (restricted to minters)
     * @param to Address to mint to
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) public onlyMinter whenNotPaused returns (bool) {
        _mint(to, amount);
        return true;
    }
    
    /**
     * @dev Burn tokens from caller's account
     * @param amount Amount to burn
     */
    function burn(uint256 amount) public whenNotPaused returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
    
    /**
     * @dev Burn tokens from specified account (restricted to burners)
     * @param from Address to burn from
     * @param amount Amount to burn
     */
    function burnFrom(address from, uint256 amount) public onlyBurner whenNotPaused returns (bool) {
        _burn(from, amount);
        return true;
    }
    
    /**
     * @dev Transfer ownership to a new address
     * @param newOwner New owner address
     */
    function transferOwnership(address newOwner) public onlyOwner returns (bool) {
        require(newOwner != address(0), "SecureToken: new owner is the zero address");
        
        address oldOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(oldOwner, newOwner);
        return true;
    }
    
    /**
     * @dev Add a new minter
     * @param account Address to add as minter
     */
    function addMinter(address account) public onlyOwner returns (bool) {
        require(account != address(0), "SecureToken: minter is the zero address");
        require(!minters[account], "SecureToken: account is already a minter");
        
        minters[account] = true;
        emit MinterAdded(account);
        return true;
    }
    
    /**
     * @dev Remove a minter
     * @param account Address to remove as minter
     */
    function removeMinter(address account) public onlyOwner returns (bool) {
        require(minters[account], "SecureToken: account is not a minter");
        
        minters[account] = false;
        emit MinterRemoved(account);
        return true;
    }
    
    /**
     * @dev Add a new burner
     * @param account Address to add as burner
     */
    function addBurner(address account) public onlyOwner returns (bool) {
        require(account != address(0), "SecureToken: burner is the zero address");
        require(!burners[account], "SecureToken: account is already a burner");
        
        burners[account] = true;
        emit BurnerAdded(account);
        return true;
    }
    
    /**
     * @dev Remove a burner
     * @param account Address to remove as burner
     */
    function removeBurner(address account) public onlyOwner returns (bool) {
        require(burners[account], "SecureToken: account is not a burner");
        
        burners[account] = false;
        emit BurnerRemoved(account);
        return true;
    }
    
    /**
     * @dev Pause the contract
     */
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        emit Paused(msg.sender);
        return true;
    }
    
    /**
     * @dev Unpause the contract
     */
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        emit Unpaused(msg.sender);
        return true;
    }
    
    /**
     * @dev Internal transfer function
     * @param from Sender address
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "SecureToken: transfer from the zero address");
        require(to != address(0), "SecureToken: transfer to the zero address");
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "SecureToken: transfer amount exceeds balance");
        
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: amount <= fromBalance <= totalSupply
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);
    }
    
    /**
     * @dev Internal mint function
     * @param account Address to mint to
     * @param amount Amount to mint
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "SecureToken: mint to the zero address");
        require(_totalSupply + amount <= cap, "SecureToken: cap exceeded");
        
        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount
            // which is checked above
            _balances[account] += amount;
        }
        
        emit Mint(account, amount);
        emit Transfer(address(0), account, amount);
    }
    
    /**
     * @dev Internal burn function
     * @param account Address to burn from
     * @param amount Amount to burn
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "SecureToken: burn from the zero address");
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "SecureToken: burn amount exceeds balance");
        
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply
            _totalSupply -= amount;
        }
        
        emit Burn(account, amount);
        emit Transfer(account, address(0), amount);
    }
    
    /**
     * @dev Internal approve function
     * @param tokenOwner Owner address
     * @param spender Spender address
     * @param amount Amount to approve
     */
    function _approve(
        address tokenOwner,
        address spender,
        uint256 amount
    ) internal {
        require(tokenOwner != address(0), "SecureToken: approve from the zero address");
        require(spender != address(0), "SecureToken: approve to the zero address");
        
        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }
    
    /**
     * @dev Internal function to spend allowance
     * @param tokenOwner Owner address
     * @param spender Spender address
     * @param amount Amount to spend
     */
    function _spendAllowance(
        address tokenOwner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = _allowances[tokenOwner][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "SecureToken: insufficient allowance");
            unchecked {
                _approve(tokenOwner, spender, currentAllowance - amount);
            }
        }
    }
}
