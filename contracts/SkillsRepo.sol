// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./IKaggleDataOracle.sol";


// use kaggle;
// select address from notebooks where "tensorflow" in notebooks.frameworks group by address having count(*) > 5;

// kaggle().notebooks().frameworks("tensorflow").count(5)
// IPersonalDataOracle("Kaggle Oracle Address").fetch_notebooks()
// for loop on notebook ids and check 

// [Source({"src_name":"kaggle", "src_oracle": "0x1322133"}), Filters({"data_src": "notebooks", "frameworks": "tensorflow", "pub_date": {"$gt": dt}}), Aggregation(count), Conditional(5)]

enum StringComparator {eq, contains, ne, icontains, istartswith, iendswith}
enum IntComparator {gt, lt, le, eq, ne, ge}
enum Aggregators {sum, size, count, min, max}

struct DDL{
    uint[] prev_token_gating;
    IKaggleDataOracle oracle_data_src;
    mapping(string=>mapping(StringComparator=>string[])) string_val_filters;
    string[] string_val_filter_keys;
    mapping(string=>mapping(IntComparator=>uint)) integer_val_filters;
    mapping(string=>mapping(Aggregators=>uint)) conditional_aggregrator;
}

contract SkillsRepo is ERC1155{
    mapping(uint=>address) creator_token_id_map;
    mapping(uint=>DDL) token_id_verification_clause;
    uint skill_id_last_ptr;

    constructor() ERC1155("https://journal3-skill-metadata.s3.ap-south-1.amazonaws.com/{id}.json"){
        skill_id_last_ptr = 1;
    }

    function mint_skill(uint skillid) public {
        require(_verify_mint(skillid, msg.sender)==true, "CredentialVerificationFailed");
        _mint(msg.sender, skillid, 1, "");
    }

    function create_skill(address oracle, string[] memory validator_keys, string[][] memory validator_values, uint[] memory token_gating) public returns(bool) {
        require(_validateVerifier(oracle, skill_id_last_ptr, validator_keys, validator_values, validator_keys.length, token_gating)==true, "Invalid Condition for creating skill");
        creator_token_id_map[skill_id_last_ptr] = msg.sender;
        skill_id_last_ptr++;
        return true;
    }

    function _validateVerifier(address oracle, uint token_ptr, string[] memory validator_data, string[][] memory validator_values, uint validator_size, uint[] memory token_gating) internal returns(bool) {
        token_id_verification_clause[token_ptr].oracle_data_src = IKaggleDataOracle(oracle);
        token_id_verification_clause[token_ptr].string_val_filter_keys = validator_data;
        for(uint i=0; i<validator_size; i++){
            token_id_verification_clause[token_ptr].string_val_filters[validator_data[i]][StringComparator.eq] =  validator_values[i];
        }
        token_id_verification_clause[token_ptr].prev_token_gating = token_gating;
        return true;
    }

    function _verify_mint(uint skillid, address to_verify) internal view returns(bool){
        uint skill_length = token_id_verification_clause[skillid].string_val_filter_keys.length;
        for(uint i=0; i< skill_length; i++){
            require(
                check_condn(
                    token_id_verification_clause[skillid].string_val_filters[token_id_verification_clause[skillid].string_val_filter_keys[i]][StringComparator.eq],
                    token_id_verification_clause[skillid].oracle_data_src.fetch_dp_value(to_verify, token_id_verification_clause[skillid].string_val_filter_keys[i])
                )==true, "Return Verification Failed"
            );
        }
        return true;
    }
    
    function get_creator_token_id_map(uint tokenid) external view returns (address){
        return creator_token_id_map[tokenid];
    }

    function get_oracle_data_src(uint tokenid) external view returns (address){
        return token_id_verification_clause[tokenid].oracle_data_src.return_self_addr();
    }

    function check_condn(string[] memory a, string memory b) internal pure returns (bool){
        uint n = a.length;
        for(uint i=0; i< n; i++){
            if(keccak256(abi.encodePacked(a[i])) != keccak256(abi.encodePacked(b))){
                return false;
            }
        }
        return true;
    }

    // Nullify Transfers


}
