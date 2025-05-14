// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IQuestVerifier {
    function isQuestCompleted(address user) external view returns (bool);
}

contract PlayRPSVerifier is IQuestVerifier {
    mapping(address => uint256) public lastPlay;
    address public rpsContract;
    address public owner;

    constructor(address _rpsContract) {
        rpsContract = _rpsContract;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function updateRPSContract(address _newRPS) external onlyOwner {
        rpsContract = _newRPS;
    }

    function recordPlay(address player) external {
        require(msg.sender == rpsContract, "Unauthorized");
        lastPlay[player] = block.timestamp;
    }

    function isQuestCompleted(address user) external view override returns (bool) {
        return block.timestamp - lastPlay[user] < 1 days;
    }
}
