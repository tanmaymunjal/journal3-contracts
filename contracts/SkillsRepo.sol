// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


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
    address oracle_data_src;
    mapping(string=>string[]) string_val_filters;
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
        // _mint(to, id, amount, data);
    }

    function create_skill(string memory validator_data) public returns(bool) {
        require(_validateVerifier(skill_id_last_ptr, validator_data)==true, "Invalid Condition for creating skill");
        creator_token_id_map[skill_id_last_ptr] = msg.sender;
        skill_id_last_ptr++;
        return true;
    }

    function _validateVerifier(uint token_ptr, string memory validator_data) internal returns(bool) {
        token_id_verification_clause[token_ptr] = DDL({});
        return true;
    }

    // function verify_mint()


}
