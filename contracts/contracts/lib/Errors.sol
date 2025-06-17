// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { IAscCurate } from "../interfaces/IAscCurate.sol";

/**
 * @title Errors Library
 * @notice Library for all Asclepius contract custom errors.
 */
library Errors {
    ////////////////////////////////////////////////////////////////////////////
    //                           AscCurate Errors                          //
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @notice Thrown when the upgradeable beacon address is zero
     */
    error AscCurate__ZeroUpgradeableBeaconAddress();

    /**
     * @notice Thrown when the royalty module address is zero
     */
    error AscCurate__ZeroRoyaltyModuleAddress();

    /**
     * @notice Thrown when the tokenizer module address is zero
     */
    error AscCurate__ZeroTokenizerModuleAddress();

    /**
     * @notice Thrown when the IP asset registry address is zero
     */
    error AscCurate__ZeroIpAssetRegistryAddress();

    /**
     * @notice Thrown when the admin address is zero
     */
    error AscCurate__ZeroAdminAddress();

    /**
     * @notice Thrown when the IP ID address is zero
     */
    error AscCurate__ZeroIpIdAddress();

    /**
     * @notice Thrown when the IP NFT address is zero
     */
    error AscCurate__ZeroIpNftAddress();

    /**
     * @notice Thrown when the IP NFT token ID is zero
     */
    error AscCurate__ZeroIpNftTokenId();

    /**
     * @notice Thrown when the expiration time is not in the future
     * @param expirationTime The provided expiration time
     * @param currentTime The current time
     */
    error AscCurate__ExpirationTimeNotInFuture(uint256 expirationTime, uint256 currentTime);

    /**
     * @notice Thrown when the fund receiver address is zero
     */
    error AscCurate__ZeroFundReceiverAddress();

    /**
     * @notice Thrown when the IP is not registered
     * @param ipNft The IP NFT address
     * @param ipNftTokenId The IP NFT token ID
     * @param ipId The IP ID
     */
    error AscCurate__IpNotRegistered(address ipNft, uint256 ipNftTokenId, address ipId);

    /**
     * @notice Thrown when the IP is not transferred to curate
     * @param ipId The IP ID
     * @param ipNft The IP NFT address
     * @param ipNftTokenId The IP NFT token ID
     */
    error AscCurate__IpNotTransferredToCurate(address ipId, address ipNft, uint256 ipNftTokenId);

    /**
     * @notice Thrown when the bio token is not set
     */
    error AscCurate__BioTokenNotSet();

    /**
     * @notice Thrown when the caller is not the admin
     * @param caller The function caller address
     * @param admin The admin address
     */
    error AscCurate__CallerNotAdmin(address caller, address admin);

    /**
     * @notice Thrown when the curate is not open
     * @param currentState The current state of the curate
     */
    error AscCurate__CurateNotOpen(IAscCurate.State currentState);

    /**
     * @notice Thrown when the curate is not canceled
     * @param currentState The current state of the curate
     */
    error AscCurate__CurateNotCanceled(IAscCurate.State currentState);

    /**
     * @notice Thrown when there is no refundable deposit
     * @param claimer The address of the claimer
     */
    error AscCurate__NoRefundableDeposit(address claimer);

    /**
     * @notice Thrown when the curate is not closed
     * @param currentState The current state of the curate
     */
    error AscCurate__CurateNotClosed(IAscCurate.State currentState);

    /**
     * @notice Thrown when the deposit amount doesn't match the ETH sent
     * @param depositor The address of the depositor
     * @param providedAmount The amount parameter provided
     * @param actualAmount The actual ETH amount sent (msg.value)
     */
    error AscCurate__DepositAmountMismatch(address depositor, uint256 providedAmount, uint256 actualAmount);

    /**
     * @notice Thrown when the claimer is not eligible to claim the bio tokens
     * @param claimer The address of the claimer
     */
    error AscCurate__ClaimerNotEligible(address claimer);

    /**
     * @notice Thrown when the claimer has already claimed the bio tokens
     * @param claimer The address of the claimer
     */
    error AscCurate__ClaimerAlreadyClaimed(address claimer);

    /**
     * @notice Thrown when the total deposits is less than the minimum total deposits
     * @param totalDeposits The total deposits
     * @param minimumTotalDeposits The minimum total deposits
     */
    error AscCurate__TotalDepositsLessThanMinimumTotalDeposits(uint256 totalDeposits, uint256 minimumTotalDeposits);

    /**
     * @notice Thrown when the bio token total supply is less than the total deposits
     * @param bioTokenTotalSupply The total supply of the bio token
     * @param totalDeposits The total deposits
     */
    error AscCurate__BioTokenSupplyLessThanTotalDeposits(uint256 bioTokenTotalSupply, uint256 totalDeposits);

    /**
     * @notice Thrown when the bio token is already deployed
     * @param bioToken The address of the bio token
     */
    error AscCurate__BioTokenAlreadyDeployed(address bioToken);

    /**
     * @notice Thrown when the refund claim failed
     * @param claimer The address of the claimer
     * @param amount The amount of the refund
     */
    error AscCurate__RefundClaimFailed(address claimer, uint256 amount);

    /**
     * @notice Thrown when the withdraw failed
     * @param withdrawnAmount The amount of the IP token withdrawn
     */
    error AscCurate__WithdrawFailed(uint256 withdrawnAmount);

    /**
     * @notice Thrown when the IP royalty vault is not deployed
     * @param ipId The IP ID
     */
    error AscCurate__IpRoyaltyVaultNotDeployed(address ipId);

    /**
     * @notice Thrown when the allowance is insufficient
     * @param spender The address of the spender
     * @param allowance The allowance of the spender
     * @param expectedAllowance The expected allowance
     */
    error AscCurate__InsufficientRoyaltyVaultAllowance(address spender, uint256 allowance, uint256 expectedAllowance);

    ////////////////////////////////////////////////////////////////////////////
    //                           AscCurateFactory Errors                    //
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @notice Thrown when the caller is not the factory admin
     * @param caller The function caller address
     * @param admin The admin address
     */
    error AscCurateFactory__CallerNotAdmin(address caller, address admin);

    /**
     * @notice Thrown when the admin address is zero
     */
    error AscCurateFactory__ZeroAdminAddress();

    /**
     * @notice Thrown when the curate template address is zero
     */
    error AscCurateFactory__ZeroCurateTemplateAddress();

    ////////////////////////////////////////////////////////////////////////////
    //                           AscStaking Errors                         //
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @notice Thrown when the caller is not the admin
     * @param caller The function caller address
     * @param admin The admin address
     */
    error AscStaking__CallerNotAdmin(address caller, address admin);

    /**
     * @notice Thrown when the upgradeable beacon address is zero
     */
    error AscStaking__ZeroUpgradeableBeaconAddress();

    /**
     * @notice Thrown when the royalty module address is zero
     */
    error AscStaking__ZeroRoyaltyModuleAddress();

    /**
     * @notice Thrown when the fractional token address is zero
     */
    error AscStaking__ZeroFractionalTokenAddress();

    /**
     * @notice Thrown when the bio token address is zero
     */
    error AscStaking__ZeroBioTokenAddress();

    /**
     * @notice Thrown when the admin address is zero
     */
    error AscStaking__ZeroAdminAddress();

    /**
     * @notice Thrown when the IP ID address is zero
     */
    error AscStaking__ZeroIpIdAddress();

    /**
     * @notice Thrown when the reward token address is zero
     */
    error AscStaking__ZeroRewardTokenAddress();

    /**
     * @notice Thrown when the deposit amount is zero
     */
    error AscStaking__ZeroDepositAmount();

    /**
     * @notice Thrown when the withdraw amount is zero
     */
    error AscStaking__ZeroWithdrawAmount();

    /**
     * @notice Thrown when the staking token address is zero
     */
    error AscStaking__ZeroStakingTokenAddress();

    /**
     * @notice Thrown when the bio token alloc points is zero
     */
    error AscStaking__ZeroBioTokenAllocPoints();

    /**
     * @notice Thrown when the reward distribution period is zero
     */
    error AscStaking__ZeroRewardDistributionPeriod();

    /**
     * @notice Thrown when the staking pool already exists
     * @param stakingToken The address of the staking token
     */
    error AscStaking__StakingPoolAlreadyExists(address stakingToken);

    /**
     * @notice Thrown when the IP royalty vault is not deployed
     * @param ipId The IP ID
     */
    error AscStaking__IpRoyaltyVaultNotDeployed(address ipId);

    /**
     * @notice Thrown when the staker's staked balance is insufficient
     * @param staker The address of the staker
     * @param stakingToken The address of the staking token
     * @param stakedBalance The staker's staked balance
     * @param withdrawAmount The amount of bio tokens to withdraw
     */
    error AscStaking__InsufficientStakedBalance(
        address staker,
        address stakingToken,
        uint256 stakedBalance,
        uint256 withdrawAmount
    );

    /**
     * @notice Thrown when there are no rewards to claim
     * @param claimer The address of the claimer
     */
    error AscStaking__NoRewardsToClaim(address claimer);
}
