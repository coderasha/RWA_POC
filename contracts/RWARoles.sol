// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract RWARoles is AccessControl {
    bytes32 public constant RWA_ADMIN_ROLE = keccak256("RWA_ADMIN_ROLE");
    bytes32 public constant SELLER_ROLE = keccak256("SELLER_ROLE");
    bytes32 public constant BUYER_ROLE = keccak256("BUYER_ROLE");

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RWA_ADMIN_ROLE, admin);
    }

    function addSeller(address seller) external onlyRole(RWA_ADMIN_ROLE) {
        grantRole(SELLER_ROLE, seller);
    }

    function removeSeller(address seller) external onlyRole(RWA_ADMIN_ROLE) {
        revokeRole(SELLER_ROLE, seller);
    }

    function addBuyer(address buyer) external onlyRole(RWA_ADMIN_ROLE) {
        grantRole(BUYER_ROLE, buyer);
    }

    function removeBuyer(address buyer) external onlyRole(RWA_ADMIN_ROLE) {
        revokeRole(BUYER_ROLE, buyer);
    }
}
