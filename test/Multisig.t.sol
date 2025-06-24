pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Multisig} from "../src/Multisig.sol";

contract MultisigTest is Test {
    Multisig sig;
    address[] owners;


    function setUp() public {
        owners.push(address(0x1));
        owners.push(address(0x11));
        owners.push(address(0x111));
        owners.push(address(0x1111));
        sig = new Multisig(owners, 3);
    }

    function testAnyoneCanCallExecute() public {
        vm.expectRevert("Not enough signatures");
        sig.execute(address(0x2), 0, "", new bytes[](0));

        vm.prank(address(0xBEEF));
        vm.expectRevert("Not enough signatures");
        sig.execute(address(0xBEEF), 0, "", new bytes[](0));
    }

    function testUpdateRevertsIfCalledByEOA() public {
        vm.expectRevert("Not authorized");
        sig.update(owners, 2);
    }

    function testUpdateSucceedsIfCalledByContract() public {

        vm.prank(address(sig)); 
        vm.expectEmit();
        emit Multisig.Updated(owners, 2, 0);
        sig.update(owners, 2);
        
    }
}