// SPDX-License-Identifier: GPL-3.0

pragma solidity  >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./errors.sol";

contract KaggleDataOracle is Ownable{

    struct RawData{
        string ipfs;
        bool isActive;
        address verifiedBy;
    }
    struct MaxValue{
        string attributeValue;
        uint stakedAmount;
    }
    
    //       JobSeeker.         Notebook        DataPoint       Value.  Staked 
    mapping (address => mapping(string=>mapping(string=>uint))) public userDataOracle;
    
            //. validator_address    JobSeeker.         Notebook        DataPoint       Value.  Staked             
    mapping (address=>mapping(address=>mapping(string=>mapping(string=>uint)))) public validatorSplits;
       
       mapping (address=>mapping(string=>MaxValue)) public mostFavoredDataOracle;
    mapping (address=>RawData) public rawDataStore;
    IERC20 public token;
       
    function getStakeValue(address ad,string calldata v2,string calldata v3)public view returns(uint){
        return userDataOracle[ad][v2][v3];
    }

       
    constructor(address _tokenAddress) {

        token = IERC20(_tokenAddress);
    }
    
    function setRawData(address ad,string calldata ipfs, bool isActive) public {
        // require(msg.sender==owner() || msg.sender == ad,"You can only set for yourself");
        rawDataStore[ad] = RawData(ipfs,isActive,msg.sender);
           
    }
       
    function validateDataPoint( address ad,  string calldata v2, string calldata v3, uint val) public {
        if(rawDataStore[ad].isActive ==false)
            revert RawDataNotStored();

        if(val<=0)
           revert InvalidValidationFees();

        token.transferFrom(msg.sender,address(this),val);
        userDataOracle[ad][v2][v3]+=val;
        validatorSplits[msg.sender][ad][v2][v3]+=val;
        if(mostFavoredDataOracle[ad][v2].stakedAmount>userDataOracle[ad][v2][v3]){
            mostFavoredDataOracle[ad][v2] = MaxValue(v3,userDataOracle[ad][v2][v3]);
        }
    }
       
    function withdrawMoney(address ad,  string calldata v2, string calldata v3, uint val) public{
        if(validatorSplits[msg.sender][ad][v2][v3]<val)
            revert WithdrawlAmountExceedsBalance(val);

        if(userDataOracle[ad][v2][v3]<val)
            revert WithdrawlAmountExceedsBalance(val);

        token.transfer(msg.sender,val);
        userDataOracle[ad][v2][v3]-=val;
        validatorSplits[msg.sender][ad][v2][v3]-=val;
    }
    
    function return_self_addr() public view returns(address){
        return address(this);
    }

    function fetch_dp_value(address job_seker_addr, string calldata dp_label) external view returns(string memory){
        return mostFavoredDataOracle[job_seker_addr][dp_label].attributeValue;
    }
}