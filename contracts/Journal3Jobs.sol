// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ISkillsRepo.sol";
import "./errors.sol";

struct Checkpoints {
    uint checkpoint_addr;
    string checkpoint_name;
    address[] candidates;
}

struct Job {
    string metadata_ipfs;
    mapping(uint=>uint[]) qualifications;
    uint[] qual_list;
    uint qualif_size;
    mapping(uint=>Checkpoints) candidate_profiles;
    uint256 job_staked;
    bool is_active;
    address closing_indexer;
    bool gasless_experience;
    uint root;
}

contract Journal3Jobs is Ownable{
    event JobCreate(uint jobID,address indexer);
    event JobStake(uint jobID,uint amount);
    event JobAcceptApplicant(uint jobID,address applicant);
    event JobDeclineApplicant(uint jobID,address applicant);


    uint jobCount;
    mapping (uint => Job) public all_jobs;
    mapping (address=>uint) skill_creator_rewards;
    mapping(address=>uint) oracle_reward_returns;
    
    IERC20 journal3;
    ISkillsRepo skills_repo;

    constructor(address contract_address){
        jobCount = 0;
        journal3 = IERC20(contract_address);
    }

    function createJob(string calldata metadata_ipfs, uint[] calldata qualifications, uint[][] calldata qualification_filtering, Checkpoints[] calldata checkpoints, uint checkpoint_size, uint qualifications_size, uint root, address closing_indexer) public returns(bool){
        Job memory tempJob = all_jobs[jobCount];
        tempJob.metadata_ipfs = metadata_ipfs;
        
        tempJob.root = root;

        for (uint i; i < checkpoint_size;){
            tempJob.candidate_profiles[checkpoints[i].checkpoint_addr] = checkpoints[i];
            unchecked { ++i; }
        }

        for (uint i; i < qualifications_size;){
            for(uint j; j < qualifications_size;){
                if(qualification_filtering[i][j]==1){
                    tempJob.qualifications[qualifications[i]].push(qualifications[j]);
                }
                unchecked { ++j; }
            }
            if(tempJob.qualifications[qualifications[i]].length == 0){
                tempJob.qualifications[qualifications[i]].push(0);
                tempJob.qualifications[qualifications[i]].push(0);
            }
            unchecked { ++i; }
        }
        tempJob.is_active = false;
        tempJob.job_staked = 0;
        tempJob.closing_indexer = closing_indexer;
        tempJob.qual_list = qualifications;
        tempJob.qualif_size = qualifications_size;
        emit JobCreate(jobCount,closing_indexer);
        jobCount++;

        return true;
        }

    function stake_on_job(uint idx, uint amount) public {
        if(amount <= 0)
           revert InvalidStakeAmount();
        uint256 allowance = journal3.allowance(msg.sender, address(this));
        if(allowance < amount)
            revert InsufficientAmount(amount);
        journal3.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        all_jobs[idx].job_staked += amount;
        all_jobs[idx].is_active = true;
        emit JobStake(idx, amount);
    }
    
    function apply_job(uint idx) public returns(bool) {
        if(all_jobs[idx].is_active==false)
           revert JobNotActive();
        if(all_jobs[idx].job_staked==0)
           revert JobNotAcceptingApplications();

        uint currnode = all_jobs[idx].root;
        
        while (currnode!=0){
            if (skills_repo.balanceOf(msg.sender, currnode)==1){
                currnode = all_jobs[idx].qualifications[currnode][0];
                uint skill_creation_fees = all_jobs[idx].job_staked/400000;
                skill_creator_rewards[skills_repo.get_creator_token_id_map(currnode)] += skill_creation_fees;
                all_jobs[idx].job_staked -= skill_creation_fees;
                if(all_jobs[idx].candidate_profiles[currnode].checkpoint_addr==currnode){
                    all_jobs[idx].candidate_profiles[currnode].candidates.push(msg.sender);
                        emit JobAcceptApplicant(idx,msg.sender);
                        return true;
                }
            }
            else{
                currnode = all_jobs[idx].qualifications[currnode][1];
            }
        }
         emit JobDeclineApplicant(idx,msg.sender);
        return false;
    } 

    function close_job(uint idx) public {
        if(msg.sender!=owner()	|| msg.sender!=all_jobs[idx].closing_indexer)
              revert UnauthorizedCloser();
        if(all_jobs[idx].is_active == false)
              revert JobNotActive();

        uint qualif_size = all_jobs[idx].qualif_size;
        for(uint i; i< qualif_size;){
            oracle_reward_returns[skills_repo.get_oracle_data_src(all_jobs[idx].qual_list[i])] +=1;
            uint transferAmt = 51 * all_jobs[idx].job_staked * oracle_reward_returns[skills_repo.get_oracle_data_src(all_jobs[idx].qual_list[i])] / (100 * all_jobs[idx].qualif_size);
            all_jobs[idx].job_staked -= transferAmt;
            journal3.transfer(
                skills_repo.get_oracle_data_src(all_jobs[idx].qual_list[i]), 
                transferAmt
            );
            oracle_reward_returns[skills_repo.get_oracle_data_src(all_jobs[idx].qual_list[i])] = 0;
            unchecked { ++i; }
            
        }
        all_jobs[idx].is_active = false;
    }

    function claim_royalties_skill_creator() public {
        journal3.transfer(msg.sender, skill_creator_rewards[msg.sender]);
        skill_creator_rewards[msg.sender] = 0;
    }
     
}