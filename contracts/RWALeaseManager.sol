// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RWALeaseManager is Ownable {
    address public platformFeeCollector;

    struct Lease {
        address lessee;
        uint256 startTime;
        uint256 endTime;
        uint256 monthlyPayment;
        uint256 finePercentage;
        bool isActive;
    }

    mapping(uint256 => Lease) public leases;
    mapping(address => uint256) private deposits;

    event AssetLeased(uint256 indexed tokenId, address lessor, address lessee, uint256 startTime, uint256 endTime, uint256 monthlyPayment);
    event PaymentReleased(address indexed recipient, uint256 amount);

    // ✅ **Fix: Pass `msg.sender` to Ownable**
    constructor(address _platformFeeCollector) Ownable(msg.sender) {
        require(_platformFeeCollector != address(0), "Invalid platform fee collector");
        platformFeeCollector = _platformFeeCollector;
    }

    function leaseAsset(uint256 tokenId, address lessor, address lessee, uint256 finePercentage) external payable {
        require(msg.value > 0, "Insufficient lease payment");

        uint256 leaseFee = (msg.value * 100) / 10000; // 1% platform fee
        uint256 sellerAmount = msg.value - leaseFee;

        payable(platformFeeCollector).transfer(leaseFee);
        deposits[lessor] += sellerAmount;

        uint256 endTime = block.timestamp + 30 days;
        leases[tokenId] = Lease({
            lessee: lessee,
            startTime: block.timestamp,
            endTime: endTime,
            monthlyPayment: msg.value,
            finePercentage: finePercentage,
            isActive: true
        });

        emit AssetLeased(tokenId, lessor, lessee, block.timestamp, endTime, msg.value);
    }

    function claimLeasePayment(uint256 tokenId) external {
        require(leases[tokenId].isActive, "No active lease");
        require(block.timestamp >= leases[tokenId].endTime, "Lease not expired");

        uint256 payment = deposits[msg.sender];
        require(payment > 0, "No funds available");

        deposits[msg.sender] = 0;
        payable(msg.sender).transfer(payment);
        leases[tokenId].isActive = false;

        emit PaymentReleased(msg.sender, payment);
    }
}
