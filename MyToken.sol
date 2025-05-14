// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IQuestVerifier {
    function recordPlay(address user) external;
}

contract MyToken {
    struct Player {
        address playerAddress;
        uint256 wins;
        uint256 losses;
        uint256 totalGames;
    }

    mapping(address => Player) public players;
    address[] public playerAddresses;
    address public owner;
    uint256 public entryFee = 0.1 ether;

    address public verifierAddress;

    event PlayerJoined(address indexed player);
    event GamePlayed(address indexed player, string result);

    constructor() {
        owner = msg.sender;
    }

    function setVerifier(address _verifierAddress) external {
        require(msg.sender == owner, "Only owner can set verifier");
        verifierAddress = _verifierAddress;
    }

    function play(uint8 playerMove) public payable {
        require(msg.value >= entryFee, "Entry fee is 0.1 Quai");

        if (players[msg.sender].playerAddress == address(0)) {
            players[msg.sender] = Player(msg.sender, 0, 0, 0);
            playerAddresses.push(msg.sender);
            emit PlayerJoined(msg.sender);
        }

        uint8 botMove = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 3);

        if (playerMove == botMove) {
            players[msg.sender].totalGames++;
            emit GamePlayed(msg.sender, "Draw");
        } else if ((playerMove + 1) % 3 == botMove) {
            players[msg.sender].losses++;
            players[msg.sender].totalGames++;
            emit GamePlayed(msg.sender, "Loss");
        } else {
            players[msg.sender].wins++;
            players[msg.sender].totalGames++;
            emit GamePlayed(msg.sender, "Win");
        }

        // ✅ Notify Verifier
        if (verifierAddress != address(0)) {
            IQuestVerifier(verifierAddress).recordPlay(msg.sender);
        }
    }

    function getLeaderboard() public view returns (Player[] memory) {
        Player[] memory leaderboard = new Player[](playerAddresses.length);
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            leaderboard[i] = players[playerAddresses[i]];
        }
        return leaderboard;
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}
