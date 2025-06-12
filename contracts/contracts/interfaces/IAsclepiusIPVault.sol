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
     * @param token The address of the token received
     * @param amount The amount of the token received
     */
    event DepositReceived(address indexed depositor, address indexed token, uint256 amount);

    /**
     * @notice Emitted when a refund is claimed by the depositor
     * @param claimer The address of the claimer
     * @param token The address of the token claimed
     * @param amount The amount of the token claimed
     */
    event RefundClaimed(address indexed claimer, address indexed token, uint256 amount);

    /**
     * @notice Emitted when tokens are withdrawn from the vault by the fund receiver
     * @param receiver The address of the fund receiver
     * @param tokens The addresses of the tokens withdrawn
     * @param amounts The amounts of the tokens withdrawn
     */
    event TokensWithdrawn(address indexed receiver, address[] indexed tokens, uint256[] amounts);

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
     * @notice Emitted when the IP token contract address is updated
     * @param previousIpTokenContractAddress The address of the previous IP token contract
     * @param newIpTokenContractAddress The address of the new IP token contract
     */
    event IpTokenContractAddressUpdated(
        address indexed previousIpTokenContractAddress,
        address indexed newIpTokenContractAddress
    );

    /**
     * @notice Initializes the vault
     * @param admin_ The address of the admin
     * @param expiredTime_ The expiration time
     * @param fundReceiver_ The address of the fund receiver
     * @param rwipName_ The name of the RWIP
     * @param fractionalTokenName_ The name of the fractional token
     * @param fractionalTokenSymbol_ The symbol of the fractional token
     * @param totalySupplyOfFractionalizedToken_ The total supply of the fractionalized token
     * @param ipTokenContractAddress_ The address of the IP token contract
     */
    function initialize(
        address admin_,
        uint256 expiredTime_,
        address fundReceiver_,
        string memory rwipName_,
        string memory fractionalTokenName_,
        string memory fractionalTokenSymbol_,
        uint256 totalySupplyOfFractionalizedToken_,
        address ipTokenContractAddress_
    ) external;

    /**
     * @notice Deposits IP token to the vault, only when the vault is Open
     * @param erc20 The address of the token to deposit
     * @param amount The amount of the token to deposit
     */
    function deposit(address erc20, uint256 amount) external;

    /**
     * @notice Claims refund, only when the vault is Canceled
     * @param erc20 The address of the token to claim refund
     * @return amount The amount of the token claimed
     */
    function claimRefund(address erc20) external returns (uint256 amount);

    /**
     * @notice Transfers all funds to the fund receiver, only when the vault is Closed
     * @dev Only the admin can withdraw funds
     * @return tokens The addresses of the tokens withdrawn
     * @return withdrawnAmounts The amounts of the tokens withdrawn
     */
    function withdraw() external returns (address[] memory tokens, uint256[] memory withdrawnAmounts);

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
     * @notice Admin updates the IP token contract address
     * @param newIpTokenContractAddress The address of the new IP token contract
     */
    function updateIpTokenContractAddress(address newIpTokenContractAddress) external;

    /**
     * @notice Admin updates the total supply of the fractional token
     * @param newTotalSupply The new total supply of the fractional token
     */
    function updateFractionalTokenTotalSupply(uint256 newTotalSupply) external;

    /**
     * @notice Returns the address of the IP token contract
     * @return ipTokenContractAddress The address of the IP token contract
     */
    function getIpTokenContractAddress() external view returns (address);

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
     * @notice Returns the deposited amount of a user for a token
     * @param user The address of the user
     * @param token The address of the token
     * @return amount The deposited amount of the user for the token
     */
    function getDepositedAmount(address user, address token) external view returns (uint256);

    /**
     * @notice Returns the total deposited amount of a token
     * @param token The address of the token
     * @return totalDeposited The total deposited amount of the token
     */
    function getTotalDeposited(address token) external view returns (uint256);

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
