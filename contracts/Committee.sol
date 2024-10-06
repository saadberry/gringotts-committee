// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "hardhat/console.sol";

/**
* @title Committee
* Written for Gringotts Wizarding Bank, to autonomously manage their committees.
methods: 
(1) AddMoney()
(2) CheckBalance()
(3) RequestEarlyWithdrawal()
(4) AllocateMemory()
(5) ComputePayouts()
.. and more
**/

contract Committee {
    address public owner;
    uint public sessionId;
    uint public constant MAX_USERS_PER_SESSION = 5;

    constructor() {
        owner = msg.sender;
        sessionId = 0;
    }

    struct User {
        address userAddress; // Address of user
        uint balance; // Balance of user
        uint sessionId; // Session id of user
    }

    struct Session {
        uint sessionId; // ID of the session
        uint totalBalance; // Total balance of the session
        address[] payoutQueue; // Queue of addresses to be payed to
        address[] members; // Members in session
        bool isActive; 
    }

    // Mapping user address to User struct
    mapping(address => User) public users;
    // Mapping session ID to Session struct
    mapping(uint => Session) public sessions;

    /*
    @dev Create a new session
    @return <uint> sessionId ID of the newly created session
    */
    function createNewSession() public returns (uint) {
        sessions[sessionId] = Session(sessionId, 0, new address[](0), new address[](0), true);
        uint currentId = sessionId;
        sessionId += 1; 
        return currentId;
    }

    /*
    @dev Add a new user to an existing session
    @param <address> _userAddress Address of the new user
    @param <uint> _sessionId ID of the session to join
    */
    function addUserToSession(address _userAddress, uint _sessionId) public {
        require(sessions[_sessionId].isActive, "Session does not exist or is not active");
        require(sessions[_sessionId].members.length < MAX_USERS_PER_SESSION, "Session is full");
        require(users[_userAddress].userAddress == address(0), "User already exists");
        
        users[_userAddress] = User(_userAddress, 0, _sessionId);
        sessions[_sessionId].members.push(_userAddress);
    }

    /*
    @dev Get users in a said session
    @param: <uint> ID of Session 
    @return: <address[] memory> Users in a session
    */
    function getUsersInSession(uint _sessionId) public view returns (address[] memory) {
        require(sessions[_sessionId].isActive, "Session does not exist or is not active");
        return sessions[_sessionId].members;    
        }

    /*
    @dev Add money to the committee
    @param userAddress Address of user
    @param amount Amount to be added
    */
    function AddMoney(address userAddress, uint amount) public {
        require(users[userAddress].userAddress != address(0), "User does not exist");
        users[userAddress].balance += amount;
        sessionId = users[userAddress].sessionId;
        sessions[sessionId].totalBalance += amount;
    }


    /*
    @dev Allows user to request an early withdrawal
    @param <address> Address of user
    */
    function RequestEarlyWithdrawal(address user) public {}

    /*
    
    */
    function DecidePayouts() public {

    }

    /*
    @dev Check balance of user
    @param <address> userAddress Address of user
    @return <uint> Balance of a user
    */
    function CheckBalance(address userAddress) public view returns (uint) {
        require(users[userAddress].userAddress != address(0), "User does not exist");
        return users[userAddress].balance;
    }

    /*
    @dev Check if a session is full
    @param _sessionId ID of the session
    @return <bool> Result of users > MAX_USERS_PER_SESSION
    */
    function isSessionFull(uint _sessionId) public view returns (bool) {
        require(sessions[_sessionId].isActive, "Session does not exist or is not active");
        return sessions[_sessionId].members.length >= MAX_USERS_PER_SESSION;
    }

    /*
    @dev Check if a session is active
    @param _sessionId ID of the session
    @return <bool> Active status of a session
    */
    function isSessionActive(uint _sessionId) public view returns (bool) {
        return sessions[_sessionId].isActive;
    }
}
