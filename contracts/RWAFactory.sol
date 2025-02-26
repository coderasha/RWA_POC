// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./RWA.sol";

contract RWAFactory is Ownable {
    event NewAssetCategoryCreated(address indexed assetContract, string category);
    event PlatformFeeCollectorUpdated(address indexed newCollector);
    event AssetCategoryRemoved(string category, address assetContract);

    mapping(string => address) public assetCategories;
    address public platformFeeCollector;

    constructor(address _platformFeeCollector) Ownable(msg.sender) {
        require(_platformFeeCollector != address(0), "Invalid collector address");
        platformFeeCollector = _platformFeeCollector;
    }

    function setPlatformFeeCollector(address _platformFeeCollector) external onlyOwner {
        require(_platformFeeCollector != address(0), "Invalid address");
        platformFeeCollector = _platformFeeCollector;
        emit PlatformFeeCollectorUpdated(_platformFeeCollector);
    }

    function createAssetCategory(
        string memory category,
        string memory name,
        string memory symbol,
        string memory uri
    ) external onlyOwner {
        require(assetCategories[category] == address(0), "Category already exists");
        RWA newAsset = new RWA(name, symbol, uri, msg.sender, platformFeeCollector);
        assetCategories[category] = address(newAsset);
        emit NewAssetCategoryCreated(address(newAsset), category);
    }

    function removeAssetCategory(string memory category) external onlyOwner {
        require(assetCategories[category] != address(0), "Category does not exist");
        address assetContract = assetCategories[category];
        delete assetCategories[category];
        emit AssetCategoryRemoved(category, assetContract);
    }
}
