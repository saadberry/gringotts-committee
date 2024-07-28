// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

/**
* @title Committee
* Written for Gringotts Wizarding Bank, to autonomously manage their committees.
methods: 
(1) AddMoney()
(2) CheckBalance()
(3) RequestEarlyWithdrawal()
(4) AllocateMemory()
**/

contract Committee {

    struct User {
        address userAddress; // address of user
        uint balance; // balance of user
    }

    struct Session {
        uint sessionId; // ID of the session
        uint totalBalance; // Total balance of the session
    }

    /*
    @dev Add money to the committee
    @param Address of user
    */
    function AddMoney(address user) public {}

    /*
    @dev Check balance of user
    @param Address of user
    */
    function CheckBalance(address user) public {}

    /*
    @dev Allows user to request an early withdrawal
    @param Address of user
    */
    function RequestEarlyWithdrawal(address user) public {}
 


}
