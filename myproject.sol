// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearningQuests {
    address public owner;
    
    struct Quest {
        uint256 id;
        string name;
        string description;
        uint256 reward;
        bool isCompleted;
    }

    mapping(uint256 => Quest) public quests;
    mapping(address => uint256[]) public userQuests;
    uint256 public questCount;

    event QuestCreated(uint256 indexed questId, string name, string description, uint256 reward);
    event QuestCompleted(address indexed user, uint256 indexed questId);
    event RewardClaimed(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier questExists(uint256 questId) {
        require(questId < questCount, "Quest does not exist");
        _;
    }

    modifier questNotCompleted(uint256 questId) {
        require(!quests[questId].isCompleted, "Quest already completed");
        _;
    }

    modifier hasNotCompletedQuest(uint256 questId) {
        bool alreadyCompleted = false;
        for (uint256 i = 0; i < userQuests[msg.sender].length; i++) {
            if (userQuests[msg.sender][i] == questId) {
                alreadyCompleted = true;
                break;
            }
        }
        require(!alreadyCompleted, "Quest already completed by this user");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createQuest(string memory name, string memory description, uint256 reward) public onlyOwner {
        quests[questCount] = Quest(questCount, name, description, reward, false);
        emit QuestCreated(questCount, name, description, reward);
        questCount++;
    }

    function completeQuest(uint256 questId) public questExists(questId) questNotCompleted(questId) {
        quests[questId].isCompleted = true;
        userQuests[msg.sender].push(questId);
        emit QuestCompleted(msg.sender, questId);
    }

    function claimReward(uint256 questId) public questExists(questId) hasNotCompletedQuest(questId) {
        require(quests[questId].isCompleted, "Quest not completed yet");
        uint256 reward = quests[questId].reward;
        payable(msg.sender).transfer(reward);
        emit RewardClaimed(msg.sender, reward);
    }

    function fundContract() public payable onlyOwner {}

    function getQuestDetails(uint256 questId) public view returns (string memory, string memory, uint256, bool) {
        return (quests[questId].name, quests[questId].description, quests[questId].reward, quests[questId].isCompleted);
    }

    function getUserQuests(address user) public view returns (uint256[] memory) {
        return userQuests[user];
    }

    receive() external payable {}
}
