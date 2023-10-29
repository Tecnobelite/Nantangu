/// @title The Sale manager contract.
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/// @dev Importing @openzeppelin stuffs.

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "../interfaces/ISale.sol";
import "hardhat/console.sol";

/// @dev Struct for Project Details
struct ProjectDetails {
    /// @param logoUrl:  image logo url
    string logoUrl;
    /// @param bannerUrl: banner image url
    string bannerUrl;
    /// @param  websiteUrl: website url
    string websiteUrl;
    /// @param telegramUrl: telegram url
    string telegramUrl;
    /// @param telegramUrl: telegram url
    string githubUrl;
    /// @param telegramUrl: telegram url
    string twitterUrl;
    /// @param telegramUrl: telegram url
    string discordUrl;
    /// @param youtubePresentationVideoUrl: Youtube Short Video
    string youtubePresentationVideoUrl;
    /// @param whitelistContestUrl: White list contest url
    string whitelistContestUrl;
    /// @param redditUrl : Reddit url
    string redditUrl;
    /// @param projectDescription ; Project Description
    string projectDescription;
}

contract SaleManager is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    /// @dev totalNumberOfPreSale: The number of preSale created.
    uint256 public totalNumberOfPreSale;

    /// @dev Clone FairSale address.
    address public cloneableNormalFairSale;

    /// @dev totalPreSaleCreatedBy: The number of preSale created by an address.
    mapping(address => uint256) public totalPreSaleCreatedBy;
    /// @dev projectDetailsOf: The project details of PreSale contracts.
    mapping(address => ProjectDetails) public projectDetailsOf;
    /// @dev preSaleToOwner: The owner address by PreSale address.
    mapping(address => address) public preSaleToOwner;

    /// @dev preSaleAddressByOwnerAndId: The preSale contract address by owner address.
    mapping(address => mapping(uint256 => address))
        public preSaleAddressByOwnerAndId;

    /**
     * @notice Events.
     */
    /**
     * @dev `PreSaleCreated` will be fired when a new preSale created.
     * @param preSale: The newly created preSale address.
     * @param preSaleOwner: The creator of the preSale.
     * @param id: The preSale id for the preSale owner.
     */
    event PreSaleCreated(address preSale, address preSaleOwner, uint256 id);

    /**
     * @dev `ProjectDetailsUpdated` will be fired when project details updated for a preSale.
     * @param preSale: The newly created preSale address.
     * @param timestamp: The time project get updated.
     */
    event ProjectDetailsUpdated(address preSale, uint256 timestamp);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _cloneableNormalFairSale) public initializer {

        _validateAddress(_cloneableNormalFairSale);
        __Ownable_init();
        __ReentrancyGuard_init();

        cloneableNormalFairSale = _cloneableNormalFairSale;
    }

    function updateNormalPreSale(
        address _cloneableNormalFairSale
    ) external onlyOwner {
        // @dev Parameter checking.
        _validateAddress(_cloneableNormalFairSale);
        /// @dev Updating the cloneablePreSale address.
        cloneableNormalFairSale = _cloneableNormalFairSale;
    }

    /**
     * @notice Updater functions.
     */
    /**
     * (PUBLIC)
     * @dev Updating project details of a preSale address.
     * Required: logoUrl & Description should not be empty string.
     * @param _preSaleAddress: The preSale address.
     * @param _newProjectDetails: The updated project details
     */
    function updateProjectDetails(
        address _preSaleAddress,
        ProjectDetails memory _newProjectDetails
    ) external returns (bool) {
        /// @dev Parameter validations.
        _validateProjectDetails(_newProjectDetails);
        _validatePreSaleAddressAndOwner(_preSaleAddress);

        /// @dev Update the project details.
        projectDetailsOf[_preSaleAddress] = _newProjectDetails;

        /// @dev Emitting event.
        emit ProjectDetailsUpdated(_preSaleAddress, block.timestamp);
        /// @dev Return true after execution.
        return true;
    }

    function createPreSale(
        uint256 _exchangeRate,
        uint256 _hardCap,
        address _saleToken,
        ProjectDetails memory _projectDetails
    ) external nonReentrant returns (bool) {
        /// @dev Parameter validations.
        _validateProjectDetails(_projectDetails);


      
        bytes32 salt = keccak256(abi.encodePacked(msg.sender , _saleToken , block.timestamp));
        address _newPreSale= Clones.cloneDeterministic(cloneableNormalFairSale, salt);
       
        ISale(_newPreSale).initialize(_exchangeRate, _hardCap, _saleToken);

        uint256 _tokensRequiredForSale = _hardCap * _exchangeRate / 1e18;

        IERC20Upgradeable(_saleToken).transferFrom(
            msg.sender,
            _newPreSale,
            _tokensRequiredForSale
        );

        _afterPreSaleCreate(_newPreSale, _projectDetails);
        /// @dev Return true after execution.
        return true;
    }

    /**
     * @notice PreSale Contract functions.
     */
    /**
     * (PUBLIC)
     * BUY WITH ETH = TRUE
     * @dev Invest ETH into PreSale contract.
     * @param _preSaleAddress: The preSale address.
     */
    function investIntoPreSale(
        address _preSaleAddress
    ) external payable nonReentrant returns (bool) {
        /// @dev Parameter validations.
        _validatePreSale(_preSaleAddress);

        /// @dev Buy tokens with ETH.
        ISale(_preSaleAddress).buy{value: msg.value}(msg.sender);
        /// @dev Return true after execution.
        return true;
    }

    /**
     * (PUBLIC)
     * @dev Claim tokens as per invest amount from PreSale.
     * @param _preSaleAddress: The preSale address.
     */
    function claimTokensFromPreSale(
        address _preSaleAddress
    ) external nonReentrant returns (bool) {
        /// @dev Parameter validations.
        _validatePreSale(_preSaleAddress);

        /// @dev Buy tokens with ERC20 token.
        ISale(_preSaleAddress).claimTokens(msg.sender);
        /// @dev Return true after execution.
        return true;
    }

    function withdrawFundRaised(
        address _preSaleAddress
    ) external nonReentrant returns (bool) {
        /// @dev Parameter validations.
        _validatePreSale(_preSaleAddress);
        _validatePreSaleAddressAndOwner(_preSaleAddress);

        /// @dev Buy tokens with ERC20 token.
        ISale(_preSaleAddress).withdrawFundRaised(msg.sender);
        /// @dev Return true after execution.
        return true;
    }

    /// @dev HELPER FUNCTIONS

    /**
     * (PRIVATE)
     * @dev Validating the Project details params
     * @param _projectDetails: The variable of ProjectDetails type struct
     */
    function _validateProjectDetails(
        ProjectDetails memory _projectDetails
    ) private pure {
        /// @dev check logo url cannot be empty
        require(_isValidString(_projectDetails.logoUrl), "ERR_LOGO_URL_EMPTY");
        /// @dev check project Description should not empty
        require(
            _isValidString(_projectDetails.projectDescription),
            "ERR_PROJECT_DETAILS_EMPTY"
        );
    }

    /**
     * (PRIVATE)
     * @dev Function to check the address is zero address.
     * @param _address: The address you want to check
     */
    function _validateAddress(address _address) private pure {
        /// @dev Parameter checking.
        require(_address != address(0), "ERR_ZERO_ADDRESS");
    }

    /**
     * (PRIVATE)
     * @dev Function to check the string is empty or not
     * @param _string: The string you want to check
     */
    function _isValidString(string memory _string) private pure returns (bool) {
        /// @dev return true or false
        return bytes(_string).length > 0;
    }

    /**
     * (PRIVATE)
     * @dev Updating the PreSale details after creating a PreSale.
     * @param _newPreSaleAddress: The newly created PreSale address.
     * @param _projectDetails: The project details about the created PreSale.
     */
    function _afterPreSaleCreate(
        address _newPreSaleAddress,
        ProjectDetails memory _projectDetails
    ) private {
        /// @dev Updating created PreSale.
        uint256 _currentPreSaleId = totalPreSaleCreatedBy[msg.sender];
        preSaleAddressByOwnerAndId[msg.sender][
            _currentPreSaleId
        ] = _newPreSaleAddress;
        ++totalPreSaleCreatedBy[msg.sender];
        ++totalNumberOfPreSale;
        /// @dev Update the project & Owner details.
        projectDetailsOf[_newPreSaleAddress] = _projectDetails;
        preSaleToOwner[_newPreSaleAddress] = msg.sender;

        /// @dev Emitting event.
        emit PreSaleCreated(_newPreSaleAddress, msg.sender, _currentPreSaleId);
    }

    /**
     * (PRIVATE)
     * @dev Validating the Project details params
     * @param _preSaleAddress: The preSale address.
     */
    function _validatePreSaleAddressAndOwner(
        address _preSaleAddress
    ) private view {
        /// @dev check preSale address is not empty.
        _validateAddress(_preSaleAddress);
        require(
            preSaleToOwner[_preSaleAddress] == msg.sender,
            "ERR_CALLER_NOT_OWNER"
        );
    }

    /**
     * (PRIVATE)
     * @dev Function to check the address is valid preSale address.
     * @param _address: The address you want to check.
     */
    function _validatePreSale(address _address) private view {
        /// @dev Parameter checking.
        _validateAddress(_address);
        require(
            preSaleToOwner[_address] != address(0),
            "ERR_SALE_NOT_VALID"
        );
    }
}
