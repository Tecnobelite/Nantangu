// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/// @dev importing openzeppelin libraries
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract Sale is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    /// @dev State variable to check for total fund Raised
    uint256 public fundRaised;

    uint256 exchangeRate;

    uint256 hardCap;

    address saleToken;

    /// @dev mapping to track which investor contributed how much fund
    mapping(address => uint256) public investorContribution;

    /**
     * `TokensPurchased` will be emitted when an investor invest in the preSale to but tokens.
     * @param _investor The address of the investor
     * @param _amount The amount of investment
     */
    event TokensPurchased(address _investor, uint256 _amount);

    /**
     * `tokensClaimed` will be emitted when an investor claim his tokens when the preSale ends
     * @param _investor The address of the investor
     * @param _amount The tokens he received of his investment
     */

    event tokensClaimed(address _investor, uint256 _amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        uint256 _exchangeRate,
        uint256 _hardCap,
        address _saleToken
    ) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        _validateSaleParameters(_exchangeRate, _hardCap, _saleToken);

        hardCap = _hardCap;
        exchangeRate = _exchangeRate;
        saleToken = _saleToken;
    }

    function buy(address _investor) external payable onlyOwner nonReentrant {
        uint256 _buyAmount = msg.value;
        require(_buyAmount > 0, "ERR_0_BUY_AMOUNT");
        require(_buyAmount + fundRaised <= hardCap, "ERR_HARD_CAP_EXCEEDED");

        fundRaised += _buyAmount;
        investorContribution[_investor] += _buyAmount;

        emit TokensPurchased(_investor, _buyAmount);
    }

    function claimTokens(address _investor) external onlyOwner nonReentrant {
        uint256 _investedAmount = investorContribution[_investor];
        require(_investedAmount > 0, "ERR_NO_TOKENS_TO_CLAIM");

        uint256 _tokensToClaim = _investedAmount * exchangeRate;

        delete investorContribution[_investor];

        IERC20Upgradeable(saleToken).transfer(_investor, _tokensToClaim);

        emit tokensClaimed(_investor, _tokensToClaim);
    }

    function withdrawFundRaised(
        address _investor
    ) external onlyOwner nonReentrant {
        uint256 _currentFundsAmount = address(this).balance;
        require(_currentFundsAmount > 0, "ERR_NO_FUNDS_TO_WITHDRAW");

        (bool sent, ) = payable(_investor).call{value: _currentFundsAmount}("");
        require(sent, "ERR_FAIL_TO_TRANFER");
    }

    function _validateSaleParameters(
        uint256 _exchangeRate,
        uint256 _hardCap,
        address _saleToken
    ) private pure {
        require(_exchangeRate > 0, "ERR_INVALID_EXCHANGE_RATE");
        require(_hardCap > 0, "ERR_INVALID_HARD_CAP");
        require(_saleToken != address(0), "ERR_INVALID_SALE_TOKEN");
    }
}
