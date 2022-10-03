//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract VotingToken is ERC20 {

    struct Votings{
        uint[5] positions;
        bool status;
        uint timeTill;
    }
    Votings public voting;
    address public owner;
    constructor(uint initialSupply, uint timeLimitFromNow) ERC20("VoteForEth", "VFE") {
        _mint(msg.sender, initialSupply);
        owner = msg.sender;
        voting.status=true;
        voting.timeTill = block.timestamp + timeLimitFromNow * 1 seconds;
        
    }

    modifier onlyEligibleVoter(address _voter) {
        uint balance = this.balanceOf(_voter);
        require(balance > 0,"Not Enough Balance");
        _;
    }


    modifier onlyOwner(){
        require(msg.sender==owner,"Only Owner Can Call this function");
        _;
    }

    modifier ifOpen(){
        if(block.timestamp>voting.timeTill){
            voting.status = false;
            require(voting.status, "Voting is closed (Voting Ended)");
        }
        require(voting.status, "Voting is closed (Can be Resumed)");
        _;
    }


    function castVotes(uint _position) public onlyEligibleVoter(msg.sender) ifOpen(){
        require(_position<voting.positions.length, "The Positions Available to vote is from 0 - 4");
        transfer(address(this),1);
        uint currentPossitions = voting.positions[_position];
        currentPossitions +=1;
        voting.positions[_position] = currentPossitions;
    }

    function getVotes() public view returns(uint[5] memory){
        return voting.positions;
    }

    function toggleStatus() onlyOwner() public {
        voting.status = !voting.status;
    }

    function getStatus() public view returns(string memory){
        if(voting.status){
            return "Voting Open";
        }
        else {
            return "Voting CLosed";
        }
    }

    
}