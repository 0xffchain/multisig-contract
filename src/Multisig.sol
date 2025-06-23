// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Multisig {

    address[] public signers;
    mapping(address => bool) public isSigner;
    uint256 public threshold; 
    uint256 public nonce; 
// history of the multisig. computation should be done offchain 

    modifier onlyContract() {
        require(msg.sender == address(this), "Not authorized");
        _;
    }

    event Executed(address indexed to, uint256 value, bytes data, bool success, uint256 indexed nonce);
    event Updated(address[] newOwners, uint256 newThreshold, uint256 indexed nonce);
    event Received(address indexed sender, uint256 amount);

    constructor(address[] memory _signers, uint256 _threshold) {
        require(_signers.length > 0 &&  _threshold <= _signers.length && _threshold > 0, "Kindly provide valid owners and threshold");
        for(uint256 i = 0; i < _signers.length; i++) {
            address signer = _signers[i];
            require(signer != address(0), "Signer cannot be zero address");
            require(!isSigner[signer], "Signer already exists");
            isSigner[signer] = true;
            signers.push(signer);
        }
        threshold = _threshold;

        emit Updated(_signers, _threshold, nonce);
    }

    function execute(address to, uint256 value, bytes calldata data, bytes[] calldata signatures) external returns (bool) {
        require(signatures.length >= threshold, "Not enough signatures");
        return true;
    }

    function update( address[] memory _signers, uint256 _threshold) onlyContract external returns (bool){
        
        emit Updated(_signers, _threshold, nonce);
        return true;
    }

    receive() external payable {}
}