// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract DataOnboarderSigner is EIP712{
    
    struct DataSourceLink{
        string profile_uid;
        string platform_name;
        address corresponding_pubkey;
        bytes signature;
    }

    constructor(string memory SIGNING_DOMAIN,string memory SIGNATURE_VERSION) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION){
        
    }

    function getSigner(DataSourceLink memory result) public view returns(address){
        return _verify(result);
    }
  
    function _hash(DataSourceLink memory result) internal view returns (bytes32) {
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

    function _verify(DataSourceLink memory result) internal view returns (address) {
        bytes32 digest = _hash(result);
        return ECDSA.recover(digest, result.signature);
    }

}