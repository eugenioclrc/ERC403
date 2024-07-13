// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC403} from "./ERC403.sol";

contract Demo is ERC403 {
    function uri(uint256) public pure virtual override returns (string memory) {}

    function mint(address to, uint256 id, uint256 amount, bytes memory data) public virtual {
        _mint(to, id, amount, data);
    }

    function batchMint(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual {
        _batchMint(to, ids, amounts, data);
    }
}
