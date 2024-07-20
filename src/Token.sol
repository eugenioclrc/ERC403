// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20} from "./ERC20.sol";
import {LibString} from "solady/utils/LibString.sol";
import {ERC403} from "./ERC403.sol";

contract Token is ERC20 {
    // we need to know the tokenId to be able to emit the events on the 403 contract
    uint256 public immutable tokenId;
    // owner is the 403 contract
    address private immutable _owner;

    constructor(uint256 _tokenId) ERC20("Token", "TKN", 18) {
        tokenId = _tokenId;
        _owner = msg.sender;
        string memory idStr = LibString.toString(_tokenId);
        name = string.concat("Token ERC403, id ", idStr);
        symbol = string.concat("ERC403-", idStr);
    }

    function erc1155Transfer(address from, address to, uint256 amount) public {
        require(msg.sender == _owner, "!owner");

        // @notice amount in items has no decimals, so `* 1 ether` transform it in token
        amount = amount * 1 ether;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == _owner, "!owner");
        _mint(to, amount);
    }

    function _handleTransfer(address from, address to, uint256 amount) internal {
        if (from == to) {
            return;
        }
        // operator is the ERC20 contract
        uint256 originalBalance = balanceOf[to];
        uint256 amountMint = ((originalBalance + amount) / 1 ether) - (originalBalance / 1 ether);

        originalBalance = balanceOf[from];
        uint256 amountBurn = (originalBalance / 1 ether) - ((originalBalance - amount) / 1 ether);

        ERC403(_owner).emitEvents(tokenId, from, amountBurn, to, amountMint);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _handleTransfer(msg.sender, to, amount);
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _handleTransfer(from, to, amount);
        return super.transferFrom(from, to, amount);
    }
}
