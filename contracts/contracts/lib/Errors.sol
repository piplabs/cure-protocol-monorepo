// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { IAsclepiusIPVault } from "../interfaces/IAsclepiusIPVault.sol";

/**
 * @title Errors Library
 * @notice Library for all Asclepius contract custom errors.
 */
library Errors {
    ////////////////////////////////////////////////////////////////////////////
    //                           AsclepiusIPVault Errors                          //
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @notice Thrown when the upgradeable beacon address is zero
     */
    error AsclepiusIPVault__ZeroUpgradeableBeaconAddress();

    /**
     * @notice Thrown when the royalty token distribution workflows address is zero
     */
    error AsclepiusIPVault__ZeroRoyaltyTokenDistributionWorkflowsAddress();

    /**
     * @notice Thrown when the royalty module address is zero
     */
    error AsclepiusIPVault__ZeroRoyaltyModuleAddress();

    /**
     * @notice Thrown when the tokenizer module address is zero
     */
    error AsclepiusIPVault__ZeroTokenizerModuleAddress();

    /**
     * @notice Thrown when the fractional token template address is zero
     */
    error AsclepiusIPVault__ZeroFractionalTokenTemplateAddress();

    /**
     * @notice Thrown when the admin address is zero
     */
    error AsclepiusIPVault__ZeroAdminAddress();

    /**
     * @notice Thrown when the expiration time is not in the future
     * @param expirationTime The provided expiration time
     * @param currentTime The current time
     */
    error AsclepiusIPVault__ExpirationTimeNotInFuture(uint256 expirationTime, uint256 currentTime);

    /**
     * @notice Thrown when the fund receiver address is zero
     */
    error AsclepiusIPVault__ZeroFundReceiverAddress();

    /**
     * @notice Thrown when the USDC contract address is zero
     */
    error AsclepiusIPVault__ZeroUsdcContractAddress();

    /**
     * @notice Thrown when the spg nft contract address is zero
     */
    error AsclepiusIPVault__ZeroSPGNftContractAddress();

    /**
     * @notice Thrown when the fractional token is not set
     */
    error AsclepiusIPVault__FractionalTokenNotSet();

    /**
     * @notice Thrown when the caller is not the admin
     * @param caller The function caller address
     * @param admin The admin address
     */
    error AsclepiusIPVault__CallerNotAdmin(address caller, address admin);

    /**
     * @notice Thrown when the USDC address is invalid
     */
    error AsclepiusIPVault__InvalidUSDCAddress();

    /**
     * @notice Thrown when the token is not supported
     */
    error AsclepiusIPVault__UnsupportedIERC20();

    /**
     * @notice Thrown when the vault is not open
     * @param currentState The current state of the vault
     */
    error AsclepiusIPVault__VaultNotOpen(IAsclepiusIPVault.State currentState);

    /**
     * @notice Thrown when the vault is not canceled
     * @param currentState The current state of the vault
     */
    error AsclepiusIPVault__VaultNotCanceled(IAsclepiusIPVault.State currentState);

    /**
     * @notice Thrown when there is no refundable deposit
     * @param claimer The address of the claimer
     * @param token The address of the token that the claimer wants to claim
     */
    error AsclepiusIPVault__NoRefundableDeposit(address claimer, address token);

    /**
     * @notice Thrown when the vault is not closed
     * @param currentState The current state of the vault
     */
    error AsclepiusIPVault__VaultNotClosed(IAsclepiusIPVault.State currentState);

    /**
     * @notice Thrown when the deposit amount is zero
     * @param depositor The address of the depositor
     * @param token The address of the token that the depositor wants to deposit
     */
    error AsclepiusIPVault__ZeroDepositAmount(address depositor, address token);

    /**
     * @notice Thrown when the claimer is not eligible to claim the fractionalized IP tokens
     * @param claimer The address of the claimer
     */
    error AsclepiusIPVault__ClaimerNotEligible(address claimer);

    /**
     * @notice Thrown when the claimer has already claimed the fractionalized IP tokens
     * @param claimer The address of the claimer
     */
    error AsclepiusIPVault__ClaimerAlreadyClaimed(address claimer);

    /**
     * @notice Thrown when there are active deposits
     * @param token The address of the token
     * @param totalDeposits The total deposits
     */
    error AsclepiusIPVault__ActiveDepositsExist(address token, uint256 totalDeposits);

    /**
     * @notice Thrown when the fractional token total supply is less than the total deposits
     * @param fractionalTokenTotalSupply The total supply of the fractional token
     * @param totalDeposits The total deposits
     */
    error AsclepiusIPVault__FractionalTokenSupplyLessThanTotalDeposits(
        uint256 fractionalTokenTotalSupply,
        uint256 totalDeposits
    );

    /**
     * @notice Thrown when the fractional token is already deployed
     * @param fractionalToken The address of the fractional token
     */
    error AsclepiusIPVault__FractionalTokenAlreadyDeployed(address fractionalToken);

    ////////////////////////////////////////////////////////////////////////////
    //                           AsclepiusIPVaultFactory Errors                    //
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @notice Thrown when the caller is not the factory admin
     * @param caller The function caller address
     * @param admin The admin address
     */
    error AsclepiusIPVaultFactory__CallerNotAdmin(address caller, address admin);

    /**
     * @notice Thrown when the admin address is zero
     */
    error AsclepiusIPVaultFactory__ZeroAdminAddress();

    /**
     * @notice Thrown when the vault template address is zero
     */
    error AsclepiusIPVaultFactory__ZeroVaultTemplateAddress();

    ////////////////////////////////////////////////////////////////////////////
    //                       AsclepiusIPDistributionContract Errors              //
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @notice Thrown when the caller is not the admin
     * @param caller The function caller address
     * @param admin The admin address
     */
    error AsclepiusIPDistributionContract__CallerNotAdmin(address caller, address admin);

    /**
     * @notice Thrown when the royalty module address is zero
     */
    error AsclepiusIPDistributionContract__ZeroRoyaltyModuleAddress();

    /**
     * @notice Thrown when the upgradeable beacon address is zero
     */
    error AsclepiusIPDistributionContract__ZeroUpgradeableBeaconAddress();

    /**
     * @notice Thrown when the fractional token address is zero
     */
    error AsclepiusIPDistributionContract__ZeroFractionalTokenAddress();

    /**
     * @notice Thrown when the admin address is zero
     */
    error AsclepiusIPDistributionContract__ZeroAdminAddress();

    /**
     * @notice Thrown when the IP ID address is zero
     */
    error AsclepiusIPDistributionContract__ZeroIpIdAddress();

    /**
     * @notice Thrown when the protocol treasury address is zero
     */
    error AsclepiusIPDistributionContract__ZeroProtocolTreasuryAddress();

    /**
     * @notice Thrown when the reward token address is zero
     */
    error AsclepiusIPDistributionContract__ZeroRewardTokenAddress();

    /**
     * @notice Thrown when the fractional token alloc points is zero
     */
    error AsclepiusIPDistributionContract__ZeroFractionalTokenAllocPoints();

    /**
     * @notice Thrown when the staking token address is zero
     */
    error AsclepiusIPDistributionContract__ZeroStakingTokenAddress();

    /**
     * @notice Thrown when the deposit amount is zero
     */
    error AsclepiusIPDistributionContract__ZeroDepositAmount();

    /**
     * @notice Thrown when the withdraw amount is zero
     */
    error AsclepiusIPDistributionContract__ZeroWithdrawAmount();

    /**
     * @notice Thrown when the reward distribution period is zero
     */
    error AsclepiusIPDistributionContract__ZeroRewardDistributionPeriod();

    /**
     * @notice Thrown when attempting to add a staking pool that already exists
     * @param stakingToken The address of the staking token
     */
    error AsclepiusIPDistributionContract__StakingPoolAlreadyExists(address stakingToken);

    /**
     * @notice Thrown when the staker's staked balance is insufficient
     * @param staker The address of the staker
     * @param stakingToken The address of the staking token
     * @param stakedBalance The staker's staked balance
     * @param withdrawAmount The amount of staking tokens to withdraw
     */
    error AsclepiusIPDistributionContract__InsufficientStakedBalance(
        address staker,
        address stakingToken,
        uint256 stakedBalance,
        uint256 withdrawAmount
    );

    /**
     * @notice Thrown when there are no rewards to claim
     * @param claimer The address of the claimer
     */
    error AsclepiusIPDistributionContract__NoRewardsToClaim(address claimer);

    /**
     * @notice Thrown when the IP royalty vault is not deployed
     * @param ipId The IP ID
     */
    error AsclepiusIPDistributionContract__IpRoyaltyVaultNotDeployed(address ipId);
}
