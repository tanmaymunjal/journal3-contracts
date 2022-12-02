// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


struct Checkpoints {
    address checkpoint_addr;
    string checkpoint_name;
    address[] candidates;
}

struct Job {
    bytes32 metadata_ipfs;
    mapping(address=>address[]) qualifications;
    mapping(address=>Checkpoints) candidate_profiles;
    uint256 jou_staked;
    bool is_active;
    address closing_indexer;
    bool gasless_experience;

    address root;
}

contract Journal3Jobs is Ownable{

    uint job_cnt;
    mapping (uint => Job) public all_jobs;
    
    event staking_successful(uint idx, uint amount);
    IERC20 public jou;

    constructor(){
        job_cnt = 0;
        jou = IERC20(0x5fE94247a9d3f9FE0a0c470Fb5B81C4076C0e12D);
    }

    function createJob(bytes32 metadata_ipfs, address[] memory qualifications, uint16[][] memory qualification_filtering, Checkpoints[] memory checkpoints, uint checkpoint_size, uint qualifications_size, address root) public returns(bool){
        Job storage tempJob = all_jobs[job_cnt];
        tempJob.metadata_ipfs = metadata_ipfs;
        
        tempJob.root = root;

        for (uint i=0; i < checkpoint_size; i++){
            tempJob.candidate_profiles[checkpoints[i].checkpoint_addr] = checkpoints[i];
        }

        for (uint i=0; i < qualifications_size; i++){
            for(uint j=0; j < qualifications_size; j++){
                if(qualification_filtering[i][j]==1){
                    tempJob.qualifications[qualifications[i]].push(qualifications[j]);
                }
            }
        }
        tempJob.is_active = false;
        tempJob.jou_staked = 0;

        job_cnt++;

        return true;


    }

    function stake_jou_job(uint idx, uint amount) public {
        require(amount > 0, "InvalidAmountException");
        uint256 allowance = jou.allowance(msg.sender, address(this));
        require(allowance >= amount, "AllowanceException");
        jou.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        all_jobs[idx].jou_staked += amount;
        emit staking_successful(idx, amount);

    }
    
    function apply_job(uint idx) public {
        // all_jobs[]
        // Run a shallow search on the decision tree, during each iteration check if node is a checkpoint and the next check fails
        // If it does break loop and return
        // Also at each iteration log the amount of JOU to be rewarded to each person

        Job memory job = jobs[idx];

        // we need the root of the tree to start the search. For now, taking it in createJob function
        address root = job.root;

        address nextNodes = job.qualifications[root];

        for (uint i = 0; i < nextNodes.length; i++)) {
            address storage currentSkillLNFT = nextNodes[i];

            // TODO: check if currentSkillNFT is a checkpoint
            if (currentSkillNFT.isCheckpoint()) {
                job.candidate_profiles[currentSkilLNFT].candidates.push(msg.sender);
            }

        }
        // TODO: How to get updated nextNodes? Shold we use queue to go through the decision truee?
    } 

    function close_job(uint idx) onlyOwner public returns(bool) {
        if(all_jobs[idx].is_active == true){
            all_jobs[idx].is_active = false;
            return true;
        }
        return false;
    }

    // claim_loyalties

     
