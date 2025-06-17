import { useState, useEffect } from "react";
import { formatEther, parseEther } from "viem";
import { useWallet } from "./useWallet";
import { CONTRACTS, STAKING_ABI, ERC20_ABI } from "@/contracts";
import type { LoadingStates, StakingData } from "@/lib/types/index";

export function useStaking(stakingContractAddress?: string) {
  const { account, isConnected, publicClient, walletClient } = useWallet();
  const [loading, setLoading] = useState<LoadingStates>({});
  const [stakingData, setStakingData] = useState<StakingData | null>(null);
  const [tokenBalances, setTokenBalances] = useState<{ [key: string]: string }>(
    {}
  );
  const [statusMessage, setStatusMessage] = useState<string>("");

  const contractAddress = stakingContractAddress || CONTRACTS.AscStaking;

  const showStatus = (message: string) => {
    setStatusMessage(message);
    setTimeout(() => setStatusMessage(""), 5000);
  };

  const setLoadingState = (key: string, value: boolean) => {
    setLoading((prev) => ({ ...prev, [key]: value }));
  };

  useEffect(() => {
    if (
      isConnected &&
      account &&
      publicClient &&
      contractAddress &&
      contractAddress !== "0x0000000000000000000000000000000000000000"
    ) {
      loadStakingData();
      loadTokenBalances();
    }
  }, [isConnected, account, publicClient, contractAddress]);

  const loadTokenBalances = async () => {
    if (!publicClient || !account) return;

    try {
      const balances: { [key: string]: string } = {};

      // Load BIO balance if contract exists
      if (
        CONTRACTS.StakingToken !== "0x0000000000000000000000000000000000000000"
      ) {
        const bioBalance = await publicClient.readContract({
          address: CONTRACTS.StakingToken,
          abi: ERC20_ABI,
          functionName: "balanceOf",
          args: [account],
        });
        balances.BIO = formatEther(bioBalance);
      }

      // Add more token balances as needed
      // Example: FRAX, USDC, etc.

      setTokenBalances(balances);
    } catch (error) {
      console.error("Failed to load token balances:", error);
    }
  };

  const loadStakingData = async () => {
    if (
      !publicClient ||
      !account ||
      !contractAddress ||
      contractAddress === "0x0000000000000000000000000000000000000000"
    )
      return;

    try {
      // Load staking data
      // Note: You'll need to add getter functions to your staking contract
      // or implement view functions to get user staking info, total staked, etc.

      setStakingData({
        userStaked: "0",
        totalStaked: "60,846,596",
        pendingRewards: "0",
        stakingToken: CONTRACTS.StakingToken,
        rewardToken: CONTRACTS.StakingToken,
        apr: "4.50%",
      });
    } catch (error) {
      console.error("Failed to load staking data:", error);
    }
  };

  const stakeTokens = async (tokenAddress: string, amount: string) => {
    if (
      !walletClient ||
      !account ||
      !contractAddress ||
      contractAddress === "0x0000000000000000000000000000000000000000"
    )
      return;

    setLoadingState("stake", true);
    try {
      const amountWei = parseEther(amount);

      // Approve tokens first
      await walletClient.writeContract({
        account,
        address: tokenAddress,
        abi: ERC20_ABI,
        functionName: "approve",
        args: [contractAddress, amountWei],
      });

      showStatus("Token approval successful, staking tokens...");

      // Stake tokens using the updated ABI
      const hash = await walletClient.writeContract({
        account,
        address: contractAddress,
        abi: STAKING_ABI,
        functionName: "deposit",
        args: [tokenAddress, amountWei],
      });

      console.log("Staking hash:", hash);
      showStatus("Tokens staked successfully! Updating data...");

      // Refresh data
      await Promise.all([loadStakingData(), loadTokenBalances()]);
      showStatus("Staking completed!");
    } catch (error: any) {
      console.error("Failed to stake tokens:", error);
      showStatus(`Failed to stake: ${error.message || "Unknown error"}`);
    } finally {
      setLoadingState("stake", false);
    }
  };

  const unstakeTokens = async (tokenAddress: string, amount: string) => {
    if (
      !walletClient ||
      !account ||
      !contractAddress ||
      contractAddress === "0x0000000000000000000000000000000000000000"
    )
      return;

    setLoadingState("unstake", true);
    try {
      const amountWei = parseEther(amount);

      const hash = await walletClient.writeContract({
        account,
        address: contractAddress,
        abi: STAKING_ABI,
        functionName: "withdraw",
        args: [tokenAddress, amountWei],
      });

      console.log("Unstaking hash:", hash);
      showStatus("Tokens unstaked successfully! Updating data...");

      // Refresh data
      await Promise.all([loadStakingData(), loadTokenBalances()]);
      showStatus("Unstaking completed!");
    } catch (error: any) {
      console.error("Failed to unstake tokens:", error);
      showStatus(`Failed to unstake: ${error.message || "Unknown error"}`);
    } finally {
      setLoadingState("unstake", false);
    }
  };

  const claimRewards = async () => {
    if (
      !walletClient ||
      !account ||
      !contractAddress ||
      contractAddress === "0x0000000000000000000000000000000000000000"
    )
      return;

    setLoadingState("claim", true);
    try {
      const hash = await walletClient.writeContract({
        account,
        address: contractAddress,
        abi: STAKING_ABI,
        functionName: "claimAllRewards",
        args: [account],
      });

      console.log("Claim rewards hash:", hash);
      showStatus("Rewards claimed successfully! Updating data...");

      // Refresh data
      await Promise.all([loadStakingData(), loadTokenBalances()]);
      showStatus("Rewards claimed!");
    } catch (error: any) {
      console.error("Failed to claim rewards:", error);
      showStatus(
        `Failed to claim rewards: ${error.message || "Unknown error"}`
      );
    } finally {
      setLoadingState("claim", false);
    }
  };

  const collectRoyalties = async () => {
    if (
      !walletClient ||
      !account ||
      !contractAddress ||
      contractAddress === "0x0000000000000000000000000000000000000000"
    )
      return;

    setLoadingState("collect", true);
    try {
      const hash = await walletClient.writeContract({
        account,
        address: contractAddress,
        abi: STAKING_ABI,
        functionName: "collectRoyalties",
        args: [],
      });

      console.log("Collect royalties hash:", hash);
      showStatus("Royalties collected successfully! Updating data...");

      // Refresh data
      await Promise.all([loadStakingData(), loadTokenBalances()]);
      showStatus("Royalties collected!");
    } catch (error: any) {
      console.error("Failed to collect royalties:", error);
      showStatus(
        `Failed to collect royalties: ${error.message || "Unknown error"}`
      );
    } finally {
      setLoadingState("collect", false);
    }
  };

  return {
    // State
    loading,
    stakingData,
    tokenBalances,
    statusMessage,
    contractAddress,

    // Actions
    stakeTokens,
    unstakeTokens,
    claimRewards,
    collectRoyalties,
    loadStakingData,
    loadTokenBalances,
    showStatus,
  };
}
