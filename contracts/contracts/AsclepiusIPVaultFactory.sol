// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { Errors } from "./lib/Errors.sol";
import { IAsclepiusIPVault } from "./interfaces/IAsclepiusIPVault.sol";
import { IAsclepiusIPVaultFactory } from "./interfaces/IAsclepiusIPVaultFactory.sol";

/**
 * @title AsclepiusIPVaultFactory
 * @notice This contract is used to deploy new AsclepiusIPVault instances
 */
contract AsclepiusIPVaultFactory is IAsclepiusIPVaultFactory, UUPSUpgradeable {
    /**
     * @dev Storage structure for the AsclepiusIPVaultFactory
     * @custom:storage-location erc7201:asclepius-protocol.AsclepiusIPVaultFactory
     */
    struct AsclepiusIPVaultFactoryStorage {
        address admin;
        address vaultTemplate;
    }

    // keccak256(abi.encode(uint256(keccak256("asclepius-protocol.AsclepiusIPVaultFactory")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant AsclepiusIPVaultFactoryStorageLocation =
        0xd9ee93c04e865258b9c7bc0d4b8b484d88147f1de6b2035289e5b445625d1200;

    /// @dev Modifier to check if the caller is the admin
    modifier onlyAdmin() {
        if (msg.sender != _getAsclepiusIPVaultFactoryStorage().admin) {
            revert Errors.AsclepiusIPVaultFactory__CallerNotAdmin(
                msg.sender,
                _getAsclepiusIPVaultFactoryStorage().admin
            );
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
        if (admin_ == address(0)) revert Errors.AsclepiusIPVaultFactory__ZeroAdminAddress();
        if (vaultTemplate_ == address(0)) revert Errors.AsclepiusIPVaultFactory__ZeroVaultTemplateAddress();

        __UUPSUpgradeable_init();

        AsclepiusIPVaultFactoryStorage storage $ = _getAsclepiusIPVaultFactoryStorage();
        $.admin = admin_;
        $.vaultTemplate = vaultTemplate_;
    }

    /**
     * @notice Deploys a new IP vault
     * @param vaultAdmin The address of the admin
     * @param expiredTime The expiration time
     * @param fundReceiver The address of the fund receiver
     * @param rwipName The name of the RWIP
     * @param fractionalTokenName The name of the fractional token
     * @param fractionalTokenSymbol The symbol of the fractional token
     * @param totalSupplyOfFractionalToken The total supply of the fractional token
     * @param usdcContractAddress The address of the USDC contract
     */
    function deployIpVault(
        address vaultAdmin,
        uint256 expiredTime,
        address fundReceiver,
        string memory rwipName,
        string memory fractionalTokenName,
        string memory fractionalTokenSymbol,
        uint256 totalSupplyOfFractionalToken,
        address usdcContractAddress
    ) external returns (address ipVault) {
        // skip zero address checks since they are checked in the AsclepiusIPVault initializer
        ipVault = address(
            new BeaconProxy(
                IAsclepiusIPVault(_getAsclepiusIPVaultFactoryStorage().vaultTemplate).getUpgradeableBeacon(),
                abi.encodeWithSelector(
                    IAsclepiusIPVault.initialize.selector,
                    vaultAdmin,
                    expiredTime,
                    fundReceiver,
                    rwipName,
                    fractionalTokenName,
                    fractionalTokenSymbol,
                    totalSupplyOfFractionalToken,
                    usdcContractAddress
                )
            )
        );

        emit IpVaultDeployed(ipVault);
    }

    /**
     * @notice Sets the vault template
     * @param newVault The address of the new vault template
     */
    function setVaultTemplate(address newVault) external onlyAdmin {
        if (newVault == address(0)) revert Errors.AsclepiusIPVaultFactory__ZeroVaultTemplateAddress();

        AsclepiusIPVaultFactoryStorage storage $ = _getAsclepiusIPVaultFactoryStorage();
        address oldVault = $.vaultTemplate;
        $.vaultTemplate = newVault;

        emit VaultTemplateUpdated(oldVault, newVault);
    }

    /**
     * @notice Returns the address of the vault template
     * @return vaultTemplate The address of the vault template
     */
    function getVaultTemplate() external view returns (address) {
        return _getAsclepiusIPVaultFactoryStorage().vaultTemplate;
    }

    /**
     * @notice Returns the address of the admin
     * @return admin The address of the admin
     */
    function getAdmin() external view returns (address) {
        return _getAsclepiusIPVaultFactoryStorage().admin;
    }

    /// @dev Returns the storage struct of AsclepiusIPVaultFactory.
    function _getAsclepiusIPVaultFactoryStorage() private pure returns (AsclepiusIPVaultFactoryStorage storage $) {
        assembly {
            $.slot := AsclepiusIPVaultFactoryStorageLocation
        }
    }

    /**
     * @dev Hook to authorize the upgrade according to UUPSUpgradeable
     * @dev Enforced to be only callable by the protocol admin in governance.
     * @param newImplementation The address of the new implementation
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {}
}
