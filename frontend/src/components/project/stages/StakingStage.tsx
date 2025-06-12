"use client";

import { useState } from "react";
import { DollarSign, Coins, ArrowUpRight, ExternalLink } from "lucide-react";
import { Project } from "@/lib/types";
import { projectDetails } from "@/lib/data/projectDetails";
import { useStaking } from "@/lib/hooks/useStaking";
import { useWallet } from "@/lib/hooks/useWallet";
import LoadingSpinner from "@/components/ui/LoadingSpinner";

interface StakingStageProps {
  project: Project;
}

export default function StakingStage({ project }: StakingStageProps) {
  const { isConnected, connectWallet } = useWallet();
  const {
    loading,
    stakingData,
    tokenBalances,
    statusMessage,
    stakeTokens,
    unstakeTokens,
    claimRewards,
    collectRoyalties,
  } = useStaking(projectDetails[project.id]?.stakingContract);

  const [stakeAmount, setStakeAmount] = useState("");
  const [unstakeAmount, setUnstakeAmount] = useState("");
  const [selectedToken, setSelectedToken] = useState("BIO");

  const handleStake = async () => {
    if (!stakeAmount || parseFloat(stakeAmount) <= 0) return;
    // You'll need to map token symbols to addresses
    const tokenAddress = "0x0000000000000000000000000000000000000000"; // Replace with actual token address
    await stakeTokens(tokenAddress, stakeAmount);
    setStakeAmount("");
  };

  const handleUnstake = async () => {
    if (!unstakeAmount || parseFloat(unstakeAmount) <= 0) return;
    const tokenAddress = "0x0000000000000000000000000000000000000000"; // Replace with actual token address
    await unstakeTokens(tokenAddress, unstakeAmount);
    setUnstakeAmount("");
  };

  const canStake =
    isConnected &&
    parseFloat(tokenBalances[selectedToken] || "0") >=
      parseFloat(stakeAmount || "0") &&
    parseFloat(stakeAmount || "0") > 0 &&
    !loading.stake;

  const canUnstake =
    isConnected &&
    parseFloat(stakingData?.userStaked || "0") >=
      parseFloat(unstakeAmount || "0") &&
    parseFloat(unstakeAmount || "0") > 0 &&
    !loading.unstake;

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
            Connect your wallet to participate in staking and earn rewards
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
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-white">Stake Tokens</h3>
                <button className="p-2 hover:bg-gray-800 rounded-lg transition-colors">
                  <div className="w-5 h-5 border border-gray-400 rounded"></div>
                </button>
              </div>

              <div className="space-y-6">
                <div className="flex items-center justify-between p-4 bg-gray-800/50 rounded-xl border border-gray-700/50">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                      <DollarSign className="w-4 h-4 text-white" />
                    </div>
                    <div>
                      <select
                        value={selectedToken}
                        onChange={(e) => setSelectedToken(e.target.value)}
                        className="bg-transparent text-white font-medium outline-none"
                      >
                        <option value="BIO" className="bg-gray-900">
                          BIO
                        </option>
                        <option value="FRAX" className="bg-gray-900">
                          FRAX
                        </option>
                      </select>
                    </div>
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
                      {parseFloat(tokenBalances[selectedToken] || "0").toFixed(
                        4
                      )}
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
                      s{selectedToken}
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
                      YOU WILL RECEIVE
                    </span>
                    <span className="text-white font-bold">
                      {stakeAmount || "0.000"} s{selectedToken}
                    </span>
                  </div>
                </div>

                <button
                  onClick={handleStake}
                  disabled={!canStake}
                  className="w-full bg-green-500 hover:bg-green-600 disabled:bg-gray-600 disabled:cursor-not-allowed text-black font-bold py-4 rounded-xl transition-colors flex items-center justify-center gap-2"
                >
                  {loading.stake && <LoadingSpinner size="sm" />}
                  {loading.stake ? "Staking..." : `Stake ${selectedToken}`}
                </button>

                {!canStake && stakeAmount && parseFloat(stakeAmount) > 0 && (
                  <div className="text-xs text-red-400 p-3 bg-red-900/20 rounded-lg border border-red-700/50">
                    Insufficient {selectedToken} balance
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
                    {stakingData?.totalStaked || "60,846,596"}
                  </div>
                </div>

                <div className="text-center">
                  <div className="text-gray-400 text-sm mb-1">
                    EST. CURRENT APR
                  </div>
                  <div className="text-2xl font-bold text-green-400">
                    {stakingData?.apr || "4.50%"}
                  </div>
                </div>

                <div className="bg-gray-800/30 rounded-xl p-4 border border-gray-700/50 space-y-4">
                  <div>
                    <div className="text-gray-400 text-sm mb-1">
                      Your staked amount
                    </div>
                    <div className="text-white font-medium">
                      {parseFloat(stakingData?.userStaked || "0").toFixed(4)} s
                      {selectedToken}
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
                      {selectedToken}
                    </div>
                  </div>

                  <div>
                    <div className="text-gray-400 text-sm mb-1">
                      Your share of the pool
                    </div>
                    <div className="text-white font-medium">0.00%</div>
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
                      {loading.unstake && <LoadingSpinner size="sm" />}
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
                    {loading.claim && <LoadingSpinner size="sm" />}
                    {loading.claim ? "Claiming..." : "Claim Rewards"}
                  </button>

                  <button
                    onClick={collectRoyalties}
                    disabled={loading.collect}
                    className="w-full bg-blue-500 hover:bg-blue-600 disabled:bg-gray-600 disabled:cursor-not-allowed text-white font-bold py-2 rounded-xl transition-colors flex items-center justify-center gap-2"
                  >
                    {loading.collect && <LoadingSpinner size="sm" />}
                    {loading.collect ? "Collecting..." : "Collect Royalties"}
                  </button>
                </div>

                <div className="text-right">
                  <div className="text-gray-400 text-xs mb-2">CONTRACTS</div>
                  <div className="space-y-1">
                    <div className="flex items-center justify-end gap-2">
                      <span className="text-blue-400 text-sm">
                        {selectedToken}
                      </span>
                      <ExternalLink className="w-3 h-3 text-gray-400" />
                    </div>
                    <div className="flex items-center justify-end gap-2">
                      <span className="text-green-400 text-sm">
                        s{selectedToken}
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
              <h3 className="text-xl font-bold text-white">Reward History</h3>
            </div>

            <div className="text-center mb-6">
              <div className="text-gray-400 text-sm mb-2">
                Track your staking rewards over time.
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
              <div className="text-sm mt-2">Start staking to earn rewards!</div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
