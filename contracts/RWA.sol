// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RWARoles.sol";
import "./RWAPayments.sol";

contract RWA is ERC1155, RWARoles, RWAPayments {
    string public name;
    string public symbol;
    uint256 private nextTokenId = 1;

    struct Asset {
        uint256 totalSupply;
        uint256 fungibleSupply;
        uint256 salePrice;
        uint256 leasePrice;
        address creator;
    }

    mapping(uint256 => Asset) public assets;

    event AssetCreated(uint256 indexed tokenId, uint256 totalSupply, uint256 salePrice, uint256 leasePrice);
    event AssetTransferred(uint256 indexed tokenId, address from, address to, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory uri,
        address admin,
        address _platformFeeCollector
    ) ERC1155(uri) RWARoles(admin) RWAPayments(_platformFeeCollector) {
        name = _name;
        symbol = _symbol;
    }

    function createAsset(uint256 totalSupply, uint256 fungibleSupply, uint256 salePrice, uint256 leasePrice) external onlySeller {
        require(totalSupply >= fungibleSupply, "Invalid supply values");
        uint256 tokenId = nextTokenId++;
        assets[tokenId] = Asset(totalSupply, fungibleSupply, salePrice, leasePrice, msg.sender);
        _mint(msg.sender, tokenId, totalSupply, "");
        emit AssetCreated(tokenId, totalSupply, salePrice, leasePrice);
    }

    function transferAsset(uint256 tokenId, address to, uint256 amount) external payable {
        require(balanceOf(msg.sender, tokenId) >= amount, "Insufficient balance");
        require(msg.value >= assets[tokenId].salePrice * amount, "Insufficient payment");

        _handlePayment(msg.sender, msg.value);
        _safeTransferFrom(msg.sender, to, tokenId, amount, "");
        emit AssetTransferred(tokenId, msg.sender, to, amount);
    }
}
