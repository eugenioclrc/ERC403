// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20} from "./ERC20.sol";
import {LibString} from "solady/utils/LibString.sol";

contract Token is ERC20 {
    // we need to know the tokenId to be able to emit the events on the 403 contract
    uint256 public immutable tokenId;
    // owner is the 403 contract
    address private immutable _owner;
    constructor(uint256 _tokenId) ERC20("Token", "TKN", 18) {
        tokenId = _tokenId;
        _owner = msg.sender;
        string memory idStr = LibString.toString(_tokenId);
        name = string.concat("Token ERC404, id ", idStr);
        symbol = string.concat("ERC404-", idStr);
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


}