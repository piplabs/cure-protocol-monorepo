// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { IRoyaltyModule } from "@storyprotocol/core/interfaces/modules/royalty/IRoyaltyModule.sol";
import { IIpRoyaltyVault } from "@storyprotocol/core/interfaces/modules/royalty/policies/IIpRoyaltyVault.sol";

import { Errors } from "./lib/Errors.sol";
import { IAscStaking } from "./interfaces/IAscStaking.sol";

/**
 * @title AscStaking
 * @notice This contract is used for distributing a IP's revenue to the fractionalized token (and its LP tokens) stakers
 */
contract AscStaking is IAscStaking, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @dev Storage structure for the a staking pool
     * @param stakingToken The address of the staking token
     * @param totalStakedBalance The total staked balance of the pool
     * @param allocPoints The allocation points of the pool
     * @param remainingRewardAmount The remaining reward amount in the pool
     * @param rewardPerBlock The amount of reward emitted per block
     * @param accumulatedRewardPerToken The accumulated reward per staked token of the pool
     * @param lastRewardUpdateBlock The last reward update block of the pool
     * @param stakingBalance The staking balance of each staker
     * @param pendingRewards The pending rewards of each staker
     * @param rewardPerTokenPaid The reward per token paid to each staker
     */
    struct PoolInfo {
        address stakingToken;
        uint256 totalStakedBalance;
        uint256 allocPoints;
        uint256 remainingRewardAmount;
        uint256 rewardPerBlock;
        uint256 accumulatedRewardPerToken;
        uint256 lastRewardUpdateBlock;
        mapping(address staker => uint256 stakingBalance) stakingBalance;
        mapping(address staker => uint256 pendingRewards) pendingRewards;
        mapping(address staker => uint256 rewardPerTokenPaid) rewardPerTokenPaid;
    }

    /**
     * @dev Storage structure for the AscStaking
     * @param admin The address of the admin of the contract
     * @param ipId The address of the IP that this contract is distributing the revenue for
     * @param rewardDistributionPeriod The number of blocks during which the all rewards are distributed
     * @param currentDistributionEndBlock The block number at which the current distribution period ends
     * @param rewardToken The address of the reward token
     * @param totalAllocPoints The total allocation points across all staking pools
     * @param stakingTokens The set of staking tokens (each staking token has a staking pool)
     * @param poolInfo The pool information of each staking pool
     * @custom:storage-location erc7201:asclepius-protocol.AscStaking
     */
    struct AscStakingStorage {
        address admin;
        address ipId;
        uint256 rewardDistributionPeriod;
        uint256 currentDistributionEndBlock;
        address rewardToken;
        uint256 totalAllocPoints;
        EnumerableSet.AddressSet stakingTokens;
        mapping(address => PoolInfo) poolInfo;
    }

    // keccak256(abi.encode(uint256(keccak256("asclepius-protocol.AscStaking")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant AscStakingStorageLocation =
        0x683918d8f10fbe935e448053a6b3d4f73db83ad193a0ffbad8aba748c1eee100;

    /**
     * @notice The maximum percentage value
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    uint256 public immutable MAX_PERCENTAGE = 100_000_000;

    /**
     * @notice The number of decimals of the staking token
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    uint256 public immutable STAKING_TOKEN_DECIMALS = 10 ** 18;

    /**
     * @notice The royalty module contract
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    IRoyaltyModule public immutable ROYALTY_MODULE;

    /**
     * @notice The upgradeable beacon address.
     * @custom:oz-upgrades-unsafe-allow state-variable-immutable
     */
    address public immutable UPGRADEABLE_BEACON;

    /// @notice Modifier to check if the caller is the admin
    modifier onlyAdmin() {
        AscStakingStorage storage $ = _getAscStakingStorage();
        if (msg.sender != $.admin) {
            revert Errors.AscStaking__CallerNotAdmin(msg.sender, $.admin);
        }
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address royaltyModule_, address upgradeableBeacon_) {
        if (royaltyModule_ == address(0)) revert Errors.AscStaking__ZeroRoyaltyModuleAddress();
        if (upgradeableBeacon_ == address(0)) revert Errors.AscStaking__ZeroUpgradeableBeaconAddress();

        ROYALTY_MODULE = IRoyaltyModule(royaltyModule_);
        UPGRADEABLE_BEACON = upgradeableBeacon_;

        _disableInitializers();
    }

    /**
     * @dev Initializes the AsclepiusIPDistributionContract
     * @param initData The initialization data {see IAsclepiusIPDistributionContract.InitData}
     */
    function initialize(address fractionalToken, InitData memory initData) external initializer {
        if (fractionalToken == address(0)) revert Errors.AscStaking__ZeroFractionalTokenAddress();
        if (initData.admin == address(0)) revert Errors.AscStaking__ZeroAdminAddress();
        if (initData.ipId == address(0)) revert Errors.AscStaking__ZeroIpIdAddress();
        if (initData.rewardToken == address(0)) revert Errors.AscStaking__ZeroRewardTokenAddress();
        if (initData.bioTokenAllocPoints == 0) revert Errors.AscStaking__ZeroBioTokenAllocPoints();

        __ReentrancyGuard_init();

        AscStakingStorage storage $ = _getAscStakingStorage();
        $.admin = initData.admin;
        $.ipId = initData.ipId;
        $.rewardDistributionPeriod = initData.rewardDistributionPeriod;
        $.rewardToken = initData.rewardToken;
        $.stakingTokens.add(fractionalToken);
        $.poolInfo[fractionalToken].allocPoints = initData.bioTokenAllocPoints;
        $.totalAllocPoints += initData.bioTokenAllocPoints;
    }

    /**
     * @dev Deposits staking tokens into the staking pool
     * @param stakingToken The address of the staking token
     * @param amount The amount of staking tokens to deposit
     */
    function deposit(address stakingToken, uint256 amount) external nonReentrant {
        if (stakingToken == address(0)) revert Errors.AscStaking__ZeroStakingTokenAddress();
        if (amount == 0) revert Errors.AscStaking__ZeroDepositAmount();

        _updateStakerRewardInPool(stakingToken, msg.sender);
        AscStakingStorage storage $ = _getAscStakingStorage();
        PoolInfo storage poolInfo = $.poolInfo[stakingToken];

        poolInfo.totalStakedBalance += amount;
        poolInfo.stakingBalance[msg.sender] += amount;

        IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), amount);

        emit Deposited(msg.sender, stakingToken, amount);
    }

    /**
     * @dev Withdraws staking tokens from the staking pool
     * @param stakingToken The address of the staking token
     * @param amount The amount of staking tokens to withdraw
     */
    function withdraw(address stakingToken, uint256 amount) external nonReentrant {
        if (stakingToken == address(0)) revert Errors.AscStaking__ZeroStakingTokenAddress();
        if (amount == 0) revert Errors.AscStaking__ZeroWithdrawAmount();

        _updateStakerRewardInPool(stakingToken, msg.sender);
        AscStakingStorage storage $ = _getAscStakingStorage();
        PoolInfo storage poolInfo = $.poolInfo[stakingToken];

        if (poolInfo.stakingBalance[msg.sender] < amount) {
            revert Errors.AscStaking__InsufficientStakedBalance(
                msg.sender,
                stakingToken,
                poolInfo.stakingBalance[msg.sender],
                amount
            );
        }

        poolInfo.totalStakedBalance -= amount;
        poolInfo.stakingBalance[msg.sender] -= amount;

        IERC20(stakingToken).safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, stakingToken, amount);
    }

    /**
     * @dev Claims all rewards across all staking pools for a staker
     * @param claimer The address of the staker
     */
    function claimAllRewards(address claimer) external nonReentrant {
        AscStakingStorage storage $ = _getAscStakingStorage();
        uint256 length = $.stakingTokens.length();
        uint256 totalRewards;
        for (uint256 i = 0; i < length; i++) {
            address stakingToken = $.stakingTokens.at(i);
            _updateStakerRewardInPool(stakingToken, claimer);
            PoolInfo storage poolInfo = $.poolInfo[stakingToken];
            totalRewards += poolInfo.pendingRewards[claimer];
            poolInfo.pendingRewards[claimer] = 0;
        }

        if (totalRewards > 0) {
            address rewardToken = $.rewardToken;
            IERC20(rewardToken).safeTransfer(claimer, totalRewards);
            emit RewardsClaimed(claimer, totalRewards);
        }
    }

    /**
     * @notice Collects royalties from the royalty vault and distributes them to each staking pools.
     * If the current distribution period is over, it will finalize the old period and start a new one.
     * If not over, collected royalties will be emitted in the remaining distribution period.
     */
    function collectRoyalties() external {
        _collectRoyalties();
    }

    /**
     * @dev Adds a new staking pool
     * @param stakingToken The address of the staking token
     * @param allocPoints The allocation points of the staking pool
     */
    function addStakingPool(address stakingToken, uint256 allocPoints) external onlyAdmin {
        if (stakingToken == address(0)) revert Errors.AscStaking__ZeroStakingTokenAddress();

        AscStakingStorage storage $ = _getAscStakingStorage();
        if (!$.stakingTokens.add(stakingToken)) {
            revert Errors.AscStaking__StakingPoolAlreadyExists(stakingToken);
        }
        $.poolInfo[stakingToken].allocPoints = allocPoints;
        $.totalAllocPoints += allocPoints;
        emit StakingPoolAdded(stakingToken, allocPoints);
    }

    /**
     * @dev Sets the allocation points for a staking pool
     * @param stakingToken The address of the staking token
     * @param allocPoints The allocation points of the staking pool
     */
    function setPoolAllocPoints(address stakingToken, uint256 allocPoints) external onlyAdmin {
        if (stakingToken == address(0)) revert Errors.AscStaking__ZeroStakingTokenAddress();
        AscStakingStorage storage $ = _getAscStakingStorage();
        uint256 oldAllocPoints = $.poolInfo[stakingToken].allocPoints;
        $.poolInfo[stakingToken].allocPoints = allocPoints;
        $.totalAllocPoints = $.totalAllocPoints - oldAllocPoints + allocPoints;
        emit PoolAllocPointsUpdated(stakingToken, oldAllocPoints, allocPoints);
    }

    /**
     * @dev Sets the reward distribution period
     * @param numberOfBlocks The number of blocks during which the all rewards are distributed
     */
    function setRewardDistributionPeriod(uint256 numberOfBlocks) external onlyAdmin {
        if (numberOfBlocks == 0) revert Errors.AscStaking__ZeroRewardDistributionPeriod();
        // will be applied to the next distribution period
        AscStakingStorage storage $ = _getAscStakingStorage();
        uint256 oldPeriod = $.rewardDistributionPeriod;
        $.rewardDistributionPeriod = numberOfBlocks;
        emit RewardDistributionPeriodUpdated(oldPeriod, numberOfBlocks);
    }

    /**
     * @dev Gets the total available rewards across all staking pools
     * @return totalRewards The total available rewards
     */
    function getAvailableRewards() external view returns (uint256 totalRewards) {
        AscStakingStorage storage $ = _getAscStakingStorage();
        for (uint256 i = 0; i < $.stakingTokens.length(); i++) {
            PoolInfo storage poolInfo = $.poolInfo[$.stakingTokens.at(i)];
            totalRewards += poolInfo.remainingRewardAmount;
        }
    }

    /**
     * @dev Gets the admin of the contract
     * @return admin The address of the admin
     */
    function getAdmin() external view returns (address) {
        return _getAscStakingStorage().admin;
    }

    /**
     * @dev Gets the IP ID of the contract
     * @return ipId The address of the IP
     */
    function getIpId() external view returns (address) {
        return _getAscStakingStorage().ipId;
    }

    /**
     * @dev Gets the reward distribution period
     * @return rewardDistributionPeriod The number of blocks during which the all rewards are distributed
     */
    function getRewardDistributionPeriod() external view returns (uint256) {
        return _getAscStakingStorage().rewardDistributionPeriod;
    }

    /**
     * @dev Gets the current distribution end block
     * @return currentDistributionEndBlock The block number at which the current distribution period ends
     */
    function getCurrentDistributionEndBlock() external view returns (uint256) {
        return _getAscStakingStorage().currentDistributionEndBlock;
    }

    /**
     * @dev Gets the current reward per block for a staking pool
     * @param stakingToken The address of the staking token
     * @return rewardPerBlock The reward per block
     */
    function getRewardPerBlock(address stakingToken) external view returns (uint256) {
        return _getAscStakingStorage().poolInfo[stakingToken].rewardPerBlock;
    }

    /**
     * @dev Gets the reward token
     * @return rewardToken The address of the reward token
     */
    function getRewardToken() external view returns (address) {
        return _getAscStakingStorage().rewardToken;
    }

    /**
     * @dev Gets the total allocation points across all staking pools
     * @return totalAllocPoints The total allocation points
     */
    function getTotalAllocPoints() external view returns (uint256) {
        return _getAscStakingStorage().totalAllocPoints;
    }

    /**
     * @dev Gets the allocation points for a staking pool
     * @param stakingToken The address of the staking token
     * @return allocPoints The allocation points of the staking pool
     */
    function getPoolAllocPoints(address stakingToken) external view returns (uint256) {
        return _getAscStakingStorage().poolInfo[stakingToken].allocPoints;
    }

    /**
     * @dev Gets the staked balance for a user in a staking pool
     * @param stakingToken The address of the staking token
     * @param staker The address of the staker
     * @return stakedBalance The staked balance of the staker
     */
    function getUserStakedBalance(address stakingToken, address staker) external view returns (uint256) {
        return _getAscStakingStorage().poolInfo[stakingToken].stakingBalance[staker];
    }

    /**
     * @dev Gets the total staked balance for a staking pool
     * @param stakingToken The address of the staking token
     * @return totalStakedBalance The total staked balance of the staking pool
     */
    function getPoolTotalStakedBalance(address stakingToken) external view returns (uint256) {
        return _getAscStakingStorage().poolInfo[stakingToken].totalStakedBalance;
    }

    /**
     * @dev Gets the pending rewards for a staker in a staking pool
     * @param stakingToken The address of the staking token
     * @param staker The address of the staker
     * @return pendingRewards The pending rewards of the staker
     */
    function getPendingRewardsForStaker(address stakingToken, address staker) external returns (uint256) {
        _updateStakerRewardInPool(stakingToken, staker);
        return _getAscStakingStorage().poolInfo[stakingToken].pendingRewards[staker];
    }

    /**
     * @dev Gets the upgradeable beacon address
     * @return upgradeableBeacon The address of the upgradeable beacon
     */
    function getUpgradeableBeacon() external view returns (address) {
        return UPGRADEABLE_BEACON;
    }

    /**
     * @dev Updates the reward for a staker in a staking pool
     * @param stakingToken The address of the staking token
     * @param staker The address of the staker
     */
    function _updateStakerRewardInPool(address stakingToken, address staker) private {
        AscStakingStorage storage $ = _getAscStakingStorage();
        PoolInfo storage poolInfo = $.poolInfo[stakingToken];

        uint256 endBlock = block.number > $.currentDistributionEndBlock ? $.currentDistributionEndBlock : block.number;
        _updateRewardPerTokenForPool(poolInfo, endBlock);

        uint256 stakedBalance = poolInfo.stakingBalance[staker];
        if (stakedBalance > 0) {
            uint256 rewardDelta = poolInfo.accumulatedRewardPerToken - poolInfo.rewardPerTokenPaid[staker];
            if (rewardDelta > 0)
                poolInfo.pendingRewards[staker] += (stakedBalance * rewardDelta) / STAKING_TOKEN_DECIMALS;
        }
        poolInfo.rewardPerTokenPaid[staker] = poolInfo.accumulatedRewardPerToken;
    }

    /**
     * @dev Updates the reward per token for a staking pool
     * @param pool The storage of the staking pool
     * @param endBlock The last block this update is accounting for
     */
    function _updateRewardPerTokenForPool(PoolInfo storage pool, uint256 endBlock) private {
        uint256 remainingRewardAmount = pool.remainingRewardAmount;
        uint256 lastRewardUpdateBlock = pool.lastRewardUpdateBlock;
        if (
            endBlock <= lastRewardUpdateBlock ||
            pool.totalStakedBalance == 0 ||
            remainingRewardAmount == 0 ||
            pool.rewardPerBlock == 0
        ) {
            if (endBlock > lastRewardUpdateBlock) pool.lastRewardUpdateBlock = endBlock;
            return;
        }

        uint256 blocksToReward = endBlock - lastRewardUpdateBlock;
        uint256 blockRewards = blocksToReward * pool.rewardPerBlock;
        if (blockRewards > remainingRewardAmount) blockRewards = remainingRewardAmount;

        pool.accumulatedRewardPerToken += (blockRewards * STAKING_TOKEN_DECIMALS) / pool.totalStakedBalance;
        pool.remainingRewardAmount -= blockRewards;
        pool.lastRewardUpdateBlock = endBlock;

        if (endBlock == _getAscStakingStorage().currentDistributionEndBlock || pool.remainingRewardAmount == 0) {
            pool.rewardPerBlock = 0;
        }
    }

    /**
     * @dev Collects royalties from the royalty vault and distributes them to each staking pools.
     * If the current distribution period is over, it will finalize the old period and start a new one.
     * If not over, collected royalties will be emitted in the remaining distribution period.
     */
    function _collectRoyalties() private {
        AscStakingStorage storage $ = _getAscStakingStorage();
        address ipId = $.ipId;
        IIpRoyaltyVault vault = IIpRoyaltyVault(ROYALTY_MODULE.ipRoyaltyVaults(ipId));
        if (address(vault) == address(0)) revert Errors.AscStaking__IpRoyaltyVaultNotDeployed(ipId);

        uint256 amount = vault.claimRevenueOnBehalf(address(this), $.rewardToken);
        uint256 length = $.stakingTokens.length();
        uint256 currentBlock = block.number;
        uint256 endBlock = $.currentDistributionEndBlock;

        if ($.currentDistributionEndBlock == 0 && $.rewardDistributionPeriod == 0) {
            revert Errors.AscStaking__ZeroRewardDistributionPeriod();
        }

        for (uint256 i = 0; i < length; i++) {
            PoolInfo storage poolInfo = $.poolInfo[$.stakingTokens.at(i)];
            if (currentBlock >= endBlock) {
                _updateRewardPerTokenForPool(poolInfo, endBlock);
            } else {
                _updateRewardPerTokenForPool(poolInfo, currentBlock);
            }
        }

        // Finalize the old distribution period if we're past the end block
        if (block.number >= endBlock) {
            // Start a new distribution period
            endBlock = block.number + $.rewardDistributionPeriod;
            $.currentDistributionEndBlock = endBlock;
        }

        uint256 blocksToDistribute = endBlock - block.number;

        for (uint256 i = 0; i < length; i++) {
            PoolInfo storage poolInfo = $.poolInfo[$.stakingTokens.at(i)];

            poolInfo.remainingRewardAmount += (amount * poolInfo.allocPoints) / $.totalAllocPoints;
            poolInfo.rewardPerBlock = poolInfo.remainingRewardAmount / blocksToDistribute;
            poolInfo.lastRewardUpdateBlock = block.number;
        }

        emit RoyaltiesCollected(ipId, amount, endBlock);
    }

    /// @dev Returns the storage struct of AscStaking.
    function _getAscStakingStorage() private pure returns (AscStakingStorage storage $) {
        assembly {
            $.slot := AscStakingStorageLocation
        }
    }
}
