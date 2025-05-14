// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 * @title DailyLoginVerifier
 * @notice Used as a verifier for daily login XP quests in QuaiQuests.
 *         This contract tracks the last time each user claimed daily XP
 *         and allows claiming only once every 24 hours.
 */
contract DailyLoginVerifier {
    mapping(address => uint256) public lastLogin;

    /**
     * @notice Checks if the user is eligible for daily login XP.
     * @param user The wallet address of the user.
     * @return True if 24 hours have passed since last login claim.
     */
    function isQuestCompleted(address user) external view returns (bool) {
        return block.timestamp > lastLogin[user] + 1 days;
    }

    /**
     * @notice Called by QuestController after successful XP claim.
     * @dev This must be called ONLY after confirming `isQuestCompleted` is true.
     * @param user The wallet address of the user to record login for.
     */
    function recordLogin(address user) external {
        lastLogin[user] = block.timestamp;
    }
}
