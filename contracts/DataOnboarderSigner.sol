// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract DataOnboarderSigner is EIP712{
    
    //Link of data source through which user data is acessed
    struct DataSourceLink{
        string profile_uid;
        string platform_name;
        address corresponding_pubkey;
        bytes signature;
    }

    constructor(string memory SIGNING_DOMAIN,string memory SIGNATURE_VERSION) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION){
        
    }

    //gets public key of signer
    function getSigner(DataSourceLink calldata result) public view returns(address){
        return _verify(result);
    }
    
    //create a unique hash given the Datasource link, and user's public key
    function _hash(DataSourceLink calldata result) internal view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256("DataSourceLink(string profile_uid,string platform_name,address corresponding_pubkey)"),
                    keccak256(bytes(result.profile_uid)),
                    keccak256(bytes(result.platform_name)),
                    result.corresponding_pubkey
                )
            )
        );
    }
    
    //verifiies the hash of data and signarure of memory to verify that the data is valid and unchanged and returns the 
    // public key of user 
    function _verify(DataSourceLink calldata result) internal view returns (address) {
        bytes32 digest = _hash(result);
        return ECDSA.recover(digest, result.signature);
    }

}