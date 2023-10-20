/// @title The interface PreSale.
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface ISale {
    function initialize(
        uint256 _exchangeRate,
        uint256 _hardCap,
        address _saleToken
    ) external;

    function buy(address _investor) external payable;

    function claimTokens(address _investor) external;

    function withdrawFundRaised(address _investor) external;
}
