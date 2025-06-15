// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

/**
 * @title IAscCurateFactory
 * @notice Interface for the IAscCurateFactory contract
 */
interface IAscCurateFactory {
    /**
     * @notice Emitted when a new curate is deployed
     * @param curate The address of the new curate
     */
    event CurateDeployed(address indexed curate);

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
        uint256 expiredTime,
        address fundReceiver,
        string memory bioName,
        string memory bioTokenName,
        string memory bioTokenSymbol,
        uint256 minimalIpTokenForLaunch
    ) external returns (address curate);

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
