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
     * @param curateTemplate_ The address of the curate template
     */
    function initialize(address admin_, address curateTemplate_) external initializer {
        if (admin_ == address(0)) revert Errors.AscCurateFactory__ZeroAdminAddress();
        if (curateTemplate_ == address(0)) revert Errors.AscCurateFactory__ZeroCurateTemplateAddress();

        __UUPSUpgradeable_init();

        AscCurateFactoryStorage storage $ = _getAscCurateFactoryStorage();
        $.admin = admin_;
        $.curateTemplate = curateTemplate_;
    }

    /**
     * @notice Launches a new curate instance
     * @param initData The initialization data for the AscCurate {see IAscCurate.CurateInitData}
     */
    function launchCurate(IAscCurate.CurateInitData memory initData) external returns (address curate) {
        // skip zero address checks since they are checked in the AscCurate initializer
        curate = address(
            new BeaconProxy(
                (IAscCurate(_getAscCurateFactoryStorage().curateTemplate)).getUpgradeableBeacon(),
                abi.encodeWithSelector(IAscCurate.initialize.selector, initData)
            )
        );

        IERC721(initData.ipNft).safeTransferFrom(msg.sender, curate, initData.ipNftTokenId);

        emit CurateDeployed(curate);
    }

    /**
     * @notice Sets the curate template
     * @param newCurateTemplate The address of the new curate template
     */
    function setCurateTemplate(address newCurateTemplate) external onlyAdmin {
        if (newCurateTemplate == address(0)) revert Errors.AscCurateFactory__ZeroCurateTemplateAddress();

        AscCurateFactoryStorage storage $ = _getAscCurateFactoryStorage();
        address oldCurateTemplate = $.curateTemplate;
        $.curateTemplate = newCurateTemplate;

        emit CurateTemplateUpdated(oldCurateTemplate, newCurateTemplate);
    }

    /**
     * @notice Returns the address of the curate template
     * @return curateTemplate The address of the curate template
     */
    function getCurateTemplate() external view returns (address) {
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
