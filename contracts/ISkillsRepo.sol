// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface ISkillsRepo is IERC1155 {
    function get_creator_token_id_map(uint tokenid) external view returns (address);
    function get_oracle_data_src(uint tokenid) external view returns (address);
}