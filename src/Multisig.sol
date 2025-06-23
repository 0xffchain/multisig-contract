// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Multisig {

    address[] public owners;
    mapping(address => bool) public isOwner;
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

    constructor(address[] memory _owners, uint256 _threshold) {}

    function execute(address to, uint256 value, bytes calldata data, bytes[] calldata signatures) external returns (bool) {}

    function update( address[] memory _owners, uint256 _threshold) external returns (bool){}

    receive() external payable {}
}