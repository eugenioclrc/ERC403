// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.26;

import {Demo} from "src/Demo.sol";
import {ERC403} from "src/ERC403.sol";
import {ERC20} from "src/ERC20.sol";
import {Test, console} from "forge-std/Test.sol";

contract ERC1155EventsTest is Test {
    Demo token;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    mapping(address => mapping(uint256 => uint256)) public userMintAmounts;
    mapping(address => mapping(uint256 => uint256)) public userTransferOrBurnAmounts;

    function setUp() public {
        token = new Demo();
    }

    function testMintToEOA() public {
        vm.expectEmit(true, true, true, true);
        emit ERC20.Transfer(address(0), bob, 1 ether);
        vm.expectEmit(true, true, true, true);
        emit ERC403.TransferSingle(address(this), address(0), bob, 1337, 1);
        token.mint(bob, 1337, 1, "");
    }

    function testTransfer() public {
        token.mint(bob, 1337, 10, "");
        vm.label(address(token.tokenIdToERC20(1337)), "erc20");

        ERC20 erc20 = ERC20(token.tokenIdToERC20(1337));

        vm.expectEmit(true, true, true, true);
        emit ERC403.TransferSingle(address(erc20), bob, address(0), 1337, 1);
        vm.expectEmit(true, true, true, true);
        emit ERC20.Transfer(bob, alice, 1);

        vm.prank(bob);
        erc20.transfer(alice, 1);

        vm.expectEmit(true, true, true, true);
        emit ERC20.Transfer(bob, bob, 1 ether);

        vm.prank(bob);
        erc20.transfer(bob, 1 ether);

        vm.prank(bob);
        erc20.transfer(alice, 1 ether - 1);
    }
}
