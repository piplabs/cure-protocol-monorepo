// src/lib/hooks/useStaking.ts
import { useState, useEffect } from "react";
import { formatEther, parseEther } from "viem";
import { useWallet } from "./useWallet";
import { useCuration } from "./useCuration";
import { CONTRACTS, STAKING_ABI, ERC20_ABI } from "@/contracts";
import type { LoadingStates, StakingData } from "@/lib/types/index";

export function useStaking(projectId: string) {
  const { account, isConnected, publicClient, walletClient } = useWallet();
  const { projectLaunchData } = useCuration(projectId); // Get launch data from curation hook

  const [loading, setLoading] = useState<LoadingStates>({});
  const [stakingData, setStakingData] = useState<StakingData | null>(null);
  const [tokenBalances, setTokenBalances] = useState<{ [key: string]: string }>(
    {}
  );
  const [statusMessage, setStatusMessage] = useState<string>("");

  // Use the staking contract from launch data, fallback to default
  const contractAddress =
    projectLaunchData?.stakingContract || CONTRACTS.AscStaking;
  const bioTokenAddress = projectLaunchData?.bioToken || CONTRACTS.StakingToken;
  const isProjectLaunched = projectLaunchData?.isLaunched || false;

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
      isProjectLaunched &&
      contractAddress &&
      contractAddress !== "0x0000000000000000000000000000000000000000"
    ) {
      loadStakingData();
      loadTokenBalances();
    }
  }, [
    isConnected,
    account,
    publicClient,
    contractAddress,
    isProjectLaunched,
    bioTokenAddress,
  ]);

  const loadTokenBalances = async () => {
    if (!publicClient || !account || !bioTokenAddress) return;

    try {
      const balances: { [key: string]: string } = {};

      // Load BIO token balance (the launched token)
      if (bioTokenAddress !== "0x0000000000000000000000000000000000000000") {
        const bioBalance = await publicClient.readContract({
          address: bioTokenAddress,
          abi: ERC20_ABI,
          functionName: "balanceOf",
          args: [account],
        });
        balances.BIO = formatEther(bioBalance);

        // Also get the token symbol
        const symbol = (await publicClient.readContract({
          address: bioTokenAddress,
          abi: ERC20_ABI,
          functionName: "symbol",
          args: [],
        })) as string;
        balances[symbol] = formatEther(bioBalance);
      }

      // Load native IP balance for potential other staking
      const ipBalance = await publicClient.getBalance({
        address: account,
      });
      balances.IP = formatEther(ipBalance);

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
      contractAddress === "0x0000000000000000000000000000000000000000" ||
      !isProjectLaunched
    )
      return;

    try {
      // Load staking data from the actual contract
      // Note: You'll need to add getter functions to your staking contract
      // For now, using mock data but this should be replaced with real contract calls

      setStakingData({
        userStaked: "0",
        totalStaked: "0",
        pendingRewards: "0",
        stakingToken: bioTokenAddress,
        rewardToken: bioTokenAddress, // Assuming same token for rewards
        apr: "0%",
      });
    } catch (error) {
      console.error("Failed to load staking data:", error);
    }
  };

  const stakeTokens = async (amount: string) => {
    if (
      !walletClient ||
      !account ||
      !contractAddress ||
      !bioTokenAddress ||
      contractAddress === "0x0000000000000000000000000000000000000000" ||
      !isProjectLaunched
    )
      return;

    setLoadingState("stake", true);
    try {
      const amountWei = parseEther(amount);

      // Approve tokens first
      await walletClient.writeContract({
        account,
        address: bioTokenAddress,
        abi: ERC20_ABI,
        functionName: "approve",
        args: [contractAddress, amountWei],
      });

      showStatus("Token approval successful, staking tokens...");

      // Stake tokens
      const hash = await walletClient.writeContract({
        account,
        address: contractAddress,
        abi: STAKING_ABI,
        functionName: "deposit",
        args: [bioTokenAddress, amountWei],
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

  const unstakeTokens = async (amount: string) => {
    if (
      !walletClient ||
      !account ||
      !contractAddress ||
      !bioTokenAddress ||
      contractAddress === "0x0000000000000000000000000000000000000000" ||
      !isProjectLaunched
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
        args: [bioTokenAddress, amountWei],
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
      contractAddress === "0x0000000000000000000000000000000000000000" ||
      !isProjectLaunched
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
      contractAddress === "0x0000000000000000000000000000000000000000" ||
      !isProjectLaunched
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
    bioTokenAddress,
    isProjectLaunched,

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
