// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KaggleDataOracle is Ownable{
    
    //       JobSeeker.         Notebook        DataPoint       Value.  Staked 
    mapping (address => mapping(string=>mapping(string=>uint))) public userDataOracle;
    
            //. validator_address    JobSeeker.         Notebook        DataPoint       Value.  Staked             
    mapping (address=>mapping(address=>mapping(string=>mapping(string=>uint)))) public validatorSplits;
       
    mapping (address=>bool) public rawDataStore;
    IERC20 public token;
       
    function getStakeValue(address ad,string memory v2,string memory v3)public view returns(uint){
        return userDataOracle[ad][v2][v3];
    }

       
    constructor(address _tokenAddress) {

        token = IERC20(_tokenAddress);
    }
    
    function setRawData(address ad, bool set) public {
        require(msg.sender==owner() || msg.sender == ad,"You can only set for yourself");
        rawDataStore[ad] = set;
           
    }
       
    function validateDataPoint( address ad,  string memory v2, string memory v3, uint val) public {
        require(rawDataStore[ad] ==true , "Raw Data not stored!");
        require(val>0,"Value must be greator than 0");
        token.transfer(msg.sender,address(this),val);
        userDataOracle[ad][v2][v3]+=val;
        validatorSplits[msg.sender][ad][v2][v3]+=val;
    }
       
    function withdrawMoney(address ad,  string memory v2, string memory v3, uint val) public{
        require(validatorSplits[msg.sender][ad][v2][v3]>=val,"Amount Exceeds Balance");
        require(userDataOracle[ad][v2][v3]>=val,"Amount Exceeds Total Balance");
        token.transfer(msg.sender,val);
        userDataOracle[ad][v2][v3]-=val;
        validatorSplits[msg.sender][ad][v2][v3]-=val;
    }
}