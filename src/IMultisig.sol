// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMultisig {
    event Executed(address indexed to, uint256 value, bytes data, bool success, uint256 indexed nonce);
    event Updated(address[] newOwners, uint256 newThreshold, uint256 indexed nonce);
    event Received(address indexed sender, uint256 amount);

    function execute(address to, uint256 value, bytes calldata data, bytes[] calldata signatures) external returns (bool);
    function update(address[] memory _signers, uint256 _threshold) external returns (bool);
    function nonce() external view returns (uint256);
    function threshold() external view returns (uint256);
    function signers(uint256) external view returns (address);
    function isSigner(address) external view returns (bool);
} 