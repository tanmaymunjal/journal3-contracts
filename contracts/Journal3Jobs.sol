// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";


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
}

contract Journal3Jobs is Ownable{

    // address indexer_wallet;
    // Job[] all_jobs;
    uint job_cnt;
    mapping (uint => Job) all_jobs;


    constructor(){
        job_cnt = 0;
    }

    function createJob(bytes32 metadata_ipfs, address[] memory qualifications, uint16[][] memory qualification_filtering, Checkpoints[] memory checkpoints, uint checkpoint_size, uint qualifications_size) public returns(bool){
        Job storage tempJob = all_jobs[job_cnt];
        tempJob.metadata_ipfs = metadata_ipfs;

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

    // function stake_jou_job()
    // function apply_job()
    // function close_job()



     

}