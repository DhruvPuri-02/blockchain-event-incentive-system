// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Blockchain Event Incentive System
/// @author Dhruv
/// @notice Manages event creation and student reward distribution on blockchain

contract EventToken {

    /* =============================================================
                            STATE VARIABLES
    ============================================================= */

    address public owner;
    uint256 public totalSupply;

    struct Event {
        uint256 id;
        string name;
        string description;
        uint256 date;          // Unix timestamp
        address createdBy;
    }

    Event[] private events;

    mapping(address => uint256) private balanceOf;
    mapping(address => uint256[]) private studentEvents;
    mapping(address => mapping(uint256 => uint256)) private tokensPerEvent;
    mapping(address => mapping(uint256 => bool)) private hasParticipated;


    /* =============================================================
                                MODIFIER
    ============================================================= */

    /// @notice Restricts function to contract owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only organizer can call this");
        _;
    }


    /* =============================================================
                              CONSTRUCTOR
    ============================================================= */

    /// @notice Sets deployer as contract owner
    constructor() {
        owner = msg.sender;
    }


    /* =============================================================
                              EVENT LOGIC
    ============================================================= */

    /// @notice Creates a new event
    /// @param name Name of the event
    /// @param description Short description of the event
    /// @param date Event date in Unix timestamp format
    function createEvent(
        string memory name,
        string memory description,
        uint256 date
    ) public onlyOwner {

        events.push(Event({
            id: events.length,
            name: name,
            description: description,
            date: date,
            createdBy: msg.sender
        }));
    }

    /// @notice Returns total number of events created
    /// @return count Total events
    function getEventsCount()
        public
        view
        returns (uint256 count)
    {
        return events.length;
    }

    /// @notice Returns details of a specific event
    /// @param eventId ID of the event
    /// @return id Event ID
    /// @return name Event name
    /// @return description Event description
    /// @return date Event timestamp
    /// @return createdBy Address of creator
    function getEvent(uint256 eventId)
        public
        view
        returns (
            uint256 id,
            string memory name,
            string memory description,
            uint256 date,
            address createdBy
        )
    {
        require(eventId < events.length, "Invalid event ID");

        Event memory e = events[eventId];

        return (
            e.id,
            e.name,
            e.description,
            e.date,
            e.createdBy
        );
    }


    /* =============================================================
                          REWARD LOGIC
    ============================================================= */

    /// @notice Rewards a student for participating in an event
    /// @param eventId ID of the event
    /// @param student Address of the student
    /// @param amount Number of tokens to reward
    function rewardStudentForEvent(
        uint256 eventId,
        address student,
        uint256 amount
    ) public onlyOwner {

        require(eventId < events.length, "Invalid event ID");
        require(student != address(0), "Invalid student address");
        require(amount > 0, "Amount must be greater than zero");

        balanceOf[student] += amount;
        totalSupply += amount;

        tokensPerEvent[student][eventId] += amount;

        if (!hasParticipated[student][eventId]) {
            studentEvents[student].push(eventId);
            hasParticipated[student][eventId] = true;
        }
    }


    /* =============================================================
                          STUDENT VIEW FUNCTIONS
    ============================================================= */

    /// @notice Returns total token balance of a student
    /// @param student Address of the student
    /// @return balance Total token balance
    function getBalance(address student)
        public
        view
        returns (uint256 balance)
    {
        return balanceOf[student];
    }

    /// @notice Returns tokens earned by student in a specific event
    /// @param student Address of the student
    /// @param eventId ID of the event
    /// @return tokens Tokens earned in that event
    function getTokensPerEvent(address student, uint256 eventId)
        public
        view
        returns (uint256 tokens)
    {
        return tokensPerEvent[student][eventId];
    }

    /// @notice Returns all event IDs attended by a student
    /// @param student Address of the student
    /// @return eventIds Array of event IDs
    function getStudentEvents(address student)
        public
        view
        returns (uint256[] memory eventIds)
    {
        return studentEvents[student];
    }

    /// @notice Calculates marks based on total tokens
    /// @param student Address of the student
    /// @return marks Number of marks (10 tokens = 1 mark)
    function calculateMarks(address student)
        public
        view
        returns (uint256 marks)
    {
        return balanceOf[student] / 10;
    }
}
