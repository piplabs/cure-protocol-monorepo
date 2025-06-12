import { useState, useEffect } from "react";
import { formatEther, parseEther } from "viem";
import { useWallet } from "./useWallet";
import { CONTRACTS, CURATE_ABI, ERC20_ABI } from "../../contracts/index";
import type { LoadingStates, CurationData } from "../types/index";

export function useCuration(projectId: string) {
  const { account, isConnected, publicClient, walletClient } = useWallet();
  const [loading, setLoading] = useState<LoadingStates>({});
  const [curationData, setCurationData] = useState<CurationData | null>(null);
  const [bioBalance, setBioBalance] = useState<string>("0");
  const [statusMessage, setStatusMessage] = useState<string>("");

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
      loadBioBalance();
    }
  }, [isConnected, account, publicClient, projectId]);

  const loadBioBalance = async () => {
    if (!publicClient || !account || !CONTRACTS.BioToken) return;

    try {
      const balance = await publicClient.readContract({
        address: CONTRACTS.BioToken,
        abi: ERC20_ABI,
        functionName: "balanceOf",
        args: [account],
      });

      setBioBalance(formatEther(balance));
    } catch (error) {
      console.error("Failed to load BIO balance:", error);
    }
  };

  const loadCurationData = async () => {
    if (!publicClient || !account) return;

    try {
      // Load curation data specific to the project
      // TODO: implement contract calls based on  actual contract structure

      setCurationData({
        totalCommitted: "663.88K",
        userCommitted: "0",
        curationLimit: "2.25M",
        isActive: true,
        canClaim: false,
      });
    } catch (error) {
      console.error("Failed to load curation data:", error);
    }
  };

  const commitToCuration = async (amount: string) => {
    if (!walletClient || !account) return;

    setLoadingState("commit", true);
    try {
      const amountWei = parseEther(amount);

      // First approve BIO tokens if needed
      if (CONTRACTS.BioToken !== "0x0000000000000000000000000000000000000000") {
        await walletClient.writeContract({
          account,
          address: CONTRACTS.BioToken,
          abi: ERC20_ABI,
          functionName: "approve",
          args: [CONTRACTS.AscCurate, amountWei],
        });

        showStatus("Token approval successful, committing to curation...");
      }

      // Commit to curation
      const hash = await walletClient.writeContract({
        account,
        address: CONTRACTS.AscCurate,
        abi: CURATE_ABI,
        functionName: "deposit",
        args: [amountWei],
      });

      console.log("Curation commitment hash:", hash);
      showStatus("Successfully committed to curation! Updating data...");

      // Refresh data
      await Promise.all([loadCurationData(), loadBioBalance()]);
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
      await Promise.all([loadCurationData(), loadBioBalance()]);
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
      await Promise.all([loadCurationData(), loadBioBalance()]);
      showStatus("Refund claimed!");
    } catch (error: any) {
      console.error("Failed to claim refund:", error);
      showStatus(`Failed to claim refund: ${error.message || "Unknown error"}`);
    } finally {
      setLoadingState("claim", false);
    }
  };

  const launchProject = async (initData: any) => {
    if (!walletClient || !account) return;

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
            rewardToken: initData.rewardToken || CONTRACTS.BioToken,
          },
        ],
      });

      console.log("Project launch hash:", hash);
      showStatus("Project launched successfully!");

      // Refresh data
      await loadCurationData();
      showStatus("Project launch completed!");
    } catch (error: any) {
      console.error("Failed to launch project:", error);
      showStatus(
        `Failed to launch project: ${error.message || "Unknown error"}`
      );
    } finally {
      setLoadingState("launch", false);
    }
  };

  return {
    // State
    loading,
    curationData,
    bioBalance,
    statusMessage,

    // Actions
    commitToCuration,
    withdrawFromCuration,
    claimRefund,
    launchProject,
    loadCurationData,
    loadBioBalance,
    showStatus,
  };
}
