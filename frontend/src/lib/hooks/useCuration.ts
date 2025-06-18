// src/lib/hooks/useCuration.ts
import { useState, useEffect } from "react";
import { formatEther, parseEther } from "viem";
import { useWallet } from "./useWallet";
import { CONTRACTS, CURATE_ABI } from "@/contracts";
import type {
  LoadingStates,
  CurationData,
  ProjectLaunchData,
} from "@/lib/types/index";

export function useCuration(projectId: string) {
  const { account, isConnected, publicClient, walletClient } = useWallet();
  const [loading, setLoading] = useState<LoadingStates>({});
  const [curationData, setCurationData] = useState<CurationData | null>(null);
  const [projectLaunchData, setProjectLaunchData] =
    useState<ProjectLaunchData | null>(null);
  const [ipBalance, setIpBalance] = useState<string>("0");
  const [statusMessage, setStatusMessage] = useState<string>("");
  const [ipId, setIpId] = useState<string>("");

  const showStatus = (message: string) => {
    setStatusMessage(message);
    setTimeout(() => setStatusMessage(""), 5000);
  };

  const setLoadingState = (key: string, value: boolean) => {
    setLoading((prev) => ({ ...prev, [key]: value }));
  };

  useEffect(() => {
    if (isConnected && account && publicClient) {
      loadCurationData();
      loadIpBalance();
      loadProjectLaunchData();
    }
  }, [isConnected, account, publicClient, projectId]);

  const loadIpBalance = async () => {
    if (!publicClient || !account) return;

    try {
      // Get native $IP token balance
      const balance = await publicClient.getBalance({
        address: account,
      });
      setIpBalance(formatEther(balance));
    } catch (error) {
      console.error("Failed to load $IP balance:", error);
    }
  };

  const loadCurationData = async () => {
    if (!publicClient || !account) return;

    const ipId = await publicClient.readContract({
      address: CONTRACTS.AscCurate,
      abi: CURATE_ABI,
      functionName: "getIpId",
    });
    setIpId(ipId);

    const totalCommitted = await publicClient.readContract({
      address: CONTRACTS.AscCurate,
      abi: CURATE_ABI,
      functionName: "getTotalDeposited",
    });

    console.log("Total committed:", formatEther(totalCommitted));

    const userCommitted = await publicClient.readContract({
      address: CONTRACTS.AscCurate,
      abi: CURATE_ABI,
      functionName: "getDepositedAmount",
      args: [account],
    });

    console.log("User committed:", formatEther(userCommitted));

    try {
      setCurationData({
        totalCommitted: formatEther(totalCommitted),
        userCommitted: formatEther(userCommitted),
        curationLimit: "2.25M",
        isActive: true,
        canClaim: false,
      });
    } catch (error) {
      console.error("Failed to load curation data:", error);
    }
  };

  const loadProjectLaunchData = async () => {
    if (!publicClient || !CONTRACTS.AscCurate) return;

    try {
      // Check if project has been launched by calling the getter functions
      const [bioToken, stakingContract] = await Promise.all([
        publicClient.readContract({
          address: CONTRACTS.AscCurate,
          abi: CURATE_ABI,
          functionName: "getBioToken",
        }) as Promise<string>,
        publicClient.readContract({
          address: CONTRACTS.AscCurate,
          abi: CURATE_ABI,
          functionName: "getStakingContract",
        }) as Promise<string>,
      ]);

      // Check if addresses are not zero address (indicating project has been launched)
      const isLaunched =
        bioToken !== "0x0000000000000000000000000000000000000000" &&
        stakingContract !== "0x0000000000000000000000000000000000000000";

      if (isLaunched) {
        setProjectLaunchData({
          bioToken,
          stakingContract,
          transactionHash: "", // We don't have this from getter functions
          isLaunched: true,
        });
      }
    } catch (error) {
      console.error("Failed to load project launch data:", error);
      // If the call fails, assume project is not launched yet
      setProjectLaunchData({
        bioToken: "0x0000000000000000000000000000000000000000",
        stakingContract: "0x0000000000000000000000000000000000000000",
        transactionHash: "",
        isLaunched: false,
      });
    }
  };

  const commitToCuration = async (amount: string) => {
    if (!walletClient || !account) return;

    setLoadingState("commit", true);
    try {
      const amountWei = parseEther(amount);

      // Since we're using native $IP token, we send it as value in the transaction
      const hash = await walletClient.writeContract({
        account,
        address: CONTRACTS.AscCurate,
        abi: CURATE_ABI,
        functionName: "deposit",
        args: [amountWei],
        value: amountWei, // Send $IP as native token value
      });

      console.log("Curation commitment hash:", hash);
      showStatus("Successfully committed to curation! Updating data...");

      // Refresh data
      await Promise.all([loadCurationData(), loadIpBalance()]);
      showStatus("Curation commitment successful!");
    } catch (error: any) {
      console.error("Failed to commit to curation:", error);
      showStatus(`Failed to commit: ${error.message || "Unknown error"}`);
    } finally {
      setLoadingState("commit", false);
    }
  };

  const withdrawFromCuration = async () => {
    if (!walletClient || !account) return;

    setLoadingState("withdraw", true);
    try {
      const hash = await walletClient.writeContract({
        account,
        address: CONTRACTS.AscCurate,
        abi: CURATE_ABI,
        functionName: "withdraw",
        args: [],
      });

      console.log("Withdrawal hash:", hash);
      showStatus("Withdrawal successful! Updating data...");

      // Refresh data
      await Promise.all([loadCurationData(), loadIpBalance()]);
      showStatus("Withdrawal completed!");
    } catch (error: any) {
      console.error("Failed to withdraw:", error);
      showStatus(`Failed to withdraw: ${error.message || "Unknown error"}`);
    } finally {
      setLoadingState("withdraw", false);
    }
  };

  const claimRefund = async () => {
    if (!walletClient || !account) return;

    setLoadingState("claim", true);
    try {
      const hash = await walletClient.writeContract({
        account,
        address: CONTRACTS.AscCurate,
        abi: CURATE_ABI,
        functionName: "claimRefund",
        args: [],
      });

      console.log("Claim refund hash:", hash);
      showStatus("Refund claimed successfully! Updating data...");

      // Refresh data
      await Promise.all([loadCurationData(), loadIpBalance()]);
      showStatus("Refund claimed!");
    } catch (error: any) {
      console.error("Failed to claim refund:", error);
      showStatus(`Failed to claim refund: ${error.message || "Unknown error"}`);
    } finally {
      setLoadingState("claim", false);
    }
  };

  const launchProject = async (initData: {
    fractionalTokenTemplate: string;
    distributionContractTemplate: string;
    admin?: string;
    rewardToken?: string;
  }) => {
    if (!walletClient || !account) return;

    // check if all required fields are provided
    if (
      !initData.fractionalTokenTemplate ||
      !initData.distributionContractTemplate ||
      !initData.admin ||
      !initData.rewardToken
    ) {
      throw new Error("Missing required fields for project launch");
    }

    setLoadingState("launch", true);
    try {
      const hash = await walletClient.writeContract({
        account,
        address: CONTRACTS.AscCurate,
        abi: CURATE_ABI,
        functionName: "launchProject",
        args: [
          initData.fractionalTokenTemplate,
          initData.distributionContractTemplate,
          {
            admin: initData.admin || account,
            ipId: ipId,
            rewardDistributionPeriod: 288000,
            rewardToken: initData.rewardToken || CONTRACTS.StakingToken,
            bioTokenAllocPoints: 100,
          },
        ],
      });

      console.log("Project launch transaction sent:", hash);
      showStatus(
        "Project launch transaction sent! Waiting for confirmation..."
      );

      const receipt = await publicClient.waitForTransactionReceipt({ hash });
      console.log("Transaction confirmed:", receipt);
      showStatus(
        "Transaction confirmed. Loading deployed contract addresses..."
      );

      const [bioToken, stakingContract] = await Promise.all([
        publicClient.readContract({
          address: CONTRACTS.AscCurate,
          abi: CURATE_ABI,
          functionName: "getBioToken",
        }) as Promise<string>,
        publicClient.readContract({
          address: CONTRACTS.AscCurate,
          abi: CURATE_ABI,
          functionName: "getStakingContract",
        }) as Promise<string>,
      ]);

      const launchData: ProjectLaunchData = {
        bioToken,
        stakingContract,
        transactionHash: hash,
        isLaunched: true,
      };

      setProjectLaunchData(launchData);
      showStatus("Project launched successfully!");

      return launchData;
    } catch (error: any) {
      console.error("Failed to launch project:", error);
      showStatus(
        `Failed to launch project: ${error.message || "Unknown error"}`
      );
      throw error;
    } finally {
      setLoadingState("launch", false);
    }
  };

  return {
    // State
    loading,
    curationData,
    projectLaunchData,
    ipBalance,
    statusMessage,

    // Actions
    commitToCuration,
    withdrawFromCuration,
    claimRefund,
    launchProject,
    loadCurationData,
    loadIpBalance,
    loadProjectLaunchData,
    showStatus,
  };
}
