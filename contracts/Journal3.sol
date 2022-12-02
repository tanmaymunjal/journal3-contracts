// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";


struct Author {
    string author_gscholar_uid;
    address author_pub_address;
}



contract Journal3 is Ownable{
    // The list of paper's authors to effectively create/credential an .openml ENS that maps author's 
    // gscholar uid to public address. That aids in compensation and other indexing usecases
    Author[] authors_gscholar_uid;


    // This stores the JSON of the research paper's metadata on IPFS
    /*
    metadata = {
        "paper_title": "",
        "paper_keywords": ["", "", ""],
        "paper_doi": "",
        "paper_pdf_ipfs": "",
        "": ""
    }
    */
    string paper_metadata_ipfs_url;

    mapping(string=>address) references;

    // Some stuff here to setup an oracle

    function fetchRawDataMutations() external view returns (string memory mutation_lambda) {

    }

    // function calibrateInference() external pure returns (Performance model_perfomance) {
        // Here we will allow people to actually run the model on a given set to get accuracy/recall/F1 data
    // }

    function setupReplicationEnv() public payable {
        //Here it will generate some JSON response that we will use on our jupyter API call to generate the notebook from a boilerplate
    }

    function vouchCorrectness() public payable {
        // Here basically we allow people to stake basic ERC-20 or Eth to vouch for the correctness of the inference
    }

    function generateInference() public payable {
         //
    }

    // function create_paper_reference() -> converts this paper into a reference that anyother paper can use
    // function set_paper_references() -> adds references into this paper for all other models/papers used as inspiration or for benchmarking

}