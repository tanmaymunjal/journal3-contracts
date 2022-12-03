// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IKaggleDataOracle {
    function fetch_dp_value(address job_seker_addr, string memory dp_label) external view returns(string memory);
    function return_self_addr() external view returns(address);
}