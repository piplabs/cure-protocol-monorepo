// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IAscCurate {
    struct InitData {
        address admin;
        address rewardToken;
    }

    /**
     * @notice Deposits $IP token to the curate, only curate is still alive
     * @param amount The amount of the IP token to deposit
     */
    function deposit(uint256 amount) payable external;

    /**
     * @notice Claims refund, only when the curate is expired
     * @return amount The amount of the token claimed
     */
    function claimRefund(address erc20) external returns (uint256 amount);

    /// @notice Withdraw $IP token and mint according bioTokens so that create LP pool on Dex
    function withdraw() external payable returns (uint256 memory withdrawnAmounts);

    /// @notice Launch the Bio Project
    /// @dev deploy bio Token contract, deploy staking Contract
    function launchProject(
        address fractionalTokenTemplate,
        address distributionContractTemplate,
        InitData memory initData
    )
    external
    returns (
        uint256 licenseTermsId,
        address fractionalToken,
        address stakingContract
    );
}
