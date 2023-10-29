/// @title The common contract for all type of ERC20 Tokens.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

/// @dev Importing @openzeppelin stuffs.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @dev Custom Errors (For parameters).
error TransferFailed();
error StringValueShouldBeNonEmpty();
error TotalSupplyShouldBeMoreThanZero();
error DecimalsShouldBeLessThanOrEqualsTo18();
error FeeManagerAddressShouldNotBeZeroAddress();

contract TestToken is ERC20 {
    /// @dev `__decimals` for user defined decimals.
    uint8 private immutable __decimals;

    /**
     * @dev Initializing the ERC20 contract and minting the `_totalSupply` of tokens to `Owner/Caller`.
     * Also transferring fee to FeeManager contract.
     * @param name_ The name of the ERC20 token.
     * @param symbol_ The symbol of the ERC20 token.
     * @param decimals_ The decimals of the ERC20 token.
     * @param totalSupply_ The total supply of the token.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) payable ERC20(name_, symbol_) {
        /// @dev Parameters verification.
        _validateParameters(name_, symbol_, decimals_, totalSupply_);

        /// @dev Setting the decimals as per user.
        __decimals = decimals_;
        /// @dev Minting the supply to caller.
        _mint(_msgSender(), totalSupply_);
    }

    /**
     * @dev Overriding the `decimals` function to get user defined decimals.
     * @return uint8: Decimals value.
     */
    function decimals() public view virtual override returns (uint8) {
        return __decimals;
    }

    /**
     * @dev String length checker i.e. more than zero or not empty string;
     * @param _string The string which you want to check.
     */
    function _isValidString(string memory _string) private pure returns (bool) {
        return bytes(_string).length > 0;
    }

    /**
     * @dev Validation function to check parameters.
     * @param name_ The name of the ERC20 token.
     * @param symbol_ The symbol of the ERC20 token.
     * @param decimals_ The decimals of the ERC20 token.
     * @param totalSupply_ The total supply of the token.
     */
    function _validateParameters(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) private pure {
        /// @dev Verifications.
        if (totalSupply_ == 0) revert TotalSupplyShouldBeMoreThanZero();
        if (decimals_ > 18) revert DecimalsShouldBeLessThanOrEqualsTo18();
        if (!_isValidString(name_) || !_isValidString(symbol_))
            revert StringValueShouldBeNonEmpty();
    }
}
