// /app/components/project/stages/StakingStage.tsx
"use client";

import { useState } from "react";
import { DollarSign, Coins, ArrowUpRight, ExternalLink } from "lucide-react";
import { Project } from "@/lib/types";
import { projectDetails } from "@/lib/data/projectDetails";
import { useStaking } from "@/lib/hooks/useStaking";
import { useWallet } from "@/lib/hooks/useWallet";

interface StakingStageProps {
  project: Project;
}

export default function StakingStage({ project }: StakingStageProps) {
  const { isConnected, connectWallet } = useWallet();

  // Get project-specific staking details
  const projectDetail = projectDetails[project.id];
  const stakingContractAddress = projectDetail?.stakingContract?.address;
  const stakingTokenInfo = projectDetail?.stakingContract?.stakingToken;
  const rewardTokenInfo = projectDetail?.stakingContract?.rewardToken;

  const {
    loading,
    stakingData,
    tokenBalances,
    statusMessage,
    contractAddress,
    stakeTokens,
    unstakeTokens,
    claimRewards,
    collectRoyalties,
  } = useStaking(stakingContractAddress);

  const [stakeAmount, setStakeAmount] = useState("");
  const [unstakeAmount, setUnstakeAmount] = useState("");

  const handleStake = async () => {
    if (!stakeAmount || parseFloat(stakeAmount) <= 0 || !stakingTokenInfo)
      return;
    await stakeTokens(stakingTokenInfo.address, stakeAmount);
    setStakeAmount("");
  };

  const handleUnstake = async () => {
    if (!unstakeAmount || parseFloat(unstakeAmount) <= 0 || !stakingTokenInfo)
      return;
    await unstakeTokens(stakingTokenInfo.address, unstakeAmount);
    setUnstakeAmount("");
  };

  const canStake =
    isConnected &&
    stakingTokenInfo &&
    parseFloat(tokenBalances[stakingTokenInfo.symbol] || "0") >=
      parseFloat(stakeAmount || "0") &&
    parseFloat(stakeAmount || "0") > 0 &&
    !loading.stake &&
    contractAddress !== "0x0000000000000000000000000000000000000000";

  const canUnstake =
    isConnected &&
    parseFloat(stakingData?.userStaked || "0") >=
      parseFloat(unstakeAmount || "0") &&
    parseFloat(unstakeAmount || "0") > 0 &&
    !loading.unstake &&
    contractAddress !== "0x0000000000000000000000000000000000000000";

  // If no staking contract is configured for this project
  if (
    !stakingContractAddress ||
    !stakingTokenInfo ||
    contractAddress === "0x0000000000000000000000000000000000000000"
  ) {
    return (
      <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-12 backdrop-blur-sm text-center">
        <h3 className="text-2xl font-bold text-white mb-4">
          Staking Not Available
        </h3>
        <p className="text-gray-400 mb-6">
          {!stakingContractAddress || !stakingTokenInfo
            ? "Staking contract has not been configured for this project yet."
            : "Staking contract has not been deployed yet. Complete the curation phase and launch the project first."}
        </p>
        {stakingTokenInfo && (
          <div className="text-sm text-gray-500">
            Expected staking token: {stakingTokenInfo.symbol}
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Status Message */}
      {statusMessage && (
        <div className="bg-blue-900 border-blue-700 text-blue-100 border px-6 py-3 rounded-xl">
          {statusMessage}
        </div>
      )}

      {!isConnected ? (
        <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-12 backdrop-blur-sm text-center">
          <h3 className="text-2xl font-bold text-white mb-4">
            Connect Wallet to Stake
          </h3>
          <p className="text-gray-400 mb-6">
            Connect your wallet to stake {stakingTokenInfo.symbol} tokens and
            earn rewards
          </p>
          <button
            onClick={connectWallet}
            className="bg-green-500 hover:bg-green-600 text-black font-bold py-3 px-8 rounded-xl transition-colors"
          >
            Connect Wallet
          </button>
        </div>
      ) : (
        <>
          {/* Project Token Info Header */}
          <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-bold text-white mb-2">
                  {project.name} Staking
                </h2>
                <p className="text-gray-400">
                  Stake {stakingTokenInfo.symbol} tokens to earn{" "}
                  {rewardTokenInfo?.symbol || stakingTokenInfo.symbol} rewards
                </p>
              </div>
              <div className="text-right">
                <div className="text-sm text-gray-400">Staking Token</div>
                <div className="text-xl font-bold text-green-400">
                  {stakingTokenInfo.symbol}
                </div>
                <div className="text-xs text-gray-500">
                  Contract: {contractAddress.slice(0, 6)}...
                  {contractAddress.slice(-4)}
                </div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-white">Stake Tokens</h3>
                <div className="text-xs text-gray-400">
                  Token: {stakingTokenInfo.symbol}
                </div>
              </div>

              <div className="space-y-6">
                <div className="flex items-center justify-between p-4 bg-gray-800/50 rounded-xl border border-gray-700/50">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                      <DollarSign className="w-4 h-4 text-white" />
                    </div>
                    <span className="text-white font-medium">
                      {stakingTokenInfo.symbol}
                    </span>
                  </div>
                  <div className="text-right">
                    <input
                      type="text"
                      placeholder="0"
                      value={stakeAmount}
                      onChange={(e) => setStakeAmount(e.target.value)}
                      className="bg-transparent text-white font-bold text-right outline-none w-24"
                    />
                    <div className="text-gray-400 text-sm">
                      MAX:{" "}
                      {parseFloat(
                        tokenBalances[stakingTokenInfo.symbol] || "0"
                      ).toFixed(4)}
                    </div>
                  </div>
                </div>

                <div className="flex items-center justify-center">
                  <div className="flex items-center gap-2 p-2 bg-gray-800/50 rounded-lg border border-gray-700/50">
                    <ArrowUpRight className="w-4 h-4 text-gray-400" />
                    <ArrowUpRight className="w-4 h-4 text-gray-400 rotate-180" />
                  </div>
                </div>

                <div className="flex items-center justify-between p-4 bg-gray-800/50 rounded-xl border border-gray-700/50">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
                      <Coins className="w-4 h-4 text-white" />
                    </div>
                    <span className="text-white font-medium">
                      Staked {stakingTokenInfo.symbol}
                    </span>
                  </div>
                  <div className="text-right">
                    <div className="text-white font-bold">
                      {stakeAmount || "0"}
                    </div>
                  </div>
                </div>

                <div className="bg-gray-800/30 rounded-xl p-4 border border-gray-700/50">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-gray-400 text-sm">STAKING FEE</span>
                    <span className="text-gray-400 text-sm">0.00%</span>
                  </div>
                  <div className="border-t border-gray-700 my-3"></div>
                  <div className="flex justify-between items-center">
                    <span className="text-white font-medium">
                      YOU WILL STAKE
                    </span>
                    <span className="text-white font-bold">
                      {stakeAmount || "0.000"} {stakingTokenInfo.symbol}
                    </span>
                  </div>
                </div>

                <button
                  onClick={handleStake}
                  disabled={!canStake}
                  className="w-full bg-green-500 hover:bg-green-600 disabled:bg-gray-600 disabled:cursor-not-allowed text-black font-bold py-4 rounded-xl transition-colors flex items-center justify-center gap-2"
                >
                  {loading.stake && (
                    <div className="animate-spin rounded-full border-2 border-gray-300 border-t-black w-4 h-4" />
                  )}
                  {loading.stake
                    ? "Staking..."
                    : `Stake ${stakingTokenInfo.symbol}`}
                </button>

                {!canStake && stakeAmount && parseFloat(stakeAmount) > 0 && (
                  <div className="text-xs text-red-400 p-3 bg-red-900/20 rounded-lg border border-red-700/50">
                    Insufficient {stakingTokenInfo.symbol} balance
                  </div>
                )}
              </div>
            </div>

            <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
              <h3 className="text-lg font-bold text-white mb-6">
                Current Stake
              </h3>

              <div className="space-y-6">
                <div className="text-center">
                  <div className="text-gray-400 text-sm mb-1">TOTAL STAKED</div>
                  <div className="text-2xl font-bold text-white">
                    {stakingData?.totalStaked ||
                      projectDetail?.staking?.totalStaked ||
                      "0"}
                  </div>
                  <div className="text-xs text-gray-400">
                    {stakingTokenInfo.symbol}
                  </div>
                </div>

                <div className="text-center">
                  <div className="text-gray-400 text-sm mb-1">
                    EST. CURRENT APR
                  </div>
                  <div className="text-2xl font-bold text-green-400">
                    {stakingData?.apr || projectDetail?.staking?.apr || "TBD"}
                  </div>
                </div>

                <div className="bg-gray-800/30 rounded-xl p-4 border border-gray-700/50 space-y-4">
                  <div>
                    <div className="text-gray-400 text-sm mb-1">
                      Your staked amount
                    </div>
                    <div className="text-white font-medium">
                      {parseFloat(stakingData?.userStaked || "0").toFixed(4)}{" "}
                      {stakingTokenInfo.symbol}
                    </div>
                  </div>

                  <div>
                    <div className="text-gray-400 text-sm mb-1">
                      Pending rewards
                    </div>
                    <div className="text-white font-medium">
                      {parseFloat(stakingData?.pendingRewards || "0").toFixed(
                        4
                      )}{" "}
                      {rewardTokenInfo?.symbol || stakingTokenInfo.symbol}
                    </div>
                  </div>

                  <div>
                    <div className="text-gray-400 text-sm mb-1">
                      Your share of the pool
                    </div>
                    <div className="text-white font-medium">
                      {stakingData?.totalStaked && stakingData?.userStaked
                        ? (
                            (parseFloat(stakingData.userStaked) /
                              parseFloat(stakingData.totalStaked)) *
                            100
                          ).toFixed(2)
                        : "0.00"}
                      %
                    </div>
                  </div>
                </div>

                <div className="space-y-3">
                  <div className="flex gap-2">
                    <input
                      type="text"
                      placeholder="Amount to unstake"
                      value={unstakeAmount}
                      onChange={(e) => setUnstakeAmount(e.target.value)}
                      className="flex-1 bg-gray-800/50 border border-gray-700 rounded-xl px-4 py-2 text-white text-sm"
                    />
                    <button
                      onClick={handleUnstake}
                      disabled={!canUnstake}
                      className="bg-red-500 hover:bg-red-600 disabled:bg-gray-600 disabled:cursor-not-allowed text-white font-bold py-2 px-4 rounded-xl transition-colors flex items-center gap-2"
                    >
                      {loading.unstake && (
                        <div className="animate-spin rounded-full border-2 border-gray-300 border-t-white w-4 h-4" />
                      )}
                      {loading.unstake ? "Unstaking..." : "Unstake"}
                    </button>
                  </div>

                  <button
                    onClick={claimRewards}
                    disabled={
                      loading.claim ||
                      !stakingData?.pendingRewards ||
                      parseFloat(stakingData.pendingRewards) === 0
                    }
                    className="w-full bg-purple-500 hover:bg-purple-600 disabled:bg-gray-600 disabled:cursor-not-allowed text-white font-bold py-2 rounded-xl transition-colors flex items-center justify-center gap-2"
                  >
                    {loading.claim && (
                      <div className="animate-spin rounded-full border-2 border-gray-300 border-t-white w-4 h-4" />
                    )}
                    {loading.claim
                      ? "Claiming..."
                      : `Claim ${
                          rewardTokenInfo?.symbol || stakingTokenInfo.symbol
                        } Rewards`}
                  </button>

                  <button
                    onClick={collectRoyalties}
                    disabled={loading.collect}
                    className="w-full bg-blue-500 hover:bg-blue-600 disabled:bg-gray-600 disabled:cursor-not-allowed text-white font-bold py-2 rounded-xl transition-colors flex items-center justify-center gap-2"
                  >
                    {loading.collect && (
                      <div className="animate-spin rounded-full border-2 border-gray-300 border-t-white w-4 h-4" />
                    )}
                    {loading.collect ? "Collecting..." : "Collect Royalties"}
                  </button>
                </div>

                <div className="text-right">
                  <div className="text-gray-400 text-xs mb-2">CONTRACTS</div>
                  <div className="space-y-1">
                    <div className="flex items-center justify-end gap-2">
                      <span className="text-blue-400 text-sm">
                        {stakingTokenInfo.symbol}
                      </span>
                      <ExternalLink className="w-3 h-3 text-gray-400" />
                    </div>
                    <div className="flex items-center justify-end gap-2">
                      <span className="text-green-400 text-sm">
                        Staking Contract
                      </span>
                      <ExternalLink className="w-3 h-3 text-gray-400" />
                    </div>
                    <div className="flex items-center justify-end gap-2">
                      <span className="text-gray-400 text-sm">Docs</span>
                      <ExternalLink className="w-3 h-3 text-gray-400" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-xl font-bold text-white">
                {stakingTokenInfo.symbol} Reward History
              </h3>
            </div>

            <div className="text-center mb-6">
              <div className="text-gray-400 text-sm mb-2">
                Track your {stakingTokenInfo.symbol} staking rewards over time.
              </div>
            </div>

            <div className="grid grid-cols-4 gap-4 mb-4 text-xs text-gray-400 uppercase tracking-wider">
              <div>Date</div>
              <div>Rewards Earned</div>
              <div>APR</div>
              <div>Staked Balance</div>
            </div>

            <div className="text-center text-gray-500 py-8">
              <div className="text-lg">No reward history yet</div>
              <div className="text-sm mt-2">
                Start staking {stakingTokenInfo.symbol} to earn rewards!
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
