// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DPay {
    address public owner;

    event Deposit(address indexed from, uint amount, uint timestamp);
    event Withdraw(address indexed to, uint amount, uint timestamp);
    event Transfer(address indexed to, uint amount, uint timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Allow ETH to be sent directly
    receive() external payable {
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    // Owner-only deposit (optional explicit trigger)
    function deposit() public payable onlyOwner {
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    // Owner-only withdraw
    function withdraw(uint _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(owner).transfer(_amount);
        emit Withdraw(owner, _amount, block.timestamp);
    }

    // Owner-only transfer to another address (GPay-style send)
    function transfer(address _to, uint _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(_to).transfer(_amount);
        emit Transfer(_to, _amount, block.timestamp);
    }

    // Anyone can view contract balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
