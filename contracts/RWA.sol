// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RWARoles.sol";
import "./RWALeaseManager.sol";

contract RWA is ERC1155, Ownable, RWARoles {
    string public name;
    string public symbol;
    uint256 public platformFee = 100; // 1% default
    uint256 private nextTokenId = 1;
    address public platformFeeCollector;
    RWALeaseManager public leaseManager;

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
    event PlatformFeeUpdated(uint256 newFee);
    event PlatformFeeCollectorUpdated(address indexed newCollector);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory uri,
        address admin,
        address _platformFeeCollector
    ) ERC1155(uri) RWARoles(admin) Ownable(admin) {
        require(_platformFeeCollector != address(0), "Invalid fee collector");
        name = _name;
        symbol = _symbol;
        platformFeeCollector = _platformFeeCollector;
        leaseManager = new RWALeaseManager(_platformFeeCollector);
    }

    function setPlatformFee(uint256 newFee) external onlyOwner {
        require(newFee <= 1000, "Fee too high");
        platformFee = newFee;
        emit PlatformFeeUpdated(newFee);
    }

    function setPlatformFeeCollector(address newCollector) external onlyOwner {
        require(newCollector != address(0), "Invalid address");
        platformFeeCollector = newCollector;
        emit PlatformFeeCollectorUpdated(newCollector);
    }

    function createAsset(uint256 totalSupply, uint256 fungibleSupply, uint256 salePrice, uint256 leasePrice) external {
        require(hasRole(SELLER_ROLE, msg.sender), "Only Sellers can create assets");
        require(totalSupply >= fungibleSupply, "Invalid supply values");
        uint256 tokenId = nextTokenId++;
        assets[tokenId] = Asset(totalSupply, fungibleSupply, salePrice, leasePrice, msg.sender);
        _mint(msg.sender, tokenId, totalSupply, "");
        emit AssetCreated(tokenId, totalSupply, salePrice, leasePrice);
    }

    function transferAsset(uint256 tokenId, address to, uint256 amount) external payable {
        require(balanceOf(msg.sender, tokenId) >= amount, "Insufficient balance");
        require(msg.value >= assets[tokenId].salePrice * amount, "Insufficient payment");

        uint256 fee = (msg.value * platformFee) / 10000;
        uint256 sellerAmount = msg.value - fee;

        payable(platformFeeCollector).transfer(fee);
        payable(msg.sender).transfer(sellerAmount);

        _safeTransferFrom(msg.sender, to, tokenId, amount, "");
        emit AssetTransferred(tokenId, msg.sender, to, amount);
    }

    function leaseAsset(uint256 tokenId, address lessee, uint256 finePercentage) external payable {
        leaseManager.leaseAsset{value: msg.value}(tokenId, msg.sender, lessee, finePercentage);
    }
}
