// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IAscStaking {
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
}
