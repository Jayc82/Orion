// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title OrionToken
 * @dev Simple ERC20 token implementation for Orion network
 * @notice This is a basic example for DEVELOPMENT/TESTING ONLY. 
 *         For production, use OpenZeppelin contracts with proper access control.
 * @warning The mint() function has no access control and is for demonstration only.
 *          Remove or add owner/role-based access control before production use.
 */
contract OrionToken {
    // Token metadata
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    // Balances
    mapping(address => uint256) private balances;
    
    // Allowances
    mapping(address => mapping(address => uint256)) private allowances;
    
    // Owner (for basic access control)
    address public owner;
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev Modifier to restrict functions to owner only
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    /**
     * @dev Constructor that gives msg.sender all of initial supply
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = _initialSupply * 10**decimals;
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
        
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    /**
     * @dev Returns the balance of an account
     */
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    
    /**
     * @dev Transfer tokens to a specified address
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    /**
     * @dev Returns the remaining number of tokens that spender is allowed to spend
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }
    
    /**
     * @dev Approve the passed address to spend the specified amount of tokens
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "Approve to zero address");
        
        allowances[msg.sender][spender] = amount;
        
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    /**
     * @dev Transfer tokens from one address to another using allowance
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Insufficient allowance");
        
        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
    
    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "Approve to zero address");
        
        allowances[msg.sender][spender] += addedValue;
        
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }
    
    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "Approve to zero address");
        require(allowances[msg.sender][spender] >= subtractedValue, "Decreased allowance below zero");
        
        allowances[msg.sender][spender] -= subtractedValue;
        
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }
    
    /**
     * @dev Mint new tokens (restricted to owner)
     * @notice For development/testing. Remove or add more sophisticated access control for production.
     */
    function mint(address to, uint256 amount) public onlyOwner returns (bool) {
        require(to != address(0), "Mint to zero address");
        
        totalSupply += amount;
        balances[to] += amount;
        
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
        return true;
    }
    
    /**
     * @dev Transfer ownership to a new address
     */
    function transferOwnership(address newOwner) public onlyOwner returns (bool) {
        require(newOwner != address(0), "New owner is zero address");
        
        address oldOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(oldOwner, newOwner);
        return true;
    }
    
    /**
     * @dev Burn tokens from sender's account
     */
    function burn(uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance to burn");
        
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        
        emit Burn(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}
