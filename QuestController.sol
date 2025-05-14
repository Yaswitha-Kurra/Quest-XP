// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IQuestVerifier {
    function isQuestCompleted(address user) external view returns (bool);
}

interface IDailyLoginVerifier {
    function recordLogin(address user) external;
}

contract QuestController {
    struct Quest {
        string name;
        address verifier;
        uint256 rewardXP;
        bool isActive;
    }

    mapping(uint256 => Quest) public quests;
    mapping(address => mapping(uint256 => bool)) public completed;
    mapping(address => uint256) public xp;
    mapping(address => uint256) public lastClaimTimestamp;

    address public owner;
    uint256 public questCounter;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    event QuestAdded(uint256 indexed questId, string name);
    event QuestCompleted(address indexed user, uint256 questId, uint256 rewardXP);

    constructor() {
        owner = msg.sender;
    }

    function addQuest(string memory name, address verifier, uint256 rewardXP) external onlyOwner {
        quests[questCounter] = Quest(name, verifier, rewardXP, true);
        emit QuestAdded(questCounter, name);
        questCounter++;
    }

    function deactivateQuest(uint256 questId) external onlyOwner {
        require(questId < questCounter, "Invalid quest ID");
        quests[questId].isActive = false;
    }

    function claimAllXP(uint256[] memory questIds) external {
        require(block.timestamp - lastClaimTimestamp[msg.sender] >= 5 minutes, "You can only claim once every 5 minutes");

        uint256 totalXP = 0;

        for (uint i = 0; i < questIds.length; i++) {
            uint256 questId = questIds[i];
            Quest memory q = quests[questId];

            if (q.isActive && !completed[msg.sender][questId] && IQuestVerifier(q.verifier).isQuestCompleted(msg.sender)) {
                completed[msg.sender][questId] = true;
                totalXP += q.rewardXP;

                // ✅ Automatically record login for Daily Login quest (ID 0)
                if (questId == 0) {
                    try IDailyLoginVerifier(q.verifier).recordLogin(msg.sender) {
                        // recorded successfully
                    } catch {
                        // fail silently
                    }
                }

                emit QuestCompleted(msg.sender, questId, q.rewardXP);
            }
        }

        require(totalXP > 0, "No XP to claim");

        xp[msg.sender] += totalXP;
        lastClaimTimestamp[msg.sender] = block.timestamp;
    }

    function getLevel(address user) external view returns (uint256 level) {
        uint256 userXP = xp[user];

        if (userXP < 100) return 1;
        else if (userXP < 250) return 2;
        else if (userXP < 500) return 3;
        else if (userXP < 1000) return 4;
        else return 5;
    }
}
