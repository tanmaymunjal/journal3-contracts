// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DataOnboarderSigner.sol";
import "./errors.sol";

contract DataOnboarder is Ownable, DataOnboarderSigner{
    
    mapping(address=>mapping(string=>string)) public add_to_source_map;
    mapping(string=>mapping(string=>address)) public source_to_add_map;
    address router_creator;

    //inialises the router_creator as msg.sender in constructor
    constructor() DataOnboarderSigner("journal3.com", "1"){
        router_creator = msg.sender;
    }

    //adds data source to user data source link map
    function add_data_source(DataSourceLink calldata verified_data_source) external{
        
        //checks that the creator of contract is the one who initialised the data source to be correct
        //note: to review this, having only the creator of contract make data sources seems scammy
        address request_signer = getSigner(verified_data_source);
        if (router_creator != request_signer)
            // Error call using named parameters. Equivalent to
            // revert InsufficientBalance(balance[msg.sender], amount);
            revert IncorrectlySignedDataSourceRequest({
                sender: request_signer
            });

        //checks if data source already in users data source map
        if (bytes(add_to_source_map[msg.sender][verified_data_source.platform_name]).length!=0)
            revert DataSourceAlreadyExists();
        //else adds it to the map
        add_to_source_map[msg.sender][verified_data_source.platform_name] = verified_data_source.profile_uid;
        source_to_add_map[verified_data_source.platform_name][verified_data_source.profile_uid] = msg.sender;
    }

    //sets route creator, can only be modified by owner of contract 
    function setRouterCreator(address _creator) external onlyOwner{
        router_creator = _creator;
    }

}