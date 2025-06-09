// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

/**
 * @title IAsclepiusIPVaultFactory
 * @notice Interface for the AsclepiusIPVaultFactory contract
 */
interface IAsclepiusIPVaultFactory {
    /**
     * @notice Emitted when a new IP vault is deployed
     * @param ipVault The address of the new IP vault
     */
    event IpVaultDeployed(address indexed ipVault);

    /**
     * @notice Emitted when the vault template is updated
     * @param oldVault The address of the old vault template
     * @param newVault The address of the new vault template
     */
    event VaultTemplateUpdated(address indexed oldVault, address indexed newVault);

    /**
     * @notice Initializes the factory
     * @param admin_ The address of the admin
     * @param vaultTemplate_ The address of the vault template
     */
    function initialize(address admin_, address vaultTemplate_) external;

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
    ) external returns (address ipVault);

    /**
     * @notice Sets the vault template
     * @param newVault The address of the new vault template
     */
    function setVaultTemplate(address newVault) external;

    /**
     * @notice Returns the address of the admin
     * @return admin The address of the admin
     */
    function getAdmin() external view returns (address);

    /**
     * @notice Returns the address of the vault template
     * @return vaultTemplate The address of the vault template
     */
    function getVaultTemplate() external view returns (address);
}
