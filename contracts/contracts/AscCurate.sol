// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { IRoyaltyModule } from "@storyprotocol/core/interfaces/modules/royalty/IRoyaltyModule.sol";
import { IOwnableERC20 } from "@storyprotocol/periphery/contracts/interfaces/modules/tokenizer/IOwnableERC20.sol";
import { ITokenizerModule } from "@storyprotocol/periphery/contracts/interfaces/modules/tokenizer/ITokenizerModule.sol";
import { IIPAssetRegistry } from "@storyprotocol/core/interfaces/registries/IIPAssetRegistry.sol";
import { IIPAccount } from "@storyprotocol/core/interfaces/IIPAccount.sol";

import { Errors } from "./lib/Errors.sol";
import { IAscStaking } from "./interfaces/IAscStaking.sol";
import { IAscCurate } from "./interfaces/IAscCurate.sol";

/**
 * @title AscCurate
 * @notice This contract is used to manage the deposit and refund of $IP for the project on Asclepius.
 */
contract AscCurate is IAscCurate, ReentrancyGuardUpgradeable, ERC721Holder {
    using SafeERC20 for IERC20;

    /**
     * @dev Storage structure for the AscCurate
     * @param admin The address of the vault admin
     * @param ipId The ID of the IP
     * @param ipNft The address of the ERC 6551 NFT contract bound to the IP
     * @param ipNftTokenId The token ID of the ERC 6551 NFT contract bound to the IP
     * @param state The state of the vault either Open, Closed, or Canceled
     * @param expirationTime The expiration time of the vault (0 if no expiration)
     * @param fundReceiver The address of the fund receiver (a safe/multisig address)
     * @param bioName The name of the bio project
     * @param bioToken The address of the bio token
     * @param bioTokenName The name of the bio token
     * @param bioTokenSymbol The symbol of the bio token
     * @param minimalIpTokenForLaunch The minimal IP token amount required for launch
     * @param rewardToken The address of the reward token
     * @param stakingContract The address of staking contract for staking bio token and distributing the IP revenue
     * @param totalDeposits The total deposits received
     * @param deposits The deposit amount information of the users
     * @param bioTokenClaimed The flag to check if the user has claimed the bio token
     * @custom:storage-location erc7201:asclepius-protocol.AscCurate
     */
    struct AscCurateStorage {
        address admin;
        address ipId;
        address ipNft;
        uint256 ipNftTokenId;
        State state;
        uint256 expirationTime;
        address fundReceiver;
        string bioName;
        address bioToken;
        string bioTokenName;
        string bioTokenSymbol;
        uint256 minimalIpTokenForLaunch;
        address rewardToken;
        address stakingContract;
        uint256 totalDeposits;
        mapping(address user => uint256 amount) deposits;
        mapping(address user => bool claimed) bioTokenClaimed;
    }

    // keccak256(abi.encode(uint256(keccak256("asclepius-protocol.AscCurate")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant AscCurateStorageLocation =
        0x1d4c0bf7aa428ed0aa0cdf62dfdb12c3fae0238a65115589ddd1d36f6559c600;

    /**
     * @notice The address of the Story PoC Core's RoyaltyModule contract
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    IRoyaltyModule public immutable ROYALTY_MODULE;

    /**
     * @notice The address of the Story PoC Core's IPAssetRegistry contract
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    IIPAssetRegistry public immutable IP_ASSET_REGISTRY;

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

    /**
     * @notice The total supply of bio tokens.
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    uint256 public immutable TOTAL_BIO_TOKEN_SUPPLY = 1e27; // 1 billion tokens (1e9 * 1e18)

    /// @dev Modifier to check if the caller is the admin
    modifier onlyAdmin() {
        if (msg.sender != _getAscCurateStorage().admin) {
            revert Errors.AscCurate__CallerNotAdmin(msg.sender, _getAscCurateStorage().admin);
        }
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address royaltyModule, address tokenizerModule, address upgradeableBeacon, address ipAssetRegistry) {
        if (upgradeableBeacon == address(0)) revert Errors.AscCurate__ZeroUpgradeableBeaconAddress();
        if (royaltyModule == address(0)) revert Errors.AscCurate__ZeroRoyaltyModuleAddress();
        if (tokenizerModule == address(0)) revert Errors.AscCurate__ZeroTokenizerModuleAddress();
        if (ipAssetRegistry == address(0)) revert Errors.AscCurate__ZeroIpAssetRegistryAddress();

        UPGRADEABLE_BEACON = upgradeableBeacon;
        ROYALTY_MODULE = IRoyaltyModule(royaltyModule);
        TOKENIZER_MODULE = ITokenizerModule(tokenizerModule);
        IP_ASSET_REGISTRY = IIPAssetRegistry(ipAssetRegistry);

        _disableInitializers();
    }

    /**
     * @dev Initializes the AscCurate
     * @param initData The initialization data for the AscCurate {see IAscCurate.CurateInitData}
     */
    function initialize(CurateInitData memory initData) external initializer {
        if (initData.admin == address(0)) revert Errors.AscCurate__ZeroAdminAddress();
        if (initData.ipId == address(0)) revert Errors.AscCurate__ZeroIpIdAddress();
        if (initData.ipNft == address(0)) revert Errors.AscCurate__ZeroIpNftAddress();
        if (initData.ipNftTokenId == 0) revert Errors.AscCurate__ZeroIpNftTokenId();
        if (initData.expirationTime != 0 && initData.expirationTime <= block.timestamp) {
            revert Errors.AscCurate__ExpirationTimeNotInFuture(initData.expirationTime, block.timestamp);
        }
        if (initData.fundReceiver == address(0)) revert Errors.AscCurate__ZeroFundReceiverAddress();
        if (IP_ASSET_REGISTRY.ipId(block.chainid, initData.ipNft, initData.ipNftTokenId) != initData.ipId)
            revert Errors.AscCurate__IpNotRegistered(initData.ipNft, initData.ipNftTokenId, initData.ipId);

        AscCurateStorage storage $ = _getAscCurateStorage();
        $.admin = initData.admin;
        $.ipId = initData.ipId;
        $.ipNft = initData.ipNft;
        $.ipNftTokenId = initData.ipNftTokenId;
        $.expirationTime = initData.expirationTime;
        $.fundReceiver = initData.fundReceiver;
        $.bioName = initData.bioName;
        $.bioTokenName = initData.bioTokenName;
        $.bioTokenSymbol = initData.bioTokenSymbol;
        $.minimalIpTokenForLaunch = initData.minimalIpTokenForLaunch;
        $.rewardToken = initData.rewardToken;
        $.state = State.Open;
        __ReentrancyGuard_init();
    }

    /**
     * @notice Deposits $IP to the curate, only when the curate is Open
     * @param amount The amount of the token to deposit
     */
    function deposit(uint256 amount) external payable nonReentrant {
        _checkAndUpdateState();
        if (amount != msg.value) revert Errors.AscCurate__DepositAmountMismatch(msg.sender, amount, msg.value);
        AscCurateStorage storage $ = _getAscCurateStorage();
        if ($.state != State.Open) revert Errors.AscCurate__CurateNotOpen($.state);

        $.deposits[msg.sender] += amount;
        $.totalDeposits += amount;

        emit DepositReceived({ depositor: msg.sender, amount: amount });
    }

    /**
     * @notice Depositor claims refund, only when the curate is Canceled
     * @return amount The amount of IP token claimed
     */
    function claimRefund() external nonReentrant returns (uint256 amount) {
        AscCurateStorage storage $ = _getAscCurateStorage();
        State state = $.state;
        if (state != State.Canceled) revert Errors.AscCurate__CurateNotCanceled(state);
        if ($.deposits[msg.sender] == 0) revert Errors.AscCurate__NoRefundableDeposit(msg.sender);

        amount = $.deposits[msg.sender];
        $.deposits[msg.sender] = 0;
        $.totalDeposits -= amount;

        (bool success, ) = payable(msg.sender).call{ value: amount }("");
        if (!success) revert Errors.AscCurate__RefundClaimFailed(msg.sender, amount);

        emit RefundClaimed({ claimer: msg.sender, amount: amount });
    }

    /**
     * @notice Admin withdraws all funds to the fund receiver, only when the curate is Closed
     * @return withdrawnAmount The amount of IP token withdrawn
     */
    function withdraw() external onlyAdmin returns (uint256 withdrawnAmount) {
        _checkAndUpdateState();
        AscCurateStorage storage $ = _getAscCurateStorage();
        State state = $.state;
        if (state != State.Closed) revert Errors.AscCurate__CurateNotClosed(state);

        withdrawnAmount = $.totalDeposits;
        $.totalDeposits = 0;

        (bool success, ) = payable($.fundReceiver).call{ value: withdrawnAmount }("");
        if (!success) revert Errors.AscCurate__WithdrawFailed(withdrawnAmount);

        emit TokensWithdrawn({ receiver: $.fundReceiver, amount: withdrawnAmount });
    }

    /**
     * @notice User claims the bio tokens, only when the curate is Closed
     * @param claimer The address of the claimer
     * @return bioToken The address of the bio token
     * @return amountClaimed The amount of the bio token claimed
     */
    function claimBioTokens(address claimer) external returns (address bioToken, uint256 amountClaimed) {
        AscCurateStorage storage $ = _getAscCurateStorage();
        if ($.state != State.Closed) revert Errors.AscCurate__CurateNotClosed($.state);
        if ($.deposits[claimer] == 0) revert Errors.AscCurate__ClaimerNotEligible(claimer);
        if ($.bioTokenClaimed[claimer]) revert Errors.AscCurate__ClaimerAlreadyClaimed(claimer);

        bioToken = $.bioToken;
        if (bioToken == address(0)) revert Errors.AscCurate__BioTokenNotSet();
        $.bioTokenClaimed[claimer] = true;

        uint256 userDeposit = $.deposits[claimer];
        uint256 totalDeposit = $.totalDeposits;
        amountClaimed = (userDeposit * TOTAL_BIO_TOKEN_SUPPLY) / totalDeposit;

        IOwnableERC20(bioToken).mint(claimer, amountClaimed);

        emit BioTokenClaimed({ claimer: claimer, amountClaimed: amountClaimed });
    }

    /**
     * @notice Admin cancels the curate, only when the curate is Open
     */
    function cancel() external onlyAdmin {
        AscCurateStorage storage $ = _getAscCurateStorage();
        if ($.state != State.Open) revert Errors.AscCurate__CurateNotOpen($.state);
        $.state = State.Canceled;

        emit CurateCanceled();
    }

    /**
     * @notice Admin closes the curate
     */
    function close() external onlyAdmin {
        AscCurateStorage storage $ = _getAscCurateStorage();
        State state = $.state;
        if (state != State.Open) revert Errors.AscCurate__CurateNotOpen(state);
        uint256 totalDeposits = $.totalDeposits;
        uint256 minimalIpTokenForLaunch = $.minimalIpTokenForLaunch;
        if (totalDeposits < minimalIpTokenForLaunch)
            revert Errors.AscCurate__TotalDepositsLessThanMinimumTotalDeposits(totalDeposits, minimalIpTokenForLaunch);
        $.state = State.Closed;

        emit CurateClosed();
    }

    /**
     * @notice Admin transfers the admin role
     * @param newAdmin The address of the new admin
     */
    function transferAdminRole(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert Errors.AscCurate__ZeroAdminAddress();
        AscCurateStorage storage $ = _getAscCurateStorage();
        $.admin = newAdmin;

        emit AdminRoleTransferred({ previousAdmin: msg.sender, newAdmin: newAdmin });
    }

    /**
     * @notice Admin launches the bio project
     * @param bioTokenTemplate The template of the bio token
     * @param stakingContractTemplate The template of the staking contract
     * @param initData The initialization data for the staking contract {see IAscStaking.InitData}
     * @return bioToken The address of the bio token
     * @return stakingContract The address of the staking contract
     */
    function launchProject(
        address bioTokenTemplate,
        address stakingContractTemplate,
        IAscStaking.InitData memory initData
    ) external returns (address bioToken, address stakingContract) {
        _checkAndUpdateState();
        AscCurateStorage storage $ = _getAscCurateStorage();
        State state = $.state;
        if (state != State.Closed) revert Errors.AscCurate__CurateNotClosed(state);

        if (IERC721($.ipNft).ownerOf($.ipNftTokenId) != address(this))
            revert Errors.AscCurate__IpNotTransferredToCurate($.ipId, $.ipNft, $.ipNftTokenId);

        bioToken = _deployBioToken($.ipId, bioTokenTemplate);
        stakingContract = _deployStakingContract(stakingContractTemplate, bioToken, initData);

        address ipRoyaltyVault = ROYALTY_MODULE.ipRoyaltyVaults($.ipId);
        if (ipRoyaltyVault == address(0)) revert Errors.AscCurate__IpRoyaltyVaultNotDeployed($.ipId);

        IIPAccount(payable($.ipId)).execute(
            ipRoyaltyVault,
            0,
            abi.encodeWithSelector(IERC20.transferFrom.selector, $.ipId, stakingContract, ROYALTY_MODULE.maxPercent())
        );

        emit ProjectLaunched({ ipId: $.ipId, bioToken: bioToken, stakingContract: stakingContract });
    }

    /**
     * @notice Admin withdraws the IP NFT to the recipient, only when the curate is Canceled
     * @param recipient The address of the recipient
     */
    function withdrawIp(address recipient) external onlyAdmin {
        AscCurateStorage storage $ = _getAscCurateStorage();
        State state = $.state;
        if (state != State.Canceled) revert Errors.AscCurate__CurateNotCanceled(state);

        IERC721($.ipNft).safeTransferFrom(address(this), recipient, $.ipNftTokenId);

        emit IpWithdrawn({ recipient: recipient });
    }

    /**
     * @notice Returns the state of the curate
     * @return state The state of the curate
     */
    function getState() external view returns (State) {
        return _getAscCurateStorage().state;
    }

    /**
     * @notice Returns the address of the curate admin
     * @return admin The address of the curate admin
     */
    function getAdmin() external view returns (address) {
        return _getAscCurateStorage().admin;
    }

    /**
     * @notice Returns the ID of the IP
     * @return ipId The ID of the IP
     */
    function getIpId() external view returns (address) {
        return _getAscCurateStorage().ipId;
    }

    /**
     * @notice Returns the deposited amount of a user
     * @param user The address of the user
     * @return amount The deposited amount of the user
     */
    function getDepositedAmount(address user) external view returns (uint256) {
        return _getAscCurateStorage().deposits[user];
    }

    /**
     * @notice Returns the total deposited amount
     * @return totalDeposited The total deposited amount
     */
    function getTotalDeposited() external view returns (uint256) {
        return _getAscCurateStorage().totalDeposits;
    }

    /**
     * @notice Returns the expiration time of the curate
     * @return expirationTime The expiration time of the curate
     */
    function getExpirationTime() external view returns (uint256) {
        return _getAscCurateStorage().expirationTime;
    }

    /**
     * @notice Returns the address of the fund receiver
     * @return fundReceiver The address of the fund receiver
     */
    function getFundReceiver() external view returns (address) {
        return _getAscCurateStorage().fundReceiver;
    }

    /**
     * @notice Returns the name of the bio project
     * @return bioName The name of the bio project
     */
    function getBioName() external view returns (string memory) {
        return _getAscCurateStorage().bioName;
    }

    /**
     * @notice Returns the address of the bio token
     * @return bioToken The address of the bio token
     */
    function getBioToken() external view returns (address) {
        return _getAscCurateStorage().bioToken;
    }

    /**
     * @notice Returns the name of the bio token
     * @return bioTokenName The name of the bio token
     */
    function getBioTokenName() external view returns (string memory) {
        return _getAscCurateStorage().bioTokenName;
    }

    /**
     * @notice Returns the symbol of the bio token
     * @return bioTokenSymbol The symbol of the bio token
     */
    function getBioTokenSymbol() external view returns (string memory) {
        return _getAscCurateStorage().bioTokenSymbol;
    }

    /**
     * @notice Returns the total supply of the bio token
     * @return totalSupplyOfBioToken The total supply of the bio token
     */
    function getTotalSupplyOfBioToken() external pure returns (uint256) {
        return TOTAL_BIO_TOKEN_SUPPLY;
    }

    /**
     * @notice Returns the address of the staking contract
     * @return stakingContract The address of the staking contract
     */
    function getStakingContract() external view returns (address) {
        return _getAscCurateStorage().stakingContract;
    }

    /**
     * @notice Returns the address of the upgradeable beacon
     * @return upgradeableBeacon The address of the upgradeable beacon
     */
    function getUpgradeableBeacon() external view returns (address) {
        return UPGRADEABLE_BEACON;
    }

    /**
     * @dev deploy bio token
     * @param ipId The IP ID
     * @param bioTokenTemplate The template of the bio token
     * @return bioToken The address of the bio token
     */
    function _deployBioToken(address ipId, address bioTokenTemplate) internal returns (address bioToken) {
        AscCurateStorage storage $ = _getAscCurateStorage();
        if (TOTAL_BIO_TOKEN_SUPPLY < $.totalDeposits)
            // This should never happen
            revert Errors.AscCurate__BioTokenSupplyLessThanTotalDeposits(TOTAL_BIO_TOKEN_SUPPLY, $.totalDeposits);
        if ($.bioToken != address(0)) revert Errors.AscCurate__BioTokenAlreadyDeployed($.bioToken);

        bioToken = TOKENIZER_MODULE.tokenize({
            ipId: ipId,
            tokenTemplate: bioTokenTemplate,
            initData: abi.encode(
                IOwnableERC20.InitData({
                    name: $.bioTokenName,
                    symbol: $.bioTokenSymbol,
                    cap: TOTAL_BIO_TOKEN_SUPPLY,
                    initialOwner: address(this)
                })
            )
        });

        $.bioToken = bioToken;
    }

    /**
     * @dev deploy staking contract
     * @param stakingContractTemplate The template of the staking contract
     * @param bioToken The address of the bio token
     * @param initData The initialization data for the staking contract {see IAscStaking.InitData}
     * @return stakingContract The address of the staking contract
     */
    function _deployStakingContract(
        address stakingContractTemplate,
        address bioToken,
        IAscStaking.InitData memory initData
    ) internal returns (address stakingContract) {
        stakingContract = address(
            new BeaconProxy(
                IAscStaking(stakingContractTemplate).getUpgradeableBeacon(),
                abi.encodeCall(IAscStaking.initialize, (bioToken, initData))
            )
        );

        _getAscCurateStorage().stakingContract = stakingContract;
    }

    /**
     * @dev Checks if it has passed the expiration time, If so, updates the state to Closed
     */
    function _checkAndUpdateState() private {
        AscCurateStorage storage $ = _getAscCurateStorage();
        if ($.state == State.Open && $.expirationTime != 0 && block.timestamp >= $.expirationTime) {
            if ($.totalDeposits < $.minimalIpTokenForLaunch) {
                $.state = State.Canceled;
                emit CurateCanceled();
            } else {
                $.state = State.Closed;
                emit CurateClosed();
            }
        }
    }

    /// @dev Returns the storage struct of AscCurate.
    function _getAscCurateStorage() private pure returns (AscCurateStorage storage $) {
        assembly {
            $.slot := AscCurateStorageLocation
        }
    }
}
