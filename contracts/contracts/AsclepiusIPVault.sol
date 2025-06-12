// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { IRoyaltyModule } from "@storyprotocol/core/interfaces/modules/royalty/IRoyaltyModule.sol";
import { WorkflowStructs } from "@storyprotocol/periphery/contracts/lib/WorkflowStructs.sol";
import { IOwnableERC20 } from "@storyprotocol/periphery/contracts/interfaces/modules/tokenizer/IOwnableERC20.sol";
import { ITokenizerModule } from "@storyprotocol/periphery/contracts/interfaces/modules/tokenizer/ITokenizerModule.sol";
// solhint-disable-next-line max-line-length
import { IRoyaltyTokenDistributionWorkflows } from "@storyprotocol/periphery/contracts/interfaces/workflows/IRoyaltyTokenDistributionWorkflows.sol";

import { Errors } from "./lib/Errors.sol";
import { IAsclepiusIPDistributionContract } from "./interfaces/IAsclepiusIPDistributionContract.sol";
import { IAsclepiusIPVault } from "./interfaces/IAsclepiusIPVault.sol";

/**
 * @title AsclepiusIPVault
 * @notice This contract is used to manage the deposit and refund of IP token for the Asclepius IP Vault.
 */
contract AsclepiusIPVault is IAsclepiusIPVault, ReentrancyGuardUpgradeable, ERC721Holder {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    /**
     * @dev Storage structure for the AsclepiusIPVault
     * @param admin The address of the vault admin
     * @param ipId The ID of the IP
     * @param state The state of the vault either Open, Closed, or Canceled
     * @param expirationTime The expiration time of the vault (0 if no expiration)
     * @param fundReceiver The address of the fund receiver (a safe/multisig address)
     * @param rwipName The name of the Real-World Intellectual Property
     * @param fractionalTokenName The name of the fractional token
     * @param fractionalTokenSymbol The symbol of the fractional token
     * @param totalSupplyOfFractionalToken The total supply of the fractional token
     * @param distributionContract The address of distribution contract for staking fractional token and distributing the IP revenue
     * @param ipTokenContractAddress The address of the IP token contract
     * @param tokensInVault The set of tokens in the vault
     * @param totalDeposits The total deposits received for each token
     * @param deposits The deposit token address and amount information of the users
     * @param fractionalTokenClaimed The flag to check if the user has claimed the fractional token
     * @param minimumTotalDeposits The minimum total deposits required to close the vault
     * @custom:storage-location erc7201:asclepius-protocol.AsclepiusIPVault
     */
    struct AsclepiusIPVaultStorage {
        address admin;
        address ipId;
        State state;
        uint256 expirationTime;
        address fundReceiver;
        string rwipName;
        address fractionalToken;
        string fractionalTokenName;
        string fractionalTokenSymbol;
        uint256 totalSupplyOfFractionalToken;
        address protocolTreasury;
        address distributionContract;
        address ipTokenContractAddress;
        EnumerableSet.AddressSet tokensInVault;
        mapping(address token => uint256 totalDeposited) totalDeposits;
        mapping(address user => mapping(address token => uint256 amount)) deposits;
        mapping(address user => bool claimed) fractionalTokenClaimed;
        uint256 minimumTotalDeposits;
    }

    // keccak256(abi.encode(uint256(keccak256("asclepius-protocol.AsclepiusIPVault")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant AsclepiusIPVaultStorageLocation =
        0x42c9c0f2c59028a46a97ff701442785a2340be4e9f5ccbf53eda76e17b81cb00;

    /**
     * @notice The address of the Story PoC Periphery's RoyaltyTokenDistributionWorkflows contract
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    IRoyaltyTokenDistributionWorkflows public immutable RT_DISTRIBUTION_WORKFLOWS;

    /**
     * @notice The address of the Story PoC Core's RoyaltyModule contract
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    IRoyaltyModule public immutable ROYALTY_MODULE;

    /**
     * @notice The address of the Story PoC Core's TokenizerModule contract
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    ITokenizerModule public immutable TOKENIZER_MODULE;

    /**
     * @notice The upgradeable beacon address.
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    address public immutable UPGRADEABLE_BEACON;

    /// @dev Modifier to check if the caller is the admin
    modifier onlyAdmin() {
        if (msg.sender != _getAsclepiusIPVaultStorage().admin) {
            revert Errors.AsclepiusIPVault__CallerNotAdmin(msg.sender, _getAsclepiusIPVaultStorage().admin);
        }
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address royaltyTokenDistributionWorkflows,
        address royaltyModule,
        address tokenizerModule,
        address upgradeableBeacon
    ) {
        if (upgradeableBeacon == address(0)) revert Errors.AsclepiusIPVault__ZeroUpgradeableBeaconAddress();
        if (royaltyTokenDistributionWorkflows == address(0))
            revert Errors.AsclepiusIPVault__ZeroRoyaltyTokenDistributionWorkflowsAddress();
        if (royaltyModule == address(0)) revert Errors.AsclepiusIPVault__ZeroRoyaltyModuleAddress();
        if (tokenizerModule == address(0)) revert Errors.AsclepiusIPVault__ZeroTokenizerModuleAddress();

        UPGRADEABLE_BEACON = upgradeableBeacon;
        RT_DISTRIBUTION_WORKFLOWS = IRoyaltyTokenDistributionWorkflows(royaltyTokenDistributionWorkflows);
        ROYALTY_MODULE = IRoyaltyModule(royaltyModule);
        TOKENIZER_MODULE = ITokenizerModule(tokenizerModule);

        _disableInitializers();
    }

    /**
     * @dev Initializes the AsclepiusIPVault
     * @param admin_ The address of the vault admin
     * @param expirationTime_ The expiration time of the vault (0 if no expiration)
     * @param fundReceiver_ The address of the fund receiver (a safe/multisig address)
     * @param rwipName_ The name of the Real-World Intellectual Property
     * @param fractionalTokenName_ The name of the fractional token
     * @param fractionalTokenSymbol_ The symbol of the fractional token
     * @param fractionalTokenTotalSupply_ The total supply of the fractional token
     * @param ipTokenContractAddress_ The address of the IP token contract
     * @param minimumTotalDeposits_ The minimum total deposits required to close the vault
     */
    function initialize(
        address admin_,
        uint256 expirationTime_,
        address fundReceiver_,
        string memory rwipName_,
        string memory fractionalTokenName_,
        string memory fractionalTokenSymbol_,
        uint256 fractionalTokenTotalSupply_,
        address ipTokenContractAddress_,
        uint256 minimumTotalDeposits_
    ) external initializer {
        if (admin_ == address(0)) revert Errors.AsclepiusIPVault__ZeroAdminAddress();
        if (expirationTime_ != 0 && expirationTime_ <= block.timestamp) {
            revert Errors.AsclepiusIPVault__ExpirationTimeNotInFuture(expirationTime_, block.timestamp);
        }
        if (fundReceiver_ == address(0)) revert Errors.AsclepiusIPVault__ZeroFundReceiverAddress();
        if (ipTokenContractAddress_ == address(0)) revert Errors.AsclepiusIPVault__ZeroIPTokenContractAddress();

        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        $.admin = admin_;
        $.expirationTime = expirationTime_;
        $.fundReceiver = fundReceiver_;
        $.rwipName = rwipName_;
        $.fractionalTokenName = fractionalTokenName_;
        $.fractionalTokenSymbol = fractionalTokenSymbol_;
        $.totalSupplyOfFractionalToken = fractionalTokenTotalSupply_;
        $.ipTokenContractAddress = ipTokenContractAddress_;
        $.state = State.Open;
        $.minimumTotalDeposits = minimumTotalDeposits_;
        __ReentrancyGuard_init();
    }

    /**
     * @notice Deposits IP token to the vault, only when the vault is Open
     * @param erc20 The address of the token to deposit
     * @param amount The amount of the token to deposit
     */
    function deposit(address erc20, uint256 amount) external nonReentrant {
        _checkAndUpdateState();
        if (amount == 0) revert Errors.AsclepiusIPVault__ZeroDepositAmount(msg.sender, erc20);
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        if (erc20 != $.ipTokenContractAddress) revert Errors.AsclepiusIPVault__InvalidIPTokenAddress();
        if ($.state != State.Open) revert Errors.AsclepiusIPVault__VaultNotOpen($.state);

        $.tokensInVault.add(erc20);
        $.deposits[msg.sender][erc20] += amount;
        $.totalDeposits[erc20] += amount;

        IERC20(erc20).safeTransferFrom(msg.sender, address(this), amount);

        emit DepositReceived({ depositor: msg.sender, token: erc20, amount: amount });
    }

    /**
     * @notice Depositor claims refund, only when the vault is Canceled
     * @param erc20 The address of the token to claim refund
     * @return amount The amount of tokens claimed
     */
    function claimRefund(address erc20) external nonReentrant returns (uint256 amount) {
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        State state = $.state;
        if (state != State.Canceled) revert Errors.AsclepiusIPVault__VaultNotCanceled(state);
        if ($.deposits[msg.sender][erc20] == 0) revert Errors.AsclepiusIPVault__NoRefundableDeposit(msg.sender, erc20);

        amount = $.deposits[msg.sender][erc20];
        $.deposits[msg.sender][erc20] = 0;
        $.totalDeposits[erc20] -= amount;

        IERC20(erc20).safeTransfer(msg.sender, amount);

        emit RefundClaimed({ claimer: msg.sender, token: erc20, amount: amount });
    }

    /**
     * @notice Admin withdraws all funds to the fund receiver, only when the vault is Closed
     * @return tokens The addresses of the tokens withdrawn
     * @return withdrawnAmounts The amounts of the tokens withdrawn
     */
    function withdraw() external onlyAdmin returns (address[] memory tokens, uint256[] memory withdrawnAmounts) {
        _checkAndUpdateState();
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        State state = $.state;
        if (state != State.Closed) revert Errors.AsclepiusIPVault__VaultNotClosed(state);

        uint256 length = $.tokensInVault.length();

        tokens = new address[](length);
        withdrawnAmounts = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            tokens[i] = $.tokensInVault.at(i);
            withdrawnAmounts[i] = IERC20(tokens[i]).balanceOf(address(this));
            $.tokensInVault.remove(tokens[i]);
            IERC20(tokens[i]).safeTransfer($.fundReceiver, withdrawnAmounts[i]);
        }

        emit TokensWithdrawn({ receiver: $.fundReceiver, tokens: tokens, amounts: withdrawnAmounts });
    }

    /**
     * @notice Admin registers the IP and fractionalizes it, only when the vault is Closed
     * @param spgNftContract The address of the SPG NFT contract
     *         The spgNFTContract used here has to have 0 mint fee and have MINTER_ROLE granted to the AsclepiusIPVault contract
     * @param ipMetadata The metadata of the IP
     * @param licenseTermsData The license terms data to be attached to the IP
     * @param fractionalTokenTemplate The template of the fractional token
     * @param distributionContractTemplate The template of the IP distribution contract
     * @param initData The initialization data for the IP distribution contract {see IAsclepiusIPDistributionContract.InitData}
     * @return tokenId The token ID of the IP
     * @return ipId The IP ID
     * @return licenseTermsId The license terms ID attached to the IP
     * @return fractionalToken The address of the fractional token
     * @return distributionContract The address of the IP distribution contract
     */
    function registerIPAndFractionalize(
        address spgNftContract,
        WorkflowStructs.IPMetadata memory ipMetadata,
        WorkflowStructs.LicenseTermsData memory licenseTermsData,
        address fractionalTokenTemplate,
        address distributionContractTemplate,
        IAsclepiusIPDistributionContract.InitData memory initData
    )
        external
        onlyAdmin
        returns (
            uint256 tokenId,
            address ipId,
            uint256 licenseTermsId,
            address fractionalToken,
            address distributionContract
        )
    {
        if (spgNftContract == address(0)) revert Errors.AsclepiusIPVault__ZeroSPGNftContractAddress();
        _checkAndUpdateState();
        State state = _getAsclepiusIPVaultStorage().state;
        if (state != State.Closed) revert Errors.AsclepiusIPVault__VaultNotClosed(state);

        (ipId, tokenId, licenseTermsId) = _registerIpAndAttachTermsAndCollectRoyaltyTokens(
            spgNftContract,
            ipMetadata,
            licenseTermsData
        );

        fractionalToken = _deployFractionalToken(ipId, fractionalTokenTemplate);

        distributionContract = _deployDistributionContract(distributionContractTemplate, fractionalToken, initData);

        // transfer max percent of the royalty token to the distribution contract
        IERC20(ROYALTY_MODULE.ipRoyaltyVaults(ipId)).safeTransfer(distributionContract, ROYALTY_MODULE.maxPercent());

        emit IPRegisteredAndFractionalized({
            ipId: ipId,
            spgNftContract: spgNftContract,
            tokenId: tokenId,
            licenseTermsId: licenseTermsId,
            fractionalToken: fractionalToken,
            distributionContract: distributionContract
        });
    }

    /**
     * @notice User claims the fractionalized IP tokens, only when the vault is Closed
     * @param claimer The address of the claimer
     * @return fractionalToken The address of the fractional token
     * @return amountClaimed The amount of the fraction token claimed
     */
    function claimFractionalTokens(address claimer) external returns (address fractionalToken, uint256 amountClaimed) {
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        if ($.state != State.Closed) revert Errors.AsclepiusIPVault__VaultNotClosed($.state);
        if ($.deposits[claimer][$.ipTokenContractAddress] == 0)
            revert Errors.AsclepiusIPVault__ClaimerNotEligible(claimer);
        if ($.fractionalTokenClaimed[claimer]) revert Errors.AsclepiusIPVault__ClaimerAlreadyClaimed(claimer);

        fractionalToken = $.fractionalToken;
        if (fractionalToken == address(0)) revert Errors.AsclepiusIPVault__FractionalTokenNotSet();
        $.fractionalTokenClaimed[claimer] = true;

        address ipTokenContractAddress = $.ipTokenContractAddress;
        uint256 userDeposit = $.deposits[claimer][ipTokenContractAddress];
        uint256 totalDeposit = $.totalDeposits[ipTokenContractAddress];
        amountClaimed = (userDeposit * $.totalSupplyOfFractionalToken) / totalDeposit;

        IOwnableERC20(fractionalToken).mint(claimer, amountClaimed);

        emit FractionalTokenClaimed({ claimer: claimer, amountClaimed: amountClaimed });
    }

    /**
     * @notice Admin cancels the vault, only when the vault is Open
     */
    function cancel() external onlyAdmin {
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        if ($.state != State.Open) revert Errors.AsclepiusIPVault__VaultNotOpen($.state);
        $.state = State.Canceled;

        emit VaultCanceled();
    }

    /**
     * @notice Admin closes the vault, only when the vault is Open
     */
    function close() external onlyAdmin {
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        State state = $.state;
        if (state != State.Open) revert Errors.AsclepiusIPVault__VaultNotOpen(state);
        uint256 totalDeposits = $.totalDeposits[$.ipTokenContractAddress];
        uint256 minimumTotalDeposits = $.minimumTotalDeposits;
        if (totalDeposits < minimumTotalDeposits)
            revert Errors.AsclepiusIPVault__TotalDepositsLessThanMinimumTotalDeposits(
                totalDeposits,
                minimumTotalDeposits
            );
        $.state = State.Closed;

        emit VaultClosed();
    }

    /**
     * @notice Admin transfers the admin role
     * @param newAdmin The address of the new admin
     */
    function transferAdminRole(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert Errors.AsclepiusIPVault__ZeroAdminAddress();
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        $.admin = newAdmin;

        emit AdminRoleTransferred({ previousAdmin: msg.sender, newAdmin: newAdmin });
    }

    /**
     * @notice Admin updates the IP token contract address
     * @param newIpTokenContractAddress The address of the new IP token contract
     */
    function updateIpTokenContractAddress(address newIpTokenContractAddress) external onlyAdmin {
        if (newIpTokenContractAddress == address(0)) revert Errors.AsclepiusIPVault__ZeroIPTokenContractAddress();
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        if ($.state != State.Open) revert Errors.AsclepiusIPVault__VaultNotOpen($.state);
        if ($.totalDeposits[$.ipTokenContractAddress] > 0)
            revert Errors.AsclepiusIPVault__ActiveDepositsExist(
                $.ipTokenContractAddress,
                $.totalDeposits[$.ipTokenContractAddress]
            );

        $.ipTokenContractAddress = newIpTokenContractAddress;

        emit IpTokenContractAddressUpdated({
            previousIpTokenContractAddress: $.ipTokenContractAddress,
            newIpTokenContractAddress: newIpTokenContractAddress    
        });
    }

    function updateFractionalTokenTotalSupply(uint256 newTotalSupply) external onlyAdmin {
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        if (newTotalSupply < $.totalDeposits[$.ipTokenContractAddress])
            revert Errors.AsclepiusIPVault__FractionalTokenSupplyLessThanTotalDeposits(
                newTotalSupply,
                $.totalDeposits[$.ipTokenContractAddress]
            );
        if ($.fractionalToken != address(0)) {
            revert Errors.AsclepiusIPVault__FractionalTokenAlreadyDeployed($.fractionalToken);
        }

        $.totalSupplyOfFractionalToken = newTotalSupply;

        emit FractionalTokenTotalSupplyUpdated({
            previousTotalSupply: $.totalSupplyOfFractionalToken,
            newTotalSupply: newTotalSupply
        });
    }

    /**
     * @notice Returns the address of the IP token contract
     * @return ipTokenContractAddress The address of the IP token contract
     */
    function getIpTokenContractAddress() external view returns (address) {
        return _getAsclepiusIPVaultStorage().ipTokenContractAddress;
    }

    /**
     * @notice Returns the state of the vault
     * @return state The state of the vault
     */
    function getState() external view returns (State) {
        return _getAsclepiusIPVaultStorage().state;
    }

    /**
     * @notice Returns the address of the vault admin
     * @return admin The address of the vault admin
     */
    function getAdmin() external view returns (address) {
        return _getAsclepiusIPVaultStorage().admin;
    }

    /**
     * @notice Returns the ID of the IP (0 if not registered)
     * @return ipId The ID of the IP
     */
    function getIpId() external view returns (address) {
        return _getAsclepiusIPVaultStorage().ipId;
    }

    /**
     * @notice Returns the deposited amount of a user for a token
     * @param user The address of the user
     * @param token The address of the token
     * @return amount The deposited amount of the user for the token
     */
    function getDepositedAmount(address user, address token) external view returns (uint256) {
        return _getAsclepiusIPVaultStorage().deposits[user][token];
    }

    /**
     * @notice Returns the total deposited amount of a token
     * @param token The address of the token
     * @return totalDeposited The total deposited amount of the token
     */
    function getTotalDeposited(address token) external view returns (uint256) {
        return _getAsclepiusIPVaultStorage().totalDeposits[token];
    }

    /**
     * @notice Returns the expiration time of the vault
     * @return expirationTime The expiration time of the vault
     */
    function getExpirationTime() external view returns (uint256) {
        return _getAsclepiusIPVaultStorage().expirationTime;
    }

    /**
     * @notice Returns the address of the fund receiver
     * @return fundReceiver The address of the fund receiver
     */
    function getFundReceiver() external view returns (address) {
        return _getAsclepiusIPVaultStorage().fundReceiver;
    }

    /**
     * @notice Returns the name of the Real-World Intellectual Property
     * @return rwipName The name of the Real-World Intellectual Property
     */
    function getRwipName() external view returns (string memory) {
        return _getAsclepiusIPVaultStorage().rwipName;
    }

    /**
     * @notice Returns the address of the fractional token (0 if not fractionalized)
     * @return fractionalToken The address of the fractional token
     */
    function getFractionalToken() external view returns (address) {
        return _getAsclepiusIPVaultStorage().fractionalToken;
    }

    /**
     * @notice Returns the name of the fractional token
     * @return fractionalTokenName The name of the fractional token
     */
    function getFractionalTokenName() external view returns (string memory) {
        return _getAsclepiusIPVaultStorage().fractionalTokenName;
    }

    /**
     * @notice Returns the symbol of the fractional token
     * @return fractionalTokenSymbol The symbol of the fractional token
     */
    function getFractionalTokenSymbol() external view returns (string memory) {
        return _getAsclepiusIPVaultStorage().fractionalTokenSymbol;
    }

    /**
     * @notice Returns the total supply of the fractional token
     * @return totalSupplyOfFractionalToken The total supply of the fractional token
     */
    function getTotalSupplyOfFractionalToken() external view returns (uint256) {
        return _getAsclepiusIPVaultStorage().totalSupplyOfFractionalToken;
    }

    /**
     * @notice Returns the address of the distribution contract (0 if IP is not yet fractionalized)
     * @return distributionContract The address of the distribution contract
     */
    function getDistributionContract() external view returns (address) {
        return _getAsclepiusIPVaultStorage().distributionContract;
    }

    /**
     * @notice Returns the address of the upgradeable beacon of the AsclepiusIPVault
     * @return upgradeableBeacon The address of the upgradeable beacon
     */
    function getUpgradeableBeacon() external view returns (address) {
        return UPGRADEABLE_BEACON;
    }

    /**
     * @dev register IP and attach terms and collect royalty tokens
     * @param spgNftContract The address of the SPG NFT contract
     * @param ipMetadata The metadata of the IP
     * @param licenseTermsData The license terms data to be attached to the IP
     * @return ipId The IP ID
     * @return tokenId The token ID of the IP
     * @return licenseTermsId The license terms ID attached to the IP
     */
    function _registerIpAndAttachTermsAndCollectRoyaltyTokens(
        address spgNftContract,
        WorkflowStructs.IPMetadata memory ipMetadata,
        WorkflowStructs.LicenseTermsData memory licenseTermsData
    ) internal returns (address ipId, uint256 tokenId, uint256 licenseTermsId) {
        uint32 maxPercent = ROYALTY_MODULE.maxPercent();
        WorkflowStructs.RoyaltyShare[] memory royaltyShares = new WorkflowStructs.RoyaltyShare[](1);
        royaltyShares[0] = WorkflowStructs.RoyaltyShare({ recipient: address(this), percentage: maxPercent });
        WorkflowStructs.LicenseTermsData[] memory licenseTermsDataArr = new WorkflowStructs.LicenseTermsData[](1);
        licenseTermsDataArr[0] = licenseTermsData;

        uint256[] memory licenseTermsIds = new uint256[](1);
        (ipId, tokenId, licenseTermsIds) = RT_DISTRIBUTION_WORKFLOWS
            .mintAndRegisterIpAndAttachPILTermsAndDistributeRoyaltyTokens({
                spgNftContract: spgNftContract,
                recipient: address(this),
                ipMetadata: ipMetadata,
                licenseTermsData: licenseTermsDataArr,
                royaltyShares: royaltyShares,
                allowDuplicates: false
            });
        licenseTermsId = licenseTermsIds[0];

        _getAsclepiusIPVaultStorage().ipId = ipId;
    }

    /**
     * @dev deploy fractional token
     * @param ipId The IP ID
     * @param fractionalTokenTemplate The template of the fractional token
     * @return fractionalToken The address of the fractional token
     */
    function _deployFractionalToken(
        address ipId,
        address fractionalTokenTemplate
    ) internal returns (address fractionalToken) {
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        if ($.totalSupplyOfFractionalToken < $.totalDeposits[$.ipTokenContractAddress])
            revert Errors.AsclepiusIPVault__FractionalTokenSupplyLessThanTotalDeposits(
                $.totalSupplyOfFractionalToken,
                $.totalDeposits[$.ipTokenContractAddress]
            );
        if ($.fractionalToken != address(0))
            revert Errors.AsclepiusIPVault__FractionalTokenAlreadyDeployed($.fractionalToken);

        fractionalToken = ITokenizerModule(TOKENIZER_MODULE).tokenize({
            ipId: ipId,
            tokenTemplate: fractionalTokenTemplate,
            initData: abi.encode(
                IOwnableERC20.InitData({
                    name: $.fractionalTokenName,
                    symbol: $.fractionalTokenSymbol,
                    cap: $.totalSupplyOfFractionalToken,
                    initialOwner: address(this)
                })
            )
        });

        $.fractionalToken = fractionalToken;
    }

    /**
     * @dev deploy distribution contract
     * @param distributionContractTemplate The template of the IP distribution contract
     * @param fractionalToken The address of the fractionalized IP token
     * @param initData The initialization data for the IP distribution contract {see IAsclepiusIPDistributionContract.InitData}
     * @return distributionContract The address of the IP distribution contract
     */
    function _deployDistributionContract(
        address distributionContractTemplate,
        address fractionalToken,
        IAsclepiusIPDistributionContract.InitData memory initData
    ) internal returns (address distributionContract) {
        distributionContract = address(
            new BeaconProxy(
                IAsclepiusIPDistributionContract(distributionContractTemplate).getUpgradeableBeacon(),
                abi.encodeCall(IAsclepiusIPDistributionContract.initialize, (fractionalToken, initData))
            )
        );

        _getAsclepiusIPVaultStorage().distributionContract = distributionContract;
    }

    /**
     * @dev Checks if it has passed the expiration time, If so, updates the state to Closed
     */
    function _checkAndUpdateState() private {
        AsclepiusIPVaultStorage storage $ = _getAsclepiusIPVaultStorage();
        if ($.state == State.Open && block.timestamp >= $.expirationTime) $.state = State.Closed;
    }

    /// @dev Returns the storage struct of AsclepiusIPVault.
    function _getAsclepiusIPVaultStorage() private pure returns (AsclepiusIPVaultStorage storage $) {
        assembly {
            $.slot := AsclepiusIPVaultStorageLocation
        }
    }
}
