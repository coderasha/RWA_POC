// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract RWARoles is AccessControl {
    bytes32 public constant SELLER_ROLE = keccak256("SELLER_ROLE");
    bytes32 public constant BUYER_ROLE = keccak256("BUYER_ROLE");

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(SELLER_ROLE, admin);
    }

    modifier onlySeller() {
        require(hasRole(SELLER_ROLE, msg.sender), "Not authorized: Seller only");
        _;
    }

    modifier onlyBuyer() {
        require(hasRole(BUYER_ROLE, msg.sender), "Not authorized: Buyer only");
        _;
    }

    function addSeller(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(SELLER_ROLE, account);
    }

    function addBuyer(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(BUYER_ROLE, account);
    }
}
