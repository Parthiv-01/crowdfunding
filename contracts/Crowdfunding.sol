// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Crowdfunding {
    mapping(address => uint256) public funders;
    uint256 public deadline;
    uint256 public targetFunds;
    string public name;
    address public owner;
    bool public fundsWithdrawn;

    event Funded(address _funder, uint256 _amount);
    event OwnerWithdraw(uint256 _amount);
    event FunderWithdraw(address _funder, uint256 _amount);

    constructor(
        string memory _name,
        uint256 _targetFunds,
        uint256 _deadline
    ) {
        owner = msg.sender;
        name = _name;
        targetFunds = _targetFunds;
        deadline = _deadline;
    }

    function fund() public payable {
        require(isFundEnabled() == true, "Funding period is over");

        funders[msg.sender] += msg.value;
        emit Funded(msg.sender, msg.value);
    }

    function withdrawOwner() public {
        require(isFundSuccess() == true, "Cannot Withdraw Funds");
        require(msg.sender == owner, "Only owner can withdraw funds");

        uint256 amountToSend = address(this).balance;
        (bool success, ) = msg.sender.call{value: amountToSend}("");
        require(success, "Unable to send");
        fundsWithdrawn = true;
        emit OwnerWithdraw(amountToSend);
    }

    function withdrawFunder() public {
        require(isFundSuccess() == false && isFundSuccess() == false, "Cannot Withdraw Funds");
        
        uint256 amountToSend = funders[msg.sender];
        funders[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amountToSend}("");
        require(success, "Unable to send");
        emit FunderWithdraw(msg.sender, amountToSend);
    }

    //Helper functions

    function isFundEnabled() public view returns (bool) {
        if(block.timestamp > deadline || fundsWithdrawn) {
            return false;
        }else{
            return true;
        }
    }

    function isFundSuccess() public view returns (bool) {
        if(address(this).balance >= targetFunds || fundsWithdrawn) {
            return true;
        }else{
            return false;
        }
    }

}