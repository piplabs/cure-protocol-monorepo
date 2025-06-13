// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { WorkflowStructs } from "@storyprotocol/periphery/contracts/lib/WorkflowStructs.sol";

import { IAsclepiusIPDistributionContract } from "./IAsclepiusIPDistributionContract.sol";

/**
 * @title IAsclepiusIPVault
 * @notice Interface for the Asclepius IP Vault
 */
interface IAsclepiusIPVault {
    /**
     * @notice The state of the vault
     * When the vault is Open, the anyone can deposit IP token to the vault, the admin can cancel or close the vault.
     * When the vault is Closed, the admin can withdraw all funds to the fund receiver.
     * When the vault is Canceled, the depositor can claim their deposits.
     */
    enum State {
        Open,
        Closed,
        Canceled
    }

    /**
     * @notice Emitted when a deposit is received by the vault
     * @param depositor The address of the depositor
     * @param amount The amount of the IP token received
     */
    event DepositReceived(address indexed depositor, uint256 amount);

    /**
     * @notice Emitted when a refund is claimed by the depositor
     * @param claimer The address of the claimer
     * @param amount The amount of the IP token claimed
     */
    event RefundClaimed(address indexed claimer, uint256 amount);

    /**
     * @notice Emitted when tokens are withdrawn from the vault by the fund receiver
     * @param receiver The address of the fund receiver
     * @param amount The amount of the IP token withdrawn
     */
    event TokensWithdrawn(address indexed receiver, uint256 amount);

    /**
     * @notice Emitted when the admin role is transferred
     * @param previousAdmin The address of the previous admin
     * @param newAdmin The address of the new admin
     */
    event AdminRoleTransferred(address indexed previousAdmin, address indexed newAdmin);

    /**
     * @notice Emitted when the fractional token total supply is updated
     * @param previousTotalSupply The previous total supply of the fractional token
     * @param newTotalSupply The new total supply of the fractional token
     */
    event FractionalTokenTotalSupplyUpdated(uint256 previousTotalSupply, uint256 newTotalSupply);

    /**
     * @notice Emitted when the fractional token is minted
     * @param ipId The address of the newly registered IP
     * @param spgNftContract The address of the SPG NFT contract that was used to register the IP
     * @param tokenId The token id in the SPG NFT contract that was used to register the IP
     * @param licenseTermsId The license terms ID attached to the IP
     * @param fractionalToken The address of the fractional token
     * @param distributionContract The address of the IP distribution contract
     */
    event IPRegisteredAndFractionalized(
        address indexed ipId,
        address spgNftContract,
        uint256 tokenId,
        uint256 licenseTermsId,
        address indexed fractionalToken,
        address indexed distributionContract
    );

    /**
     * @notice Emitted when the fractional token is claimed
     * @param claimer The address of the claimer
     * @param amountClaimed The amount of the fractional token claimed
     */
    event FractionalTokenClaimed(address indexed claimer, uint256 amountClaimed);

    /**
     * @notice Emitted when the vault is canceled
     */
    event VaultCanceled();

    /**
     * @notice Emitted when the vault is closed
     */
    event VaultClosed();
    /**
     * @notice Initializes the vault
     * @param admin_ The address of the admin
     * @param expirationTime_ The expiration time
     * @param fundReceiver_ The address of the fund receiver
     * @param rwipName_ The name of the RWIP
     * @param fractionalTokenName_ The name of the fractional token
     * @param fractionalTokenSymbol_ The symbol of the fractional token
     * @param fractionalTokenTotalSupply_ The total supply of the fractional token
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
        uint256 minimumTotalDeposits_
    ) external;

    /**
     * @notice Deposits IP token to the vault, only when the vault is Open
     */
    function deposit() external payable;

    /**
     * @notice Claims refund, only when the vault is Canceled
     * @return amount The amount of the IP token claimed
     */
    function claimRefund() external returns (uint256 amount);

    /**
     * @notice Transfers all funds to the fund receiver, only when the vault is Closed
     * @dev Only the admin can withdraw funds
     * @return withdrawnAmount The amount of the IP token withdrawn
     */
    function withdraw() external returns (uint256 withdrawnAmount);

    /**
     * @notice Registers the IP and fractionalizes the IP
     * @param spgNftContract The address of the SPG NFT contract
     * @param ipMetadata The metadata of the IP
     * @param licenseTermsData The license terms data to be attached to the IP
     * @param fractionalTokenTemplate The template of the fractional token
     * @param distributionContractTemplate The template of the IP distribution contract
     * @param initData The initialization data for the distribution contract {see IAsclepiusIPDistributionContract.InitData}
     * @return tokenId The token ID of the fractionalized IP
     * @return ipId The address of the IP
     * @return licenseTermsId The license terms ID
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
        returns (
            uint256 tokenId,
            address ipId,
            uint256 licenseTermsId,
            address fractionalToken,
            address distributionContract
        );

    /**
     * @notice Claims the fractionalized IP tokens, only when the vault is Closed
     * @param claimer The address of the claimer
     * @return fractionalToken The address of the fractional token
     * @return amountClaimed The amount of the fractional token claimed
     */
    function claimFractionalTokens(address claimer) external returns (address fractionalToken, uint256 amountClaimed);

    /**
     * @notice Cancels the vault, only when the vault is Open
     * @dev Only the admin can cancel the vault
     */
    function cancel() external;

    /**
     * @notice Closes the vault, only when the vault is Open
     * @dev Only the admin can close the vault
     */
    function close() external;

    /**
     * @notice Transfers the admin role
     * @dev Only the admin can transfer the admin role
     */
    function transferAdminRole(address newAdmin) external;

    /**
     * @notice Admin updates the total supply of the fractional token
     * @param newTotalSupply The new total supply of the fractional token
     */
    function updateFractionalTokenTotalSupply(uint256 newTotalSupply) external;

    /**
     * @notice Returns the state of the vault
     * @return state The state of the vault
     */
    function getState() external view returns (State);

    /**
     * @notice Returns the address of the vault admin
     * @return admin The address of the vault admin
     */
    function getAdmin() external view returns (address);

    /**
     * @notice Returns the ID of the IP (0 if not registered)
     * @return ipId The ID of the IP
     */
    function getIpId() external view returns (address);

    /**
     * @notice Returns the deposited amount of a user
     * @param user The address of the user
     * @return amount The deposited amount of the user
     */
    function getDepositedAmount(address user) external view returns (uint256);

    /**
     * @notice Returns the total deposited amount
     * @return totalDeposited The total deposited amount
     */
    function getTotalDeposited() external view returns (uint256);

    /**
     * @notice Returns the expiration time of the vault
     * @return expirationTime The expiration time of the vault
     */
    function getExpirationTime() external view returns (uint256);

    /**
     * @notice Returns the address of the fund receiver
     * @return fundReceiver The address of the fund receiver
     */
    function getFundReceiver() external view returns (address);

    /**
     * @notice Returns the name of the Real-World Intellectual Property
     * @return rwipName The name of the Real-World Intellectual Property
     */
    function getRwipName() external view returns (string memory);

    /**
     * @notice Returns the name of the fractional token
     * @return fractionalTokenName The name of the fractional token
     */
    function getFractionalTokenName() external view returns (string memory);

    /**
     * @notice Returns the symbol of the fractional token
     * @return fractionalTokenSymbol The symbol of the fractional token
     */
    function getFractionalTokenSymbol() external view returns (string memory);

    /**
     * @notice Returns the total supply of the fractional token
     * @return totalySupplyOfFractionToken The total supply of the fractional token
     */
    function getTotalSupplyOfFractionalToken() external view returns (uint256);

    /**
     * @notice Returns the address of the fractional token (0 if not fractionalized)
     * @return fractionalToken The address of the fractional token
     */
    function getFractionalToken() external view returns (address);

    /**
     * @notice Returns the address of the upgradeable beacon of the AsclepiusIPVault
     * @return upgradeableBeacon The address of the upgradeable beacon
     */
    function getUpgradeableBeacon() external view returns (address);
}
