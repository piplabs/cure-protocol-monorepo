// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { Errors } from "./lib/Errors.sol";
import { IAscCurate } from "./interfaces/IAscCurate.sol";
import { IAscCurateFactory } from "./interfaces/IAscCurateFactory.sol";

/**
 * @title AscCurateFactory
 * @notice This contract is used to deploy new AscCurate instances
 */
contract AscCurateFactory is IAscCurateFactory, UUPSUpgradeable {
    /// @dev Storage structure for the AscCurateFactory
    /// @custom:storage-location erc7201:asclepius-protocol.AscCurateFactory
    struct AscCurateFactoryStorage {
        address admin;
        address curateTemplate;
    }

    // keccak256(abi.encode(uint256(keccak256("asclepius-protocol.AscCurateFactory")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant AscCurateFactoryStorageLocation =
        0xd3d037f78491eb046e62d648afc0613570e0db1eedef9ea8641bb04690864500;

    /// @dev Modifier to check if the caller is the admin
    modifier onlyAdmin() {
        if (msg.sender != _getAscCurateFactoryStorage().admin) {
            revert Errors.AscCurateFactory__CallerNotAdmin(msg.sender, _getAscCurateFactoryStorage().admin);
        }
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the factory
     * @param admin_ The address of the admin
     * @param vaultTemplate_ The address of the vault template
     */
    function initialize(address admin_, address vaultTemplate_) external initializer {
        if (admin_ == address(0)) revert Errors.AscCurateFactory__ZeroAdminAddress();
        if (vaultTemplate_ == address(0)) revert Errors.AscCurateFactory__ZeroVaultTemplateAddress();

        __UUPSUpgradeable_init();

        AscCurateFactoryStorage storage $ = _getAscCurateFactoryStorage();
        $.admin = admin_;
        $.curateTemplate = vaultTemplate_;
    }

    /**
     * @notice Launches a new curate instance
     * @param admin The address of the admin
     * @param ipId The IP ID address
     * @param expiredTime The expiration time
     * @param fundReceiver The address of the fund receiver
     * @param bioName The name of the bio project
     * @param bioTokenName The name of the bio token
     * @param bioTokenSymbol The symbol of the bio token
     * @param minimalIpTokenForLaunch The minimal IP token amount required for launch
     */
    function launchCurate(
        address admin,
        address ipId,
        address ipNft,
        uint256 ipNftTokenId,
        uint256 expiredTime,
        address fundReceiver,
        string memory bioName,
        string memory bioTokenName,
        string memory bioTokenSymbol,
        uint256 minimalIpTokenForLaunch,
        address rewardToken
    ) external returns (address curate) {
        // skip zero address checks since they are checked in the AscCurate initializer
        curate = address(
            new BeaconProxy(
                _getAscCurateFactoryStorage().curateTemplate,
                abi.encodeWithSelector(
                    IAscCurate.initialize.selector,
                    admin, // admin
                    ipId,
                    ipNft,
                    ipNftTokenId,
                    expiredTime,
                    fundReceiver,
                    bioName,
                    bioTokenName,
                    bioTokenSymbol,
                    minimalIpTokenForLaunch,
                    rewardToken
                )
            )
        );

        IERC721(ipNft).safeTransferFrom(msg.sender, curate, ipNftTokenId);

        emit CurateDeployed(curate);
    }

    /**
     * @notice Sets the vault template
     * @param newVault The address of the new vault template
     */
    function setVaultTemplate(address newVault) external onlyAdmin {
        if (newVault == address(0)) revert Errors.AscCurateFactory__ZeroVaultTemplateAddress();

        AscCurateFactoryStorage storage $ = _getAscCurateFactoryStorage();
        address oldVault = $.curateTemplate;
        $.curateTemplate = newVault;

        emit VaultTemplateUpdated(oldVault, newVault);
    }

    /**
     * @notice Returns the address of the vault template
     * @return vaultTemplate The address of the vault template
     */
    function getVaultTemplate() external view returns (address) {
        return _getAscCurateFactoryStorage().curateTemplate;
    }

    /**
     * @notice Returns the address of the admin
     * @return admin The address of the admin
     */
    function getAdmin() external view returns (address) {
        return _getAscCurateFactoryStorage().admin;
    }

    /// @dev Returns the storage struct of AscCurateFactory.
    function _getAscCurateFactoryStorage() private pure returns (AscCurateFactoryStorage storage $) {
        assembly {
            $.slot := AscCurateFactoryStorageLocation
        }
    }

    /**
     * @dev Hook to authorize the upgrade according to UUPSUpgradeable
     * @dev Enforced to be only callable by the protocol admin in governance.
     * @param newImplementation The address of the new implementation
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {}
}
