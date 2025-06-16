// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

/**
 * @title IAscStaking
 * @notice Interface for the IAscStaking contract
 */
interface IAscStaking {
    /**
     * @dev Data structure for initializing the IAscStaking
     * @param admin The address of the admin
     * @param ipId The address of the IP
     * @param rewardDistributionPeriod The number of blocks during which the all rewards are distributed
     * @param rewardToken The address of the reward token
     * @param bioTokenAllocPoints The allocation points for the bio token staking pool
     */
    struct InitData {
        address admin;
        address ipId;
        uint256 rewardDistributionPeriod;
        address rewardToken;
        uint256 bioTokenAllocPoints;
    }

    /**
     * @notice Emitted when a user deposits staking tokens
     * @param staker The address of the staker
     * @param stakingToken The address of the staking token
     * @param depositedAmount The amount of the staking token deposited
     */
    event Deposited(address indexed staker, address indexed stakingToken, uint256 depositedAmount);

    /**
     * @notice Emitted when a user withdraws staking tokens
     * @param staker The address of the staker
     * @param stakingToken The address of the staking token
     * @param withdrawnAmount The amount of the staking token withdrawn
     */
    event Withdrawn(address indexed staker, address indexed stakingToken, uint256 withdrawnAmount);

    /**
     * @notice Emitted when a user claims all their rewards
     * @param staker The address of the staker
     * @param totalRewards The total amount of rewards claimed
     */
    event RewardsClaimed(address indexed staker, uint256 totalRewards);

    /**
     * @notice Emitted when royalties are collected and distributed
     * @param ipId The address of the IP
     * @param totalRoyaltiesCollected The total amount of royalties collected
     * @param distributionEndBlock The end block of the current distribution period
     */
    event RoyaltiesCollected(address indexed ipId, uint256 totalRoyaltiesCollected, uint256 distributionEndBlock);

    /**
     * @notice Emitted when a new staking pool is added
     * @param stakingToken The address of the staking token for which the staking pool is added
     * @param allocPoints The allocation points for the staking pool
     */
    event StakingPoolAdded(address indexed stakingToken, uint256 allocPoints);

    /**
     * @notice Emitted when allocation points for a staking pool are updated
     * @param stakingToken The address of the staking token for which the allocation points are updated
     * @param oldAllocPoints The old allocation points for the staking pool
     * @param newAllocPoints The new allocation points for the staking pool
     */
    event PoolAllocPointsUpdated(address indexed stakingToken, uint256 oldAllocPoints, uint256 newAllocPoints);

    /**
     * @notice Emitted when the reward distribution period is updated
     * @param oldPeriod The old reward distribution period
     * @param newPeriod The new reward distribution period
     */
    event RewardDistributionPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);

    /**
     * @dev Initializes the IAscStaking
     * @param bioToken The address of the bio token
     * @param initData The initialization data {see IAscStaking.InitData}
     */
    function initialize(address bioToken, InitData memory initData) external;

    /**
     * @dev Deposits a staking token into the distribution contract
     * @param stakingToken The address of the staking token
     * @param amount The amount of the staking token to deposit
     */
    function deposit(address stakingToken, uint256 amount) external;

    /**
     * @dev Withdraws a staking token from the distribution contract
     * @param stakingToken The address of the staking token
     * @param amount The amount of the staking token to withdraw
     */
    function withdraw(address stakingToken, uint256 amount) external;

    /**
     * @dev Claims all rewards for a staker
     * @param claimer The address of the staker
     */
    function claimAllRewards(address claimer) external;

    /**
     * @dev Collects royalties from the royalty vault and distributes them to each staking pools
     * If the current distribution period is over, it will finalize the old period and start a new one.
     * If not over, collected royalties will be emitted in the remaining distribution period.
     */
    function collectRoyalties() external;

    /**
     * @dev Adds a staking pool to the distribution contract
     * @param stakingToken The address of the staking token
     * @param allocPoints The allocation points for the staking pool
     */
    function addStakingPool(address stakingToken, uint256 allocPoints) external;

    /**
     * @dev Sets the allocation points for a staking pool
     * @param stakingToken The address of the staking token
     * @param allocPoints The allocation points for the staking pool
     */
    function setPoolAllocPoints(address stakingToken, uint256 allocPoints) external;

    /**
     * @dev Sets the reward distribution period
     * @param numberOfBlocks The number of blocks during which the all rewards are distributed
     */
    function setRewardDistributionPeriod(uint256 numberOfBlocks) external;

    /**
     * @dev Returns the address of the admin
     * @return admin The address of the admin
     */
    function getAdmin() external view returns (address);

    /**
     * @dev Returns the address of the IP
     * @return ipId The address of the IP
     */
    function getIpId() external view returns (address);

    /**
     * @dev Returns the reward distribution period
     * @return rewardDistributionPeriod The reward distribution period
     */
    function getRewardDistributionPeriod() external view returns (uint256);

    /**
     * @dev Returns the current distribution end block
     * @return currentDistributionEndBlock The current distribution end block
     */
    function getCurrentDistributionEndBlock() external view returns (uint256);

    /**
     * @dev Returns the current reward per block for a staking pool
     * @param stakingToken The address of the staking token
     * @return rewardPerBlock The current reward per block
     */
    function getRewardPerBlock(address stakingToken) external view returns (uint256);

    /**
     * @dev Returns the address of the reward token
     * @return rewardToken The address of the reward token
     */
    function getRewardToken() external view returns (address);

    /**
     * @dev Returns the total allocation points across all staking pools
     * @return totalAllocPoints The total allocation points
     */
    function getTotalAllocPoints() external view returns (uint256);

    /**
     * @dev Returns the allocation points for a staking pool
     * @param stakingToken The address of the staking token
     * @return allocPoints The allocation points for the staking pool
     */
    function getPoolAllocPoints(address stakingToken) external view returns (uint256);

    /**
     * @dev Returns the staked balance for a user in a staking pool
     * @param stakingToken The address of the staking token
     * @param staker The address of the staker
     * @return stakedBalance The staked balance for the staker
     */
    function getUserStakedBalance(address stakingToken, address staker) external view returns (uint256);

    /**
     * @dev Returns the total staked balance for a staking pool
     * @param stakingToken The address of the staking token
     * @return totalStakedBalance The total staked balance for the staking pool
     */
    function getPoolTotalStakedBalance(address stakingToken) external view returns (uint256);

    /**
     * @dev Returns the pending rewards for a staker in a staking pool
     * @param stakingToken The address of the staking token
     * @param staker The address of the staker
     * @return pendingRewards The pending rewards for the staker
     */
    function getPendingRewardsForStaker(address stakingToken, address staker) external view returns (uint256);

    /**
     * @dev Gets the upgradeable beacon address
     * @return upgradeableBeacon The address of the upgradeable beacon
     */
    function getUpgradeableBeacon() external view returns (address);
}
