// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title HelloWorld
 * @dev Simple smart contract demonstrating basic Solidity functionality on Orion EVM
 */
contract HelloWorld {
    string private message;
    address public owner;
    uint256 public updateCount;

    event MessageUpdated(string oldMessage, string newMessage, address updatedBy);

    /**
     * @dev Constructor sets the initial message
     */
    constructor() {
        message = "Hello, Orion!";
        owner = msg.sender;
        updateCount = 0;
    }

    /**
     * @dev Returns the current message
     * @return Current message string
     */
    function getMessage() public view returns (string memory) {
        return message;
    }

    /**
     * @dev Updates the message (anyone can call)
     * @param newMessage The new message to set
     */
    function setMessage(string memory newMessage) public {
        string memory oldMessage = message;
        message = newMessage;
        updateCount++;
        emit MessageUpdated(oldMessage, newMessage, msg.sender);
    }

    /**
     * @dev Get the total number of times message has been updated
     * @return Number of updates
     */
    function getUpdateCount() public view returns (uint256) {
        return updateCount;
    }

    /**
     * @dev Get contract owner
     * @return Address of owner
     */
    function getOwner() public view returns (address) {
        return owner;
    }
}
