// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { IAscStaking } from "./IAscStaking.sol";

interface IAscCurate {
    /**
     * @notice The state of the vault
     * When the vault is Open, the anyone can deposit $IP to the vault, the admin can cancel or close the vault.
     * When the vault is Closed, the admin can withdraw all funds to the fund receiver.
     * When the vault is Canceled, the depositor can claim their deposits.
     */
    enum State {
        Open,
        Closed,
        Canceled
    }

    /**
     * @dev The initialization data for the AscCurate
     * @param admin The address of the vault admin
     * @param ipId The ID of the IP
     * @param ipNft The address of the ERC 6551 NFT contract bound to the IP
     * @param ipNftTokenId The token ID of the ERC 6551 NFT contract bound to the IP
     * @param expirationTime The expiration time of the vault (0 if no expiration)
     * @param fundReceiver The address of the fund receiver (a safe/multisig address)
     * @param bioName The name of the bio project
     * @param bioTokenName The name of the bio token
     * @param bioTokenSymbol The symbol of the bio token
     * @param minimalIpTokenForLaunch The minimal IP token amount required for launch
     * @param rewardToken The address of the reward token
     */
    struct CurateInitData {
        address admin;
        address ipId;
        address ipNft;
        uint256 ipNftTokenId;
        uint256 expirationTime;
        address fundReceiver;
        string bioName;
        string bioTokenName;
        string bioTokenSymbol;
        uint256 minimalIpTokenForLaunch;
        address rewardToken;
    }

    /**
     * @notice Emitted when a deposit is received by the vault
     * @param depositor The address of the depositor
     * @param amount The amount of the token received
     */
    event DepositReceived(address indexed depositor, uint256 amount);

    /**
     * @notice Emitted when a refund is claimed by the depositor
     * @param claimer The address of the claimer
     * @param amount The amount of the token claimed
     */
    event RefundClaimed(address indexed claimer, uint256 amount);

    /**
     * @notice Emitted when tokens are withdrawn from the vault by the fund receiver
     * @param receiver The address of the fund receiver
     * @param amount The amount of the token withdrawn
     */
    event TokensWithdrawn(address indexed receiver, uint256 amount);

    /**
     * @notice Emitted when the bio token is claimed
     * @param claimer The address of the claimer
     * @param amountClaimed The amount of the bio token claimed
     */
    event BioTokenClaimed(address indexed claimer, uint256 amountClaimed);

    /**
     * @notice Emitted when the admin role is transferred
     * @param previousAdmin The address of the previous admin
     * @param newAdmin The address of the new admin
     */
    event AdminRoleTransferred(address indexed previousAdmin, address indexed newAdmin);

    /**
     * @notice Emitted when the vault is canceled
     */
    event VaultCanceled();

    /**
     * @notice Emitted when the vault is closed
     */
    event VaultClosed();

    /**
     * @notice Emitted when the project is launched
     * @param ipId The IP ID
     * @param bioToken The address of the bio token
     * @param stakingContract The address of the staking contract
     */
    event ProjectLaunched(address indexed ipId, address indexed bioToken, address indexed stakingContract);

    /**
     * @notice Emitted when the IP is withdrawn
     * @param recipient The address of the recipient
     */
    event IpWithdrawn(address indexed recipient);

    /**
     * @notice Initializes the AscCurate
     * @param initData The initialization data for the AscCurate {see IAscCurate.CurateInitData}
     */
    function initialize(CurateInitData memory initData) external;

    /**
     * @notice Deposits $IP token to the curate, only when the vault is Open
     * @param amount The amount of the IP token to deposit
     */
    function deposit(uint256 amount) external payable;

    /**
     * @notice Claims refund, only when the curate is canceled
     * @return amount The amount of the token claimed
     */
    function claimRefund() external returns (uint256 amount);

    /**
     * @notice Admin withdraws all funds to the fund receiver, only when the vault is Closed
     * @return withdrawnAmount The amount of IP token withdrawn
     */
    function withdraw() external returns (uint256 withdrawnAmount);

    /**
     * @notice User claims the bio tokens, only when the vault is Closed
     * @param claimer The address of the claimer
     * @return bioToken The address of the bio token
     * @return amountClaimed The amount of the bio token claimed
     */
    function claimBioTokens(address claimer) external returns (address bioToken, uint256 amountClaimed);

    /**
     * @notice Admin launches the bio project
     * @param bioTokenTemplate The template of the bio token
     * @param stakingContractTemplate The template of the staking contract
     * @param initData The initialization data for the staking contract
     * @return bioToken The address of the bio token
     * @return stakingContract The address of the staking contract
     */
    function launchProject(
        address bioTokenTemplate,
        address stakingContractTemplate,
        IAscStaking.InitData memory initData
    ) external returns (address bioToken, address stakingContract);

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
     * @param newAdmin The address of the new admin
     */
    function transferAdminRole(address newAdmin) external;

    /**
     * @notice Admin withdraws the IP NFT to the recipient, only when the vault is Canceled
     * @param recipient The address of the recipient
     */
    function withdrawIp(address recipient) external;

    /**
     * @notice Returns the state of the vault
     * @return state The state of the vault
     */
    function getState() external view returns (State state);

    /**
     * @notice Returns the address of the vault admin
     * @return admin The address of the vault admin
     */
    function getAdmin() external view returns (address admin);

    /**
     * @notice Returns the ID of the IP
     * @return ipId The ID of the IP
     */
    function getIpId() external view returns (address ipId);

    /**
     * @notice Returns the deposited amount of a user
     * @param user The address of the user
     * @return amount The deposited amount of the user
     */
    function getDepositedAmount(address user) external view returns (uint256 amount);

    /**
     * @notice Returns the total deposited amount
     * @return totalDeposited The total deposited amount
     */
    function getTotalDeposited() external view returns (uint256 totalDeposited);

    /**
     * @notice Returns the expiration time of the vault
     * @return expirationTime The expiration time of the vault
     */
    function getExpirationTime() external view returns (uint256 expirationTime);

    /**
     * @notice Returns the address of the fund receiver
     * @return fundReceiver The address of the fund receiver
     */
    function getFundReceiver() external view returns (address fundReceiver);

    /**
     * @notice Returns the name of the bio project
     * @return bioName The name of the bio project
     */
    function getBioName() external view returns (string memory bioName);

    /**
     * @notice Returns the address of the bio token
     * @return bioToken The address of the bio token
     */
    function getBioToken() external view returns (address bioToken);

    /**
     * @notice Returns the name of the bio token
     * @return bioTokenName The name of the bio token
     */
    function getBioTokenName() external view returns (string memory bioTokenName);

    /**
     * @notice Returns the symbol of the bio token
     * @return bioTokenSymbol The symbol of the bio token
     */
    function getBioTokenSymbol() external view returns (string memory bioTokenSymbol);

    /**
     * @notice Returns the total supply of the bio token
     * @return totalSupplyOfBioToken The total supply of the bio token
     */
    function getTotalSupplyOfBioToken() external view returns (uint256 totalSupplyOfBioToken);

    /**
     * @notice Returns the address of the staking contract
     * @return stakingContract The address of the staking contract
     */
    function getStakingContract() external view returns (address stakingContract);

    /**
     * @notice Returns the address of the upgradeable beacon
     * @return upgradeableBeacon The address of the upgradeable beacon
     */
    function getUpgradeableBeacon() external view returns (address upgradeableBeacon);
}
