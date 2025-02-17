// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract RWAPayments {
    uint256 public platformFee = 100; // 1% default
    address public platformFeeCollector;
    mapping(address => uint256) private deposits;

    event PaymentProcessed(address indexed payer, uint256 amount);
    event PlatformFeeUpdated(uint256 newFee);
    event PlatformFeeCollectorUpdated(address indexed newCollector);

    constructor(address _platformFeeCollector) {
        require(_platformFeeCollector != address(0), "Invalid collector address");
        platformFeeCollector = _platformFeeCollector;
    }

    function _handlePayment(address seller, uint256 amount) internal {
        uint256 fee = (amount * platformFee) / 10000;
        uint256 sellerAmount = amount - fee;

        payable(platformFeeCollector).transfer(fee);
        payable(seller).transfer(sellerAmount);

        emit PaymentProcessed(seller, amount);
    }

    function setPlatformFee(uint256 newFee) external {
        require(newFee <= 1000, "Fee too high");
        platformFee = newFee;
        emit PlatformFeeUpdated(newFee);
    }

    function setPlatformFeeCollector(address newCollector) external {
        require(newCollector != address(0), "Invalid address");
        platformFeeCollector = newCollector;
        emit PlatformFeeCollectorUpdated(newCollector);
    }
}
