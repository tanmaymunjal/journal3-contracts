// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DataOnboarderSigner.sol";

contract DataOnboarder is Ownable, DataOnboarderSigner{
    
    mapping(address=>mapping(string=>string)) public add_to_source_map;
    address router_creator;

    constructor() DataOnboarderSigner("journal3.com", "1"){
        router_creator = msg.sender;
    }

    function add_name(DataSourceLink memory verified_data_source) external{
        require(router_creator == getSigner(verified_data_source), "Incorrectly signed data source verification request");
        require(bytes(add_to_source_map[msg.sender][verified_data_source.platform_name]).length==0, "Data Source Already Verified");
        add_to_source_map[msg.sender][verified_data_source.platform_name] = verified_data_source.profile_uid;
    }

    function setRouterCreator(address _creator) external onlyOwner{
        router_creator = _creator;
    }

}